import dayjs from 'dayjs';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';

import { Stack } from '@mui/material';
import LoadingButton from '@mui/lab/LoadingButton';

import {
  useCompany,
  useUpdateMutation,
  useCreatePayrollConfigMutation,
  useUpdatePayrollConfigMutation,
} from 'src/pages/companies/api';

import { Form } from 'src/components/hook-form';

import { useAuthContext } from 'src/auth/hooks';

import { companyDetailsSchema } from './validation';
import { CompanyDetailsContent } from './CompanyDetailsContent';
import { getCompanyDetailsDefaultValues } from './defaultValues';

interface CompanyDetailsFormProps {
  onSubmit: () => void;
  isViewMode: boolean;
  isEditMode: boolean;
}

export const CompanyDetailsForm = ({
  onSubmit,
  isViewMode,
  isEditMode,
}: CompanyDetailsFormProps) => {
  const { user } = useAuthContext();
  const currentCompanyId = user?.last_accessed_company?.id || null;
  const { company } = useCompany(currentCompanyId);

  const [updateCompany, updateCompanyResult] = useUpdateMutation();
  const [createPayrollConfig, createPayrollResult] = useCreatePayrollConfigMutation();
  const [updatePayrollConfig, updatePayrollResult] = useUpdatePayrollConfigMutation();

  const title = 'Complete Company Details';
  const defaultValues = getCompanyDetailsDefaultValues(company);

  const formMethods = useForm({
    defaultValues,
    resolver: zodResolver(companyDetailsSchema),
  });

  const handleSubmit = async (data: any) => {
    const companyParams = {
      company: {
        name: data.entityName,
        company_type: data.entityType,
        fein: data.fein,
        nys_no: data.nysUnemploymentNumber,
        phone: data.phoneNumber,
        addresses_attributes: [
          {
            address_type: 'primary',
            address_line_1: data.addressLine1,
            address_line_2: data.addressLine2,
            city: data.city,
            state: data.state,
            zip_code: data.zipCode,
            active_from: new Date().toISOString(),
          },
        ],
      },
    };

    const payrollParams = {
      payroll_config: {
        frequency: data.payFrequency,
        period: data.payPeriod,
        start_date: dayjs(data.payScheduleStart).format('YYYY-MM-DD'),
        check_start_number: data.checkNumber,
        active: true,
      },
    };

    await updateCompany({ id: currentCompanyId, ...companyParams });

    if (company?.payroll_config?.id) {
      await updatePayrollConfig({
        companyId: currentCompanyId,
        id: company.payroll_config.id,
        ...payrollParams,
      });
    } else {
      await createPayrollConfig({ companyId: currentCompanyId, ...payrollParams });
    }

    onSubmit();
  };

  return (
    <Form methods={formMethods} onSubmit={formMethods.handleSubmit(handleSubmit)}>
      <Stack spacing={2}>
        <CompanyDetailsContent isViewMode={isViewMode} />
        {!isViewMode && (
          <Stack sx={{ mt: 'auto' }}>
            <LoadingButton type="submit" variant="contained" color="primary" fullWidth>
              {isEditMode ? 'Save' : 'Submit'}
            </LoadingButton>
          </Stack>
        )}
      </Stack>
    </Form>
  );
};
