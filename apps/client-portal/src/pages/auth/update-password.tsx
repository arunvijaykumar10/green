import { Helmet } from 'react-helmet-async';

import { CONFIG } from 'src/global-config';

import UpdatePasswordView from 'src/auth/view/UpdatePasswordView';

// ----------------------------------------------------------------------

const metadata = { title: `Update password | Amplify - ${CONFIG.appName}` };

export default function Page() {
  return (
    <>
      <Helmet>
        <title> {metadata.title}</title>
      </Helmet>

      <UpdatePasswordView />
    </>
  );
}
