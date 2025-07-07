import _ from 'lodash';

import { Box, Card, Chip, Grid2, CardHeader, Typography, CardContent } from '@mui/material';

import { Image } from 'src/components/image';
import { Iconify } from 'src/components/iconify';

interface SignaturesCardProps {
  signatureType: string;
  signatureUrl?: string;
  secondarySignatureUrl?: string;
}

export const SignaturesCard = ({
  signatureType,
  signatureUrl,
  secondarySignatureUrl,
}: SignaturesCardProps) => (
  <Card elevation={1} sx={{ height: '100%' }}>
    <CardHeader
      avatar={<Iconify icon="mdi:draw-pen" color="primary.main" width={24} />}
      title="Signatures Configuration"
      titleTypographyProps={{ variant: 'h6', fontWeight: 600 }}
      action={
        <Chip label={_.startCase(signatureType)} size="small" color="info" variant="outlined" />
      }
    />
    <CardContent>
      <Grid2 container spacing={2}>
        <Grid2 size={{ xs: 12, md: signatureType === 'double' ? 6 : 12 }}>
          <Typography variant="subtitle2" gutterBottom>
            Primary Signature
          </Typography>
          {signatureUrl ? (
            <Box
              sx={{
                border: '2px dashed #e0e0e0',
                borderRadius: 2,
                p: 2,
                textAlign: 'center',
                bgcolor: 'grey.50',
              }}
            >
              <Image
                alt="image"
                src={signatureUrl}
                sx={{
                  top: 0,
                  left: 0,
                  height: '100%',
                  width: '100%',
                  objectFit: 'cover',
                  borderRadius: 1.5,
                }}
              />
            </Box>
          ) : (
            <Box
              sx={{
                border: '2px dashed #e0e0e0',
                borderRadius: 2,
                p: 3,
                textAlign: 'center',
                color: 'text.secondary',
              }}
            >
              <Iconify icon="mdi:signature" width={32} sx={{ mb: 1, opacity: 0.5 }} />
              <Typography variant="body2">No signature uploaded</Typography>
            </Box>
          )}
        </Grid2>
        {signatureType === 'double' && (
          <Grid2 size={{ xs: 12, md: 6 }}>
            <Typography variant="subtitle2" gutterBottom>
              Secondary Signature
            </Typography>
            {secondarySignatureUrl ? (
              <Box
                sx={{
                  border: '2px dashed #e0e0e0',
                  borderRadius: 2,
                  p: 2,
                  textAlign: 'center',
                  bgcolor: 'grey.50',
                }}
              >
                <Image
                  alt="image"
                  src={secondarySignatureUrl}
                  sx={{
                    top: 0,
                    left: 0,
                    height: '100%',
                    width: '100%',
                    objectFit: 'cover',
                    borderRadius: 1.5,
                  }}
                />
              </Box>
            ) : (
              <Box
                sx={{
                  border: '2px dashed #e0e0e0',
                  borderRadius: 2,
                  p: 3,
                  textAlign: 'center',
                  color: 'text.secondary',
                }}
              >
                <Iconify icon="mdi:signature" width={32} sx={{ mb: 1, opacity: 0.5 }} />
                <Typography variant="body2">No signature uploaded</Typography>
              </Box>
            )}
          </Grid2>
        )}
      </Grid2>
    </CardContent>
  </Card>
);
