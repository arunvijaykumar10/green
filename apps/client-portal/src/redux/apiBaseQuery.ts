import qs from 'qs';
import _ from 'lodash';
import { retry, fetchBaseQuery } from '@reduxjs/toolkit/query/react';

import { CONFIG } from 'src/global-config';


export interface ParamsObject {
  [key: string]: string | string[];
}
/* ----------apiBaseQuery---------- */
const paramsSerializer = (params: ParamsObject): string =>
  _.chain(params)
    .omitBy((v) => {
      const isEmpty = (_.isString(v) || _.isArray(v)) && _.isEmpty(v);
      return _.isNil(v) || isEmpty;
    })
    .thru((p) => qs.stringify(p, { arrayFormat: 'brackets', encode: false }))
    .value();

export const apiBaseQuery = () =>
  retry(
    fetchBaseQuery({
      baseUrl: CONFIG.apiHost,
      prepareHeaders: (headers: Headers, { getState }) => {
        if (!headers.has('no-auth')) {
          const { token } = _.get(getState(), 'auth', { token: '', account: {} });
          if (token) {
            headers.set('Accept', 'application/json');
            headers.set('Content-Encoding', 'gzip');
            headers.set('Authorization', `${token}`);
          }
        }
      },
      paramsSerializer,
    }),
    {
      maxRetries: 0,
    }
  );
