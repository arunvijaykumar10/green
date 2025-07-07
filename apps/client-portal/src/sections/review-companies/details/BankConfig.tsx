import _ from 'lodash';

import {
  Box,
  Card,
  Chip,
  Stack,
  Divider,
  Tooltip,
  CardHeader,
  Typography,
  CardContent,
} from '@mui/material';

import { Iconify } from 'src/components/iconify';

import { getColor } from './utils';

interface BankConfigCardProps {
  bankConfig?: {
    authorized: boolean;
    bank_name?: string;
    account_type?: string;
    account_number?: string;
    routing_number_ach?: string;
    routing_number_wire?: string;
    active?: boolean;
  };
  status: string;
}

export const BankConfig = ({ bankConfig, status }: BankConfigCardProps) => (
  <Card elevation={1} sx={{ height: '100%' }}>
    <CardHeader
      avatar={<Iconify icon="mdi:bank" color="primary.main" width={24} />}
      title="Banking Details"
      titleTypographyProps={{ variant: 'h6', fontWeight: 600 }}
      action={
        <Tooltip
          title={
            bankConfig?.authorized
              ? 'Bank account is authorized'
              : 'Bank account needs authorization'
          }
        >
          <Chip
            label={bankConfig?.authorized ? 'Authorized' : 'Unauthorized'}
            color={bankConfig?.authorized ? 'success' : 'error'}
            size="small"
            icon={
              <Iconify icon={bankConfig?.authorized ? 'mdi:check-circle' : 'mdi:alert-circle'} />
            }
          />
        </Tooltip>
      }
    />
    <CardContent>
      <Stack spacing={2}>
        <Box>
          <Typography variant="caption" color="text.secondary">
            Bank Name
          </Typography>
          <Typography variant="body1" sx={{ fontWeight: 500 }}>
            {bankConfig?.bank_name || 'Not specified'}
          </Typography>
        </Box>
        <Box>
          <Typography variant="caption" color="text.secondary">
            Account Type
          </Typography>
          <Typography variant="body1" sx={{ fontWeight: 500 }}>
            {bankConfig?.account_type || 'Not specified'}
          </Typography>
        </Box>
        <Box>
          <Typography variant="caption" color="text.secondary">
            Account Number
          </Typography>
          <Typography variant="body1" sx={{ fontWeight: 500, fontFamily: 'monospace' }}>
            {bankConfig?.account_number || 'Not specified'}
          </Typography>
        </Box>
        <Divider />
        <Box>
          <Typography variant="caption" color="text.secondary">
            ACH Routing
          </Typography>
          <Typography variant="body1" sx={{ fontWeight: 500, fontFamily: 'monospace' }}>
            {bankConfig?.routing_number_ach || 'N/A'}
          </Typography>
        </Box>
        <Box>
          <Typography variant="caption" color="text.secondary">
            Wire Routing
          </Typography>
          <Typography variant="body1" sx={{ fontWeight: 500, fontFamily: 'monospace' }}>
            {bankConfig?.routing_number_wire || 'N/A'}
          </Typography>
        </Box>
        <Box display="flex" gap={1} flexWrap="wrap" mt={2}>
          <Chip
            label={_.startCase(status)}
            color={getColor(status)}
            size="small"
            variant="outlined"
          />
          <Chip
            label={bankConfig?.active ? 'Active' : 'Inactive'}
            color={bankConfig?.active ? 'success' : 'default'}
            size="small"
            variant="outlined"
          />
        </Box>
      </Stack>
    </CardContent>
  </Card>
);
