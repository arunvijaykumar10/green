import { z } from 'zod';

const payrollSchema = z.object({
  pay_frequency: z.string().min(1, 'Pay frequency is required'),
  pay_period: z.string().min(1, 'Pay period is required'),
  payroll_start_date: z.string().min(1, 'Start date is required'),
  check_number: z.union([z.string(), z.number()]).refine((val) => Number(val), { message: 'Check number must be a number' }),
});

const companyInfoSchema = z.object({
  entity_name: z.string().min(1, 'Entity Name is required'),
  entity_type: z.string().min(1, 'Entity Type is required'),
  fein: z
    .string()
    .optional()
    .refine((val) => !val || /^\d+$/.test(val), { message: 'FEIN must be a number' }),
  address_line_1: z.string().optional(),
  address_line_2: z.string().optional(),
  city: z.string().optional(),
  state: z.string().optional(),
  zip_code: z.string().optional(),
  phone_number: z.string().optional(),
  nys_unemployment_registration_number: z
    .string()
    .optional()
    .refine((val) => !val || /^\d+$/.test(val), { message: 'NYS must be a number' }),
});

const userDetailsSchema = z.object({
  first_name: z.string().min(1, 'First name is required'),
  last_name: z.string().min(1, 'Last name is required'),
  middle_name: z.string().min(1, 'Middle name is required'),
  email_address: z.string().email('Invalid email address'),
  role_title: z.string().optional(),
  password: z.string().min(6, 'Password must be at least 6 characters'),
});

const summarySchema = z.object({
  terms_service: z.boolean().refine((val) => val === true, { message: 'You must accept the Terms of Service' }),
  privacy_policy: z.boolean().refine((val) => val === true, { message: 'You must accept the Privacy Policy' }),
  data_processing_agreement: z.boolean().refine((val) => val === true, { message: 'You must accept the Data Processing Agreement' }),
});

const makeRegisterValidation = (activeStep: number) => {
  if (activeStep === 0) {
    return companyInfoSchema;
  } else if (activeStep === 1) {
    return userDetailsSchema;
  } else if (activeStep === 2) {
    return payrollSchema;
  } else if (activeStep === 3) {
    return summarySchema;
  } else {
    return z.object({});
  }
};

export default makeRegisterValidation;