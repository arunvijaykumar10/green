import { useState, useEffect, useCallback } from 'react';

import { Box, Card, Stack, Alert, Typography, CardContent } from '@mui/material';

import { useRouter } from 'src/routes/hooks';

import { useRegisterMutation } from 'src/pages/auth/api';

import { toast } from 'src/components/snackbar';

import { SimplifiedRegistrationForm } from './components';

const STORAGE_KEY = 'registration_data';

const removeLocalStorageItems = () => {
  localStorage.removeItem(STORAGE_KEY);
  localStorage.removeItem('registration_form_values');
  localStorage.removeItem('registration_user_verified');
  localStorage.removeItem('registration_otp_verified');
};

export default function SignUpView() {
  const [formData, setFormData] = useState<any>(() => {
    const savedData = localStorage.getItem(STORAGE_KEY);
    return savedData ? JSON.parse(savedData) : {};
  });

  const [registrationError, setRegistrationError] = useState<string | null>(null);
  const [register, registrationResult] = useRegisterMutation();

  useEffect(() => {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(formData));
  }, [formData]);

  const router = useRouter();

  const handleSubmit = useCallback(
    async (formValues: any) => {
      try {
        const registrationData = {
          company: {
            name: formValues.entity_name,
            company_type: formValues.entity_type,
          },
          user_profile: {
            first_name: formValues.first_name,
            last_name: formValues.last_name,
            email: formValues.email_address,
          },
          role: {
            id: formValues.roles?.id,
          }
        };

        setFormData(registrationData);
        await register(registrationData);
      } catch (error) {
        console.error('Registration error:', error);
        setRegistrationError(
          error instanceof Error ? error.message : 'An error occurred during registration'
        );
      }
    },
    [register]
  );

  useEffect(() => {
    if (registrationResult.isSuccess) {
      removeLocalStorageItems();
      toast.success('Registration successful! Please sign in.');

      router.push('/auth/sign-in');
    } else if (registrationResult.isError) {
      toast.error('Registration failed. Please try again.');
    }
  });

  return (
    <Box
      sx={{
        minHeight: '100vh',
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
        bgcolor: 'background.default',
        py: 5,
      }}
    >
      <Card sx={{ width: '100%', maxWidth: 800 }}>
        <CardContent>
          <Stack spacing={4}>
            <Typography
              variant="h4"
              textAlign="center"
              fontWeight="bold"
              color="primary"
              gutterBottom
            >
              Registration
            </Typography>

            {registrationError && (
              <Alert severity="error" onClose={() => setRegistrationError(null)}>
                {registrationError}
              </Alert>
            )}

            <SimplifiedRegistrationForm onSubmit={handleSubmit} formData={formData} />
          </Stack>
        </CardContent>
      </Card>
    </Box>
  );
}
