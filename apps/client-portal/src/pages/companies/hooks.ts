import { useGetQuery } from './api';

export const useCompany = (companyId: number | null) => {
  const id = companyId || 0;
  const { data, error, isLoading, isError } = useGetQuery(id, { skip: !companyId });

  return {
    company: data?.data?.company,
    error,
    isLoading,
    isError,
  };
};
