import type * as apitype from './types';
import * as consts from './const';

const getOpts = {
  method: 'GET',
  headers: {
    'Content-Type': 'application/json'
  }
};

// const postOpts = (payload: object) => ({
//   method: 'POST',
//   headers: {
//     'Content-Type': 'application/json'
//   },
//   body: JSON.stringify(payload)
// });

// TODO: 今かなり PUT 使ってるけど同じエンドポイントに対しては POST のほうがよさそう
const putOpts = (payload: object) => ({
  method: 'PUT',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify(payload)
});

// Records
export const fetchRecords = async (params: string): Promise<apitype.RecordsResponse> => {
  return fetch(`${consts.ApiBaseUrl}/v1/records?${params}`, getOpts).then((res) => {
    if (!res.ok) {
      throw new Error('Failed to fetch records');
    }
    return res?.json();
  });
};

export const putRecord = async (
  record: apitype.PutRecordRequest
): Promise<apitype.PutRecordResponse> => {
  return fetch(`${consts.ApiBaseUrl}/v1/records`, putOpts(record)).then((res) => {
    if (!res.ok) {
      throw new Error('Failed to put record');
    }
    return res?.json();
  });
};

// Categories
export const fetchCategories = async (): Promise<apitype.CategoriesResponse> => {
  return fetch(`${consts.ApiBaseUrl}/v1/categories`, getOpts).then((res) => {
    if (!res.ok) {
      throw new Error('Failed to fetch categories');
    }
    return res?.json();
  });
};

export const putCategory = async (
  req: apitype.PutCategoryRequest
): Promise<apitype.PutCategoryResponse> => {
  return fetch(`${consts.ApiBaseUrl}/v1/categories`, putOpts(req)).then((res) => {
    if (!res.ok) {
      throw new Error('Failed to put category');
    }
    return res?.json();
  });
};

export const updateCategory = async (
  req: apitype.UpdateCategoryRequest
): Promise<apitype.UpdateCategoryResponse> => {
  return fetch(`${consts.ApiBaseUrl}/v1/categories/${req.id}`, putOpts(req)).then((res) => {
    if (!res.ok) {
      throw new Error('Failed to update category');
    }
    return res?.json();
  });
};

// Payment Methods
export const fetchPaymentMethods = async (): Promise<apitype.PaymentMethodsResponse> => {
  return fetch(`${consts.ApiBaseUrl}/v1/payment_methods`, getOpts).then((res) => {
    if (!res.ok) {
      throw new Error('Failed to fetch payment methods');
    }
    return res?.json();
  });
};

export const putPaymentMethod = async (
  req: apitype.PutPaymentMethodRequest
): Promise<apitype.PutPaymentMethodResponse> => {
  return fetch(`${consts.ApiBaseUrl}/v1/payment_methods`, putOpts(req)).then((res) => {
    if (!res.ok) {
      throw new Error('Failed to put payment method');
    }
    return res?.json();
  });
};

// Invoice Records
export const fetchInvoiceRecords = async (
  params: string
): Promise<apitype.InvoiceRecordsResponse> => {
  return fetch(`${consts.ApiBaseUrl}/v1/invoice_records?${params}`, getOpts).then((res) => {
    if (!res.ok) {
      throw new Error('Failed to fetch invoice records');
    }
    return res?.json();
  });
};

export const putInvoiceRecord = async (
  req: apitype.PutInvoiceRecordRequest
): Promise<apitype.PutInvoiceRecordResponse> => {
  return fetch(`${consts.ApiBaseUrl}/v1/invoice_records`, putOpts(req)).then((res) => {
    if (!res.ok) {
      throw new Error('Failed to put invoice_records');
    }
    return res?.json();
  });
};
