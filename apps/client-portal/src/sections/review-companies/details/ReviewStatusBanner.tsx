import _ from 'lodash';
import dayjs from 'dayjs';

import { Box, Card, Typography, CardContent } from '@mui/material';

import { Iconify } from 'src/components/iconify';

import { getColor } from './utils';

interface ReviewStatusBannerProps {
  status: string;
  updatedAt: string;
}

export const ReviewStatusBanner = ({ status, updatedAt }: ReviewStatusBannerProps) => {
  const color = getColor(status);
  return (
    <Card
      elevation={1}
      sx={{
        bgcolor: `${color}.lighter`,
        border: '1px solid',
        borderColor: `${color}.main`,
      }}
    >
      <CardContent>
        <Box display="flex" alignItems="center" justifyContent="center" gap={2} py={2}>
          <Iconify
            icon={status === 'approved' ? 'mdi:check-circle' : 'mdi:close-circle'}
            color={`${status}.main`}
            width={32}
          />
          <Typography variant="h6" color={`${status}.main`} sx={{ fontWeight: 600 }}>
            Company {_.startCase(status)}
          </Typography>
          <Typography variant="body2" color="text.secondary">
            {status === 'approved' ? 'Approved' : 'Rejected'} on{' '}
            {dayjs(updatedAt).format('MMM DD, YYYY')}
          </Typography>
        </Box>
      </CardContent>
    </Card>
  );
};
