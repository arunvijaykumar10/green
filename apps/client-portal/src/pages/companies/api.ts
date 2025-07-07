import { createApi } from '@reduxjs/toolkit/query/react';

import { apiBaseQuery } from 'src/redux/apiBaseQuery';

import type {
  Company,
  BankConfig,
  UnionConfig,
  PayrollConfig,
  CompanyResponse,
  BankConfigResponse,
  PresignedUrlParams,
  allCompanyResponse,
  UnionConfigResponse,
  PresignedUrlResponse,
  PayrollConfigResponse,
} from './types';

// TAG_TYPES
const TAG_TYPES = {
  COMPANIES: 'COMPANIES',
  BANK_CONFIG: 'BANK_CONFIG',
  UNION_CONFIG: 'UNION_CONFIG',
  PAYROLL_CONFIG: 'PAYROLL_CONFIG',
  REVIEW_STATUS: 'REVIEW_STATUS',
} as const;

const { COMPANIES, BANK_CONFIG, UNION_CONFIG, PAYROLL_CONFIG, REVIEW_STATUS } = TAG_TYPES;

const api = createApi({
  reducerPath: 'companies_api',
  baseQuery: apiBaseQuery(),
  tagTypes: Object.values(TAG_TYPES),
  endpoints: (builder) => ({
    list: builder.query<allCompanyResponse, void>({
      query: () => ({
        url: '/companies',
        method: 'GET',
      }),
      providesTags: [COMPANIES],
    }),
    get: builder.query<CompanyResponse, number>({
      query: (id) => ({
        url: `/companies/${id}`,
        method: 'GET',
      }),
      providesTags: (result, error, id) => [{ type: COMPANIES, id }],
    }),
    create: builder.mutation<Company, Omit<Company, 'id'>>({
      query: (body) => ({
        url: '/companies',
        method: 'POST',
        body,
      }),
      invalidatesTags: [COMPANIES],
    }),
    update: builder.mutation<Company, { id: number } & Partial<Company>>({
      query: ({ id, ...body }) => ({
        url: `/companies/${id}`,
        method: 'PATCH',
        body,
      }),
      invalidatesTags: (result, error, { id }) => [{ type: COMPANIES, id }],
    }),
    delete: builder.mutation<void, number>({
      query: (id) => ({
        url: `/companies/${id}`,
        method: 'DELETE',
      }),
      invalidatesTags: (result, error, id) => [{ type: COMPANIES, id }],
    }),
    getBankConfig: builder.query<BankConfigResponse, number>({
      query: (companyId) => ({
        url: `/companies/${companyId}/bank_config`,
        method: 'GET',
      }),
      providesTags: (result, error, companyId) => [
        { type: BANK_CONFIG, id: companyId },
        { type: COMPANIES, id: companyId },
      ],
    }),
    createBankConfig: builder.mutation<
      BankConfig,
      { companyId: number } & Omit<BankConfig, 'id' | 'company_id'>
    >({
      query: ({ companyId, ...body }) => ({
        url: `/companies/${companyId}/bank_config`,
        method: 'POST',
        body,
      }),
      invalidatesTags: (result, error, { companyId }) => [
        { type: BANK_CONFIG, id: companyId },
        { type: COMPANIES, id: companyId },
      ],
    }),
    updateBankConfig: builder.mutation<
      BankConfig,
      { companyId: number; id: number } & Partial<BankConfig>
    >({
      query: ({ companyId, id, ...body }) => ({
        url: `/companies/${companyId}/bank_config`,
        method: 'PATCH',
        body,
      }),
      invalidatesTags: (result, error, { companyId }) => [
        { type: BANK_CONFIG, id: companyId },
        { type: COMPANIES, id: companyId },
      ],
    }),
    getPayrollConfig: builder.query<PayrollConfigResponse, number>({
      query: (companyId) => ({
        url: `/companies/${companyId}/payroll_config`,
        method: 'GET',
      }),
      providesTags: (result, error, companyId) => [
        { type: PAYROLL_CONFIG, id: companyId },
        { type: COMPANIES, id: companyId },
      ],
    }),
    createPayrollConfig: builder.mutation<
      PayrollConfig,
      { companyId: number; payroll_config: Omit<PayrollConfig, 'id' | 'company_id'> }
    >({
      query: ({ companyId, payroll_config }) => ({
        url: `/companies/${companyId}/payroll_config`,
        method: 'POST',
        body: { payroll_config },
      }),
      invalidatesTags: (result, error, { companyId }) => [
        { type: PAYROLL_CONFIG, id: companyId },
        { type: COMPANIES, id: companyId },
      ],
    }),
    updatePayrollConfig: builder.mutation<
      PayrollConfig,
      { companyId: number; id: number; payroll_config: Omit<PayrollConfig, 'id' | 'company_id'> }
    >({
      query: ({ companyId, id, payroll_config }) => ({
        url: `/companies/${companyId}/payroll_config`,
        method: 'PATCH',
        body: { payroll_config },
      }),
      invalidatesTags: (result, error, { companyId }) => [
        { type: PAYROLL_CONFIG, id: companyId },
        { type: COMPANIES, id: companyId },
      ],
    }),
    getUnionConfig: builder.query<UnionConfigResponse, number>({
      query: (companyId) => ({
        url: `/companies/${companyId}/company_union_configuration`,
        method: 'GET',
      }),
      providesTags: (result, error, companyId) => [
        { type: UNION_CONFIG, id: companyId },
        { type: COMPANIES, id: companyId },
      ],
    }),
    createUnionConfig: builder.mutation<
      UnionConfig,
      { companyId: number; company_union_configuration: Omit<UnionConfig, 'id' | 'company_id'> }
    >({
      query: ({ companyId, company_union_configuration }) => ({
        url: `/companies/${companyId}/company_union_configuration`,
        method: 'POST',
        body: { company_union_configuration },
      }),
      invalidatesTags: (result, error, { companyId }) => [
        { type: UNION_CONFIG, id: companyId },
        { type: COMPANIES, id: companyId },
      ],
    }),
    updateUnionConfig: builder.mutation<
      UnionConfig,
      {
        companyId: number;
        unionId: number;
        company_union_configuration: Omit<UnionConfig, 'id' | 'company_id'>;
      }
    >({
      query: ({ companyId, unionId, company_union_configuration }) => ({
        url: `/companies/${companyId}/company_union_configuration`,
        method: 'PATCH',
        body: { company_union_configuration },
      }),
      invalidatesTags: (result, error, { companyId }) => [
        { type: UNION_CONFIG, id: companyId },
        { type: COMPANIES, id: companyId },
      ],
    }),
    getPresignedUrl: builder.mutation<PresignedUrlResponse, PresignedUrlParams>({
      query: (fileData) => ({
        url: `/uploads/presigned_url`,
        method: 'POST',
        body: fileData,
      }),
    }),
    attachFileToRecord: builder.mutation<void, { companyId: number; body: any }>({
      query: ({ companyId, body }) => ({
        url: `/companies/${companyId}`,
        method: 'PATCH',
        body,
      }),
      invalidatesTags: (result, error, { companyId }) => [{ type: COMPANIES, id: companyId }],
    }),
    submitForReview: builder.mutation<void, number>({
      query: (companyId) => ({
        url: `/companies/${companyId}/submit_for_review`,
        method: 'POST',
      }),
      invalidatesTags: (result, error, companyId) => [
        { type: COMPANIES, id: companyId },
        { type: REVIEW_STATUS, id: companyId },
      ],
    }),
    getReviewStatus: builder.query<
      {
        status: string;
        message: string;
        data: {
          review_status: {
            status: string;
            notes: string | null;
            reviewed_at: string | null;
            reviewed_by: string | null;
          };
        };
      },
      number
    >({
      query: (companyId) => ({
        url: `/companies/${companyId}/review_status`,
        method: 'GET',
      }),
      providesTags: (result, error, companyId) => [
        { type: REVIEW_STATUS, id: companyId },
        { type: COMPANIES, id: companyId },
      ],
    }),
  }),
});

export default api;
export const {
  useListQuery,
  useGetQuery,
  useCreateMutation,
  useUpdateMutation,
  useDeleteMutation,
  useGetBankConfigQuery,
  useCreateBankConfigMutation,
  useUpdateBankConfigMutation,
  useGetPayrollConfigQuery,
  useCreatePayrollConfigMutation,
  useUpdatePayrollConfigMutation,
  useGetUnionConfigQuery,
  useCreateUnionConfigMutation,
  useUpdateUnionConfigMutation,
  useAttachFileToRecordMutation,
  useGetPresignedUrlMutation,
  useSubmitForReviewMutation,
  useGetReviewStatusQuery,
} = api;

export { useCompany } from './hooks';
