import type * as apitype from './types';
import { getRecordTypeLabel, getStateLabel, getInvoiceRecordStateLabel, TodoIds } from './const';

const KEYS = {
  records: 'finascope_records',
  categories: 'finascope_categories',
  payment_methods: 'finascope_payment_methods',
  invoice_records: 'finascope_invoice_records'
} as const;

function load<T>(key: string): T[] {
  try {
    return JSON.parse(localStorage.getItem(key) ?? '[]') as T[];
  } catch {
    return [];
  }
}

function save<T>(key: string, data: T[]): void {
  localStorage.setItem(key, JSON.stringify(data));
}

// Records

export const fetchRecords = async (
  beginDate?: string,
  endDate?: string
): Promise<apitype.RecordsResponse> => {
  let records = load<apitype.Record>(KEYS.records);
  if (beginDate) records = records.filter((r) => r.date >= beginDate);
  if (endDate) records = records.filter((r) => r.date <= endDate);
  return { records };
};

export const createRecord = async (
  req: apitype.CreateRecordRequest
): Promise<apitype.CreateRecordResponse> => {
  const records = load<apitype.Record>(KEYS.records);
  const categories = load<apitype.Category>(KEYS.categories);
  const paymentMethods = load<apitype.PaymentMethod>(KEYS.payment_methods);

  const category = categories.find((c) => c.id === req.category_id);
  const paymentMethod = paymentMethods.find((p) => p.id === req.payment_method_id);

  const id = crypto.randomUUID();
  records.push({
    id,
    type: getRecordTypeLabel(req.type_id),
    title: req.title,
    amount: req.amount,
    state: getStateLabel(req.state_id),
    category: category?.label ?? (req.category_id === TodoIds.Category ? 'TODO' : ''),
    payment_method:
      paymentMethod?.label ?? (req.payment_method_id === TodoIds.PaymentMethod ? 'TODO' : ''),
    date: req.date,
    description: req.description,
    record_type_id: req.type_id,
    state_id: req.state_id,
    category_id: req.category_id,
    payment_method_id: req.payment_method_id
  });
  save(KEYS.records, records);
  return { status: 'success', id };
};

export const updateRecord = async (
  req: apitype.UpdateRecordRequest
): Promise<apitype.UpdateRecordResponse> => {
  const records = load<apitype.Record>(KEYS.records);
  const categories = load<apitype.Category>(KEYS.categories);
  const paymentMethods = load<apitype.PaymentMethod>(KEYS.payment_methods);

  const category = categories.find((c) => c.id === req.category_id);
  const paymentMethod = paymentMethods.find((p) => p.id === req.payment_method_id);

  const idx = records.findIndex((r) => r.id === req.id);
  if (idx === -1) return { status: 'not_found', id: req.id };

  records[idx] = {
    ...records[idx],
    type: getRecordTypeLabel(req.type_id),
    title: req.title,
    amount: req.amount,
    state: getStateLabel(req.state_id),
    category: category?.label ?? (req.category_id === TodoIds.Category ? 'TODO' : ''),
    payment_method:
      paymentMethod?.label ?? (req.payment_method_id === TodoIds.PaymentMethod ? 'TODO' : ''),
    date: req.date,
    description: req.description,
    record_type_id: req.type_id,
    state_id: req.state_id,
    category_id: req.category_id,
    payment_method_id: req.payment_method_id
  };
  save(KEYS.records, records);
  return { status: 'success', id: req.id };
};

export const deleteRecord = async (
  req: apitype.CommonIdRequest
): Promise<apitype.CommonResponse> => {
  const records = load<apitype.Record>(KEYS.records);
  save(
    KEYS.records,
    records.filter((r) => r.id !== req.id)
  );
  return { status: 'success', id: req.id };
};

// Categories

export const fetchCategories = async (): Promise<apitype.CategoriesResponse> => {
  return { categories: load<apitype.Category>(KEYS.categories) };
};

export const createCategory = async (
  req: apitype.CreateCategoryRequest
): Promise<apitype.CreateCategoryResponse> => {
  const categories = load<apitype.Category>(KEYS.categories);
  const id = crypto.randomUUID();
  categories.push({ id, label: req.label });
  save(KEYS.categories, categories);
  return { status: 'success', id };
};

export const updateCategory = async (
  req: apitype.UpdateCategoryRequest
): Promise<apitype.UpdateCategoryResponse> => {
  const categories = load<apitype.Category>(KEYS.categories);
  const idx = categories.findIndex((c) => c.id === req.id);
  if (idx === -1) return { status: 'not_found', id: req.id };
  categories[idx] = { ...categories[idx], label: req.label };
  save(KEYS.categories, categories);
  return { status: 'success', id: req.id };
};

// Payment Methods

export const fetchPaymentMethods = async (): Promise<apitype.PaymentMethodsResponse> => {
  return { payment_methods: load<apitype.PaymentMethod>(KEYS.payment_methods) };
};

export const createPaymentMethod = async (
  req: apitype.CreatePaymentMethodRequest
): Promise<apitype.CreatePaymentMethodResponse> => {
  const methods = load<apitype.PaymentMethod>(KEYS.payment_methods);
  const id = crypto.randomUUID();
  methods.push({
    id,
    label: req.label,
    withdrawal_day_of_month: req.withdrawal_day_of_month,
    closing_day_of_month: req.closing_day_of_month
  });
  save(KEYS.payment_methods, methods);
  return { status: 'success', id };
};

export const updatePaymentMethod = async (
  req: apitype.UpdatePaymentMethodRequest
): Promise<apitype.UpdatePaymentMethodResponse> => {
  const methods = load<apitype.PaymentMethod>(KEYS.payment_methods);
  const idx = methods.findIndex((m) => m.id === req.id);
  if (idx === -1) return { status: 'not_found', id: req.id };
  methods[idx] = {
    ...methods[idx],
    label: req.label,
    withdrawal_day_of_month: req.withdrawal_day_of_month,
    closing_day_of_month: req.closing_day_of_month
  };
  save(KEYS.payment_methods, methods);
  return { status: 'success', id: req.id };
};

// Invoice Records

export const fetchInvoiceRecords = async (
  query?: string
): Promise<apitype.InvoiceRecordsResponse> => {
  let records = load<apitype.InvoiceRecord>(KEYS.invoice_records);
  if (query) {
    const params = new URLSearchParams(query);
    const paymentMethodId = params.get('payment_method_id');
    if (paymentMethodId) records = records.filter((r) => r.payment_method_id === paymentMethodId);
  }
  return { records };
};

export const createInvoiceRecord = async (
  req: apitype.CreateInvoiceRecordRequest
): Promise<apitype.CommonResponse> => {
  const records = load<apitype.InvoiceRecord>(KEYS.invoice_records);
  const paymentMethods = load<apitype.PaymentMethod>(KEYS.payment_methods);
  const paymentMethod = paymentMethods.find((p) => p.id === req.payment_method_id);

  const id = crypto.randomUUID();
  records.push({
    id,
    state: getInvoiceRecordStateLabel(req.state_id),
    state_id: req.state_id,
    amount: req.amount,
    payment_method: paymentMethod?.label ?? '',
    payment_method_id: req.payment_method_id,
    withdrawal_date: req.withdrawal_date
  });
  save(KEYS.invoice_records, records);
  return { status: 'success', id };
};

export const updateInvoiceRecord = async (
  req: apitype.UpdateInvoiceRecordRequest
): Promise<apitype.CommonResponse> => {
  const records = load<apitype.InvoiceRecord>(KEYS.invoice_records);
  const idx = records.findIndex((r) => r.id === req.id);
  if (idx === -1) return { status: 'not_found', id: req.id };
  records[idx] = {
    ...records[idx],
    state: getInvoiceRecordStateLabel(req.state_id),
    state_id: req.state_id,
    amount: req.amount,
    withdrawal_date: req.withdrawal_date
  };
  save(KEYS.invoice_records, records);
  return { status: 'success', id: req.id };
};

export const deleteInvoiceRecord = async (
  req: apitype.CommonIdRequest
): Promise<apitype.CommonResponse> => {
  const records = load<apitype.InvoiceRecord>(KEYS.invoice_records);
  save(
    KEYS.invoice_records,
    records.filter((r) => r.id !== req.id)
  );
  return { status: 'success', id: req.id };
};

// View - aggregations (not supported in local mode)

export const fetchCategoryAggregation = async (): Promise<apitype.CategoryAggregationResponse> => {
  return { aggregations: [] };
};

export const fetchInvoiceRecordsWithdrawalAggregation = async (
  _: apitype.InvoiceRecordsWithdrawalAggregationRequest
): Promise<apitype.InvoiceRecordsWithdrawalAggregationResponse> => {
  return {
    aggregation: {
      payment_method_id: '',
      payment_method: '',
      total_amount: 0,
      begin_date: '',
      end_date: '',
      records: []
    }
  };
};
