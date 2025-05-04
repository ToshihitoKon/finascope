import type * as apitype from './types';
import * as consts from './const';

const getOpts = {
  method: 'GET',
  headers: {
    'Content-Type': 'application/json'
  }
};

const postOpts = (payload: object) => ({
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify(payload)
});

// TODO: 今かなり PUT 使ってるけど同じエンドポイントに対しては POST のほうがよさそう
const putOpts = (payload: object) => ({
  method: 'PUT',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify(payload)
});

// Records
export const fetchRecords = async (query: string): Promise<apitype.RecordsResponse> => {
  return fetch(`${consts.ApiBaseUrl}/v1/records?${query}`, getOpts).then((res) => {
    if (!res.ok) {
      throw new Error('Failed to fetch records');
    }
    return res?.json();
  });
};

export const createRecord = async (
  record: apitype.CreateRecordRequest
): Promise<apitype.CreateRecordResponse> => {
  return fetch(`${consts.ApiBaseUrl}/v1/records`, postOpts(record)).then((res) => {
    if (!res.ok) {
      throw new Error('Failed to create record');
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

export const createCategory = async (
  req: apitype.CreateCategoryRequest
): Promise<apitype.CreateCategoryResponse> => {
  return fetch(`${consts.ApiBaseUrl}/v1/categories`, postOpts(req)).then((res) => {
    if (!res.ok) {
      throw new Error('Failed to create category');
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

export const createPaymentMethod = async (
  req: apitype.CreatePaymentMethodRequest
): Promise<apitype.PutPaymentMethodResponse> => {
  return fetch(`${consts.ApiBaseUrl}/v1/payment_methods`, postOpts(req)).then((res) => {
    if (!res.ok) {
      throw new Error('Failed to put payment method');
    }
    return res?.json();
  });
};

export const updatePaymentMethod = async (
  req: apitype.UpdateCategoryRequest
): Promise<apitype.UpdateCategoryResponse> => {
  return fetch(`${consts.ApiBaseUrl}/v1/payment_methods/${req.id}`, putOpts(req)).then((res) => {
    if (!res.ok) {
      throw new Error('Failed to update payment method');
    }
    return res?.json();
  });
};

// Invoice Records
export const fetchInvoiceRecords = async (
  query: string
): Promise<apitype.InvoiceRecordsResponse> => {
  return fetch(`${consts.ApiBaseUrl}/v1/invoice_records?${query}`, getOpts).then((res) => {
    if (!res.ok) {
      throw new Error('Failed to fetch invoice records');
    }
    return res?.json();
  });
};

export const createInvoiceRecord = async (
  req: apitype.CreateInvoiceRecordRequest
): Promise<apitype.CreateInvoiceRecordResponse> => {
  return fetch(`${consts.ApiBaseUrl}/v1/invoice_records`, postOpts(req)).then((res) => {
    if (!res.ok) {
      throw new Error('Failed to put invoice_records');
    }
    return res?.json();
  });
};
