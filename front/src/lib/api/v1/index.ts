import { flags } from '$lib/feature-flags';
import * as mock from './mock';
import * as api from './api';

export const {
  fetchRecords,
  createRecord,
  updateRecord,
  deleteRecord,
  fetchCategories,
  createCategory,
  updateCategory,
  fetchPaymentMethods,
  createPaymentMethod,
  updatePaymentMethod,
  fetchInvoiceRecords,
  createInvoiceRecord,
  updateInvoiceRecord,
  deleteInvoiceRecord,
  fetchCategoryAggregation,
  fetchInvoiceRecordsWithdrawalAggregation,
} = flags.useMockApi ? mock : api;
