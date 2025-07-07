
import Box from '@mui/material/Box';
import IconButton from '@mui/material/IconButton';
import { Stack, Typography } from '@mui/material';

import { useRouter } from 'src/routes/hooks';

import { Label } from 'src/components/label';
import { Iconify } from 'src/components/iconify';

type Props = {
  name: string;
  status: string;
};

export function CompanyDetailsToolbar({ name, status }: Props) {
  const router = useRouter();

  return (
    <Box
      sx={{
        mb: { xs: 3, md: 5 },
        display: 'flex',
        flexDirection: { xs: 'column', md: 'row' },
        alignItems: { xs: 'flex-start', md: 'center' },
        gap: 2,
      }}
    >
      <Stack direction="row" alignItems="center" spacing={1}>
        <IconButton onClick={() => router.back()}>
          <Iconify icon="eva:arrow-ios-back-fill" />
        </IconButton>

        <Stack spacing={0.5}>
          <Stack direction="row" alignItems="center" spacing={1}>
            <Typography variant="h5">{name}</Typography>
            <Label
              variant="soft"
              color={
                (status === 'approved' && 'success') ||
                (status === 'pending' && 'warning') ||
                (status === 'rejected' && 'error') ||
                'default'
              }
            >
              {status}
            </Label>
          </Stack>
        </Stack>
      </Stack>
    </Box>
  );
}
