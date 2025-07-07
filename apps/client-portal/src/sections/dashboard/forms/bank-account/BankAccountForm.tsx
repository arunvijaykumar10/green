import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';

import { Stack } from '@mui/material';
import LoadingButton from '@mui/lab/LoadingButton';

import {
  useCompany,
  useCreateBankConfigMutation,
  useUpdateBankConfigMutation,
} from 'src/pages/companies/api';

import { Form } from 'src/components/hook-form';

import { useAuthContext } from 'src/auth/hooks';

import { bankAccountSchema } from './validation';
import { BankAccountContent } from './BankAccountContent';
import { getBankAccountDefaultValues } from './defaultValues';

interface BankAccountFormProps {
  onSubmit: () => void;
  isViewMode: boolean;
  isEditMode: boolean;
}

export const BankAccountForm = ({ onSubmit, isViewMode }: BankAccountFormProps) => {
  const { user } = useAuthContext();
  const currentCompanyId = user?.last_accessed_company?.id || null;
  const { company } = useCompany(currentCompanyId);

  const [createBankConfig] = useCreateBankConfigMutation();
  const [updateBankConfig] = useUpdateBankConfigMutation();

  const title = 'Link Bank Account';
  const defaultValues = getBankAccountDefaultValues(company);

  const formMethods = useForm({
    defaultValues,
    resolver: zodResolver(bankAccountSchema),
  });

  const handleSubmit = async (data: any) => {
    const bankParams = {
      bank_name: data.bankName,
      account_number: parseInt(data.accountNumber, 10),
      routing_number_ach: parseInt(data.routing_number_ach, 10),
      routing_number_wire: parseInt(data.routing_number_wire, 10),
      account_type: data.accountType.toLowerCase(),
      authorized: data.authorize,
    };

    if (company?.bank_config?.id) {
      await updateBankConfig({
        companyId: currentCompanyId,
        id: company.bank_config.id,
        ...bankParams,
      });
    } else {
      await createBankConfig({
        companyId: currentCompanyId,
        ...bankParams,
      });
    }

    onSubmit();
  };

  return (
    <Form methods={formMethods} onSubmit={formMethods.handleSubmit(handleSubmit)}>
      <Stack
        spacing={2}
        sx={{
          height: '100%',
          display: 'flex',
          flexDirection: 'column',
        }}
      >
        <BankAccountContent isViewMode={isViewMode} />
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
