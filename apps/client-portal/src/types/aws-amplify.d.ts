import 'aws-amplify/auth';

declare module 'aws-amplify/auth' {
  interface AuthUserAttributes<T> {
    'custom:role_id': number;
  }
}