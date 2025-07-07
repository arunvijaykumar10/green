import { Helmet } from 'react-helmet-async';

import { CONFIG } from 'src/global-config';

import DashboardView from 'src/sections/dashboard';

// ----------------------------------------------------------------------

const metadata = { title: `Dashboard - ${CONFIG.appName}` };

export default function DashboardPage() {
  return (
    <>
      <Helmet>
        <title>{metadata.title}</title>
      </Helmet>
      <DashboardView />
    </>
  );
}
