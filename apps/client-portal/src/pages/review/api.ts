import { createApi } from '@reduxjs/toolkit/query/react';

import { apiBaseQuery } from 'src/redux/apiBaseQuery';

import type { CompanyReviewsResponse } from './types';

const COMPANIES_TAG = 'COMPANIES';

const api = createApi({
  reducerPath: 'reviewAPi',
  baseQuery: apiBaseQuery(),
  tagTypes: [COMPANIES_TAG],
  endpoints: (builder) => ({
    listCompanies: builder.query<CompanyReviewsResponse, void>({
      query: () => '/company_reviews',
      providesTags: [COMPANIES_TAG],
    }),
    approveCompany: builder.mutation<void, { companyId: string; review_notes: string }>({
      query: ({ companyId, review_notes }) => ({
        url: `/company_reviews/${companyId}/approve`,
        method: 'PATCH',
        body: { review_notes },
      }),
      invalidatesTags: (_result, _error, { companyId }) => [
        COMPANIES_TAG,
        { type: COMPANIES_TAG, id: companyId },
      ],
    }),
    rejectCompany: builder.mutation<void, { companyId: string; review_notes: string }>({
      query: ({ companyId, review_notes }) => ({
        url: `/company_reviews/${companyId}/reject`,
        method: 'PATCH',
        body: { review_notes },
      }),
      invalidatesTags: (_result, _error, { companyId }) => [
        COMPANIES_TAG,
        { type: COMPANIES_TAG, id: companyId },
      ],
    }),
  }),
});

export const { useApproveCompanyMutation, useRejectCompanyMutation, useListCompaniesQuery } = api;

export default api;
