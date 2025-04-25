import type * as apitype from './types';
import * as consts from './const';

const getOpts = {
  method: 'GET',
  headers: {
    'Content-Type': 'application/json'
  }
};

export const fetchRecords = async (): Promise<apitype.RecordsResponse> => {
  return fetch(`${consts.ApiBaseUrl}/records`, getOpts).then((res) => {
    if (!res.ok) {
      throw new Error('Failed to fetch records');
    }
    return res?.json();
  });
};

export const fetchCategories = async (): Promise<apitype.CategoriesResponse> => {
  return fetch(`${consts.ApiBaseUrl}/categories`, getOpts).then((res) => {
    if (!res.ok) {
      throw new Error('Failed to fetch categories');
    }
    return res?.json();
  });
};

export const putRecord = async (
  record: apitype.PutRecordRequest
): Promise<apitype.PutRecordResponse> => {
  return fetch(`${consts.ApiBaseUrl}/records`, {
    method: 'PUT',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(record)
  }).then((res) => {
    if (!res.ok) {
      throw new Error('Failed to put record');
    }
    return res?.json();
  });
};
