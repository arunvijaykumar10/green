export type Company = {
  id: number;
  name: string;
  code: string;
  company_type: string;
};

export type CompanyReview = {
  id: number;
  status: string;
  submitted_at: string;
  reviewed_at: string | null;
  review_notes: string | null;
  company: Company;
};

export type CompanyReviewsResponse = {
  status: string;
  message: string;
  data: {
    company_reviews: CompanyReview[];
  };
};

export type PayrollDetails = {
  pay_frequency: string;
  pay_period: string;
  payroll_start_date: string;
  check_number: number;
};

export type UnionSignature = {
  signature_url: string;
  signed_at: string;
};

export type BankDetails = {
  bank_name: string;
  account_number: string;
  routing_number: string;
  account_type: string;
};

export type CompanyDetails = {
  id: number;
  name: string;
  code: string;
  company_type: string;
  payroll_details: PayrollDetails;
  union_signature: UnionSignature;
  bank_details: BankDetails;
};

export type CompanyDetailsResponse = {
  status: string;
  message: string;
  data: CompanyDetails;
};
