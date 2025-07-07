import { Box, Card, Alert, CardHeader, Typography, CardContent } from '@mui/material';

import { Iconify } from 'src/components/iconify';

interface AddressInfoProps {
  address?: {
    address_line_1: string;
    address_line_2?: string;
    city: string;
    state: string;
    zip_code: string;
    country: string;
  };
}

export const AddressInfo = ({ address }: AddressInfoProps) => (
  <Card elevation={1} sx={{ height: '100%' }}>
    <CardHeader
      avatar={<Iconify icon="mdi:map-marker" color="primary.main" width={24} />}
      title="Address Information"
      titleTypographyProps={{ variant: 'h6', fontWeight: 600 }}
    />
    <CardContent>
      {address ? (
        <Box sx={{ mb: 2 }}>
          <Box sx={{ p: 2, bgcolor: 'grey.50', borderRadius: 1, mb: 2 }}>
            <Typography variant="body1" sx={{ fontWeight: 500 }}>
              {address.address_line_1}
            </Typography>
            {address.address_line_2 && (
              <Typography variant="body1">{address.address_line_2}</Typography>
            )}
            <Typography variant="body1">
              {address.city}, {address.state} {address.zip_code}
            </Typography>
            <Typography variant="body1" color="text.secondary">
              {address.country}
            </Typography>
          </Box>
        </Box>
      ) : (
        <Alert severity="info" sx={{ mb: 2 }}>
          No current address on file
        </Alert>
      )}
    </CardContent>
  </Card>
);
