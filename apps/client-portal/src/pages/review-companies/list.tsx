import { Helmet } from 'react-helmet-async';

import { CONFIG } from 'src/global-config';

import CompaniesListView from 'src/sections/review-companies/list/CompaniesListView';

const metadata = { title: `Companies - ${CONFIG.appName}` };

const CompanyDetails = () => (
  <>
    <Helmet>
      <title>{metadata.title}</title>
    </Helmet>

    <CompaniesListView />
  </>
);

export default CompanyDetails;
