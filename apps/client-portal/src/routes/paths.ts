const ROOTS = {
  AUTH: '/auth',
};

// ----------------------------------------------------------------------

export const paths = {
  page403: '/error/403',
  page404: '/error/404',
  page500: '/error/500',
  // AUTH
  auth: {
    signIn: `${ROOTS.AUTH}/sign-in`,
    verify: `${ROOTS.AUTH}/verify`,
    signUp: `${ROOTS.AUTH}/sign-up`,
    updatePassword: `${ROOTS.AUTH}/update-password`,
    resetPassword: `${ROOTS.AUTH}/reset-password`,
  },
  // DASHBOARD
  app: {
    root: `/dashboard`,
    review: '/review',
    companies: '/companies',
    dashboard: `/dashboard`,
    company: `/company`,
    payroll: `/payroll`,
    taxes: `/taxes`,
    reports: `/reports`,
    settings: `/settings`,
    payees: `/payees`,
  },
};