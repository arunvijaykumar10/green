import type { RouteObject } from 'react-router';

import { lazy, Suspense } from 'react';
import { Outlet, Navigate } from 'react-router';

import Company from 'src/pages/companies';
import ReviewPage from 'src/pages/review';
import { CONFIG } from 'src/global-config';
import DashboardLayout from 'src/layouts/dashboard/layout';
import CompaniesList from 'src/pages/companies/CompaniesList'; // Import the new CompaniesList component

import { LoadingScreen } from 'src/components/loading-screen';

import { AuthGuard } from 'src/auth/guard';
import { useAuthContext } from 'src/auth/hooks';

import { usePathname } from '../hooks';

// ----------------------------------------------------------------------

// Overview
const IndexPage = lazy(() => import('src/pages/dashboard'));

// Redirect component for super admin users
const DefaultRedirect = () => {
  const { user } = useAuthContext();
  const isSuperAdmin = user?.super_admin === true;

  return isSuperAdmin ? <Navigate to="/review" replace /> : <IndexPage />;
};

// Not Implemented Page
const NotImplementedPage = () => (
  <div style={{
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    height: '100%',
    flexDirection: 'column',
    padding: '40px'
  }}>
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
      { index: true, element: <DefaultRedirect /> },
      { path: 'dashboard', element: <DefaultRedirect /> },
      { path: 'review', element: <ReviewPage /> },
      { path: 'companies', element: <CompaniesList /> }, // Use the new CompaniesList component here
      { path: 'company/:id', element: <Company /> },
      { path: 'payees', element: <NotImplementedPage /> },
      { path: 'payroll', element: <NotImplementedPage /> },
      { path: 'taxes', element: <NotImplementedPage /> },
      { path: 'reports', element: <NotImplementedPage /> },
      { path: 'settings', element: <NotImplementedPage /> },
    ],
  },
];

export { dashboardRoutes };
