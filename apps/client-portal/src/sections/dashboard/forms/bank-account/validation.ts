import { z } from 'zod';

export const bankAccountSchema = z
  .object({
    bankName: z.string().min(1, 'Bank Name is required'),
    routing_number_ach: z
      .union([z.string(), z.number()])
      .refine(Boolean, { message: 'Routing Number ACH is required' })
      .refine((val) => /^\d{9}$/.test(String(val)), {
        message: 'Routing Number ACH must be 9 digits',
      }),
    routing_number_wire: z
      .union([z.string(), z.number()])
      .refine(Boolean, { message: 'Routing Number Wire is required' })
      .refine((val) => /^\d{9}$/.test(String(val)), {
        message: 'Routing Number Wire must be 9 digits',
      }),
    accountNumber: z
      .union([z.string(), z.number()])
      .refine(Boolean, { message: 'Account Number is required' })
      .refine((val) => /^\d+$/.test(String(val)), {
        message: 'Account Number must contain only digits',
      }),
    confirmAccountNumber: z
      .union([z.string(), z.number()])
      .refine(Boolean, { message: 'Please confirm Account Number' })
      .refine((val) => /^\d+$/.test(String(val)), {
        message: 'Confirm Account Number must contain only digits',
      }),
    accountType: z.string().min(1, 'Account Type is required'),
    authorize: z.boolean().refine((val) => val === true, {
      message: 'You must authorize to proceed',
    }),
  })
  .superRefine(({ accountNumber, confirmAccountNumber }, ctx) => {
    if (String(accountNumber) !== String(confirmAccountNumber)) {
      ctx.addIssue({
        code: 'custom',
        path: ['confirmAccountNumber'],
        message: 'Account numbers do not match',
      });
    }
  });
