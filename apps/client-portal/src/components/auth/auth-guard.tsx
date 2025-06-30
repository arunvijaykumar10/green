import { useEffect } from 'react';

import { useProfileQuery } from 'src/pages/auth/api';

import { useAuthContext } from 'src/auth/hooks';

type AuthGuardProps = {
  children: React.ReactNode;
};

export default function AuthGuard({ children }: AuthGuardProps) {
  const { authenticated } = useAuthContext();
  const { refetch } = useProfileQuery(undefined, { skip: !authenticated });

  useEffect(() => {
    if (authenticated) {
      refetch();
    }
  }, [authenticated, refetch]);

  return <>{children}</>;
}
