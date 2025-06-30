import type { RouteObject } from 'react-router';

import { Outlet } from 'react-router';
import { lazy, Suspense } from 'react';

import { SplashScreen } from 'src/components/loading-screen';

import { GuestGuard } from 'src/auth/guard';

// ----------------------------------------------------------------------

const SignInPage = lazy(() => import('src/pages/auth/sign-in'));
const SignUpPage = lazy(() => import('src/pages/auth/sign-up'));
const VerifyPage = lazy(() => import('src/pages/auth/verify'));
const UpdatePasswordPage = lazy(() => import('src/pages/auth/update-password'));
const ResetPasswordPage = lazy(() => import('src/pages/auth/reset-password'));

// ----------------------------------------------------------------------

export const authRoutes: RouteObject[] = [
  {
    path: 'auth',
    element: (
      <Suspense fallback={<SplashScreen />}>
        <Outlet />
      </Suspense>
    ),
    children: [
      {
        path: 'sign-in',
        element: (
          <GuestGuard>
            <SignInPage />
          </GuestGuard>
        ),
      },
      {
        path: 'sign-up',
        element: (
          <GuestGuard>
            <SignUpPage />
          </GuestGuard>
        ),
      },
      {
        path: 'verify',
        element: <VerifyPage />,
      },
      {
        path: 'reset-password',
        element: <ResetPasswordPage />,
      },
      {
        path: 'update-password',
        element: <UpdatePasswordPage />,
      },
    ],
  },
];
