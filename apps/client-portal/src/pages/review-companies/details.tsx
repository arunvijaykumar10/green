import { Helmet } from 'react-helmet-async';

import { CONFIG } from 'src/global-config';

import CompanyDetailsView from 'src/sections/review-companies/details/CompanyDetailsView';

const metadata = { title: `Companies - ${CONFIG.appName}` };

const CompanyDetails = () => (
  <>
    <Helmet>
      <title>{metadata.title}</title>
    </Helmet>

    <CompanyDetailsView />
  </>
);

export default CompanyDetails;
