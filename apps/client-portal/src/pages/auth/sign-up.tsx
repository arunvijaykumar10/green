import { Helmet } from 'react-helmet-async';

import { CONFIG } from 'src/global-config';

import SignUpView from 'src/auth/view/SignUpView';

// ----------------------------------------------------------------------

const metadata = { title: `Sign up  - ${CONFIG.appName}` };

export default function Page() {
  return (
    <>
      <Helmet>
        <title> {metadata.title}</title>
      </Helmet>

      <SignUpView />
    </>
  );
}
