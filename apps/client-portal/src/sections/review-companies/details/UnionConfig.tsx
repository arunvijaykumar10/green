import {
  Box,
  Card,
  Chip,
  Stack,
  Divider,
  CardHeader,
  Typography,
  CardContent,
} from '@mui/material';

import { Iconify } from 'src/components/iconify';

interface UnionConfigCardProps {
  unionConfig?: {
    active?: boolean;
    union_type?: string;
    union_name?: string;
    agreement_type?: string;
    agreement_type_configuration?: {
      aea_employer_id?: string;
      musical_or_dramatic?: string;
      aea_production_title?: string;
    };
  };
}

export const UnionConfig = ({ unionConfig }: UnionConfigCardProps) => (
  <Card elevation={1} sx={{ height: '100%' }}>
    <CardHeader
      avatar={<Iconify icon="mdi:account-group" color="primary.main" width={24} />}
      title="Union Information"
      titleTypographyProps={{ variant: 'h6', fontWeight: 600 }}
      action={
        <Chip
          label={unionConfig?.active ? 'Active' : 'Inactive'}
          color={unionConfig?.active ? 'success' : 'default'}
          size="small"
          variant="outlined"
        />
      }
    />
    <CardContent>
      <Stack spacing={2}>
        <Box>
          <Typography variant="caption" color="text.secondary">
            Union Type
          </Typography>
          <Typography variant="body1" sx={{ fontWeight: 500 }}>
            {unionConfig?.union_type || 'Not specified'}
          </Typography>
        </Box>
        <Box>
          <Typography variant="caption" color="text.secondary">
            Union Name
          </Typography>
          <Typography variant="body1" sx={{ fontWeight: 500 }}>
            {unionConfig?.union_name || 'Not specified'}
          </Typography>
        </Box>
        <Box>
          <Typography variant="caption" color="text.secondary">
            Agreement Type
          </Typography>
          <Typography variant="body1" sx={{ fontWeight: 500 }}>
            {unionConfig?.agreement_type || 'Not specified'}
          </Typography>
        </Box>

        {unionConfig?.agreement_type_configuration && (
          <>
            <Divider />
            <Typography variant="subtitle2" color="primary" gutterBottom>
              Agreement Details
            </Typography>
            <Stack spacing={1}>
              <Box>
                <Typography variant="caption" color="text.secondary">
                  Employer ID
                </Typography>
                <Typography variant="body2">
                  {unionConfig.agreement_type_configuration.aea_employer_id || 'N/A'}
                </Typography>
              </Box>
              <Box>
                <Typography variant="caption" color="text.secondary">
                  Production Type
                </Typography>
                <Typography variant="body2">
                  {unionConfig.agreement_type_configuration.musical_or_dramatic || 'N/A'}
                </Typography>
              </Box>
              <Box>
                <Typography variant="caption" color="text.secondary">
                  Production Title
                </Typography>
                <Typography variant="body2">
                  {unionConfig.agreement_type_configuration.aea_production_title || 'N/A'}
                </Typography>
              </Box>
            </Stack>
          </>
        )}
      </Stack>
    </CardContent>
  </Card>
);
