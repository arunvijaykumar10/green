import type { Company } from 'src/pages/companies/types';

export const getSignatureDefaultValues = (company?: Company) => ({
  signature_policy: company?.signature_type || 'single',
  signature: company?.signature_url || null,
  primary_signature: company?.signature_url || null,
  secondary_signature_type: '',
  secondary_signature: company?.secondary_signature_url || null,
});
