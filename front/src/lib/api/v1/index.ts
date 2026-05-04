import { flags } from '$lib/feature-flags';
import { auth } from '$lib/firebase/index.svelte';
import * as mock from './mock';
import * as api from './api';
import * as localApi from './localStorageApi';

const getImpl = () => {
  if (flags.useMockApi) return mock;
  return auth.currentUser !== null ? api : localApi;
};

export const fetchRecords: typeof api.fetchRecords = (...args) =>
  getImpl().fetchRecords(...args);
export const createRecord: typeof api.createRecord = (...args) =>
  getImpl().createRecord(...args);
export const updateRecord: typeof api.updateRecord = (...args) =>
  getImpl().updateRecord(...args);
export const deleteRecord: typeof api.deleteRecord = (...args) =>
  getImpl().deleteRecord(...args);

export const fetchCategories: typeof api.fetchCategories = (...args) =>
  getImpl().fetchCategories(...args);
export const createCategory: typeof api.createCategory = (...args) =>
  getImpl().createCategory(...args);
export const updateCategory: typeof api.updateCategory = (...args) =>
  getImpl().updateCategory(...args);

export const fetchPaymentMethods: typeof api.fetchPaymentMethods = (...args) =>
  getImpl().fetchPaymentMethods(...args);
export const createPaymentMethod: typeof api.createPaymentMethod = (...args) =>
  getImpl().createPaymentMethod(...args);
export const updatePaymentMethod: typeof mock.updatePaymentMethod = (...args) =>
  getImpl().updatePaymentMethod(...args);

export const fetchInvoiceRecords: typeof api.fetchInvoiceRecords = (...args) =>
  getImpl().fetchInvoiceRecords(...args);
export const createInvoiceRecord: typeof api.createInvoiceRecord = (...args) =>
  getImpl().createInvoiceRecord(...args);
export const updateInvoiceRecord: typeof api.updateInvoiceRecord = (...args) =>
  getImpl().updateInvoiceRecord(...args);
export const deleteInvoiceRecord: typeof api.deleteInvoiceRecord = (...args) =>
  getImpl().deleteInvoiceRecord(...args);

export const fetchCategoryAggregation: typeof api.fetchCategoryAggregation = (...args) =>
  getImpl().fetchCategoryAggregation(...args);
export const fetchInvoiceRecordsWithdrawalAggregation: typeof api.fetchInvoiceRecordsWithdrawalAggregation =
  (...args) => getImpl().fetchInvoiceRecordsWithdrawalAggregation(...args);
