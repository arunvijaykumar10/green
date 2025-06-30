import { useEffect } from 'react';
import { useForm, FormProvider } from 'react-hook-form';

import {
  Box,
  Grid,
  Card,
  Button
} from "@mui/material";

import { useDispatch } from 'src/redux/store';
import { saveCompanyInformation } from 'src/redux/slice/formData';

import { RHFTextField, RHFAutocomplete } from 'src/components/hook-form';

import { useAuthContext } from 'src/auth/hooks';

import { useGetQuery, useUpdateMutation } from '../../../pages/companies/api';

import type { CompanyFormData } from '../../../pages/dashboard/types';

const ENTITY_TYPES = ['Corp', 'Partnership', 'Sole Proprietor', 'Non Profit', 'Single-member LLC'];
const STATES = ['NY', 'US'];

const CompanyInformation = () => {
  const dispatch = useDispatch();
  const { user, userCredentials } = useAuthContext();
  const currentCompanyId = user?.last_accessed_company?.id || null;
  const { data: companyData } = useGetQuery(currentCompanyId, { skip: !currentCompanyId });
  const [updateCompany] = useUpdateMutation();
  const methods = useForm<CompanyFormData>({
    defaultValues: {
      entityName: '',
      entityType: '',
      fein: '',
      addressLine1: '',
      addressLine2: '',
      city: '',
      state: 'NY',
      zipCode: '',
      phoneNumber: '',
      nysUnemploymentNumber: ''
    }
  });

  useEffect(() => {
    if (companyData?.data?.company) {
      const currentAddress = companyData.data.company.addresses.find(addr => addr.active_until === null);

      methods.reset({
        entityName: companyData.data.company.name || '',
        entityType: (companyData.data.company.company_type as CompanyFormData['entityType']) || '',
        fein: companyData.data.company.fein || '',
        addressLine1: currentAddress?.address_line_1 || '',
        addressLine2: currentAddress?.address_line_2 || '',
        city: currentAddress?.city || '',
        state: currentAddress?.state || 'NY',
        zipCode: currentAddress?.zip_code || '',
        phoneNumber: companyData.data.company.phone || '',
        nysUnemploymentNumber: companyData.data.company.nys_no || ''
      });
    }
  }, [companyData, methods]);

  if (!currentCompanyId || !companyData) {
    return null;
  }

  const { handleSubmit } = methods;

  const onSubmit = (data: CompanyFormData) => {
    const params = {
      company: {
        name: data.entityName,
        company_type: data.entityType,
        fein: data.fein,
        nys_no: data.nysUnemploymentNumber,
        phone: data.phoneNumber,
        addresses_attributes: [
          {
            address_type: "primary",
            address_line_1: data.addressLine1,
            address_line_2: data.addressLine2,
            city: data.city,
            state: data.state,
            zip_code: data.zipCode,
            active_from: new Date().toISOString()
          }
        ]
      }
    };
    updateCompany({
      id: currentCompanyId,
      ...params
    });
    dispatch(saveCompanyInformation(data));
    console.log('Form submitted:', data);
  };

  return (
    <Box sx={{ p: 2 }}>
      <FormProvider {...methods}>
        <Box component="form" onSubmit={handleSubmit(onSubmit)} sx={{ mt: 3 }}>
          <Card sx={{ p: 3, mb: 3 }}>
            <Grid container spacing={3}>

              <Grid item xs={12} sm={6}>
                <RHFTextField
                  name="entityName"
                  label="Entity Name"
                  required
                  inputProps={{ maxLength: 64 }}
                  helperText="Legal name of the production (max 64 characters)"
                  sx={{ '& .MuiOutlinedInput-root': { borderRadius: 1 } }}
                />
              </Grid>

              <Grid item xs={12} sm={6}>
                <RHFAutocomplete
                  options={ENTITY_TYPES}
                  name="entityType"
                  label="Entity Type"
                  slotProps={{
                    textfield: {
                      sx: { '& .MuiOutlinedInput-root': { borderRadius: 1 } }
                    }
                  }}
                />
              </Grid>

              <Grid item xs={12}>
                <RHFTextField
                  name="fein"
                  label="FEIN"
                  required
                  placeholder="99-9999999"
                  helperText="Format: 99-9999999"
                  sx={{ '& .MuiOutlinedInput-root': { borderRadius: 1 } }}
                />
              </Grid>


              <Grid item xs={12}>
                <RHFTextField
                  name="addressLine1"
                  label="Address Line 1"
                  required
                  inputProps={{ maxLength: 64 }}
                  sx={{ '& .MuiOutlinedInput-root': { borderRadius: 1 } }}
                />
              </Grid>

              <Grid item xs={12}>
                <RHFTextField
                  name="addressLine2"
                  label="Address Line 2"
                  inputProps={{ maxLength: 64 }}
                  sx={{ '& .MuiOutlinedInput-root': { borderRadius: 1 } }}
                />
              </Grid>

              <Grid item xs={12} sm={6}>
                <RHFTextField
                  name="city"
                  label="City"
                  required
                  inputProps={{ maxLength: 24 }}
                  sx={{ '& .MuiOutlinedInput-root': { borderRadius: 1 } }}
                />
              </Grid>

              <Grid item xs={12} sm={3}>
                <RHFAutocomplete
                  options={STATES}
                  name="state"
                  label="State"
                  slotProps={{
                    textfield: {
                      sx: { '& .MuiOutlinedInput-root': { borderRadius: 1 } }
                    }
                  }}
                />
              </Grid>

              <Grid item xs={12} sm={3}>
                <RHFTextField
                  name="zipCode"
                  label="Zip Code"
                  required
                  placeholder="12345"
                  helperText="5-digit NY zip code"
                  inputProps={{ maxLength: 5 }}
                  sx={{ '& .MuiOutlinedInput-root': { borderRadius: 1 } }}
                />
              </Grid>

              <Grid item xs={12} sm={6}>
                <RHFTextField
                  name="phoneNumber"
                  label="Phone Number"
                  required
                  placeholder="(999)-999-9999"
                  helperText="Format: (999)-999-9999"
                  sx={{ '& .MuiOutlinedInput-root': { borderRadius: 1 } }}
                />
              </Grid>

              <Grid item xs={12} sm={6}>
                <RHFTextField
                  name="nysUnemploymentNumber"
                  label="NYS Unemployment Registration Number"
                  required
                  placeholder="9999999"
                  helperText="7-digit Employer Account Number"
                  inputProps={{ maxLength: 7 }}
                  sx={{ '& .MuiOutlinedInput-root': { borderRadius: 1 } }}
                />
              </Grid>

              <Grid item xs={12}>
                <Box sx={{ display: 'flex', justifyContent: 'flex-end' }}>
                  <Button
                    type="submit"
                    variant="contained"
                    color="primary"
                    size="large"
                  >
                    Save
                  </Button>
                </Box>
              </Grid>
            </Grid>
          </Card>
        </Box>
      </FormProvider>
    </Box>
  );
};

export { CompanyInformation };
export default CompanyInformation;
