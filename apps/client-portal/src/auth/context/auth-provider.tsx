import _ from 'lodash';
import { Amplify } from 'aws-amplify';
import { useSetState } from 'minimal-shared/hooks';
import { useMemo, useEffect, useCallback } from 'react';
import { fetchAuthSession, fetchUserAttributes } from 'aws-amplify/auth';

import { CONFIG } from 'src/global-config';
import { dispatch } from 'src/redux/store';
import { useProfileQuery } from 'src/pages/auth/api';
import { setUser, setToken } from 'src/redux/slice/auth';

import { AuthContext } from './auth-context';


// ----------------------------------------------------------------------

/**
 * NOTE:
 * We only build demo at basic level.
 * Customer will need to do some extra handling yourself if you want to extend the logic and other features...
 */

/**
 * Docs:
 * https://docs.amplify.aws/react/build-a-backend/auth/manage-user-session/
 */

Amplify.configure({
  Auth: {
    Cognito: {
      userPoolId: CONFIG.amplify.userPoolId,
      userPoolClientId: CONFIG.amplify.userPoolWebClientId,
    },
  },
});

// ----------------------------------------------------------------------

type Props = {
  children: React.ReactNode;
};

export function AuthProvider({ children }: Props) {
  const { state, setState } = useSetState<any>({ user: null, loading: true, authenticated: false, credentials: null });

  const checkAuthenticated = state.authenticated ? 'authenticated' : 'unauthenticated';

  const status = state.loading ? 'loading' : checkAuthenticated;
  const { data: userDetails } = useProfileQuery(undefined, { skip: !state.authenticated });


  const checkUserSession = useCallback(async () => {
    try {
      const authSession = (await fetchAuthSession({ forceRefresh: true })).tokens;

      if (authSession) {
        const userAttributes = await fetchUserAttributes();
        const accessToken = authSession.accessToken.toString();

        dispatch(setToken(accessToken));
        setState({
          credentials: { ...authSession, ...userAttributes },
          loading: false,
          authenticated: true
        });
      } else {
        setState({ user: null, credentials: null, loading: false, authenticated: false });
      }
    } catch (error) {
      console.error(error);
      setState({ user: null, credentials: null, loading: false, authenticated: false });
    }
  }, [setState, dispatch]);

  useEffect(() => {
    checkUserSession();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  useEffect(() => {
    if (state.authenticated && !_.isEmpty(userDetails)) {
      setState({ user: userDetails });
      dispatch(setUser(userDetails));
    }
  }, [userDetails, setState, dispatch, state.authenticated]);

  // ----------------------------------------------------------------------



  const memoizedValue = useMemo(
    () => ({
      user: state.user,
      currentCompany: null,
      userCredentials: state.credentials,
      checkUserSession,
      loading: status === 'loading',
      authenticated: status === 'authenticated',
      unauthenticated: status === 'unauthenticated',
    }),
    [checkUserSession, state.user, state.credentials, status]
  );

  return <AuthContext.Provider value={memoizedValue}>{children}</AuthContext.Provider>;
}
