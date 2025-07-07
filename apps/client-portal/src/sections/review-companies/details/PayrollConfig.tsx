import _ from 'lodash';

import { Box, Card, Chip, Stack, CardHeader, Typography, CardContent } from '@mui/material';

import { Iconify } from 'src/components/iconify';

import { getColor } from './utils';

interface PayrollConfigCardProps {
  payrollConfig?: {
    frequency?: string;
    period?: string;
    check_start_number?: number;
    start_date?: string;
  };
  status: string;
}

export const PayrollConfig = ({ payrollConfig, status }: PayrollConfigCardProps) => (
  <Card elevation={1} sx={{ height: '100%' }}>
    <CardHeader
      avatar={<Iconify icon="mdi:cash-multiple" color="primary.main" width={24} />}
      title="Payroll Setup"
      titleTypographyProps={{ variant: 'h6', fontWeight: 600 }}
      action={
        <Chip
          label={_.startCase(status)}
          color={getColor(status)}
          size="small"
          variant="outlined"
        />
      }
    />
    <CardContent>
      <Stack spacing={2}>
        <Box>
          <Typography variant="caption" color="text.secondary">
            Pay Frequency
          </Typography>
          <Typography variant="body1" sx={{ fontWeight: 500 }}>
            {payrollConfig?.frequency || 'Not configured'}
          </Typography>
        </Box>
        <Box>
          <Typography variant="caption" color="text.secondary">
            Pay Period
          </Typography>
          <Typography variant="body1" sx={{ fontWeight: 500 }}>
            {payrollConfig?.period || 'Not configured'}
          </Typography>
        </Box>
        <Box>
          <Typography variant="caption" color="text.secondary">
            Payroll Start Date
          </Typography>
          <Typography variant="body1" sx={{ fontWeight: 500 }}>
            {payrollConfig?.start_date || 'Not configured'}
          </Typography>
        </Box>
        <Box>
          <Typography variant="caption" color="text.secondary">
            Check Start Number
          </Typography>
          <Typography variant="body1" sx={{ fontWeight: 500, fontFamily: 'monospace' }}>
            #{payrollConfig?.check_start_number || 'N/A'}
          </Typography>
        </Box>
      </Stack>
    </CardContent>
  </Card>
);
