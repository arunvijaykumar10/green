import { useGetQuery } from './api';

export const useCompany = (companyId: number) => {
  const {
    data,
    error,
    isLoading,
    isError,
    refetch,
  } = useGetQuery(companyId);

  return {
    company: data?.data?.company,
    error,
    isLoading,
    isError,
    refetch,
  };
};