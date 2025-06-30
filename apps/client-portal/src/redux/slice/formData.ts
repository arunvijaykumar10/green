import type { PayloadAction } from '@reduxjs/toolkit';
import type { BankSetupData, CompanyFormData, SignatureSetupData, UnionConfigurationData } from 'src/pages/dashboard/types';

import { createSlice } from '@reduxjs/toolkit';

interface FormDataState {
  companyInformation: CompanyFormData | null;
  unionConfiguration: UnionConfigurationData | null;
  bankSetup: BankSetupData | null;
  signatureSetup: SignatureSetupData | null;
  payrollAndTaxes: Record<string, any> | null;
}

const initialState: FormDataState = {
  companyInformation: null,
  unionConfiguration: null,
  bankSetup: null,
  signatureSetup: null,
  payrollAndTaxes: null,
};

const formDataSlice = createSlice({
  name: 'formData',
  initialState,
  reducers: {
    saveCompanyInformation: (state, action: PayloadAction<CompanyFormData>) => {
      state.companyInformation = action.payload;
    },
    saveUnionConfiguration: (state, action: PayloadAction<UnionConfigurationData>) => {
      state.unionConfiguration = action.payload;
    },
    saveBankSetup: (state, action: PayloadAction<BankSetupData>) => {
      state.bankSetup = action.payload;
    },
    saveSignatureSetup: (state, action: PayloadAction<SignatureSetupData>) => {
      state.signatureSetup = action.payload;
    },
    savePayrollAndTaxes: (state, action: PayloadAction<Record<string, any>>) => {
      state.payrollAndTaxes = action.payload;
    },
    resetFormData: () => initialState,
  },
});

export const {
  saveCompanyInformation,
  saveUnionConfiguration,
  saveBankSetup,
  saveSignatureSetup,
  savePayrollAndTaxes,
  resetFormData
} = formDataSlice.actions;

export default formDataSlice.reducer;
