import { z } from 'zod';

export const companyDetailsSchema = z.object({
  entityName: z.string().min(1, 'Entity name is required'),
  entityType: z.string().min(1, 'Entity type is required'),
  fein: z
    .union([z.string(), z.number()])
    .refine((val) => !!val, { message: 'NYS Unemployment Registration Number is Required' }),
  nysUnemploymentNumber: z
    .union([z.string(), z.number()])
    .refine((val) => !!val, { message: 'FEIN is Required' }),
  phoneNumber: z
    .union([z.string(), z.number()])
    .refine((val) => !!val, { message: 'Phone Number is Required' }),
  addressLine1: z.string().min(1, 'Address is required'),
  addressLine2: z.string().optional(),
  city: z.string().min(1, 'City is required'),
  state: z.string().min(1, 'State is required'),
  zipCode: z
    .union([z.string(), z.number()])
    .refine((val) => !!val, { message: 'Zip Code is Required' }),
  payFrequency: z.string().min(1, 'Pay frequency is required'),
  payPeriod: z.string().min(1, 'Pay period is required'),
  payScheduleStart: z.date(),
  checkNumber: z.number().min(1, 'Check number is required'),
});
