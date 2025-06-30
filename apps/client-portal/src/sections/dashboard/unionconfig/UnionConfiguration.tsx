import { useRef, useEffect } from 'react';
import { useForm, FormProvider } from 'react-hook-form';

import {
  Box,
  Card,
  Grid2,
  Button,
  Typography
} from '@mui/material';

import { useCompany, useCreateUnionConfigMutation, useUpdateUnionConfigMutation } from 'src/pages/companies/api';

import { RHFTextField, RHFRadioGroup, RHFAutocomplete } from 'src/components/hook-form';

import { useAuthContext } from 'src/auth/hooks';

import type { UnionConfigurationData } from '../../../pages/dashboard/types';


const UNION_OPTIONS = [
  { label: 'Non-Union', value: 'Non-Union' },
  { label: 'Union', value: 'Union' }
];
const UNIONS = ["Actor's Equity Association"];
const AGREEMENT_OPTIONS = [
  { id: 'equity_or_league_production_contract', label: 'Equity/League Production Contract', value: 'equity_or_league_production_contract' },
  { id: 'off_broadway_agreement', label: 'Off-Broadway Agreement', value: 'off_broadway_agreement' },
  { id: 'development_agreement', label: 'Development Agreement (Work Session)', value: 'development_agreement' },
  { id: '29_hour_reading', label: '29 Hour Reading', value: '29_hour_reading' },
];
const MUSICAL_OR_DRAMATIC_OPTIONS = ['Musical', 'Dramatic'];
const TIER_OPTIONS = ['Tier 1', 'Tier 2', 'Tier 3'];
const AllowedFields = {
  equity_or_league_production_contract: ['musicalOrDramatic', 'aeaEmployerId', 'aeaProductionTitle', 'aeaBusinessRep'],
  off_broadway_agreement: ['musicalOrDramatic', 'aeaEmployerId', 'aeaProductionTitle', 'aeaBusinessRep'],
  development_agreement: ['tier', 'aeaEmployerId', 'aeaProductionTitle', 'aeaBusinessRep'],
  "29_hour_reading": [],
};


function UnionConfiguration() {
  const { user } = useAuthContext();
  const currentCompanyId = user?.last_accessed_company?.id;
  const [createUnionConfig] = useCreateUnionConfigMutation();
  const [updateUnionConfig] = useUpdateUnionConfigMutation();
  const { company } = useCompany(currentCompanyId!);
  const prevAgreementType = useRef<string>('');
  const methods = useForm<UnionConfigurationData>({
    mode: 'onSubmit',
    defaultValues: {
      unionStatus: 'Non-Union',
      union: '',
      agreementType: '',
      musicalOrDramatic: '',
      tier: '',
      aeaEmployerId: '',
      aeaProductionTitle: '',
      aeaBusinessRep: '',
    }
  });
  const { watch, reset, handleSubmit, setValue, clearErrors } = methods;
  const unionStatus = watch('unionStatus');
  const union = watch('union');
  const agreementType = watch('agreementType');
  const showUnionField = unionStatus === 'Union';
  const showAgreementField = unionStatus === 'Union' && union === "Actor's Equity Association";
  const agreementTypeId = typeof agreementType === 'object' ? agreementType?.id : agreementType;
  const showMusicalOrDramatic =
    agreementTypeId === 'equity_or_league_production_contract' ||
    agreementTypeId === 'off_broadway_agreement';
  const showTier = agreementTypeId === 'development_agreement';
  const showAEAFields =
    unionStatus === 'Union' &&
    union === "Actor's Equity Association" &&
    agreementTypeId !== '29_hour_reading';





  useEffect(() => {
    if (company?.union_config) {
      const config = company.union_config;
      const agreementOption = AGREEMENT_OPTIONS.find(opt => opt.id === config.agreement_type);
      const formData: Partial<UnionConfigurationData> = {
        unionStatus: config.union_type === 'union' ? 'Union' : 'Non-Union',
        union: config.union_name || '',
        agreementType: agreementOption || '',
        musicalOrDramatic: config.agreement_type_configuration?.musical_or_dramatic || '',
        tier: config.agreement_type_configuration?.tier as UnionConfigurationData['tier'] || '',
        aeaEmployerId: config.agreement_type_configuration?.aea_employer_id || '',
        aeaProductionTitle: config.agreement_type_configuration?.aea_production_title || '',
        aeaBusinessRep: config.agreement_type_configuration?.aea_business_representative || '',
      };

      reset(formData);
    }
  }, []);

  useEffect(() => {
    if (unionStatus === 'Non-Union') {
      clearErrors(['union', 'agreementType']);
      setValue('union', '');
      setValue('agreementType', '');
      clearFields();
    }
  }, [unionStatus, clearErrors, setValue]);

  const clearFields = () => {
    setValue('musicalOrDramatic', '');
    setValue('tier', '');
    setValue('aeaEmployerId', '');
    setValue('aeaProductionTitle', '');
    setValue('aeaBusinessRep', '');
  };



  const onSubmit = async (data: UnionConfigurationData) => {

    if (currentCompanyId) {
      try {
        const currentAgreementTypeId = typeof data.agreementType === 'object' ? data.agreementType?.id : data.agreementType;
        const allowedFields: string[] = AllowedFields[currentAgreementTypeId as keyof typeof AllowedFields] || [];

        const agreementConfig: any = {};
        if (allowedFields.includes('musicalOrDramatic')) agreementConfig.musical_or_dramatic = data.musicalOrDramatic;
        if (allowedFields.includes('tier')) agreementConfig.tier = data.tier;
        if (allowedFields.includes('aeaEmployerId')) agreementConfig.aea_employer_id = data.aeaEmployerId;
        if (allowedFields.includes('aeaProductionTitle')) agreementConfig.aea_production_title = data.aeaProductionTitle;
        if (allowedFields.includes('aeaBusinessRep')) agreementConfig.aea_business_representative = data.aeaBusinessRep;

        const unionConfigId = company?.union_config?.id;

        const unionConfigPayload = {
          union_type: data.unionStatus === 'Union' ? 'union' as const : 'non-union' as const,
          active: true,
          ...(data.unionStatus === 'Union' && {
            union_name: data.union,
            agreement_type: currentAgreementTypeId,
            agreement_type_configuration: agreementConfig
          })
        };
        if (unionConfigId) {
          await updateUnionConfig({
            companyId: currentCompanyId,
            unionId: unionConfigId,
            company_union_configuration: unionConfigPayload
          }).unwrap();
        } else {
          await createUnionConfig({
            companyId: currentCompanyId,
            company_union_configuration: unionConfigPayload
          }).unwrap();
        }
        // dispatch(saveUnionConfiguration(data));
        console.log('Union config saved successfully');
      } catch (error) {
        console.error('Failed to save union config:', error);
      }
    }
  };

  return (
    <Box sx={{ p: 2 }}>
      <Typography variant="h6" gutterBottom>Union Configuration</Typography>
      <Typography variant="body2" color="text.secondary" paragraph>
        Configure union settings for your production.
      </Typography>

      <FormProvider {...methods}>
        <Box component="form" onSubmit={handleSubmit(onSubmit)} noValidate>
          <Card sx={{ p: 3 }}>
            <Grid2 container spacing={3}>
              <Grid2 size={{ xs: 12 }}>
                <RHFRadioGroup
                  name="unionStatus"
                  label="Is this a union production?"
                  options={UNION_OPTIONS}
                  row
                />
              </Grid2>

              {showUnionField && (
                <Grid2 size={{ xs: 12 }}>
                  <RHFAutocomplete
                    name="union"
                    label="Union"
                    placeholder="Select a union"
                    options={UNIONS}
                    slotProps={{
                      textfield: { fullWidth: true }
                    }}
                  />
                </Grid2>
              )}

              {showAgreementField && (
                <Grid2 size={{ xs: 12 }}>
                  <RHFAutocomplete
                    name="agreementType"
                    label="Agreement Type"
                    placeholder="Select an agreement type"
                    options={AGREEMENT_OPTIONS}
                    slotProps={{
                      textfield: { fullWidth: true }
                    }}
                  />
                </Grid2>
              )}

              {showMusicalOrDramatic && (
                <Grid2 size={{ xs: 12 }}>
                  <RHFAutocomplete
                    name="musicalOrDramatic"
                    label="Musical or Dramatic"
                    placeholder="Select type"
                    options={MUSICAL_OR_DRAMATIC_OPTIONS}
                    slotProps={{
                      textfield: { fullWidth: true }
                    }}
                  />
                </Grid2>
              )}

              {showTier && (
                <Grid2 size={{ xs: 12 }}>
                  <RHFAutocomplete
                    name="tier"
                    label="Tier"
                    placeholder="Select tier"
                    options={TIER_OPTIONS}
                    slotProps={{
                      textfield: { fullWidth: true }
                    }}
                  />
                </Grid2>
              )}

              {showAEAFields && (
                <>
                  <Grid2 size={{ xs: 12 }}>
                    <RHFTextField
                      key="aeaEmployerId"
                      name="aeaEmployerId"
                      label="AEA Employer ID"
                    />
                  </Grid2>
                  <Grid2 size={{ xs: 12 }}>
                    <RHFTextField
                      key="aeaProductionTitle"
                      name="aeaProductionTitle"
                      label="AEA Production Title"
                    />
                  </Grid2>
                  <Grid2 size={{ xs: 12 }}>
                    <RHFTextField
                      key="aeaBusinessRep"
                      name="aeaBusinessRep"
                      label="AEA Business Representative"
                    />
                  </Grid2>
                </>
              )}

              <Grid2 size={{ xs: 12 }}>
                <Box sx={{ display: 'flex', justifyContent: 'flex-end', mt: 2 }}>
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

export { UnionConfiguration };
export default UnionConfiguration;