import { z } from 'zod';
import { useState, useEffect } from 'react';
import { zodResolver } from '@hookform/resolvers/zod';
import { useForm, FormProvider } from 'react-hook-form';

import {
  Box,
  Card,
  Grid2,
  Button
} from '@mui/material';

import { useCompany, useCreateBankConfigMutation, useUpdateBankConfigMutation } from 'src/pages/companies/api';

import { RHFCheckbox, RHFTextField, RHFAutocomplete } from 'src/components/hook-form';

import { useAuthContext } from 'src/auth/hooks';

import type { BankData, AccountType, BankSetupData } from '../../../pages/dashboard/types';

const bankList: BankData[] = [
  {
    name: "Bank of America",
    routing_number_ach: "011000138",
    routing_number_wire: "026009593",
  },
  { name: "Wells Fargo", routing_number_ach: "121000248", routing_number_wire: "121000248" },
  { name: "Chase", routing_number_ach: "021000021", routing_number_wire: "021000021" },
];

const accountTypes: AccountType[] = ["Checking", "Savings"];

// Form validation schema
const BankSetupSchema = z.object({
  bankName: z.string().min(1, 'Bank name is required'),
  routing_number_ach: z.string()
    .min(1, 'Routing number (ACH) is required')
    .regex(/^\d{9}$/, 'Must be 9 digits'),
  routing_number_wire: z.string()
    .min(1, 'Routing number (Wire) is required')
    .regex(/^\d{9}$/, 'Must be 9 digits'),
  accountNumber: z.string()
    .min(1, 'Account number is required')
    .regex(/^\d+$/, 'Must contain only digits'),
  confirmAccountNumber: z.string()
    .min(1, 'Please confirm account number').regex(/^\d+$/, 'Must contain only digits'),
  accountType: z.string().min(1, 'Account type is required'),
  authorize: z.boolean().refine(val => val === true, 'You must authorize to proceed')
}).refine((data) => data.accountNumber === data.confirmAccountNumber, {
  message: 'Account numbers must match',
  path: ['confirmAccountNumber'],
});

function BankSetup() {
  const [selectedBank, setSelectedBank] = useState<string>("");
  const [isManualBank, setIsManualBank] = useState(false);

  const methods = useForm<BankSetupData>({
    resolver: zodResolver(BankSetupSchema),
    mode: 'onChange',
    defaultValues: {
      bankName: '',
      routing_number_ach: '',
      routing_number_wire: '',
      accountNumber: '',
      confirmAccountNumber: '',
      accountType: '',
      authorize: false,
    }
  });

  const { setValue, watch, handleSubmit, reset, trigger } = methods;
  const accountNumber = watch('accountNumber');
  const confirmAccountNumber = watch('confirmAccountNumber');

  const { user } = useAuthContext();
  const currentCompanyId = user?.last_accessed_company?.id;
  const { company } = useCompany(currentCompanyId);
  const [createBankConfig] = useCreateBankConfigMutation();
  const [updateBankConfig] = useUpdateBankConfigMutation();

  useEffect(() => {
    if (company?.bank_config) {
      const bankConfig = company?.bank_config;
      reset({
        bankName: bankConfig.bank_name || '',
        routing_number_ach: bankConfig.routing_number_ach?.toString() || '',
        routing_number_wire: bankConfig.routing_number_wire?.toString() || '',
        accountNumber: bankConfig.account_number?.toString() || '',
        confirmAccountNumber: bankConfig.account_number?.toString() || '',
        accountType: (bankConfig.account_type as AccountType) || '',
        authorize: bankConfig.authorized || false,
      });
    }
  }, [company, reset]);

  useEffect(() => {
    if (confirmAccountNumber) {
      trigger('confirmAccountNumber');
    }
  }, [accountNumber, confirmAccountNumber, trigger]);

  // Handle bank selection
  const handleBankSelect = (value: string) => {
    setSelectedBank(value);

    if (value === 'Enter Manually') {
      setIsManualBank(true);
      reset({
        ...methods.getValues(),
        bankName: '',
        routing_number_ach: '',
        routing_number_wire: '',
      });
    } else {
      const bank = bankList.find((b) => b.name === value);
      if (bank) {
        setIsManualBank(false);
        setValue('bankName', bank.name);
        setValue('routing_number_ach', bank.routing_number_ach);
        setValue('routing_number_wire', bank.routing_number_wire);
      } else {
        setIsManualBank(true);
        setValue('bankName', value);
        setValue('routing_number_ach', '');
        setValue('routing_number_wire', '');
      }
    }
  };

  const onSubmit = async (data: BankSetupData) => {
    if (!currentCompanyId) return;

    const payload = {
      companyId: currentCompanyId,
      bank_name: data.bankName,
      account_number: parseInt(data.accountNumber, 10),
      routing_number_ach: parseInt(data.routing_number_ach, 10),
      routing_number_wire: parseInt(data.routing_number_wire, 10),
      account_type: data.accountType.toLowerCase(),
      authorized: data.authorize
    };
    try {
      if (company?.bank_config?.id) {
        await updateBankConfig({ ...payload, id: company?.bank_config.id }).unwrap();
      } else {
        await createBankConfig(payload).unwrap();
      }
      console.log('Bank config saved successfully');
    } catch (error) {
      console.error('Failed to save bank config:', error);
    }
  };

  return (
    <Box sx={{ p: 2 }}>

      <FormProvider {...methods}>
        <Box component="form" onSubmit={handleSubmit(onSubmit)}>
          <Card sx={{ p: 3 }}>
            <Grid2 container spacing={3}>
              <Grid2 size={{ xs: 12 }}>
                <RHFAutocomplete
                  name="selectedBank"
                  label="Select Bank or Enter Manually"
                  options={[...bankList.map(bank => bank.name), 'Enter Manually']}
                  value={selectedBank}
                  onChange={(event, value) => handleBankSelect(value || '')}
                  slotProps={{
                    textfield: { fullWidth: true }
                  }}
                />
              </Grid2>

              <Grid2 size={{ xs: 12 }}>
                <RHFTextField
                  name="bankName"
                  label="Bank Name"
                  disabled={!isManualBank}
                />
              </Grid2>

              <Grid2 size={{ xs: 12, sm: 6 }}>
                <RHFTextField
                  name="routing_number_ach"
                  label="Routing Number (ACH)"
                  disabled={!isManualBank}
                  inputProps={{
                    maxLength: 9,
                    onPaste: (e: React.ClipboardEvent) => {
                      const pastedText = e.clipboardData.getData("text");
                      if (!/^\d+$/.test(pastedText)) {
                        e.preventDefault();
                      }
                    }
                  }}
                />
              </Grid2>

              <Grid2 size={{ xs: 12, sm: 6 }}>
                <RHFTextField
                  name="routing_number_wire"
                  label="Routing Number (Wire)"
                  disabled={!isManualBank}
                  inputProps={{
                    maxLength: 9,
                    onPaste: (e: React.ClipboardEvent) => {
                      const pastedText = e.clipboardData.getData("text");
                      if (!/^\d+$/.test(pastedText)) {
                        e.preventDefault();
                      }
                    }
                  }}
                />
              </Grid2>

              <Grid2 size={{ xs: 12, sm: 6 }}>
                <RHFTextField
                  name="accountNumber"
                  label="Account Number"
                  inputProps={{
                    inputMode: 'numeric',
                    onPaste: (e: React.ClipboardEvent) => e.preventDefault()
                  }}
                />
              </Grid2>

              <Grid2 size={{ xs: 12, sm: 6 }}>
                <RHFTextField
                  name="confirmAccountNumber"
                  label="Confirm Account Number"
                  inputProps={{
                    inputMode: 'numeric',
                    onPaste: (e: React.ClipboardEvent) => e.preventDefault()
                  }}
                />
              </Grid2>

              <Grid2 size={{ xs: 12 }}>
                <RHFAutocomplete
                  name="accountType"
                  label="Account Type"
                  options={accountTypes}
                  slotProps={{
                    textfield: { fullWidth: true }
                  }}
                />
              </Grid2>

              <Grid2 size={{ xs: 12 }}>
                <RHFCheckbox
                  name="authorize"
                  label="I authorize credit/debit transactions for this account"
                />
              </Grid2>

              <Grid2 size={{ xs: 12 }}>
                <Box sx={{ mt: 2, display: 'flex', justifyContent: 'flex-end' }}>
                  <Button
                    type="submit"
                    variant="contained"
                    color="primary"
                    size="large"
                  >
                    Save
                  </Button>
                </Box>
              </Grid2>
            </Grid2>
          </Card>
        </Box>
      </FormProvider>
    </Box>
  );
}

export { BankSetup };
export default BankSetup;