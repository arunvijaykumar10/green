import React from 'react';
import { Link as RouterLink } from 'react-router-dom';

import {
  Box,
  Card,
  Grid,
  Alert,
  Container,
  Typography,
  CardContent,
  CardActionArea,
  CircularProgress,
} from '@mui/material';

import { paths } from 'src/routes/paths';

import { useListQuery } from './api'; // Import the hook to fetch all companies

import type { Company } from './types'; // Assuming Company type is defined in ./types

// A simple component to display a single company as a card
const CompanyCard: React.FC<{ company: Company }> = ({ company }) => (
  <Grid item xs={12} sm={6} md={4}>
    <Card sx={{ height: '100%' }}>
      <CardActionArea
        component={RouterLink}
        to={`${paths.app.company}/${company.id}`}
        sx={{ height: '100%', display: 'flex', flexDirection: 'column', alignItems: 'flex-start' }}
      >
        <CardContent sx={{ flexGrow: 1, width: '100%' }}>
          <Typography gutterBottom variant="h5" component="h2">
            {company.name}
          </Typography>
          <Typography variant="body2" color="text.secondary">
            type: {company.company_type}
          </Typography>
          <Typography variant="body2" color="text.secondary">
            Fein: {company.fein}
          </Typography>
          <Typography variant="body2" color="text.secondary">
            Status: {company.approved ? 'Approved' : 'Pending Review'}
          </Typography>
        </CardContent>
      </CardActionArea>
    </Card>
  </Grid>
);

// The main page component that fetches and displays companies in a grid of cards
const CompaniesList: React.FC = () => {
  const { data: companyResponse, isLoading, isError, error } = useListQuery();
  const companies = companyResponse?.data.companies
  if (isLoading) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '80vh' }}>
        <CircularProgress />
      </Box>
    );
  }

  if (isError) {
    // Log the error for debugging purposes
    console.error("Failed to fetch companies:", error);
    return (
      <Container>
        <Alert severity="error" sx={{ mt: 3 }}>
          Error loading companies. Please try again later.
        </Alert>
      </Container>
    );
  }

  if (!companies || companies.length === 0) {
    return (
      <Container>
        <Typography variant="h6" align="center" sx={{ mt: 3 }}>
          No companies found.
        </Typography>
      </Container>
    );
  }

  return (
    <Container sx={{ py: 4 }} maxWidth="lg">
      <Grid container spacing={4}> 
        {(companies || []).filter(company => company.approved).map((company) => (
          <CompanyCard key={company.name} company={company} />
        ))}
      </Grid>
    </Container>
  );
};

export default CompaniesList;