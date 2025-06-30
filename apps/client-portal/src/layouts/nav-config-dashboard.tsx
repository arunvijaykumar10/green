import type { NavSectionProps } from 'src/components/nav-section';

import { paths } from 'src/routes/paths';

import { CONFIG } from 'src/global-config';

import { SvgColor } from 'src/components/svg-color';

import { useAuthContext } from 'src/auth/hooks';

// ----------------------------------------------------------------------

const icon = (name: string) => (
  <SvgColor src={`${CONFIG.assetsDir}/assets/icons/navbar/${name}.svg`} />
);

const ICONS = {
  job: icon('ic-job'),
  blog: icon('ic-blog'),
  chat: icon('ic-chat'),
  mail: icon('ic-mail'),
  user: icon('ic-user'),
  file: icon('ic-file'),
  lock: icon('ic-lock'),
  tour: icon('ic-tour'),
  order: icon('ic-order'),
  label: icon('ic-label'),
  blank: icon('ic-blank'),
  kanban: icon('ic-kanban'),
  folder: icon('ic-folder'),
  course: icon('ic-course'),
  banking: icon('ic-banking'),
  booking: icon('ic-booking'),
  invoice: icon('ic-invoice'),
  product: icon('ic-product'),
  calendar: icon('ic-calendar'),
  disabled: icon('ic-disabled'),
  external: icon('ic-external'),
  menuItem: icon('ic-menu-item'),
  ecommerce: icon('ic-ecommerce'),
  analytics: icon('ic-analytics'),
  dashboard: icon('ic-dashboard'),
  parameter: icon('ic-parameter'),
};

// ----------------------------------------------------------------------

export const useNavData = (): NavSectionProps['data'] => {
  const { user } = useAuthContext();
  const isSuperAdmin = user?.user.super_admin === true;

  const baseItems = [
    { title: 'Company', path: paths.app.company, icon: ICONS.banking },
    { title: 'Dashboard', path: paths.app.dashboard, icon: ICONS.dashboard },
    { title: 'Payees', path: paths.app.payees, icon: ICONS.user },
    { title: 'Payroll', path: paths.app.payroll, icon: ICONS.ecommerce },
    { title: 'Taxes', path: paths.app.taxes, icon: ICONS.parameter },
    { title: 'Reports', path: paths.app.reports, icon: ICONS.analytics },
    { title: 'Settings', path: paths.app.settings, icon: ICONS.external },
  ];

  const items = isSuperAdmin
    ? [
      { title: 'Review', path: paths.app.review, icon: ICONS.job },
       { title: 'Companies', path: paths.app.companies, icon: ICONS.job },
    ]
    : baseItems;

  return [
    {
      subheader: 'Overview',
      items,
    },
  ];
};

// Backward compatibility
export const navData: NavSectionProps['data'] = [
  {
    subheader: 'Overview',
    items: [
      { title: 'Company', path: paths.app.company, icon: ICONS.banking },
      { title: 'Dashboard', path: paths.app.dashboard, icon: ICONS.dashboard },
      { title: 'Payees', path: paths.app.payees, icon: ICONS.user },
      { title: 'Payroll', path: paths.app.payroll, icon: ICONS.ecommerce },
      { title: 'Taxes', path: paths.app.taxes, icon: ICONS.parameter },
      { title: 'Reports', path: paths.app.reports, icon: ICONS.analytics },
      { title: 'Settings', path: paths.app.settings, icon: ICONS.external },
    ],
  },
];
