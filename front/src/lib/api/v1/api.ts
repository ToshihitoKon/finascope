import type * as apitype from './types';
import * as consts from './const';
import { logout, getFirebaseToken } from '$lib/firebase/index.svelte.ts';
import { toast } from 'svelte-sonner';

const apiBase = async (url: string, method: string, payload: object) => {
  const opts: RequestInit = {
    method: method,
    headers: {
      'Content-Type': 'application/json'
    }
  };
  if (method !== 'GET' && payload) {
    opts.body = JSON.stringify(payload);
  }

  try {
    const jwt = await getFirebaseToken();
    if (jwt) {
      (opts.headers as Record<string, string>)['Authorization'] = `Bearer ${jwt}`;
    }

    const res = await fetch(`${consts.ApiBaseUrl}/${url}`, opts);
    if (res.status === 401) {
      toast.error('Session expired, please login again');
      await logout();
      return;
    }
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
): Promise<apitype.CreatePaymentMethodResponse> => {
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

// View - Category Aggregation
export const fetchCategoryAggregation = async (
  beginDate?: string,
  endDate?: string
): Promise<apitype.CategoryAggregationResponse> => {
  const params = new URLSearchParams();
  if (beginDate) params.set('begin_date', beginDate);
  if (endDate) params.set('end_date', endDate);
  const query = params.toString();
  return apiBase(`v1/view/categories/aggregation${query ? `?${query}` : ''}`, 'GET', {});
};

// Invoice Records Category Aggregation
export const fetchInvoiceRecordsCategoryAggregation = async (
  req: apitype.InvoiceRecordsCategoryAggregationRequest
): Promise<apitype.InvoiceRecordsCategoryAggregationResponse> => {
  const params = new URLSearchParams({
    year: req.year.toString(),
    month: req.month.toString(),
    payment_method_id: req.payment_method_id,
    category_id: req.category_id
  });
  return apiBase(`v1/invoice_records/category_aggregation?${params.toString()}`, 'GET', {});
};
