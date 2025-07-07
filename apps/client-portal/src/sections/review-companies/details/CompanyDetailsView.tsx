import React from 'react';

import { Grid2, Stack, Alert, Skeleton } from '@mui/material';

import { BankConfig } from './BankConfig';
import { AddressInfo } from './AddressInfo';
import { UnionConfig } from './UnionConfig';
import { CompanyHeader } from './CompanyHeader';
import { PayrollConfig } from './PayrollConfig';
import { ReviewActions } from './ReviewActions';
import { SignaturesCard } from './SignaturesCard';
import { useReviewDetails } from './useReviewDetails';
import { ReviewStatusBanner } from './ReviewStatusBanner';
import { CompanyDetailsToolbar } from './CompanyDetailsToolbar';

const CompanyDetailsView = () => {
  const { company, isLoading, status, currentAddress } = useReviewDetails();

  if (isLoading) {
    return (
      <Stack spacing={3} m={3}>
        <Skeleton variant="rectangular" height={60} />
        <Grid2 container spacing={3}>
          {[...Array(6)].map((_var, index) => (
            <Grid2 size={{ xs: 12, md: 6 }} key={index}>
              <Skeleton variant="rectangular" height={200} />
            </Grid2>
          ))}
        </Grid2>
      </Stack>
    );
  }

  if (!company) {
    return (
      <Stack spacing={3} m={3}>
        <Alert severity="error" sx={{ mb: 3 }}>
          Company not found. Please check the company ID and try again.
        </Alert>
      </Stack>
    );
  }

  return (
    <Stack sx={{ p: 3, maxWidth: '1400px', mx: 'auto' }}>
      <CompanyDetailsToolbar name={company.name || ''} status={status} />

      <Grid2 container spacing={3}>
        <Grid2 size={{ xs: 12 }}>
          <CompanyHeader company={company} status={status} />
        </Grid2>

        <Grid2 size={{ xs: 12, lg: 6 }}>
          <AddressInfo address={currentAddress} />
        </Grid2>

        <Grid2 size={{ xs: 12, lg: 6 }}>
          <SignaturesCard
            signatureType={company.signature_type}
            signatureUrl={company.signature_url}
            secondarySignatureUrl={company.secondary_signature_url}
          />
        </Grid2>

        <Grid2 size={{ xs: 12, md: 6, lg: 4 }}>
          <BankConfig bankConfig={company.bank_config} status={status} />
        </Grid2>

        <Grid2 size={{ xs: 12, md: 6, lg: 4 }}>
          <UnionConfig unionConfig={company.union_config} />
        </Grid2>

        <Grid2 size={{ xs: 12, md: 6, lg: 4 }}>
          <PayrollConfig payrollConfig={company?.payroll_config} status={status} />
        </Grid2>

        <Grid2 size={{ xs: 12 }}>
          {status === 'pending' ? (
            <ReviewActions />
          ) : (
            <ReviewStatusBanner status={status} updatedAt={company.updated_at} />
          )}
        </Grid2>
      </Grid2>
    </Stack>
  );
};

export default CompanyDetailsView;
