import type { Company } from 'src/pages/companies/types';

export const getUnionSetupDefaultValues = (company?: Company) => ({
  unionStatus: company?.union_config?.union_type === 'union' ? 'Union' : 'Non-Union',
  union: company?.union_config?.union_name || '',
  agreementType: company?.union_config?.agreement_type || '',
  musicalOrDramatic: company?.union_config?.agreement_type_configuration?.musical_or_dramatic || '',
  tier: company?.union_config?.agreement_type_configuration?.tier || '',
  aeaEmployerId: company?.union_config?.agreement_type_configuration?.aea_employer_id || '',
  aeaProductionTitle:
    company?.union_config?.agreement_type_configuration?.aea_production_title || '',
  aeaBusinessRep:
    company?.union_config?.agreement_type_configuration?.aea_business_representative || '',
});
