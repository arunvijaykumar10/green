import { Box, Typography } from '@mui/material';

export const ViewField = ({ label, value }: { label: string; value: any }) => (
  <Box sx={{ mb: 2 }}>
    <Typography variant="body2" color="text.secondary" sx={{ mb: 0.5 }}>
      {label}
    </Typography>
    <Typography variant="body1">{value || 'Not provided'}</Typography>
  </Box>
);
