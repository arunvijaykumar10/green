import type { BankData, AccountType } from 'src/pages/dashboard/types';

import React, { useEffect } from 'react';
import { useWatch, useFormContext } from 'react-hook-form';

import { RHFCheckbox, RHFTextField, RHFAutocomplete } from 'src/components/hook-form';

import { ViewField } from '../ViewField';

const bankList: BankData[] = [
  {
    name: 'Bank of America',
    routing_number_ach: '511000138',
    routing_number_wire: '826009593',
  },
  { name: 'Wells Fargo', routing_number_ach: '121000248', routing_number_wire: '121000248' },
  { name: 'Chase', routing_number_ach: '921000021', routing_number_wire: '821000021' },
];

const accountTypes: AccountType[] = ['Checking', 'Savings'];

interface BankAccountContentProps {
  isViewMode: boolean;
}

export const BankAccountContent = ({ isViewMode }: BankAccountContentProps) => {
  const { setValue, watch } = useFormContext();
  const selectedBank = useWatch({ name: 'selectedBank' });
  const isManualBank = selectedBank?.length === 0 || selectedBank === 'Enter Manually';
  const formData = watch();

  useEffect(() => {
    if (selectedBank && selectedBank !== 'Enter Manually') {
      const bank = bankList.find((b) => b.name === selectedBank);
      if (bank) {
        setValue('bankName', bank.name);
        setValue('routing_number_ach', bank.routing_number_ach);
        setValue('routing_number_wire', bank.routing_number_wire);
      }
    }
  }, [selectedBank, setValue]);

  if (isViewMode) {
    return (
      <>
        <ViewField label="Bank Name" value={formData.bankName} />
        <ViewField label="Routing Number (ACH)" value={formData.routing_number_ach} />
        <ViewField label="Routing Number (Wire)" value={formData.routing_number_wire} />
        <ViewField label="Account Number" value={formData.accountNumber} />
        <ViewField label="Account Type" value={formData.accountType} />
        <ViewField label="Authorized" value={formData.authorize ? 'Yes' : 'No'} />
      </>
    );
  }

  return (
    <>
      <RHFAutocomplete
        name="selectedBank"
        label="Select Bank or Enter Manually"
        options={[...bankList.map((bank) => bank.name), 'Enter Manually']}
      />

      <RHFTextField name="bankName" label="Bank Name" disabled={!isManualBank} />

      <RHFTextField
        name="routing_number_ach"
        label="Routing Number (ACH)"
        disabled={!isManualBank}
      />

      <RHFTextField
        name="routing_number_wire"
        label="Routing Number (Wire)"
        disabled={!isManualBank}
      />

      <RHFTextField name="accountNumber" label="Account Number" type="number" />

      <RHFTextField name="confirmAccountNumber" label="Confirm Account Number" type="number" />

      <RHFAutocomplete
        name="accountType"
        label="Account Type"
        options={accountTypes}
        slotProps={{
          textfield: { fullWidth: true },
        }}
      />

      <RHFCheckbox
        name="authorize"
        label="I authorize credit/debit transactions for this account"
      />
    </>
  );
};
