import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';

import { Stack } from '@mui/material';
import LoadingButton from '@mui/lab/LoadingButton';

import {
  useCompany,
  useCreateUnionConfigMutation,
  useUpdateUnionConfigMutation,
} from 'src/pages/companies/api';

import { Form } from 'src/components/hook-form';

import { useAuthContext } from 'src/auth/hooks';

import { unionSetupSchema } from './validation';
import { UnionSetupContent } from './UnionSetupContent';
import { getUnionSetupDefaultValues } from './defaultValues';

interface UnionSetupFormProps {
  onSubmit: () => void;
  isViewMode: boolean;
  isEditMode: boolean;
}

export const UnionSetupForm = ({ onSubmit, isViewMode }: UnionSetupFormProps) => {
  const { user } = useAuthContext();
  const currentCompanyId = user?.last_accessed_company?.id || null;
  const { company } = useCompany(currentCompanyId);

  const [createUnionConfig] = useCreateUnionConfigMutation();
  const [updateUnionConfig] = useUpdateUnionConfigMutation();

  const title = 'Setup Unions';
  const defaultValues = getUnionSetupDefaultValues(company);

  const formMethods = useForm({
    defaultValues,
    resolver: zodResolver(unionSetupSchema),
  });

  const handleSubmit = async (data: any) => {
    const agreementTypeValue =
      typeof data.agreementType === 'object' ? data.agreementType?.value : data.agreementType;

    const unionPayload = {
      union_type: data.unionStatus === 'Union' ? ('union' as const) : ('non-union' as const),
      active: true,
      ...(data.unionStatus === 'Union' && {
        union_name: data.union,
        agreement_type: agreementTypeValue,
        agreement_type_configuration: {
          ...(data.musicalOrDramatic && { musical_or_dramatic: data.musicalOrDramatic }),
          ...(data.tier && { tier: data.tier }),
          ...(data.aeaEmployerId && { aea_employer_id: data.aeaEmployerId }),
          ...(data.aeaProductionTitle && { aea_production_title: data.aeaProductionTitle }),
          ...(data.aeaBusinessRep && { aea_business_representative: data.aeaBusinessRep }),
        },
      }),
    };

    if (company?.union_config?.id) {
      await updateUnionConfig({
        companyId: currentCompanyId,
        unionId: company.union_config.id,
        company_union_configuration: unionPayload,
      });
    } else {
      await createUnionConfig({
        companyId: currentCompanyId,
        company_union_configuration: unionPayload,
      });
    }

    onSubmit();
  };

  return (
    <Form methods={formMethods} onSubmit={formMethods.handleSubmit(handleSubmit)}>
      <Stack spacing={2}>
        <UnionSetupContent isViewMode={isViewMode} />
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
