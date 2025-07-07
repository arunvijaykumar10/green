import dayjs from 'dayjs';
import { useFormContext } from 'react-hook-form';

import { MenuItem } from '@mui/material';

import { RHFSelect, RHFTextField, RHFDatePicker, RHFAutocomplete } from 'src/components/hook-form';

import { ViewField } from '../ViewField';

const ENTITY_TYPES = ['Corp', 'Partnership', 'Sole Proprietor', 'Non Profit', 'Single-member LLC'];
const STATES = ['NY', 'CA', 'TX', 'IL'];
const payFrequencies = ['Weekly', 'Bi-weekly', 'Monthly'];
const payPeriods = ['Current', '1 week in arrears', '2 weeks in arrears'];

interface CompanyDetailsContentProps {
  isViewMode: boolean;
}

export const CompanyDetailsContent = ({ isViewMode }: CompanyDetailsContentProps) => {
  const { watch } = useFormContext();
  const formData = watch();

  if (isViewMode) {
    return (
      <>
        <ViewField label="Entity Name" value={formData.entityName} />
        <ViewField label="Entity Type" value={formData.entityType} />
        <ViewField label="FEIN" value={formData.fein} />
        <ViewField label="Address Line 1" value={formData.addressLine1} />
        <ViewField label="Address Line 2" value={formData.addressLine2} />
        <ViewField label="City" value={formData.city} />
        <ViewField label="State" value={formData.state} />
        <ViewField label="Zip Code" value={formData.zipCode} />
        <ViewField label="Phone Number" value={formData.phoneNumber} />
        <ViewField
          label="NYS Unemployment Registration Number"
          value={formData.nysUnemploymentNumber}
        />
        <ViewField label="Pay Frequency" value={formData.payFrequency} />
        <ViewField label="Pay Period" value={formData.payPeriod} />
        <ViewField
          label="Pay Schedule Start Date"
          value={
            formData.payScheduleStart ? dayjs(formData.payScheduleStart).format('MM/DD/YYYY') : null
          }
        />
        <ViewField label="Check Number" value={formData.checkNumber} />
      </>
    );
  }

  return (
    <>
      <RHFTextField name="entityName" label="Entity Name" required />
      <RHFAutocomplete options={ENTITY_TYPES} name="entityType" label="Entity Type *" />
      <RHFTextField name="fein" label="FEIN" required type="number" />
      <RHFTextField name="addressLine1" label="Address Line 1" required />
      <RHFTextField name="addressLine2" label="Address Line 2" />
      <RHFTextField name="city" label="City" required />
      <RHFAutocomplete options={STATES} name="state" label="State" />
      <RHFTextField name="zipCode" label="Zip Code" required type="number" />
      <RHFTextField name="phoneNumber" label="Phone Number" required type="number" />
      <RHFTextField
        name="nysUnemploymentNumber"
        label="NYS Unemployment Registration Number *"
        type="number"
        required
      />
      <RHFSelect name="payFrequency" label="Pay Frequency *">
        {payFrequencies.map((freq) => (
          <MenuItem key={freq} value={freq}>
            {freq}
          </MenuItem>
        ))}
      </RHFSelect>
      <RHFSelect name="payPeriod" label="Pay Period *">
        {payPeriods.map((period) => (
          <MenuItem key={period} value={period}>
            {period}
          </MenuItem>
        ))}
      </RHFSelect>
      <RHFDatePicker
        name="payScheduleStart"
        label="Pay Schedule Start Date *"
        minDate={dayjs().add(2, 'day')}
      />
      <RHFTextField name="checkNumber" label="Check Number *" type="number" />
    </>
  );
};