import _ from 'lodash';
import { useCallback } from 'react';
import { useWatch, useFormContext } from 'react-hook-form';

import { Box, Stack, Button, Divider, Typography } from '@mui/material';

import { Image } from 'src/components/image';
import { Iconify } from 'src/components/iconify';
import { RHFRadioGroup, CanvasSignature } from 'src/components/hook-form';

interface SignatureContentProps {
  isViewMode: boolean;
}

const SignatureUpload = ({ name }: { name: string }) => {
  const { setValue, watch } = useFormContext();
  const formValues = watch();
  const currentValue = formValues[name];

  const handleFileUpload = useCallback(
    (event: React.ChangeEvent<HTMLInputElement>) => {
      const file = event.target.files?.[0];
      if (file && file.type.startsWith('image/')) {
        const newFile = Object.assign(file, {
          preview: URL.createObjectURL(file),
        });
        setValue(name, newFile, { shouldValidate: true, shouldDirty: true });
      }
    },
    [setValue, name]
  );

  const imageUrl = _.isString(currentValue) ? currentValue : currentValue?.preview;

  return (
    <Stack spacing={2}>
      <Button
        variant="contained"
        component="label"
        startIcon={<Iconify icon="ic:sharp-cloud-upload" />}
        sx={{ width: 300 }}
      >
        {currentValue ? 'Change Signature' : 'Upload Signature'}
        <input type="file" hidden accept="image/*" onChange={handleFileUpload} />
      </Button>

      {imageUrl && (
        <Box
          sx={{
            border: '2px dashed #e0e0e0',
            borderRadius: 2,
            p: 2,
            textAlign: 'center',
            bgcolor: 'grey.50',
            maxWidth: 300,
          }}
        >
          <Image
            alt="Signature Preview"
            src={imageUrl}
            sx={{
              maxHeight: 150,
              width: 'auto',
              objectFit: 'contain',
              borderRadius: 1,
            }}
          />
        </Box>
      )}
    </Stack>
  );
};

export const SignatureContent = ({ isViewMode }: SignatureContentProps) => {
  const { watch } = useFormContext();
  const formValues = watch();
  const signaturePolicy = useWatch({ name: 'signature_policy' });

  if (isViewMode) {
    return (
      <Stack spacing={2}>
        <Box sx={{ mb: 2 }}>
          <Typography variant="h5" color="text.secondary" sx={{ mb: 0.5 }}>
            Signature Policy
          </Typography>
          <Typography variant="h6">{_.startCase(formValues?.signature_policy)}</Typography>
        </Box>
        {formValues.signature_policy === 'single' && (
          <Image
            alt="image"
            src={formValues?.signature}
            sx={{
              top: 0,
              left: 0,
              height: '100%',
              width: '100%',
              objectFit: 'cover',
              borderRadius: 1.5,
            }}
          />
        )}
        {formValues.signature_policy === 'double' && (
          <>
            <Box sx={{ mb: 2 }}>
              <Typography variant="h5" color="text.secondary" sx={{ mb: 0.5 }}>
                Primary Signature
              </Typography>
              <Box
                sx={{
                  border: '2px dashed #e0e0e0',
                  borderRadius: 2,
                  p: 2,
                  textAlign: 'center',
                  bgcolor: 'grey.50',
                }}
              >
                <Image
                  alt="image"
                  src={formValues?.primary_signature}
                  sx={{
                    top: 0,
                    left: 0,
                    height: '100%',
                    width: '100%',
                    objectFit: 'cover',
                    borderRadius: 1.5,
                  }}
                />
              </Box>
            </Box>
            <Box sx={{ mb: 2 }}>
              <Typography variant="h5" color="text.secondary" sx={{ mb: 0.5 }}>
                Secondary Signature
              </Typography>
              <Box
                sx={{
                  border: '2px dashed #e0e0e0',
                  borderRadius: 2,
                  p: 2,
                  textAlign: 'center',
                  bgcolor: 'grey.50',
                }}
              >
                <Image
                  alt="image"
                  src={formValues?.secondary_signature}
                  sx={{
                    top: 0,
                    left: 0,
                    height: '100%',
                    width: '100%',
                    objectFit: 'cover',
                    borderRadius: 1.5,
                  }}
                />
              </Box>
            </Box>
          </>
        )}
      </Stack>
    );
  }

  return (
    <Stack spacing={4}>
      <Box>
        <Typography variant="h5" gutterBottom>
          Signature Policy
        </Typography>
        <RHFRadioGroup
          name="signature_policy"
          row
          options={[
            { label: 'Single', value: 'single' },
            { label: 'Double', value: 'double' },
          ]}
        />
      </Box>

      {signaturePolicy === 'single' && (
        <Box>
          <Typography variant="h5" gutterBottom>
            Signature Type
          </Typography>
          <Box mt={2}>
            <SignatureUpload name="signature" />
          </Box>
        </Box>
      )}

      {signaturePolicy === 'double' && (
        <Stack spacing={4}>
          <Box>
            <Typography variant="h5" gutterBottom>
              Primary Signature
            </Typography>
            <Box mt={2}>
              <SignatureUpload name="primary_signature" />
            </Box>
          </Box>

          <Divider />

          <Box>
            <Typography variant="h5" gutterBottom>
              Secondary Signature
            </Typography>
            <RHFRadioGroup
              name="secondary_signature_type"
              row
              options={[
                {
                  label: 'Upload',
                  value: 'upload',
                },
                {
                  label: 'Draw',
                  value: 'draw',
                },
              ]}
            />
            <Box mt={2}>
              {formValues.secondary_signature_type === 'upload' && (
                <SignatureUpload name="secondary_signature" />
              )}
              {formValues.secondary_signature_type === 'draw' && (
                <CanvasSignature name="secondary_signature" />
              )}
            </Box>
          </Box>
        </Stack>
      )}
    </Stack>
  );
};
