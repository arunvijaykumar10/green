import _ from 'lodash';
import dayjs from 'dayjs';

import { Box, Chip, Card, Stack, Avatar, Typography, CardContent } from '@mui/material';

import { Iconify } from 'src/components/iconify';

import { getColor } from './utils';
import { InfoCard } from './InfoCard';

const getReviewIcon = (sts: string) => {
  switch (sts) {
    case 'approved':
      return (
        <Iconify icon="mdi:check-circle" sx={{ color: 'success.main', width: 20, height: 20 }} />
      );
    case 'rejected':
      return (
        <Iconify icon="mdi:close-circle" sx={{ color: 'error.main', width: 20, height: 20 }} />
      );
    default:
      return (
        <Iconify icon="mdi:clock-outline" sx={{ color: 'warning.main', width: 20, height: 20 }} />
      );
  }
};

export const CompanyHeader = ({ company, status }: { company: any; status: string }) => {
  const { name, fein, company_type, phone, created_at, updated_at, nys_no } = company;

  return (
    <Card elevation={2}>
      <CardContent sx={{ p: 4 }}>
        <Box
          display="flex"
          flexDirection={{ xs: 'column', md: 'row' }}
          alignItems={{ md: 'center' }}
          justifyContent="space-between"
          gap={4}
          mb={3}
        >
          {/* Company Avatar + Title + Status */}
          <Box display="flex" alignItems="center" flexShrink={0}>
            <Avatar
              sx={{
                p: 2,
                bgcolor: 'primary.lighter',
                color: 'primary.main',
                width: 64,
                height: 64,
                borderRadius: 2,
                boxShadow: 3,
              }}
            >
              <Iconify icon="lsicon:building-filled" width={40} />
            </Avatar>
            <Box sx={{ ml: 2 }}>
              <Typography variant="h3" sx={{ fontWeight: 600, mb: 1 }}>
                {name}
              </Typography>
              <Chip
                label={_.startCase(status)}
                color={getColor(status)}
                sx={{
                  bgcolor: `${getColor(status)}.main`,
                  color: 'white',
                  fontWeight: 600,
                }}
                icon={getReviewIcon(status)}
              />
            </Box>
          </Box>

          {/* Info Cards */}
          <Stack
            direction={{ xs: 'column', sm: 'row' }}
            spacing={2}
            useFlexGap
            flexWrap="wrap"
            flex={1}
            justifyContent={{ xs: 'flex-start', md: 'flex-end' }}
          >
            <InfoCard icon="mdi:file-document" label="FEIN" value={fein} />
            <InfoCard icon="mdi:domain" label="Company Type" value={company_type} />
            <InfoCard icon="mdi:phone" label="Phone" value={phone} />
          </Stack>
        </Box>
        <Box display="flex" gap={5} flexWrap="wrap">
          <Box>
            <Typography variant="caption" color="text.secondary">
              Created
            </Typography>
            <Typography variant="body2" sx={{ fontWeight: 500 }}>
              {dayjs(created_at).format('MMM DD, YYYY [at] h:mm A')}
            </Typography>
          </Box>
          <Box>
            <Typography variant="caption" color="text.secondary">
              Last Updated
            </Typography>
            <Typography variant="body2" sx={{ fontWeight: 500 }}>
              {dayjs(updated_at).format('MMM DD, YYYY [at] h:mm A')}
            </Typography>
          </Box>
          <Box>
            <Typography variant="caption" color="text.secondary">
              NYS Number
            </Typography>
            <Typography variant="body2" sx={{ fontWeight: 500 }}>
              {nys_no || 'Not assigned'}
            </Typography>
          </Box>
        </Box>
      </CardContent>
    </Card>
  );
};
