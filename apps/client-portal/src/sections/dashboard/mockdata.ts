// mockData.ts
export const mockCompanyInfo = {
  entity_name: "Wayne Enterprises",
  entity_type: "Corporation",
  fein: "12-3456789",
  nys_unemployment_registration_number: "NY-987654",
  address_line_1: "123 Gotham Ave",
  address_line_2: "Suite 400",
  city: "Gotham",
  state: "NY",
  zip_code: "10001",
  phone_number: "212-555-0199",
};

export const mockUnionConfig = {
  isUnionProduction: true,
  union: "Actor's Equity Association",
  agreementType: "Equity/League Production Contract",
  productionType: "Musical",
  tier: undefined,
  employerId: "AEA-001",
  productionTitle: "The Gotham Chronicles",
  businessRep: "Harvey Dent",
};

export const mockBankAccount = {
  bankName: "Gotham National Bank",
  routingNumberACH: "111000025",
  routingNumberWire: "222000038",
  accountNumber: "000123456789",
  accountType: "Checking",
  isAuthorized: true,
};

export const mockSignatureConfig = {
  signaturePolicy: "Double",
  signature1: { type: "uploaded" },
  signature2: { type: "drawn" },
};

export const mockPayrollSetup = {
  payFrequency: "Biweekly",
  payPeriod: "2025-07-01 to 2025-07-15",
  payScheduleStart: "2025-07-01",
  timesheetDue: "2025-06-29",
  checkNumber: "CHK001234",
};
