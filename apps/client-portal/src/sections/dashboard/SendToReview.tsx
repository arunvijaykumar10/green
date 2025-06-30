import React, { useState } from 'react';
import { keyframes } from '@emotion/react';

import {
  Box,
  Card,
  Chip,
  Zoom,
  Grow,
  Grid2,
  Alert,
  Paper,
  Button,
  Dialog,
  Avatar,
  Accordion,
  Typography,
  DialogTitle,
  DialogContent,
  AccordionSummary,
  AccordionDetails,
  DialogContentText
} from '@mui/material';

import { useCompany, useGetReviewStatusQuery, useSubmitForReviewMutation } from 'src/pages/companies/api';

import { Iconify } from 'src/components/iconify';

import { useAuthContext } from 'src/auth/hooks';

const renderField = (label: string, value?: string | boolean) => (
  <Grid2 size={{ xs: 12, sm: 6 }}>
    <Typography variant="body2" color="text.secondary">
      {label}
    </Typography>
    <Typography variant="body1">
      {value !== undefined && value !== "" ? String(value) : "-"}
    </Typography>
  </Grid2>
);

// Define animations
const pulse = keyframes`
  0% { transform: scale(1); }
  50% { transform: scale(1.05); }
  100% { transform: scale(1); }
`;

const fadeIn = keyframes`
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
`;

const spin = keyframes`
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
`;

export default function SendToReview() {
  const [openDialog, setOpenDialog] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [expanded, setExpanded] = useState<string | false>(false);

  const { user } = useAuthContext();
  const currentCompanyId = user?.last_accessed_company?.id;
  const { company } = useCompany(currentCompanyId);
  const [submitForReview] = useSubmitForReviewMutation();
  const { data: reviewStatus } = useGetReviewStatusQuery(currentCompanyId!, {
    skip: !currentCompanyId
  });

  const hasCompanyInfo = !!company;
  const hasUnionConfig = !!company?.union_config;
  const hasBankSetup = !!company?.bank_config;
  const hasSignatureSetup = !!(company?.signature_url || company?.secondary_signature_url);
  const hasPayrollSetup = !!company?.payroll_config;

  const handleSendReview = async () => {
    if (!currentCompanyId) return;

    setIsSubmitting(true);

    try {
      await submitForReview(currentCompanyId).unwrap();
      setOpenDialog(true);

      // Close dialog automatically after 5 seconds
      setTimeout(() => {
        setOpenDialog(false);
      }, 5000);
    } catch (error) {
      console.error('Failed to submit for review:', error);
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleCloseDialog = () => {
    setOpenDialog(false);
  };

  const handleAccordionChange = (panel: string) => (event: React.SyntheticEvent, isExpanded: boolean) => {
    setExpanded(isExpanded ? panel : false);
  };

  const getStatusColor = (status: string) => {
    switch (status?.toLowerCase()) {
      case 'approved':
        return 'success';
      case 'rejected':
        return 'error';
      case 'pending':
      case 'in_review':
        return 'warning';
      default:
        return 'default';
    }
  };

  const status = reviewStatus?.data?.review_status?.status;

  return (
    <Card sx={{ maxWidth: 900, margin: 'auto', p: 2 }}>
      <Box sx={{ p: 3, pb: 1, display: 'flex', justifyContent: 'flex-end' }}>
        {status && (
          <Chip
            label={status.replace('_', '-').toUpperCase()}
            color={getStatusColor(status) as any}
            variant="filled"
          />
        )}
      </Box>

      {(!hasCompanyInfo && !hasUnionConfig && !hasBankSetup && !hasSignatureSetup && !hasPayrollSetup) && (
        <Alert severity="info" sx={{ mx: 3, mb: 3 }}>
          No information has been saved yet. Please complete the previous steps to see your data here.
        </Alert>
      )}

      <Box sx={{ p: 3 }}>
        {/* Company Information */}
        {hasCompanyInfo && (
          <Accordion expanded={expanded === 'company'} onChange={handleAccordionChange('company')}>
            <AccordionSummary expandIcon={<Iconify icon="eva:arrow-ios-downward-fill" />}>
              <Typography variant="h6">Company Information</Typography>
            </AccordionSummary>
            <AccordionDetails>
              <Grid2 container spacing={2}>
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
              </Grid2>
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
              <Grid2 container spacing={2}>
                {renderField("Union Type", company?.union_config?.union_type)}
                {renderField("Union Name", company?.union_config?.union_name)}
                {renderField("Agreement Type", company?.union_config?.agreement_type)}
                {renderField("Tier", company?.union_config?.agreement_type_configuration?.tier)}
                {renderField("Musical or Dramatic", company?.union_config?.agreement_type_configuration?.musical_or_dramatic)}
                {renderField("Employer ID", company?.union_config?.agreement_type_configuration?.aea_employer_id)}
                {renderField("Production Title", company?.union_config?.agreement_type_configuration?.aea_production_title)}
                {renderField("Business Rep", company?.union_config?.agreement_type_configuration?.aea_business_representative)}
              </Grid2>
            </AccordionDetails>
          </Accordion>
        )}

        {/* Bank Account */}
        {hasBankSetup && (
          <Accordion expanded={expanded === 'bank'} onChange={handleAccordionChange('bank')}>
            <AccordionSummary expandIcon={<Iconify icon="eva:arrow-ios-downward-fill" />}>
              <Typography variant="h6">Bank Account</Typography>
            </AccordionSummary>
            <AccordionDetails>
              <Grid2 container spacing={2}>
                {renderField("Bank Name", company?.bank_config?.bank_name)}
                {renderField("Routing Number (ACH)", company?.bank_config?.routing_number_ach)}
                {renderField("Routing Number (Wire)", company?.bank_config?.routing_number_wire)}
                {renderField("Account Number", company?.bank_config?.account_number)}
                {renderField("Account Type", company?.bank_config?.account_type)}
                {renderField("Authorized Transactions", company?.bank_config?.authorized ? "Yes" : "No")}
              </Grid2>
            </AccordionDetails>
          </Accordion>
        )}

        {/* Signature Configuration */}
        {hasSignatureSetup && (
          <Accordion expanded={expanded === 'signature'} onChange={handleAccordionChange('signature')}>
            <AccordionSummary expandIcon={<Iconify icon="eva:arrow-ios-downward-fill" />}>
              <Typography variant="h6">Signature Configuration</Typography>
            </AccordionSummary>
            <AccordionDetails>
              <Grid2 container spacing={2}>
                {renderField("Signature Policy", company.signature_type)}

                {company.signature_url && (
                  <Grid2 size={{ xs: 12 }}>
                    <Typography variant="body2" color="text.secondary">
                      Primary Signature
                    </Typography>
                    <Box sx={{ mt: 1 }}>
                      <img
                        src={company.signature_url}
                        alt="Primary Signature"
                        style={{ maxWidth: 200, maxHeight: 100, border: '1px solid #ccc' }}
                      />
                    </Box>
                  </Grid2>
                )}

                {company.secondary_signature_url && (
                  <Grid2 size={{ xs: 12 }}>
                    <Typography variant="body2" color="text.secondary">
                      Secondary Signature
                    </Typography>
                    <Box sx={{ mt: 1 }}>
                      <img
                        src={company.secondary_signature_url}
                        alt="Secondary Signature"
                        style={{ maxWidth: 200, maxHeight: 100, border: '1px solid #ccc' }}
                      />
                    </Box>
                  </Grid2>
                )}
              </Grid2>
            </AccordionDetails>
          </Accordion>
        )}

        {/* Payroll Setup */}
        {hasPayrollSetup && (
          <Accordion expanded={expanded === 'payroll'} onChange={handleAccordionChange('payroll')}>
            <AccordionSummary expandIcon={<Iconify icon="eva:arrow-ios-downward-fill" />}>
              <Typography variant="h6">Payroll Setup</Typography>
            </AccordionSummary>
            <AccordionDetails>
              <Grid2 container spacing={2}>
                {renderField("Pay Frequency", company?.payroll_config?.frequency)}
                {renderField("Pay Period", company?.payroll_config?.period)}
                {renderField("Schedule Start", company?.payroll_config?.start_date)}
                {renderField("Check Start Number", company?.payroll_config?.check_start_number?.toString())}
              </Grid2>
            </AccordionDetails>
          </Accordion>
        )}
      </Box>
      {status !== 'pending' && <Box sx={{ display: 'flex', justifyContent: 'flex-end', p: 2 }}>
        <Button
          variant="contained"
          color="primary"
          onClick={handleSendReview}
          disabled={isSubmitting}
          sx={{
            position: 'relative',
            animation: isSubmitting ? 'none' : `${pulse} 2s infinite ease-in-out`,
            transition: 'all 0.3s',
            '&:hover': {
              transform: 'translateY(-3px)',
              boxShadow: '0 4px 8px rgba(0,0,0,0.2)'
            }
          }}
        >
          {isSubmitting ? 'Sending...' : 'Send Review'}
        </Button>
      </Box>}

      <Dialog
        open={openDialog}
        onClose={handleCloseDialog}
        aria-labelledby="review-dialog-title"
        aria-describedby="review-dialog-description"
        maxWidth="md"
        fullWidth
        TransitionComponent={Zoom}
        transitionDuration={500}
        PaperProps={{
          elevation: 24,
          sx: {
            borderRadius: 2,
            p: 1,
            overflowY: 'visible'
          }
        }}
      >
        <Paper
          elevation={0}
          sx={{
            textAlign: 'center',
            p: 3,
            backgroundColor: 'background.paper',
            borderRadius: 2,
            overflow: 'visible'
          }}
        >
          <Grow in={openDialog} timeout={800}>
            <Avatar
              sx={{
                bgcolor: 'success.main',
                width: 80,
                height: 80,
                mx: 'auto',
                mb: 2,
                animation: `${spin} 1s ease-out`
              }}
            />
          </Grow>

          <DialogTitle
            id="review-dialog-title"
            sx={{
              fontSize: 28,
              fontWeight: 'bold',
              mb: 2,
              animation: `${fadeIn} 0.8s ease-out`,
              animationDelay: '0.3s',
              animationFillMode: 'both'
            }}
          >
            Review Submission Successful
          </DialogTitle>

          <DialogContent sx={{ overflow: 'hidden' }}>
            <DialogContentText
              id="review-dialog-description"
              sx={{ textAlign: 'center' }}
            >
              <Typography
                variant="h6"
                gutterBottom
                sx={{
                  color: 'text.primary',
                  animation: `${fadeIn} 0.8s ease-out`,
                  animationDelay: '0.5s',
                  animationFillMode: 'both'
                }}
              >
                Thank you for your submission!
              </Typography>

              <Typography
                paragraph
                sx={{
                  fontSize: 18,
                  mt: 2,
                  animation: `${fadeIn} 0.8s ease-out`,
                  animationDelay: '0.7s',
                  animationFillMode: 'both'
                }}
              >
                Your review request has been successfully submitted to our team.
              </Typography>

              <Typography
                paragraph
                sx={{
                  fontSize: 20,
                  fontWeight: 'medium',
                  color: 'primary.main',
                  p: 2,
                  border: '1px solid',
                  borderColor: 'primary.light',
                  borderRadius: 1,
                  backgroundColor: 'primary.lighter',
                  mt: 3,
                  animation: `${pulse} 2s infinite ease-in-out`,
                  animationDelay: '1s',
                  animationFillMode: 'both'
                }}
              >
                Please wait for 3 working days for the approval.
              </Typography>

              <Typography
                paragraph
                sx={{
                  animation: `${fadeIn} 0.8s ease-out`,
                  animationDelay: '1.2s',
                  animationFillMode: 'both'
                }}
              >
                Our team will review your information and get back to you as soon as possible.
              </Typography>

              <Typography
                variant="body2"
                color="text.secondary"
                sx={{
                  mt: 3,
                  animation: `${fadeIn} 0.8s ease-out`,
                  animationDelay: '1.5s',
                  animationFillMode: 'both'
                }}
              >
                This window will close automatically in 5 seconds.
              </Typography>
            </DialogContentText>
          </DialogContent>
        </Paper>
      </Dialog>
    </Card>
  );
}