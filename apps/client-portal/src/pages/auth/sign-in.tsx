import { Helmet } from 'react-helmet-async';

import { CONFIG } from 'src/global-config';

import SignInView from 'src/auth/view/SignInView';

// ----------------------------------------------------------------------

const metadata = { title: `Sign in | Amplify - ${CONFIG.appName}` };

export default function Page() {
  return (
    <>
      <Helmet>
        <title> {metadata.title}</title>
      </Helmet>

      <SignInView />
    </>
  );
}
