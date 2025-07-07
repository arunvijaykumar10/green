import { createApi } from '@reduxjs/toolkit/query/react';

import companies_api from 'src/pages/companies/api';
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
    approveCompany: builder.mutation<
      void,
      { companyId: string; review_notes: string; reviewID: string }
    >({
      query: ({ review_notes, reviewID }) => ({
        url: `/company_reviews/${reviewID}/approve`,
        method: 'PATCH',
        body: { review_notes },
      }),
      invalidatesTags: (_result, _error, { companyId }) => [
        COMPANIES_TAG,
        { type: COMPANIES_TAG, id: companyId },
      ],
      async onQueryStarted(args, { dispatch, queryFulfilled }) {
        try {
          await queryFulfilled;

          dispatch(
            companies_api.util.invalidateTags([
              'COMPANIES',
              { type: 'COMPANIES', id: args.companyId },
            ])
          );
        } catch (error) {
          console.error('Error during enquiry invalidation:', error);
        }
      },
    }),
    rejectCompany: builder.mutation<
      void,
      { companyId: string; review_notes: string; reviewID: string }
    >({
      query: ({ review_notes, reviewID }) => ({
        url: `/company_reviews/${reviewID}/reject`,
        method: 'PATCH',
        body: { review_notes },
      }),
      invalidatesTags: (_result, _error, { companyId }) => [
        COMPANIES_TAG,
        { type: COMPANIES_TAG, id: companyId },
      ],
      async onQueryStarted(args, { dispatch, queryFulfilled }) {
        try {
          await queryFulfilled;

          dispatch(
            companies_api.util.invalidateTags([
              'COMPANIES',
              { type: 'COMPANIES', id: args.companyId },
            ])
          );
        } catch (error) {
          console.error('Error during enquiry invalidation:', error);
        }
      },
    }),
  }),
});

export const { useApproveCompanyMutation, useRejectCompanyMutation, useListCompaniesQuery } = api;

export default api;
