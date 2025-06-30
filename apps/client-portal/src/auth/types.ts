export type UserType = Record<string, any> | null;

export type AuthState = {
  user: UserType;
  loading: boolean;
};

export type AuthContextValue = {
  userCredentials: UserType;
  user: any;
  loading: boolean;
  authenticated: boolean;
  unauthenticated: boolean;
  checkUserSession?: () => Promise<void>;
  handleLogout?: () => void;
};

export enum StepIndex {
  CompanyInfo,
  UserInfo,
  Payroll,
  Summary,
}

export interface RegistrationFormData {
  companyInfo: CompanyInformation;
  userInfo: UserInformation;
  payrollInfo: PayrollDetails;
}

export type CompanyInformation = {
  entity_name: string;
  entity_type: string;
  fein: string;
  address_line_1: string;
  address_line_2: string;
  city: string;
  state: string;
  zip_code: string;
  phone_number: string;
  nys_unemployment_registration_number: string;
};

export type UserInformation = {
  first_name: string;
  middle_name?: string;
  last_name: string;
  email_address: string;
  role_title: string;
};

export type PayrollDetails = {
  pay_frequency: string;
  pay_period: string;
  payroll_start_date: string;
  check_number: number;
};

export type CompanyData = {
  company_information: CompanyInformation;
  user_information: UserInformation;
  payroll_details: PayrollDetails;
};
