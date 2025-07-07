import type { RouteObject } from 'react-router';

import { Outlet } from 'react-router';
import { lazy, Suspense } from 'react';

import { CONFIG } from 'src/global-config';
import DashboardLayout from 'src/layouts/dashboard/layout';
// Import the new CompaniesList component

import { LoadingScreen } from 'src/components/loading-screen';

import { AuthGuard } from 'src/auth/guard';

import { usePathname } from '../hooks';

// ----------------------------------------------------------------------

// Overview
const IndexPage = lazy(() => import('src/pages/dashboard'));
const CompaniesListPage = lazy(() => import('src/pages/review-companies/list'));
const CompaniesDetailsPage = lazy(() => import('src/pages/review-companies/details'));

// Not Implemented Page
const NotImplementedPage = () => (
  <div
    style={{
      display: 'flex',
      justifyContent: 'center',
      alignItems: 'center',
      height: '100%',
      flexDirection: 'column',
      padding: '40px',
    }}
  >
    <h2>Coming Soon</h2>
    <p>This page is not implemented yet.</p>
  </div>
);

// ----------------------------------------------------------------------

function SuspenseOutlet() {
  const pathname = usePathname();
  return (
    <Suspense key={pathname} fallback={<LoadingScreen />}>
      <Outlet />
    </Suspense>
  );
}

const dashboardLayout = () => (
  <DashboardLayout>
    <SuspenseOutlet />
  </DashboardLayout>
);
const dashboardRoutes: RouteObject[] = [
  {
    path: '/',
    element: CONFIG.auth.skip ? dashboardLayout() : <AuthGuard>{dashboardLayout()}</AuthGuard>,
    children: [
      { index: true, element: <IndexPage /> },
      { path: 'dashboard', element: <IndexPage /> },
      {
        path: 'companies',
        children: [
          { index: true, element: <CompaniesListPage /> },
          { path: ':id', element: <CompaniesDetailsPage /> },
        ],
      },
      { path: 'payees', element: <NotImplementedPage /> },
      { path: 'payroll', element: <NotImplementedPage /> },
      { path: 'taxes', element: <NotImplementedPage /> },
      { path: 'reports', element: <NotImplementedPage /> },
      { path: 'settings', element: <NotImplementedPage /> },
    ],
  },
];

export { dashboardRoutes };
