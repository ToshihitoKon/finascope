import type * as apitype from './types';
import * as consts from './const';
import { getLoginInfo } from '$lib/firebase';
import { toast } from 'svelte-sonner';

const apiBase = async (url: string, method: string, payload: object) => {
  const opts = {
    method: method,
    headers: {
      'Content-Type': 'application/json'
    }
  };
  if (method !== 'GET' && payload) {
    opts.body = JSON.stringify(payload);
  }

  try {
    const loginInfo = getLoginInfo();
    if (loginInfo.jwt) {
      opts.headers['Authorization'] = `Bearer ${loginInfo.jwt}`;
    }

    const res = await fetch(`${consts.ApiBaseUrl}/${url}`, opts);
    if (!res.ok) {
      throw new Error('Failed to fetch data');
    }
    return res.json();
  } catch (error) {
    toast.error('Failed to request API ' + url);
    throw error;
  }
};

export const fetchRecords = async (query: string): Promise<apitype.RecordsResponse> => {
  return apiBase(`v1/records?${query}`, 'GET', {});
};

export const createRecord = async (
  req: apitype.CreateRecordRequest
): Promise<apitype.CreateRecordResponse> => {
  return apiBase(`v1/records`, 'POST', req);
};

export const updateRecord = async (
  req: apitype.UpdateRecordRequest
): Promise<apitype.UpdateRecordResponse> => {
  return apiBase(`v1/records/${req.id}`, 'PUT', req);
};

export const deleteRecord = async (
  req: apitype.CommonIdRequest
): Promise<apitype.CommonResponse> => {
  return apiBase(`v1/records/${req.id}`, 'DELETE', {});
};

// Categories
export const fetchCategories = async (): Promise<apitype.CategoriesResponse> => {
  return apiBase(`v1/categories`, 'GET', {});
};

export const createCategory = async (
  req: apitype.CreateCategoryRequest
): Promise<apitype.CreateCategoryResponse> => {
  return apiBase(`v1/categories`, 'POST', req);
};

export const updateCategory = async (
  req: apitype.UpdateCategoryRequest
): Promise<apitype.UpdateCategoryResponse> => {
  return apiBase(`v1/categories/${req.id}`, 'PUT', req);
};

// Payment Methods
export const fetchPaymentMethods = async (): Promise<apitype.PaymentMethodsResponse> => {
  return apiBase(`v1/payment_methods`, 'GET', {});
};

export const createPaymentMethod = async (
  req: apitype.CreatePaymentMethodRequest
): Promise<apitype.PutPaymentMethodResponse> => {
  return apiBase(`v1/payment_methods`, 'POST', req);
};

export const updatePaymentMethod = async (
  req: apitype.UpdateCategoryRequest
): Promise<apitype.UpdateCategoryResponse> => {
  return apiBase(`v1/payment_methods/${req.id}`, 'PUT', req);
};

// Invoice Records
export const fetchInvoiceRecords = async (
  query: string
): Promise<apitype.InvoiceRecordsResponse> => {
  return apiBase(`v1/invoice_records?${query}`, 'GET', {});
};

export const createInvoiceRecord = async (
  req: apitype.CreateInvoiceRecordRequest
): Promise<apitype.CommonResponse> => {
  return apiBase(`v1/invoice_records`, 'POST', req);
};

export const updateInvoiceRecord = async (
  req: apitype.UpdateInvoiceRecordRequest
): Promise<apitype.CommonResponse> => {
  return apiBase(`v1/invoice_records/${req.id}`, 'PUT', req);
};

export const deleteInvoiceRecord = async (
  req: apitype.CommonIdRequest
): Promise<apitype.CommonResponse> => {
  return apiBase(`v1/invoice_records/${req.id}`, 'DELETE', {});
};
