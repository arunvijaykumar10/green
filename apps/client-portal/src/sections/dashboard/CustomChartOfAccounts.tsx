import { useState } from 'react';

import { Box, Card, Stack, Typography } from '@mui/material';

import { Upload } from '../../components/upload';

export default function CustomChartOfAccounts() {
  const [file, setFile] = useState<File | null>(null);

  const handleDropSingleFile = (acceptedFiles: File[]) => {
    const newFile = acceptedFiles[0];
    if (newFile) {
      setFile(newFile);
    }
  };

  return (
    <Box sx={{ maxWidth: 600, mx: 'auto', mt: 6 }}>
      <Card sx={{ p: 3 }}>
        <Stack spacing={2} alignItems="center">
          <Typography variant="h6">Upload Chart of Accounts</Typography>
          
          <Typography variant="body2" color="text.secondary">
            Accepts .csv, .xlsx formats. Max file size: 5MB
          </Typography>
          
          <Upload
            onDrop={handleDropSingleFile}
            onDelete={() => setFile(null)}
            accept={{
              'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet': [],
              'text/csv': [],
            }}
            maxSize={5000000} // 5MB
            helperText={
              file ? `File: ${file.name}` : 'Drop or select file to upload'
            }
          />
        </Stack>
      </Card>
    </Box>
  );
}
