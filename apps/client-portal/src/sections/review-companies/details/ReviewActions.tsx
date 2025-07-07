import { z } from 'zod';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';

import { Box, Card, Button, CardContent } from '@mui/material';

import { Iconify } from 'src/components/iconify';
import { Form, RHFTextField } from 'src/components/hook-form';

import { useReviewDetails } from './useReviewDetails';

const schema = z.object({
  notes: z.string().optional(),
});

export const ReviewActions = () => {
  const { handleApprove, handleReject } = useReviewDetails();

  const formMethods = useForm({
    resolver: zodResolver(schema),
    defaultValues: { notes: '' },
  });

  const notesValue = formMethods.watch('notes');

  // Clear error when notes has value
  if (notesValue?.trim() && formMethods.formState.errors.notes) {
    formMethods.clearErrors('notes');
  }

  const handleSubmitReview = (action: 'approve' | 'reject') => {
    const notes = formMethods.getValues('notes') || '';

    if (action === 'reject' && !notes.trim()) {
      formMethods.setError('notes', { message: 'Notes are required for rejection' });
      return;
    }

    if (action === 'approve') {
      handleApprove(notes);
    } else {
      handleReject(notes);
    }
  };

  return (
    <Form methods={formMethods}>
      <Card elevation={1}>
        <CardContent>
          <Box
            display="flex"
            justifyContent="space-between"
            alignItems="center"
            flexWrap="wrap"
            gap={2}
          >
            <RHFTextField name="notes" label="Notes" />
            <Box display="flex" gap={2}>
              <Button
                variant="contained"
                color="error"
                startIcon={<Iconify icon="mdi:close-circle" />}
                sx={{ minWidth: 140 }}
                onClick={() => handleSubmitReview('reject')}
              >
                Reject
              </Button>
              <Button
                variant="contained"
                color="success"
                startIcon={<Iconify icon="mdi:check-circle" />}
                sx={{ minWidth: 140 }}
                onClick={() => handleSubmitReview('approve')}
              >
                Approve
              </Button>
            </Box>
          </Box>
        </CardContent>
      </Card>
    </Form>
  );
};
