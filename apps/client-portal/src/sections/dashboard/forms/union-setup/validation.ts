import { z } from 'zod';

export const unionSetupSchema = z.object({
  unionStatus: z.enum(['Union', 'Non-Union']),
  union: z.string().optional(),
  agreementType: z.any().optional(),
  musicalOrDramatic: z.string().optional(),
  tier: z.string().optional(),
  aeaEmployerId: z.string().optional(),
  aeaProductionTitle: z.string().optional(),
  aeaBusinessRep: z.string().optional(),
}).refine((data) => {
  if (data.unionStatus === 'Union') {
    return data.union && data.agreementType;
  }
  return true;
}, 'Union details are required when Union is selected');