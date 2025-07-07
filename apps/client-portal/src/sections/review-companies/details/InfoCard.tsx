import { Box, Typography } from '@mui/material';

import { Iconify } from 'src/components/iconify';

interface InfoCardProps {
  icon: string;
  label: string;
  value?: string;
}

export const InfoCard = ({ icon, label, value }: InfoCardProps) => (
  <Box
    sx={{
      flex: 1,
      minWidth: 200,
      textAlign: 'center',
      p: 2,
      bgcolor: 'rgba(255,255,255,0.1)',
      borderRadius: 2,
    }}
  >
    <Iconify icon={icon} width={24} sx={{ mb: 1 }} />
    <Typography variant="caption" display="block" sx={{ opacity: 0.8 }}>
      {label}
    </Typography>
    <Typography variant="h6" sx={{ fontWeight: 600 }}>
      {value || 'N/A'}
    </Typography>
  </Box>
);
