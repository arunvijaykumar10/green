import type { TierType, SignaturePolicy } from "../dashboard/types";


export interface BankConfig {
  id: number;
  bank_name: string;
  routing_number_ach: number;
  routing_number_wire: number;
  account_number: number;
  account_type: string;
  authorized: boolean;
  company_id: number;
}

export interface BankConfigResponse {
  data: BankConfig;
  message: string;
  status: string;
}

export interface PayrollConfig {
  id: number;
  frequency: string;
  period: string;
  start_date: string;
  check_start_number: number;
  active: boolean;
  company_id: number;
}

export interface PayrollConfigResponse {
  data: {
    payroll_config: PayrollConfig;
  };
  message: string;
  status: string;
}


export interface AddressInfo {
  id: number;
  address_type: string;
  address_line_1: string;
  address_line_2: string;
  city: string;
  state: string;
  zip_code: string;
  country: string;
  active_from: string;
  active_until: null | string;
}
export interface Company {
  id: number;
  name: string;
  code: string;
  fein: string;
  nys_no: string;
  phone: string;
  signature_type: SignaturePolicy;
  signature_url: string;
  secondary_signature_url: string;
  company_type: string;
  approved: boolean;
  created_at: string;
  updated_at: string;
  addresses: AddressInfo[];
  bank_config?: {
    id: number;
    bank_name: string;
    account_type: string;
    routing_number_ach: string;
    routing_number_wire: string;
    account_number: string;
    authorized: boolean;
    approved: boolean;
    active: boolean;
  };
  union_config?: {
    id: number;
    union_type: string;
    union_name: string;
    agreement_type: string;
    agreement_type_configuration: {
      aea_employer_id: string;
      tier: TierType;
      musical_or_dramatic: string;
      aea_production_title: string;
      aea_business_representative: string;
    };
    active: boolean;
    created_at: string;
    updated_at: string;
  };
  payroll_config?: {
    id: number;
    frequency: string;
    period: string;
    start_date: string;
    check_start_number: number;
    approved: boolean;
  };
}

export interface UnionConfig {
  id: number;
  union_type: 'union' | 'non-union';
  union_name?: string;
  agreement_type?: string;
  agreement_type_configuration?: {
    musical_or_dramatic?: string;
    aea_employer_id?: string;
    tier?: string;
    aea_production_title?: string;
    aea_business_representative?: string;
  };
  active: boolean;
  company_id: number;
}

export interface allCompanyResponse {
  status: string;
  message: string;
  data: {
    companies: Company[];
  };
}


export interface UnionConfigResponse {
  data: {
    company_union_configuration: UnionConfig;
  };
  message: string;
  status: string;
}

export interface CompanyResponse {
  data: {
    company: Company;
  };
  message: string;
  status: string;
}

export type PresignedUrlResponse = {
  status: string;
  message: string;
  data: {
    signed_id: string;
    key: string;
    direct_upload: {
      url: string;
      headers: {
        'Content-Type': string;
        'Content-MD5': string;
        'Content-Disposition': string;
      };
    };
  }[];
};

export type PresignedUrlParams = {
  filename: string;
  byte_size: number;
  checksum: string;
  content_type: string;
}[];

export type BatchPresignedUrlParams = {
  files: PresignedUrlParams;
};
