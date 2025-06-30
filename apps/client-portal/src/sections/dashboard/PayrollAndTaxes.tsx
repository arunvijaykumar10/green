import dayjs from 'dayjs';
import { useEffect } from 'react';
import { useForm, FormProvider } from 'react-hook-form';

import {
  Box,
  Card,
  Stack,
  Button,
  MenuItem,
  Typography
} from '@mui/material';

import { useCompany, useCreatePayrollConfigMutation, useUpdatePayrollConfigMutation } from 'src/pages/companies/api';

import { RHFSelect, RHFTextField, RHFDatePicker } from 'src/components/hook-form';

import { useAuthContext } from 'src/auth/hooks';

// ----------------------------------------------------------------------

const payFrequencies = ["Weekly", "Bi-weekly", "Monthly"];
const payPeriods = ["Current", "1 week in arrears", "2 weeks in arrears"];

// ----------------------------------------------------------------------

function PayrollAndTaxes() {
  const { user } = useAuthContext();
  const currentCompanyId = user?.last_accessed_company?.id;
  const [createPayrollConfig] = useCreatePayrollConfigMutation();
  const [updatePayrollConfig] = useUpdatePayrollConfigMutation();
  const { company } = useCompany(currentCompanyId);
  const methods = useForm({
    defaultValues: {
      payFrequency: "",
      payPeriod: "",
      payScheduleStart: "",
      checkNumber: "",
    }
  });

  const { handleSubmit, reset } = methods;

  useEffect(() => {
    if (company?.payroll_config) {
      const config = company.payroll_config;
      reset({
        payFrequency: config.frequency || '',
        payPeriod: config.period || '',
        payScheduleStart: config.start_date ? dayjs(config.start_date).format('YYYY-MM-DD') : dayjs().add(2, 'day').format('YYYY-MM-DD'),
        checkNumber: config.check_start_number?.toString() || '',
      });
    }
  }, [company, reset]);

  const onSubmit = async (data: any) => {
    if (currentCompanyId) {
      try {
        const payrollData = {
          frequency: data.payFrequency,
          period: data.payPeriod,
          start_date: dayjs(data.payScheduleStart).format('YYYY-MM-DD'),
          check_start_number: parseInt(data.checkNumber, 10),
          active: true
        };

        if (company?.payroll_config?.id) {
          await updatePayrollConfig({
            companyId: currentCompanyId,
            id: company.payroll_config.id,
            payroll_config: payrollData
          }).unwrap();
        } else {
          await createPayrollConfig({
            companyId: currentCompanyId,
            payroll_config: payrollData
          }).unwrap();
        }
        console.log('Payroll config saved successfully');
      } catch (error) {
        console.error('Failed to save payroll config:', error);
      }
    }
  };

  return (
    <FormProvider {...methods}>
      <form onSubmit={handleSubmit(onSubmit)}>
        <Card sx={{ p: 4 }}>
          <Stack spacing={3}>
            <Typography variant="h6">Payroll & Taxes Configuration</Typography>

            <RHFSelect name="payFrequency" label="Pay Frequency">
              {payFrequencies.map((freq) => (
                <MenuItem key={freq} value={freq}>
                  {freq}
                </MenuItem>
              ))}
            </RHFSelect>

            <RHFSelect name="payPeriod" label="Pay Period">
              {payPeriods.map((period) => (
                <MenuItem key={period} value={period}>
                  {period}
                </MenuItem>
              ))}
            </RHFSelect>

            <RHFDatePicker
              name="payScheduleStart"
              label="Pay Schedule Start Date"
              minDate={dayjs().add(2, 'day')}
            />

            <RHFTextField
              name="checkNumber"
              label="Check Number"
            />
            <Box sx={{ display: 'flex', justifyContent: 'flex-end', mt: 3 }}>
              <Button
                type="submit"
                variant="contained"
                color="primary"
                size="large"
              >
                Save
              </Button>
            </Box>
          </Stack>
        </Card>
      </form>
    </FormProvider>
  );
}

export { PayrollAndTaxes };
export default PayrollAndTaxes;