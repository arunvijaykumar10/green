import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';

import { Stack } from '@mui/material';
import LoadingButton from '@mui/lab/LoadingButton';

import computeChecksum, { uploadToS3 } from 'src/utils/s3uploads';

import {
  useCompany,
  useGetPresignedUrlMutation,
  useAttachFileToRecordMutation,
} from 'src/pages/companies/api';

import { Form } from 'src/components/hook-form';

import { useAuthContext } from 'src/auth/hooks';

import { signatureSchema } from './validation';
import { SignatureContent } from './SignatureContent';
import { getSignatureDefaultValues } from './defaultValues';

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

interface SignatureFormProps {
  onSubmit: () => void;
  isViewMode: boolean;
  isEditMode: boolean;
}

export const SignatureForm = ({ onSubmit, isViewMode }: SignatureFormProps) => {
  const { user } = useAuthContext();
  const currentCompanyId = user?.last_accessed_company?.id || null;
  const { company } = useCompany(currentCompanyId);

  const [getPresignedUrl] = useGetPresignedUrlMutation();
  const [attachFileToRecord] = useAttachFileToRecordMutation();

  const title = 'Configure Signatures';
  const defaultValues = getSignatureDefaultValues(company);

  const formMethods = useForm({
    defaultValues,
    resolver: zodResolver(signatureSchema),
  });

  const {
    formState: { errors },
  } = formMethods;

  console.log('errors', { errors });

  const handleFileUpload = async (
    file: File,
    companyId: number,
    signatureField: 'signature' | 'secondary_signature',
    signaturePolicy: 'single' | 'double'
  ) => {
    const checksum = await computeChecksum(file);
    const fileParams = {
      filename: file.name,
      byte_size: file.size,
      checksum,
      content_type: file.type,
    };

    const batchParams = { files: [fileParams] };
    const presignedResult = await getPresignedUrl(batchParams as any);

    if ('error' in presignedResult) {
      throw new Error('Failed to get presigned URLs');
    }

    const presignedData = (presignedResult.data as any).data[0];
    const signedId = await uploadToS3(file, checksum, presignedData);

    const fileContent = {
      company: {
        [signatureField]: signedId,
        signature_type: signaturePolicy,
      },
    };

    await attachFileToRecord({ companyId, body: fileContent });
  };

  const handleSubmit = async (data: any) => {
    if (data.signature_policy === 'single') {
      await handleFileUpload(data.signature, currentCompanyId, 'signature', data.signature_policy);
    } else if (data.signature_policy === 'double') {
      await handleFileUpload(
        data.primary_signature,
        currentCompanyId,
        'signature',
        data.signature_policy
      );

      if (data.secondary_signature_type === 'upload') {
        await handleFileUpload(
          data.secondary_signature,
          currentCompanyId,
          'secondary_signature',
          data.signature_policy
        );
      } else if (data.secondary_signature_type === 'draw') {
        const blob = dataURLToBlob(data.secondary_signature);
        const file = new File([blob], 'secondary_signature', { type: 'image/png' });
        await handleFileUpload(
          file,
          currentCompanyId,
          'secondary_signature',
          data.signature_policy
        );
      }
    }

    onSubmit();
  };

  return (
    <Form methods={formMethods} onSubmit={formMethods.handleSubmit(handleSubmit)}>
      <Stack spacing={2}>
        <SignatureContent isViewMode={isViewMode} />
        {!isViewMode && (
          <Stack sx={{ mt: 'auto' }}>
            <LoadingButton type="submit" variant="contained" color="primary" fullWidth>
              Submit
            </LoadingButton>
          </Stack>
        )}
      </Stack>
    </Form>
  );
};
