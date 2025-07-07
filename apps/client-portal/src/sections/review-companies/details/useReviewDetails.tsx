import type { CompanyReview } from 'src/pages/review-companies/types';

import _ from 'lodash';
import dayjs from 'dayjs';
import { useParams } from 'react-router';

import { useCompany, useListQuery } from 'src/pages/companies/api';
import {
  useListCompaniesQuery,
  useRejectCompanyMutation,
  useApproveCompanyMutation,
} from 'src/pages/review-companies/api';

export const useReviewDetails = () => {
  const { id: companyName = '' } = useParams();

  // API calls
  const { data: companyReviewsResponse, isLoading: companiesLoading } = useListCompaniesQuery();
  const { data: companiesResponse } = useListQuery();
  const [approve] = useApproveCompanyMutation();
  const [reject] = useRejectCompanyMutation();

  const isCompanyReview = (currentCom: any): currentCom is CompanyReview =>
    currentCom && currentCom.company !== undefined;

  const currentCompany =
    _.find(
      companyReviewsResponse?.data.company_reviews,
      (company) => company?.company.name === companyName
    ) || _.find(companiesResponse?.data.companies, (company) => company?.name === companyName);

  const companyID =
    (isCompanyReview(currentCompany) ? currentCompany?.company.id : currentCompany?.id) || 0;
  const { company: companyDetails, isLoading: companyLoading } = useCompany(companyID);

  const reviewID = _.find(
    companyReviewsResponse?.data?.company_reviews,
    (company) => company?.company.id === companyID
  )?.id;

  const isLoading = companiesLoading || companyLoading;

  const status = isCompanyReview(currentCompany)
    ? currentCompany.status
    : currentCompany?.approved
      ? 'approved'
      : 'rejected';

  const handleApprove = (notes = '') => {
    if (reviewID) {
      approve({ reviewID: String(reviewID), review_notes: notes, companyId: String(companyID) });
    }
  };

  const handleReject = (notes = '') => {
    if (reviewID) {
      reject({ reviewID: String(reviewID), review_notes: notes, companyId: String(companyID) });
    }
  };

  const formatDate = (date: string) => dayjs(date).format('MMM DD, YYYY [at] h:mm A');

  return {
    company: companyDetails,
    isLoading,
    status,
    handleApprove,
    handleReject,
    formatDate,
    currentAddress: companyDetails?.addresses.find((addr) => addr.active_until === null),
  };
};
