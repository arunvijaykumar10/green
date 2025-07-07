import type { Company } from 'src/pages/companies/types';

export const getBankAccountDefaultValues = (company?: Company) => ({
    bankName: company?.bank_config?.bank_name || '',

    accountNumber: company?.bank_config?.account_number || '',
    confirmAccountNumber: company?.bank_config?.account_number || '',
    routing_number_ach: company?.bank_config?.routing_number_ach || '',
    routing_number_wire: company?.bank_config?.routing_number_wire || '',
    accountType: company?.bank_config?.account_type || '',
    authorize: company?.bank_config?.authorized || false,
  });
