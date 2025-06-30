import { useState, useEffect } from 'react';

import { styled } from '@mui/material/styles';
import {
  Box,
  Step,
  Card,
  Grid,
  Paper,
  Stack,
  alpha,
  Button,
  Stepper,
  Container,
  StepLabel,
  Typography,
  StepConnector,
  LinearProgress,
  stepConnectorClasses
} from "@mui/material";

import { useDispatch } from 'src/redux/store';
import { resetFormData } from 'src/redux/slice/formData';
import { useCompany, useGetReviewStatusQuery } from 'src/pages/companies/api';

import { useAuthContext } from 'src/auth/hooks';

import SendToReview from './SendToReview';
import SignatureSetup from './SignatureSetup';
import BankSetup from './bankconfig/BankSetup';
import PayrollAndTaxes from './PayrollAndTaxes';
import { Iconify } from '../../components/iconify';
import CompanyInformation from './company/CompanyInformation';
import UnionConfiguration from './unionconfig/UnionConfiguration';

// Custom connector with line connecting steps
const ColorlibConnector = styled(StepConnector)(({ theme }) => ({
  [`&.${stepConnectorClasses.alternativeLabel}`]: {
    top: 22,
  },
  [`&.${stepConnectorClasses.active}`]: {
    [`& .${stepConnectorClasses.line}`]: {
      backgroundImage: `linear-gradient(to right, ${theme.palette.primary.main} 0%, ${theme.palette.primary.light} 100%)`,
    },
  },
  [`&.${stepConnectorClasses.completed}`]: {
    [`& .${stepConnectorClasses.line}`]: {
      backgroundImage: `linear-gradient(to right, ${theme.palette.primary.main} 0%, ${theme.palette.primary.light} 100%)`,
    },
  },
  [`& .${stepConnectorClasses.line}`]: {
    height: 4,
    border: 0,
    backgroundColor: theme.palette.mode === 'dark' ? theme.palette.grey[800] : alpha(theme.palette.grey[500], 0.2),
    borderRadius: 4,
  },
}));

// Custom step icon
const ColorlibStepIconRoot = styled('div')<{
  ownerState: { completed?: boolean; active?: boolean };
}>(({ theme, ownerState }) => ({
  backgroundColor: theme.palette.mode === 'dark' ? theme.palette.grey[700] : alpha(theme.palette.grey[500], 0.2),
  zIndex: 1,
  color: theme.palette.text.secondary,
  width: 48,
  height: 48,
  display: 'flex',
  borderRadius: '50%',
  justifyContent: 'center',
  alignItems: 'center',
  transition: theme.transitions.create(['background-color', 'box-shadow', 'color']),
  ...(ownerState.active && {
    color: theme.palette.common.white,
    backgroundImage: `linear-gradient(135deg, ${theme.palette.primary.main} 0%, ${theme.palette.primary.dark} 100%)`,
    boxShadow: `0 8px 16px 0 ${alpha(theme.palette.primary.main, 0.24)}`,
  }),
  ...(ownerState.completed && {
    color: theme.palette.common.white,
    backgroundImage: `linear-gradient(135deg, ${theme.palette.primary.main} 0%, ${theme.palette.primary.dark} 100%)`,
  }),
}));

function ColorlibStepIcon(props: any) {
  const { active, completed, className, icon } = props;

  const icons: { [index: string]: React.ReactElement } = {
    1: <Iconify icon="mdi:office-building" width={24} />,
    2: <Iconify icon="mdi:account-group" width={24} />,
    3: <Iconify icon="mdi:bank" width={24} />,
    4: <Iconify icon="mdi:signature" width={24} />,
    5: <Iconify icon="mdi:cash-register" width={24} />,
    6: <Iconify icon="mdi:file-document-check" width={24} />,
    7: <Iconify icon="mdi:chart-bar" width={24} />,
    8: <Iconify icon="mdi:account-plus" width={24} />,
  };

  return (
    <ColorlibStepIconRoot ownerState={{ completed, active }} className={className}>
      {icons[String(icon)]}
    </ColorlibStepIconRoot>
  );
}

// Styled component for step content wrapper
const StepContentWrapper = styled(Box)(({ theme }) => ({
  padding: theme.spacing(3),
  marginTop: theme.spacing(2),
  marginBottom: theme.spacing(2),
  borderRadius: theme.shape.borderRadius * 2,
  backgroundColor: theme.palette.background.neutral,
  transition: theme.transitions.create('opacity'),
}));

function Dashboard() {
  const dispatch = useDispatch();
  const [activeStep, setActiveStep] = useState(0);
  const [completed, setCompleted] = useState<{[k: number]: boolean}>({});
  const [isInitialized, setIsInitialized] = useState(false);
  
  const { user } = useAuthContext();
  const currentCompanyId = user?.last_accessed_company?.id;
  const { company } = useCompany(currentCompanyId);
  const { data: reviewStatus } = useGetReviewStatusQuery(currentCompanyId!, {
    skip: !currentCompanyId
  });
  
  const isPending = reviewStatus?.data?.review_status?.status === 'pending';
  
  // Check if company information is complete
  const isCompanyInfoComplete = () => !!(company && 
           company.name && 
           company.company_type && 
           company.fein && 
           company.phone && 
           company.addresses?.[0]?.address_line_1 && 
           company.addresses?.[0]?.city && 
           company.addresses?.[0]?.state && 
           company.addresses?.[0]?.zip_code);
  
  // Check if union configuration is complete
  const isUnionConfigComplete = () => !!(company?.union_config && 
           company.union_config.union_type && 
           company.union_config.union_name && 
           company.union_config.agreement_type);
  
  // Check if bank setup is complete
  const isBankSetupComplete = () => !!(company?.bank_config && 
           company.bank_config.bank_name && 
           company.bank_config.routing_number_ach && 
           company.bank_config.account_number && 
           company.bank_config.account_type);
  
  // Check if signature setup is complete
  const isSignatureSetupComplete = () => !!(company?.signature_url && company?.signature_type);
  
  // Check if payroll setup is complete
  const isPayrollSetupComplete = () => !!(company?.payroll_config && 
           company.payroll_config.frequency && 
           company.payroll_config.period && 
           company.payroll_config.start_date);
  
  // Mark steps as completed based on company data and set initial active step
  useEffect(() => {
    if (!company) return;
    
    const newCompleted = { ...completed };
    const completionChecks = [
      isCompanyInfoComplete(),
      isUnionConfigComplete(),
      isBankSetupComplete(),
      isSignatureSetupComplete(),
      isPayrollSetupComplete()
    ];

    completionChecks.forEach((isComplete, index) => {
      if (isComplete) newCompleted[index] = true;
    });

    // Only set initial active step once
    if (!isInitialized) {
      const firstIncompleteStep = completionChecks.findIndex(isComplete => !isComplete);
      if (firstIncompleteStep !== -1) {
        setActiveStep(firstIncompleteStep);
      } else if (completionChecks.every(Boolean)) {
        // All steps completed, move to review
        setActiveStep(5);
      }
      setIsInitialized(true);
    }

    setCompleted(newCompleted);
  }, [company, isInitialized]);

  const steps = [
    {
      label: 'Company Information',
      component: <CompanyInformation />
    },
    {
      label: 'Union Configuration',
      component: <UnionConfiguration />
    },
    {
      label: 'Bank Setup',
      component: <BankSetup />
    },
    {
      label: 'Signature Setup',
      component: <SignatureSetup />
    },
    {
      label: 'Payroll & Taxes',
      component: <PayrollAndTaxes />
    },
    {
      label: 'Send to Review',
      component: <SendToReview />
    },
    // {
    //   label: 'Custom Chart of Accounts',
    //   component: <CustomChartOfAccounts />
    // },
    // {
    //   label: 'Invite Admin',
    //   component: <InviteAdmin />
    // }
  ];

  const handleStep = (step: number) => () => undefined;

  const handleNext = () => {
    // Check if current step is completed before moving to next
    let canProceed = false;
    
    switch (activeStep) {
      case 0:
        canProceed = isCompanyInfoComplete();
        break;
      case 1:
        canProceed = isUnionConfigComplete();
        break;
      case 2:
        canProceed = isBankSetupComplete();
        break;
      case 3:
        canProceed = isSignatureSetupComplete();
        break;
      case 4:
        canProceed = isPayrollSetupComplete();
        break;
      default:
        canProceed = true;
    }
    
    if (canProceed) {
      const newCompleted = { ...completed };
      newCompleted[activeStep] = true;
      setCompleted(newCompleted);
      setActiveStep((prevActiveStep) => prevActiveStep + 1);
    } else {
      alert('Please complete all required fields before proceeding to the next step.');
    }
  };

  const handleBack = () => {
    setActiveStep((prevActiveStep) => prevActiveStep - 1);
  };

  const handleReset = () => {
    setActiveStep(0);
    setCompleted({});
    dispatch(resetFormData());
  };

  // Calculate overall progress
  const totalSteps = steps.length - 1; // Exclude "Send to Review" from progress calculation
  const completedSteps = Object.values(completed).filter(Boolean).length;
  const progressPercentage = Math.round((completedSteps / totalSteps) * 100);
  
  // Get greeting based on time of day
  const getGreeting = () => {
    const hour = new Date().getHours();
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  };

  return (
    <Container maxWidth="xl" sx={{ py: { xs: 2, md: 4 } }}>
      {/* Progress Bar */}
      <Card sx={{ p: { xs: 2, md: 4 }, mb: 3, borderRadius: 3, boxShadow: 3 }}>
        <Box sx={{ mb: 4 }}>
          <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
            <Typography variant="h5" color="primary.main" fontWeight={700}>
              {progressPercentage}% Complete
            </Typography>
            <Typography variant="body1" color="text.secondary" fontWeight={500}>
              {completedSteps} of {totalSteps} steps
            </Typography>
          </Box>
          <LinearProgress 
            variant="determinate" 
            value={progressPercentage} 
            sx={{ 
              height: 12, 
              borderRadius: 6,
              backgroundColor: 'grey.200',
              '& .MuiLinearProgress-bar': {
                borderRadius: 6,
                background: 'linear-gradient(90deg, #1976d2 0%, #42a5f5 100%)',
              }
            }} 
          />
        </Box>
        
        {/* Greeting */}
        <Typography variant="h3" sx={{ mb: 2, fontWeight: 600, color: 'text.primary' }}>
          {getGreeting()}, {user?.first_name || 'there'}!
        </Typography>
        <Typography variant="h6" color="text.secondary" sx={{ fontWeight: 400 }}>
          Complete the remaining steps to finish your account setup.
        </Typography>
      </Card>

      {/* Main Content Grid */}
      <Grid container spacing={4}>
        {/* Left Panel - Tasks */}
        <Grid item xs={12} lg={3}>
          <Card sx={{ p: 3, borderRadius: 3, height: 'fit-content', boxShadow: 2 }}>
            <Typography variant="h5" sx={{ mb: 3, fontWeight: 700, color: 'text.primary' }}>
              Quick Tasks
            </Typography>
            <Stack spacing={3}>
              {[
                { label: 'Complete Company Details', completed: isCompanyInfoComplete(), step: 0 },
                { label: 'Setup Unions', completed: isUnionConfigComplete(), step: 1 },
                { label: 'Link Bank Account', completed: isBankSetupComplete(), step: 2 },
                { label: 'Configure Signatures', completed: isSignatureSetupComplete(), step: 3 },
              ].map((task, index) => (
                <Card 
                  key={index}
                  variant="outlined" 
                  sx={{ 
                    p: 3, 
                    cursor: 'pointer',
                    transition: 'all 0.3s ease',
                    '&:hover': { 
                      boxShadow: 4,
                      borderColor: 'primary.main',
                      transform: 'translateY(-2px)'
                    },
                    borderColor: task.completed ? 'success.main' : 'grey.300',
                    borderWidth: 2,
                    borderRadius: 2
                  }}
                  onClick={() => setActiveStep(task.step)}
                >
                  <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                      {task.completed ? (
                        <Iconify icon="eva:checkmark-circle-2-fill" color="success.main" width={24} />
                      ) : (
                        <Iconify icon="eva:clock-outline" color="warning.main" width={24} />
                      )}
                      <Typography variant="body1" fontWeight={600} sx={{ flex: 1 }}>
                        {task.label}
                      </Typography>
                    </Box>
                    <Button 
                      size="medium" 
                      variant={task.completed ? "outlined" : "contained"}
                      fullWidth
                      sx={{ py: 1 }}
                    >
                      {task.completed ? 'Review' : 'Start Setup'}
                    </Button>
                  </Box>
                </Card>
              ))}
            </Stack>
          </Card>
        </Grid>

        {/* Center Panel - Main Form */}
        <Grid item xs={12} lg={6}>
          <Card sx={{ p: { xs: 3, md: 4 }, borderRadius: 3, boxShadow: 2 }}>
            <Stepper
              activeStep={activeStep}
              alternativeLabel
              connector={<ColorlibConnector />}
              sx={{
                py: 4,
                px: { xs: 1, md: 3 },
                overflowX: 'auto',
                '& .MuiStepLabel-label': {
                  mt: 2,
                  fontWeight: 600,
                  fontSize: { xs: '0.75rem', md: '0.875rem' },
                  color: 'text.secondary',
                  '&.Mui-active': {
                    color: 'primary.main',
                    fontWeight: 700,
                  },
                  '&.Mui-completed': {
                    color: 'primary.dark',
                    fontWeight: 600,
                  }
                }
              }}
            >
              {steps.map((step, index) => (
                <Step key={step.label} completed={completed[index]}>
                  <StepLabel
                    StepIconComponent={ColorlibStepIcon}
                    sx={{ cursor: 'default' }}
                  >
                    {step.label}
                  </StepLabel>
                </Step>
              ))}
            </Stepper>

            <Box sx={{ mt: 4, mb: 2 }}>
              {activeStep === steps.length ? (
                <Paper
                  elevation={0}
                  sx={{
                    p: 5,
                    textAlign: 'center',
                    borderRadius: 2,
                    backgroundColor: (theme) => alpha(theme.palette.primary.lighter, 0.2)
                  }}
                >
                  <Iconify
                    icon="eva:checkmark-circle-2-fill"
                    color="success.main"
                    width={80}
                    height={80}
                    sx={{ mb: 3, filter: 'drop-shadow(0 4px 8px rgba(0,0,0,0.16))' }}
                  />
                  <Typography variant="h5" sx={{ mb: 1 }}>All steps completed - you&apos;re finished</Typography>
                  <Typography variant="body2" color="text.secondary" sx={{ mb: 3 }}>
                    Your account setup is complete. You can now start using all features.
                  </Typography>
                  <Button
                    onClick={handleReset}
                    variant="contained"
                    size="large"
                    startIcon={<Iconify icon="eva:refresh-fill" />}
                  >
                    Start Over
                  </Button>
                </Paper>
              ) : (
                <>
                  <StepContentWrapper>
                    {steps[activeStep].component}
                  </StepContentWrapper>

                  <Box sx={{ display: 'flex', flexDirection: 'row', pt: 4, gap: 2 }}>
                    <Button
                      variant="outlined"
                      onClick={handleBack}
                      size="large"
                      sx={{ px: 4, py: 1.5 }}
                      startIcon={<Iconify icon="eva:arrow-back-fill" />}
                    >
                      Back
                    </Button>
                    <Box sx={{ flex: '1 1 auto' }} />
                    <Button
                      onClick={handleNext}
                      variant="contained"
                      size="large"
                      disabled={isPending}
                      sx={{ px: 4, py: 1.5, fontWeight: 600 }}
                      endIcon={<Iconify icon={activeStep === steps.length - 1 ? "eva:checkmark-fill" : "eva:arrow-forward-fill"} />}
                    >
                      {activeStep === steps.length - 1 ? 'Submit for Review' : 'Continue'}
                    </Button>
                  </Box>
                </>
              )}
            </Box>
          </Card>
        </Grid>

        {/* Right Panel - Recommendations */}
        <Grid item xs={12} lg={3}>
          <Card sx={{ p: 3, borderRadius: 3, height: 'fit-content', boxShadow: 2 }}>
            <Typography variant="h5" sx={{ mb: 3, fontWeight: 700, color: 'text.primary' }}>
              Next Steps
            </Typography>
            <Stack spacing={3}>
              {!isBankSetupComplete() && (
                <Box sx={{ p: 3, bgcolor: 'primary.lighter', borderRadius: 2, border: '2px solid', borderColor: 'primary.light' }}>
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mb: 2 }}>
                    <Iconify icon="eva:checkmark-circle-2-outline" color="primary.main" width={20} />
                    <Typography variant="body1" fontWeight={600}>
                      Verify Bank Details
                    </Typography>
                  </Box>
                  <Button 
                    size="medium" 
                    variant="contained" 
                    color="primary"
                    onClick={() => setActiveStep(2)}
                    fullWidth
                    sx={{ textTransform: 'none', py: 1 }}
                  >
                    Review Bank Information
                  </Button>
                </Box>
              )}
              
              {!isSignatureSetupComplete() && (
                <Box sx={{ p: 3, bgcolor: 'warning.lighter', borderRadius: 2, border: '2px solid', borderColor: 'warning.light' }}>
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mb: 2 }}>
                    <Iconify icon="eva:checkmark-circle-2-outline" color="warning.main" width={20} />
                    <Typography variant="body1" fontWeight={600}>
                      Setup Signatures
                    </Typography>
                  </Box>
                  <Button 
                    size="medium" 
                    variant="contained" 
                    color="warning"
                    onClick={() => setActiveStep(3)}
                    fullWidth
                    sx={{ textTransform: 'none', py: 1 }}
                  >
                    Complete Signature Setup
                  </Button>
                </Box>
              )}
              
              {!isPayrollSetupComplete() && (
                <Box sx={{ p: 3, bgcolor: 'info.lighter', borderRadius: 2, border: '2px solid', borderColor: 'info.light' }}>
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mb: 2 }}>
                    <Iconify icon="eva:checkmark-circle-2-outline" color="info.main" width={20} />
                    <Typography variant="body1" fontWeight={600}>
                      Finish Payroll Setup
                    </Typography>
                  </Box>
                  <Button 
                    size="medium" 
                    variant="contained" 
                    color="info"
                    onClick={() => setActiveStep(4)}
                    fullWidth
                    sx={{ textTransform: 'none', py: 1 }}
                  >
                    Complete Payroll Setup
                  </Button>
                </Box>
              )}
              
              {completedSteps === totalSteps && (
                <Box sx={{ p: 3, bgcolor: 'success.lighter', borderRadius: 2, border: '2px solid', borderColor: 'success.light' }}>
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mb: 2 }}>
                    <Iconify icon="eva:checkmark-circle-2-fill" color="success.main" width={20} />
                    <Typography variant="body1" fontWeight={600}>
                      Ready for Review
                    </Typography>
                  </Box>
                  <Button 
                    size="medium" 
                    variant="contained" 
                    color="success"
                    onClick={() => setActiveStep(5)}
                    fullWidth
                    sx={{ textTransform: 'none', py: 1 }}
                  >
                    Send to Review
                  </Button>
                </Box>
              )}
            </Stack>
          </Card>
        </Grid>
      </Grid>
    </Container>
  );
}

export { Dashboard };
export default Dashboard;
