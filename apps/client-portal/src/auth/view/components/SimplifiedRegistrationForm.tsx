import _ from 'lodash';
import * as z from 'zod';
import { useForm } from 'react-hook-form';
import { useBoolean } from 'minimal-shared/hooks';
import { zodResolver } from '@hookform/resolvers/zod';
import React, { useState, useEffect, useCallback } from 'react';

import LoadingButton from '@mui/lab/LoadingButton';
import { Box, Stack, Alert, IconButton, Typography, InputAdornment } from '@mui/material';

import { useRouter } from 'src/routes/hooks';

import { EmailInboxIcon } from 'src/assets/icons';
import { useRolesQuery } from 'src/pages/auth/api';

import { Iconify } from 'src/components/iconify';
import { Scrollbar } from 'src/components/scrollbar';
import { Form, Field, RHFCheckbox, RHFTextField, RHFAutocomplete } from 'src/components/hook-form';

import { FormHead } from 'src/auth/components/form-head';
import { signUp, confirmSignUp } from 'src/auth/context';


interface Roles {
  id: number;
  name: string;
  category: string;
  role_type: string;
}

export type RoleType = {
  id: number;
  label: string;
  value: string;
}[];

// Types
interface FormValues {
  entity_name: string;
  entity_type: string;
  first_name: string;
  middle_name: string;
  last_name: string;
  roles: Roles;
  email_address: string;
  password: string;
  confirm_password: string;
  terms_and_conditions: boolean;
  privacy_policy: boolean;
  code: string;
}

interface FormProps {
  onSubmit: (data: FormValues) => Promise<void>;
  formData?: {
    companyInfo?: {
      entity_name?: string;
      entity_type?: string;
    };
    userInfo?: {
      first_name?: string;
      middle_name?: string;
      last_name?: string;
      email_address?: string;
    };
  };
}

// Constants
const ENTITY_TYPES = ['Corp', 'Partnership', 'Sole Proprietor', 'Non Profit', 'Single-member LLC'];
const PASSWORD_REGEX = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$/;
const STORAGE_KEYS = {
  FORM_VALUES: 'registration_form_values',
  USER_VERIFIED: 'registration_user_verified',
  OTP_VERIFIED: 'registration_otp_verified',
};

// Validation schema
const registrationSchema = z
  .object({
    entity_name: z.string().min(1, 'Entity name is required'),
    entity_type: z.string().min(1, 'Entity type is required'),
    first_name: z.string().min(1, 'First name is required'),
    middle_name: z.string().min(1, 'Middle name is required'),
    last_name: z.string().min(1, 'Last name is required'),
    email_address: z.string().email('Invalid email address'),
    password: z.string().regex(PASSWORD_REGEX, {
      message:
        'Password must be at least 8 characters and include uppercase, lowercase, number, and special character',
    }),
    confirm_password: z.string().min(6, 'Confirm password must match your password'),
    terms_and_conditions: z.boolean().refine((val) => val === true, {
      message: 'You must accept the terms of service',
    }),
    privacy_policy: z.boolean().refine((val) => val === true, {
      message: 'You must accept the privacy policy',
    }),
  })
  .refine((data) => data.password === data.confirm_password, {
    message: 'Passwords do not match!',
    path: ['confirm_password'],
  });

// Custom hooks
const useLocalStorage = <T,>(key: string, initialValue: T) => {
  const [value, setValue] = useState<T>(() => {
    const saved = localStorage.getItem(key);
    return saved ? JSON.parse(saved) : initialValue;
  });

  useEffect(() => {
    localStorage.setItem(key, JSON.stringify(value));
  }, [key, value]);

  return [value, setValue] as const;
};

const useRegistrationForm = (formData?: FormProps['formData']) => {
  const [isUserVerified, setIsUserVerified] = useLocalStorage(STORAGE_KEYS.USER_VERIFIED, false);
  const [isOtpVerified, setIsOtpVerified] = useLocalStorage(STORAGE_KEYS.OTP_VERIFIED, false);

  const methods = useForm<FormValues>({
    resolver: zodResolver(registrationSchema),
    mode: 'onChange',
    defaultValues: (() => {
      const savedValues = localStorage.getItem(STORAGE_KEYS.FORM_VALUES);
      const parsedValues = savedValues ? JSON.parse(savedValues) : {};

      return {
        entity_name: parsedValues.entity_name || formData?.companyInfo?.entity_name || '',
        entity_type: parsedValues.entity_type || formData?.companyInfo?.entity_type || '',
        first_name: parsedValues.first_name || formData?.userInfo?.first_name || '',
        last_name: parsedValues.last_name || formData?.userInfo?.last_name || '',
        middle_name: parsedValues.middle_name || formData?.userInfo?.middle_name || '',
        email_address: parsedValues.email_address || formData?.userInfo?.email_address || '',
        password: parsedValues.password || '',
        terms_and_conditions: parsedValues.terms_and_conditions || false,
        privacy_policy: parsedValues.privacy_policy || false,
        code: '',
      };
    })(),
  });

  // Save form values to localStorage whenever they change
  useEffect(() => {
    const subscription = methods.watch((formValues) => {
      localStorage.setItem(STORAGE_KEYS.FORM_VALUES, JSON.stringify(formValues));
    });

    return () => subscription.unsubscribe();
  }, [methods]);

  return {
    methods,
    isUserVerified,
    setIsUserVerified,
    isOtpVerified,
    setIsOtpVerified,
  };
};

// Sub-components
const PasswordField = ({ name, label, showPassword }: { name: string; label: string; showPassword: ReturnType<typeof useBoolean> }) => (
  <Field.Text
    name={name}
    label={label}
    required
    type={showPassword.value ? 'text' : 'password'}
    slotProps={{
      input: {
        endAdornment: (
          <InputAdornment position="end">
            <IconButton onClick={showPassword.onToggle} edge="end">
              <Iconify icon={showPassword.value ? 'solar:eye-bold' : 'solar:eye-closed-bold'} />
            </IconButton>
          </InputAdornment>
        ),
      },
    }}
  />
);

const PolicyCheckbox = ({
  name,
  label
}: {
  name: 'terms_and_conditions' | 'privacy_policy';
  label: string;
}) => (
  <Stack
    direction="row"
    sx={{
      display: 'flex',
      width: '100%',
      justifyContent: 'space-between',
      alignItems: 'center',
    }}
  >
    <RHFCheckbox
      name={name}
      label={<Typography variant="body2">{label}</Typography>}
    />
    <IconButton>
      <Iconify icon="mdi-package-down" />
    </IconButton>
  </Stack>
);

const RegistrationFormFields = ({ showPassword, roles }: { showPassword: ReturnType<typeof useBoolean>, roles: RoleType }) => (
  <Stack spacing={3}>
    <Typography variant="h6">Company Information</Typography>
    <RHFTextField name="entity_name" label="Entity Name *" />
    <RHFAutocomplete options={ENTITY_TYPES} name="entity_type" label="Entity Type *" />
    <RHFAutocomplete options={roles} name="roles" label="Role/Title *" />


    <Typography variant="h6" sx={{ mt: 2 }}>
      User Information
    </Typography>
    <Box
      sx={{
        display: 'flex',
        gap: { xs: 3, sm: 2 },
        flexDirection: { xs: 'column', sm: 'row' },
      }}
    >
      <Field.Text name="first_name" label="First name *" />
      <Field.Text name="middle_name" label="Middle name *" />
      <Field.Text name="last_name" label="Last name *" />
    </Box>

    <Field.Text name="email_address" label="Email address *" />

    <PasswordField name="password" label="Password *" showPassword={showPassword} />
    <PasswordField name="confirm_password" label="Confirm Password *" showPassword={showPassword} />

    <PolicyCheckbox name="terms_and_conditions" label="Terms and Conditions" />
    <PolicyCheckbox name="privacy_policy" label="Privacy Policy" />
  </Stack>
);

const OtpVerificationForm = ({
  email,
  onResendCode
}: {
  email: string;
  onResendCode: () => void;
}) => (
  <Stack spacing={3}>
    <FormHead
      icon={<EmailInboxIcon />}
      title="Please check your email!"
      description={`We've emailed a 6-digit confirmation code to ${email}. \nPlease enter the code in the box below to verify your email.`}
    />
    <Field.Code name="code" />
  </Stack>
);

export const SimplifiedRegistrationForm = ({ onSubmit, formData }: FormProps) => {
  const router = useRouter();
  const showPassword = useBoolean();
  const { data: roles } = useRolesQuery()
  const transformedRoles = _.map(roles, role => ({
    id: role.id,
    label: role.name,
    value: role.name
  }));
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  const {
    methods,
    isUserVerified,
    setIsUserVerified,
    isOtpVerified,
    setIsOtpVerified,
  } = useRegistrationForm(formData);


  const handleReturn = () => {
    _.forEach(
      [STORAGE_KEYS.USER_VERIFIED, STORAGE_KEYS.OTP_VERIFIED, STORAGE_KEYS.FORM_VALUES],
      key => localStorage.removeItem(key)
    );
    router.push('/auth/sign-in');
  };


  const handleFinalSubmission = useCallback(async () => {
    const formValues = methods.getValues();
    try {
      setIsSubmitting(true);
      setErrorMessage(null);
      await onSubmit(formValues);
    } catch (error) {
      console.error('Error submitting form:', error);
      const errorMsg =
        error instanceof Error ? error.message : 'Failed to submit form. Please try again.';
      setErrorMessage(errorMsg);
    } finally {
      setIsSubmitting(false);
    }
  }, [methods, onSubmit]);


  const handleSignUp = useCallback(async () => {
    if (isOtpVerified && isUserVerified) {
      return await handleFinalSubmission(); // re
    }

    try {
      setIsSubmitting(true);
      setErrorMessage(null);
      const formValues = methods.getValues();

      await signUp({
        username: formValues.email_address,
        password: formValues.password,
        firstName: formValues.first_name,
        lastName: formValues.last_name,
        middleName: formValues.middle_name,
        companyName: formValues.entity_name,
        companyType: formValues.entity_type,
        roleId: formValues.roles.id || 1
      });

      setIsUserVerified(true);
    } catch (error) {
      console.error('Error signing up user:', error);
      const errorMsg =
        error instanceof Error ? error.message : 'Failed to create account. Please try again.';

      try {
        const savedValues = localStorage.getItem(STORAGE_KEYS.FORM_VALUES);
        const parsed = savedValues ? JSON.parse(savedValues) : {};
        const preservedValues = {
          entity_name: parsed.entity_name || '',
          entity_type: parsed.entity_type || '',
        };

        localStorage.setItem(STORAGE_KEYS.FORM_VALUES, JSON.stringify(preservedValues));
        localStorage.removeItem(STORAGE_KEYS.USER_VERIFIED);
        localStorage.removeItem(STORAGE_KEYS.OTP_VERIFIED);
      } catch (e) {
        console.warn('Failed to parse registration_form_values:', e);
      }

      if (errorMsg.includes('already exists')) {
        setErrorMessage('An account with this email already exists.');
      } else if (errorMsg.toLowerCase().includes('password')) {
        methods.setError('password', {
          type: 'manual',
          message: errorMsg,
        });
      } else {
        setErrorMessage(errorMsg);
      }
    } finally {
      setIsSubmitting(false);
    }

    return Promise.resolve();
  }, [methods, isOtpVerified, isUserVerified, handleFinalSubmission, setIsUserVerified]);



  const handleOtpVerification = useCallback(async () => {
    try {
      setIsSubmitting(true);
      setErrorMessage(null);
      const formValues = methods.getValues();

      await confirmSignUp({
        username: formValues.email_address,
        confirmationCode: formValues.code,
      });

      setIsOtpVerified(true);
      handleFinalSubmission();
    } catch (error) {
      console.error('Error verifying OTP:', error);
      const errorMsg =
        error instanceof Error ? error.message : 'Invalid verification code. Please try again.';

      if (errorMsg.includes('expired')) {
        setErrorMessage('Verification code has expired. Please request a new code.');
      } else if (errorMsg.includes('not found') || errorMsg.includes('Invalid verification')) {
        methods.setError('code', {
          type: 'manual',
          message: 'Invalid verification code. Please check and try again.',
        });
      } else {
        methods.setError('code', {
          type: 'manual',
          message: errorMsg,
        });
      }
    } finally {
      setIsSubmitting(false);
    }
  }, [methods, handleFinalSubmission, setIsOtpVerified]);

  const handleResendCode = useCallback(() => {
    const email = methods.getValues().email_address;
    import('src/auth/context').then(({ resendSignUpCode }) => {
      resendSignUpCode({ username: email });
    });
  }, [methods]);

  return (
    <Form methods={methods} onSubmit={methods.handleSubmit(onSubmit)}>
      <Scrollbar>
        <Stack spacing={3} py={3}>
          <RegistrationFormFields showPassword={showPassword} roles={transformedRoles} />

          {errorMessage && (
            <Alert severity="error" onClose={() => setErrorMessage(null)}>
              {errorMessage}
            </Alert>
          )}
          {isUserVerified && !isOtpVerified && (
            <>
              <OtpVerificationForm
                email={methods.getValues().email_address}
                onResendCode={handleResendCode}
              />

              <Stack direction="row" spacing={2} sx={{ mt: 2 }}>
                <LoadingButton
                  fullWidth
                  size="large"
                  variant="outlined"
                  onClick={handleResendCode}
                >
                  Resend Code
                </LoadingButton>

                <LoadingButton
                  fullWidth
                  size="large"
                  variant="contained"
                  loading={isSubmitting}
                  loadingIndicator="Verifying..."
                  onClick={handleOtpVerification}
                  disabled={!methods.watch('code')}
                >
                  Verify
                </LoadingButton>
              </Stack>
            </>
          )}

          <LoadingButton
            fullWidth
            color="primary"
            size="large"
            variant="contained"
            onClick={handleSignUp}
            loading={isSubmitting}
            loadingIndicator="Creating account..."
            disabled={!methods.formState.isValid}
          >
            Register
          </LoadingButton>

          <LoadingButton
            fullWidth
            color="primary"
            size="large"
            variant="contained"
            onClick={handleReturn}
          >
            Back to Login
          </LoadingButton>
        </Stack>
      </Scrollbar>
    </Form>
  );
};

export default SimplifiedRegistrationForm;
