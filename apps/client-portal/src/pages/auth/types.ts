export interface User {
  id: number;
  first_name: string;
  last_name: string;
  email: string;
  phone_no: string | null;
  created_at: string;
  updated_at: string;
  full_name: string;
  super_admin: boolean;
}

export interface Company {
  id: number;
  name: string;
  fein: string | number;
  code: string;
  company_type: string;
  last_accessed_at: string;
}

export interface ProfileResponse {
  user: User;
  last_accessed_company: Company;
}
