import React, { useState } from 'react';

import {
  Box,
  Grid,
  Button,
  TextField,
  Accordion,
  Typography,
  AccordionSummary,
  AccordionDetails,
} from '@mui/material';

import { Iconify } from 'src/components/iconify';

import { useCompany } from '../companies/hooks';
import { useListCompaniesQuery, useRejectCompanyMutation, useApproveCompanyMutation } from './api';

import type { CompanyReview } from './types';

const ReviewPage: React.FC = () => {
  const [expandedIndex, setExpandedIndex] = useState<number | false>(false);

  const { data: companiesData } = useListCompaniesQuery();
  const [approve] = useApproveCompanyMutation();
  const [reject] = useRejectCompanyMutation();

  const companies = companiesData?.data?.company_reviews || [];

  const handleAccordionChange =
    (index: number) => (event: React.SyntheticEvent, isExpanded: boolean) => {
      setExpandedIndex(isExpanded ? index : false);
    };

  const handleApprove = (companyId: number, notes: string) => {
    approve({ companyId: String(companyId), review_notes: notes }).then(() => {
      setExpandedIndex(false);
    });
  };

  const handleReject = (companyId: number, notes: string) => {
    reject({ companyId: String(companyId), review_notes: notes }).then(() => {
      setExpandedIndex(false);
    });
  };

  return (
    <Box sx={{ p: 4 }}>
      <Typography variant="h4" gutterBottom fontWeight="bold">
        Company Review
      </Typography>
      {companies.map((review: CompanyReview, index: number) => (
        <Accordion
          key={review.id}
          sx={{ mb: 2, borderRadius: 2, boxShadow: 3 }}
          expanded={expandedIndex === index}
          onChange={handleAccordionChange(index)}
        >
          <AccordionSummary
            expandIcon={<Iconify icon="material-symbols:keyboard-arrow-down-rounded" />}
          >
            <Box display="flex" alignItems="center" gap={1}>
              <Typography variant="h6">{review.company.name}</Typography>
              <Typography variant="body2" color="text.secondary">
                ({review.status})
              </Typography>
            </Box>
          </AccordionSummary>
          <AccordionDetails>
            <CompanyDetailsSection companyId={review.company.id} review={review} onApprove={handleApprove} onReject={handleReject} />
          </AccordionDetails>
        </Accordion>
      ))}
    </Box>
  );
};

const CompanyDetailsSection: React.FC<{
  companyId: number;
  review: CompanyReview;
  onApprove: (id: number, notes: string) => void;
  onReject: (id: number, notes: string) => void;
}> = ({ companyId, review, onApprove, onReject }) => {
  const { company } = useCompany(companyId);
  const [expanded, setExpanded] = useState<string | false>(false);
  const [notes, setNotes] = useState('');

  if (!company) {
    return <Typography>Loading company details...</Typography>;
  }

  const handleAccordionChange = (panel: string) => (event: React.SyntheticEvent, isExpanded: boolean) => {
    setExpanded(isExpanded ? panel : false);
  };

  const renderField = (label: string, value?: string | boolean) => {
    if (value === undefined || value === "" || value === null) return null;
    return (
      <Grid item xs={12} sm={6}>
        <Typography variant="body2" color="text.secondary">{label}</Typography>
        <Typography variant="body1">{String(value)}</Typography>
      </Grid>
    );
  };

  const hasCompanyInfo = company.name || company.company_type || company.fein || company.nys_no || company.addresses?.[0] || company.phone;
  const hasUnionConfig = company?.union_config;
  const hasBankConfig = company?.bank_config;
  const hasSignatureConfig = company?.signature_url || company?.secondary_signature_url;
  const hasPayrollConfig = company?.payroll_config;

  return (
    <Box display="flex" flexDirection="column" gap={2}>
      {/* Company Information */}
      {hasCompanyInfo && (
        <Accordion expanded={expanded === 'company'} onChange={handleAccordionChange('company')}>
          <AccordionSummary expandIcon={<Iconify icon="eva:arrow-ios-downward-fill" />}>
            <Typography variant="h6">Company Information</Typography>
          </AccordionSummary>
          <AccordionDetails>
            <Grid container spacing={2}>
              {renderField("Entity Name", company.name)}
              {renderField("Entity Type", company.company_type)}
              {renderField("FEIN", company.fein)}
              {renderField("NYS Unemployment No", company.nys_no)}
              {renderField("Address Line 1", company.addresses?.[0]?.address_line_1)}
              {renderField("Address Line 2", company.addresses?.[0]?.address_line_2)}
              {renderField("City", company.addresses?.[0]?.city)}
              {renderField("State", company.addresses?.[0]?.state)}
              {renderField("Zip Code", company.addresses?.[0]?.zip_code)}
              {renderField("Phone", company.phone)}
              {renderField("Submitted", new Date(review.submitted_at).toLocaleString())}
            </Grid>
          </AccordionDetails>
        </Accordion>
      )}

      {/* Union Configuration */}
      {hasUnionConfig && (
        <Accordion expanded={expanded === 'union'} onChange={handleAccordionChange('union')}>
          <AccordionSummary expandIcon={<Iconify icon="eva:arrow-ios-downward-fill" />}>
            <Typography variant="h6">Union Configuration</Typography>
          </AccordionSummary>
          <AccordionDetails>
            <Grid container spacing={2}>
              {renderField("Union Type", company?.union_config?.union_type)}
              {renderField("Union Name", company?.union_config?.union_name)}
              {renderField("Agreement Type", company?.union_config?.agreement_type)}
              {renderField("Tier", company?.union_config?.agreement_type_configuration?.tier)}
              {renderField("Musical or Dramatic", company?.union_config?.agreement_type_configuration?.musical_or_dramatic)}
              {renderField("Employer ID", company?.union_config?.agreement_type_configuration?.aea_employer_id)}
              {renderField("Production Title", company?.union_config?.agreement_type_configuration?.aea_production_title)}
              {renderField("Business Rep", company?.union_config?.agreement_type_configuration?.aea_business_representative)}
            </Grid>
          </AccordionDetails>
        </Accordion>
      )}

      {/* Bank Account */}
      {hasBankConfig && (
        <Accordion expanded={expanded === 'bank'} onChange={handleAccordionChange('bank')}>
          <AccordionSummary expandIcon={<Iconify icon="eva:arrow-ios-downward-fill" />}>
            <Typography variant="h6">Bank Account</Typography>
          </AccordionSummary>
          <AccordionDetails>
            <Grid container spacing={2}>
              {renderField("Bank Name", company?.bank_config?.bank_name)}
              {renderField("Routing Number (ACH)", company?.bank_config?.routing_number_ach)}
              {renderField("Routing Number (Wire)", company?.bank_config?.routing_number_wire)}
              {renderField("Account Number", company?.bank_config?.account_number)}
              {renderField("Account Type", company?.bank_config?.account_type)}
              {renderField("Authorized Transactions", company?.bank_config?.authorized ? "Yes" : "No")}
            </Grid>
          </AccordionDetails>
        </Accordion>
      )}

      {/* Signature Configuration */}
      {hasSignatureConfig && (
        <Accordion expanded={expanded === 'signature'} onChange={handleAccordionChange('signature')}>
          <AccordionSummary expandIcon={<Iconify icon="eva:arrow-ios-downward-fill" />}>
            <Typography variant="h6">Signature Configuration</Typography>
          </AccordionSummary>
          <AccordionDetails>
            <Grid container spacing={2}>
              {renderField("Signature Policy", company.signature_type)}
              {company.signature_url && (
                <Grid item xs={12}>
                  <Typography variant="body2" color="text.secondary">Primary Signature</Typography>
                  <Box sx={{ mt: 1 }}>
                    <img
                      src={company.signature_url}
                      alt="Primary Signature"
                      style={{ maxWidth: 200, maxHeight: 100, border: '1px solid #ccc' }}
                    />
                  </Box>
                </Grid>
              )}
              {company.secondary_signature_url && (
                <Grid item xs={12}>
                  <Typography variant="body2" color="text.secondary">Secondary Signature</Typography>
                  <Box sx={{ mt: 1 }}>
                    <img
                      src={company.secondary_signature_url}
                      alt="Secondary Signature"
                      style={{ maxWidth: 200, maxHeight: 100, border: '1px solid #ccc' }}
                    />
                  </Box>
                </Grid>
              )}
            </Grid>
          </AccordionDetails>
        </Accordion>
      )}

      {/* Payroll Setup */}
      {hasPayrollConfig && (
        <Accordion expanded={expanded === 'payroll'} onChange={handleAccordionChange('payroll')}>
          <AccordionSummary expandIcon={<Iconify icon="eva:arrow-ios-downward-fill" />}>
            <Typography variant="h6">Payroll Setup</Typography>
          </AccordionSummary>
          <AccordionDetails>
            <Grid container spacing={2}>
              {renderField("Pay Frequency", company?.payroll_config?.frequency)}
              {renderField("Pay Period", company?.payroll_config?.period)}
              {renderField("Schedule Start", company?.payroll_config?.start_date)}
              {renderField("Check Start Number", company?.payroll_config?.check_start_number?.toString())}
            </Grid>
          </AccordionDetails>
        </Accordion>
      )}


      <Box display="flex" alignItems="flex-end" gap={2} sx={{ mt: 3, justifyContent: 'flex-start' }}>
        <TextField
          label="Notes"
          multiline
          rows={2}
          value={notes}
          onChange={(e) => setNotes(e.target.value)}
          placeholder="Add rejection notes..."
          size="small"
          sx={{ flexGrow: 1, maxWidth: 600 }}
        />
        <Button
          variant="contained"
          color="error"
          onClick={() => onReject(review.id, notes)}
          sx={{ minWidth: 120, boxShadow: 2, '&:hover': { backgroundColor: 'error.dark' } }}
        >
          Reject
        </Button>
        <Button
          variant="contained"
          color="success"
          onClick={() => onApprove(review.id, notes)}
          sx={{ minWidth: 120, boxShadow: 2, '&:hover': { backgroundColor: 'success.dark' } }}
        >
          Approve
        </Button>
      </Box>
    </Box>
  );
};

export default ReviewPage;
