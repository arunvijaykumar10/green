import { z } from 'zod';

export const signatureSchema = z
  .object({
    signature_policy: z.enum(['single', 'double']),
    signature: z.any().optional(),
    primary_signature: z.any().optional(),
    secondary_signature_type: z.string().optional(),
    secondary_signature: z.any().optional(),
  })
  .refine((data) => {
    if (data.signature_policy === 'single') {
      return data.signature;
    }
    if (data.signature_policy === 'double') {
      return (
        data.primary_signature &&
        (data.secondary_signature_type === 'upload' ? data.secondary_signature : true)
      );
    }
    return false;
  }, 'Signature files are required');
