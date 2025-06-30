import React from 'react';

import {
  Box,
  Card,
  Chip,
  Grid2,
  Button,
  Typography,
  CardContent,
} from '@mui/material';

import { primary } from 'src/theme';

const mockCompanies = [
  { name: 'TechNova Inc.', role: 'Admin', status: 'Active', selected: true },
  { name: 'BrightPath LLC', role: 'Employee', status: 'Active' },
  { name: 'GreenHarvest Co.', role: 'Admin', status: 'Inactive' },
  { name: 'UrbanEdge Designs', role: 'Employee', status: 'Inactive' },
  { name: 'GlobalTech Solutions', role: 'Admin', status: 'Active' },
  { name: 'NextGen Innovations', role: 'Employee', status: 'Active' },
  { name: 'EcoWave Enterprises', role: 'Admin', status: 'Inactive' },
];

const Company = () => (
  <Box p={4}>
    <Typography variant="h5" fontWeight="bold" gutterBottom>
      Current Company
    </Typography>

    <Card
      variant="outlined"
      sx={{
        mb: 4,
        borderLeft: '5px solid',
        borderColor: primary.main,
      }}
    >
      <CardContent>
        <Typography variant="subtitle1" fontWeight="bold">
          TechNova Inc.
        </Typography>
        <Typography variant="body2">Role: Admin</Typography>
      </CardContent>
    </Card>

    <Box display="flex" justifyContent="space-between" alignItems="center" mb={2}>
      <Typography variant="h6" fontWeight="bold">
        Switch Company
      </Typography>
      <Button variant="contained" color="primary">
        + Create New Company
      </Button>
    </Box>

    <Grid2 container spacing={2}>
      {mockCompanies.map((company) =>
        <Grid2 key={company.name} size={{ xs: 12, sm: 6, md: 4 }}>
          <Card
            variant="outlined"
            sx={{
              opacity: company.status === 'Inactive' ? 0.6 : 1,
              border: company.selected ? '2px solid' : undefined,
              borderColor: company.selected ? primary.main : undefined,
              cursor: company.status === 'Inactive' ? 'not-allowed' : 'pointer',
            }}
          >
            <CardContent>
              <Box display="flex" justifyContent="space-between" alignItems="center">
                <Typography fontWeight="bold">{company.name}</Typography>
                <Chip
                  label={company.status}
                  size="small"
                  color={company.status === 'Active' ? 'success' : 'error'}
                />
              </Box>
              <Typography variant="body2" mt={1}>
                Role: {company.role}
              </Typography>
            </CardContent>
          </Card>
        </Grid2>
      )}
    </Grid2>
  </Box>
);

export default Company;
