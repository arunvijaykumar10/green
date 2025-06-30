import { useRef, useState } from 'react';
import SignatureCanvas from 'react-signature-canvas';

import {
  Box,
  Card,
  Radio,
  Stack,
  Button,
  Dialog,
  FormLabel,
  IconButton,
  RadioGroup,
  Typography,
  DialogTitle,
  FormControl,
  DialogContent,
  FormControlLabel,
} from '@mui/material';

import { uploadToS3, computeChecksum } from 'src/utils/s3uploads';

import { useSelector } from 'src/redux/store';
import { useCompany, useGetPresignedUrlMutation, useAttachFileToRecordMutation } from 'src/pages/companies/api';

import { useAuthContext } from 'src/auth/hooks';

import type { SignatureMethod, SignaturePolicy } from '../../pages/dashboard/types';



// Helper function to convert dataURL to blob
const dataURLToBlob = (dataURL: string): Blob => {
  const arr = dataURL.split(',');
  const mime = arr[0].match(/:(.*?);/)![1];
  const bstr = atob(arr[1]);
  let n = bstr.length;
  const u8arr = new Uint8Array(n);
  while (n--) {
    u8arr[n] = bstr.charCodeAt(n);
  }
  return new Blob([u8arr], { type: mime });
};

export default function SignatureSetup() {
  const savedData = useSelector((state) => state.formData.signatureSetup);
  const { user } = useAuthContext();
  const currentCompanyId = user?.last_accessed_company?.id;
  const { company } = useCompany(currentCompanyId);

  // Set default values from company object
  const defaultSignaturePolicy = company?.signature_type || savedData?.signaturePolicy || 'single';
  const hasExistingSignature = company?.signature_url;
  const hasExistingSecondarySignature = company?.secondary_signature_url;

  const [signaturePolicy, setSignaturePolicy] = useState<SignaturePolicy>(defaultSignaturePolicy);
  const [sig1Method, setSig1Method] = useState<SignatureMethod>(hasExistingSignature ? 'upload' : savedData?.sig1Method || '');
  const [sig2Method, setSig2Method] = useState<SignatureMethod>(hasExistingSecondarySignature ? 'upload' : savedData?.sig2Method || '');

  const [sig1File, setSig1File] = useState<File | null>(null);
  const [sig2File, setSig2File] = useState<File | null>(null);
  const [previewOpen, setPreviewOpen] = useState(false);
  const [previewImage, setPreviewImage] = useState<string | null>(null);

  const sig1PadRef = useRef<SignatureCanvas>(null);
  const sig2PadRef = useRef<SignatureCanvas>(null);

  const handlePolicyChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    const value = event.target.value as SignaturePolicy;
    setSignaturePolicy(value);
    if (value === 'single') {
      setSig2Method('');
      setSig2File(null);
    }
  };

  const handleSig1Upload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0] || null;
    if (file && file.size > 2 * 1024 * 1024) {
      alert('File size must be less than 2MB');
      return;
    }
    setSig1File(file);
    setSig1Method('upload');
  };

  const handleSig2Upload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0] || null;
    if (file && file.size > 2 * 1024 * 1024) {
      alert('File size must be less than 2MB');
      return;
    }
    setSig2File(file);
    setSig2Method('upload');
  };

  const handleDraw = () => {
    setSig2Method('draw');
    setSig2File(null);
  };

  const handlePreview = (signatureNum: 1 | 2) => {
    const padRef = signatureNum === 1 ? sig1PadRef : sig2PadRef;
    if (padRef.current) {
      const dataURL = padRef.current.toDataURL();
      setPreviewImage(dataURL);
      setPreviewOpen(true);
    }
  };

  const handleClear = (pad: SignatureCanvas | null, signatureNum: 1 | 2) => {
    pad?.clear();
  };

  const handleSaveSignature = async () => {
    try {
      // Handle signature 1
      if (sig1Method === 'upload' && sig1File) {
        await handleFileUpload(sig1File, company?.id || currentCompanyId, 'signature');
      }

      // Handle signature 2 (only for double policy)
      if (signaturePolicy === 'double') {
        if (sig2Method === 'upload' && sig2File) {
          await handleFileUpload(sig2File, company?.id || currentCompanyId, 'secondary_signature');
        } else if (sig2Method === 'draw' && sig2PadRef.current) {
          const dataURL = sig2PadRef.current.toDataURL();
          const blob = dataURLToBlob(dataURL);
          const file = new File([blob], 'signature2.png', { type: 'image/png' });
          await handleFileUpload(file, company?.id || currentCompanyId, 'secondary_signature');
        }
      }

      console.log('Signatures saved successfully');
    } catch (error) {
      console.error('Error saving signatures:', error);
    }
  };


  const [getPresignedUrl] = useGetPresignedUrlMutation();
  const [attachFileToRecord] = useAttachFileToRecordMutation();

  const handleFileUpload = async (
    file: File,
    companyId: number,
    signatureField: 'signature' | 'secondary_signature'
  ): Promise<any> => {
    try {
      const checksum = await computeChecksum(file);
      const fileParams = {
        filename: file.name,
        byte_size: file.size,
        checksum,
        content_type: file.type
      };

      const batchParams = { files: [fileParams] };

      const presignedResult = await getPresignedUrl(batchParams as any);
      if ('error' in presignedResult) {
        throw new Error('Failed to get presigned URLs');
      }

      const presignedData = (presignedResult.data as any).data[0];
      const signedId = await uploadToS3(file, checksum, presignedData);

      // Attach file to record
      const fileContent = {
        company: {
          [signatureField]: signedId,
          signature_type: signaturePolicy
        }
      };

      await attachFileToRecord({ companyId, body: fileContent });
      console.log(`${signatureField} uploaded and attached successfully`);
    } catch (error) {
      console.error(`Error uploading ${signatureField}:`, error);
      throw error;
    }
  };

  return (
    <Box sx={{ p: 2 }}>
      <Typography variant="h6" gutterBottom>Signature Setup</Typography>
      <Typography variant="body2" color="text.secondary" paragraph>
        Configure signature settings for your documents.
      </Typography>

      <Card sx={{ p: 3 }}>
        <Stack spacing={3}>
          <FormControl>
            <FormLabel>Signature Policy</FormLabel>
            <RadioGroup row value={signaturePolicy} onChange={handlePolicyChange}>
              <FormControlLabel
                value="single"
                control={<Radio />}
                label="Single Signature"
              />
              <FormControlLabel
                value="double"
                control={<Radio />}
                label="Double Signature"
              />
            </RadioGroup>
          </FormControl>

          <Box>
            <Typography variant="h6">
              {signaturePolicy === 'single' ? 'Signature' : 'Signature 1'}
            </Typography>
            <Stack direction="row" spacing={2} alignItems="center">
              <Button variant="outlined" component="label">
                Upload
                <input
                  type="file"
                  accept="image/*"
                  hidden
                  onChange={handleSig1Upload}
                />
              </Button>

              {(sig1Method === 'upload' && sig1File) && (
                <img
                  src={URL.createObjectURL(sig1File)}
                  alt="Signature 1"
                  style={{ maxWidth: 200, maxHeight: 100, border: '1px solid #ccc' }}
                />
              )}

              {(sig1Method === 'upload' && !sig1File && company?.signature_url) && (
                <img
                  src={company.signature_url}
                  alt="Existing Signature 1"
                  style={{ maxWidth: 200, maxHeight: 100, border: '1px solid #ccc' }}
                />
              )}
            </Stack>

          </Box>

          {signaturePolicy === 'double' && (
            <Box>
              <Typography variant="h6">Signature 2</Typography>
              <Stack direction="row" spacing={2} alignItems="center">
                <Button variant="outlined" component="label">
                  Upload
                  <input
                    type="file"
                    accept="image/*"
                    hidden
                    onChange={handleSig2Upload}
                  />
                </Button>
                <Button variant="outlined" onClick={() => handleDraw()}>
                  Draw
                </Button>

                {(sig2Method === 'upload' && sig2File) && (
                  <img
                    src={URL.createObjectURL(sig2File)}
                    alt="Signature 2"
                    style={{ maxWidth: 200, maxHeight: 100, border: '1px solid #ccc' }}
                  />
                )}

                {(sig2Method === 'upload' && !sig2File && company?.secondary_signature_url) && (
                  <img
                    src={company.secondary_signature_url}
                    alt="Existing Signature 2"
                    style={{ maxWidth: 200, maxHeight: 100, border: '1px solid #ccc' }}
                  />
                )}
              </Stack>

              {sig2Method === 'draw' && (
                <Box sx={{ mt: 2 }}>
                  <Box sx={{ border: '1px solid #ccc', backgroundColor: '#fff', mb: 1 }}>
                    <SignatureCanvas
                      ref={sig2PadRef}
                      penColor="black"
                      canvasProps={{
                        width: 400,
                        height: 150,
                        className: 'sigCanvas',
                      }}
                    />
                  </Box>
                  <Stack direction="row" spacing={1}>
                    <Button
                      variant="outlined"
                      size="small"
                      onClick={() => handleClear(sig2PadRef.current, 2)}
                    >
                      Clear
                    </Button>
                    <Button
                      variant="outlined"
                      size="small"
                      onClick={() => handlePreview(2)}
                    >
                      Preview
                    </Button>
                  </Stack>
                </Box>
              )}


            </Box>
          )}

          <Box sx={{ display: 'flex', justifyContent: 'flex-end' }}>
            <Button
              variant="contained"
              color="primary"
              onClick={handleSaveSignature}
            >
              Save
            </Button>
          </Box>
        </Stack>
      </Card>

      <Dialog open={previewOpen} onClose={() => setPreviewOpen(false)} maxWidth="md" fullWidth sx={{ '& .MuiDialog-paper': { height: '30vh' } }}>
        <DialogTitle sx={{ display: 'flex', justifyContent: 'flex-end', alignItems: 'center' }}>
          <IconButton onClick={() => setPreviewOpen(false)}>
            ×
          </IconButton>
        </DialogTitle>
        <DialogContent sx={{ display: 'flex', flexDirection: 'column', height: '100%' }}>
          {previewImage && (
            <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', flex: 1, p: 2 }}>
              <img
                src={previewImage}
                alt="Signature Preview"
                style={{ maxHeight: '100%' }}
              />
            </Box>
          )}
        </DialogContent>
      </Dialog>

    </Box>
  );
}