import React from 'react';
import { useFormContext } from 'react-hook-form';

import { Stack } from '@mui/material';

import { RHFTextField, RHFRadioGroup, RHFAutocomplete } from 'src/components/hook-form';

import { ViewField } from '../ViewField';

const UNION_OPTIONS = [
  { label: 'Non-Union', value: 'Non-Union' },
  { label: 'Union', value: 'Union' },
];

const UNIONS = ["Actor's Equity Association"];

const AGREEMENT_OPTIONS = [
  { label: 'Equity/League Production Contract', value: 'equity_or_league_production_contract' },
  { label: 'Off-Broadway Agreement', value: 'off_broadway_agreement' },
  { label: 'Development Agreement (Work Session)', value: 'development_agreement' },
  { label: '29 Hour Reading', value: '29_hour_reading' },
];

const MUSICAL_OR_DRAMATIC_OPTIONS = ['Musical', 'Dramatic'];
const TIER_OPTIONS = ['Tier 1', 'Tier 2', 'Tier 3'];

interface UnionSetupContentProps {
  isViewMode: boolean;
}

export const UnionSetupContent = ({ isViewMode }: UnionSetupContentProps) => {
  const { watch } = useFormContext();
  const formData = watch();
  const unionStatus = formData.unionStatus;
  const union = formData.union;
  const agreementType = formData.agreementType;

  if (isViewMode) {
    const agreementTypeValue =
      typeof agreementType === 'object' ? agreementType?.value : agreementType;
    return (
      <Stack spacing={2}>
        <ViewField label="Union Status" value={unionStatus} />
        {unionStatus === 'Union' && (
          <>
            <ViewField label="Union" value={union} />
            <ViewField label="Agreement Type" value={agreementTypeValue} />
            {(agreementTypeValue === 'equity_or_league_production_contract' ||
              agreementTypeValue === 'off_broadway_agreement') && (
              <ViewField label="Musical or Dramatic" value={formData.musicalOrDramatic} />
            )}
            {agreementTypeValue === 'development_agreement' && (
              <ViewField label="Tier" value={formData.tier} />
            )}
            {agreementTypeValue !== '29_hour_reading' && (
              <>
                <ViewField label="AEA Employer ID" value={formData.aeaEmployerId} />
                <ViewField label="AEA Production Title" value={formData.aeaProductionTitle} />
                <ViewField label="AEA Business Representative" value={formData.aeaBusinessRep} />
              </>
            )}
          </>
        )}
      </Stack>
    );
  }

  const showUnionField = unionStatus === 'Union';
  const showAgreementField = unionStatus === 'Union' && union === "Actor's Equity Association";
  const agreementTypeValue =
    typeof agreementType === 'object' ? agreementType?.value : agreementType;
  const showMusicalOrDramatic =
    agreementTypeValue === 'equity_or_league_production_contract' ||
    agreementTypeValue === 'off_broadway_agreement';
  const showTier = agreementTypeValue === 'development_agreement';
  const showAEAFields = showAgreementField && agreementTypeValue !== '29_hour_reading';

  return (
    <Stack spacing={3}>
      <RHFRadioGroup
        name="unionStatus"
        label="Is this a union production?"
        options={UNION_OPTIONS}
        row
      />

      {showUnionField && <RHFAutocomplete name="union" label="Union" options={UNIONS} />}

      {showAgreementField && (
        <RHFAutocomplete name="agreementType" label="Agreement Type" options={AGREEMENT_OPTIONS} />
      )}

      {showMusicalOrDramatic && (
        <RHFAutocomplete
          name="musicalOrDramatic"
          label="Musical or Dramatic"
          options={MUSICAL_OR_DRAMATIC_OPTIONS}
        />
      )}

      {showTier && <RHFAutocomplete name="tier" label="Tier" options={TIER_OPTIONS} />}

      {showAEAFields && (
        <>
          <RHFTextField name="aeaEmployerId" label="AEA Employer ID" />
          <RHFTextField name="aeaProductionTitle" label="AEA Production Title" />
          <RHFTextField name="aeaBusinessRep" label="AEA Business Representative" />
        </>
      )}
    </Stack>
  );
};