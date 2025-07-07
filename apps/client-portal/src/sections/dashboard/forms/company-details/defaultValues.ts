import type { Company } from 'src/pages/companies/types';

import _ from 'lodash';

export const getCompanyDetailsDefaultValues = (company?: Company) => {
  const currentAddress = _.find(company?.addresses, (address) => address.active_until === null);
  return {
    entityName: company?.name || '',
    entityType: company?.company_type || '',
    fein: company?.fein || '',
    nysUnemploymentNumber: company?.nys_no || '',
    phoneNumber: company?.phone || '',
    addressLine1: currentAddress?.address_line_1 || '',
    addressLine2: currentAddress?.address_line_2 || '',
    city: currentAddress?.city || '',
    state: currentAddress?.state || '',
    zipCode: currentAddress?.zip_code || '',
    payFrequency: company?.payroll_config?.frequency || '',
    payPeriod: company?.payroll_config?.period || '',
    payScheduleStart: company?.payroll_config?.start_date
      ? new Date(company.payroll_config.start_date)
      : new Date(),
    checkNumber: company?.payroll_config?.check_start_number || '',
  };
};
