import { Helmet } from 'react-helmet-async';

import { CONFIG } from 'src/global-config';

import ResetPasswordView from 'src/auth/view/ResetPasswordView';

// ----------------------------------------------------------------------

const metadata = { title: `Reset password | Amplify - ${CONFIG.appName}` };

export default function Page() {
  return (
    <>
      <Helmet>
        <title> {metadata.title}</title>
      </Helmet>

      <ResetPasswordView />
    </>
  );
}
