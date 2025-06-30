import { createApi } from '@reduxjs/toolkit/query/react';

import { apiBaseQuery } from 'src/redux/apiBaseQuery';

import type { ProfileResponse } from './types';

const api = createApi({
  reducerPath: 'roles_api',
  baseQuery: apiBaseQuery(),
  endpoints: (builder) => ({
    login: builder.mutation<any, { email: string }>({
      query: (body) => ({
        url: '/login',
        method: 'POST',
        body,
      }),
    }),
    profile: builder.query<ProfileResponse, void>({
      query: () => ({
        url: '/me',
        method: 'GET',
      }),
    }),
    register: builder.mutation<any, any>({
      query: (body) => ({
        url: '/public/register',
        method: 'POST',
        body,
      }),
    }),
    roles: builder.query<any[], void>({
      query: () => ({
        url: '/public/admin_roles',
        method: 'GET',
      }),
      transformResponse: (response: any) => response.data.admin_roles,
    }),
  }),
});

export default api;
export const { useLoginMutation, useProfileQuery, useRegisterMutation, useRolesQuery } = api;
