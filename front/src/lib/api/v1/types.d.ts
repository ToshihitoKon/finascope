// Common
export interface CommonIdRequest {
  id: string;
}

export interface CommonResponse {
  id: string;
  status: string;
}

// Records
export interface Record {
  id: string;
  type: string;
  title: string;
  amount: number;
  state: string;
  category: string;
  payment_method: string;
  date: string; // NOTE: ISO 8601 format
  description: string;
  record_type_id: number;
  state_id: number;
  category_id: string;
  payment_method_id: string;
}

export interface RecordType {
  id: number;
  label: string;
}

export interface State {
  id: number;
  label: string;
}

export interface RecordsResponse {
  records: Record[];
}

export interface CreateRecordRequest {
  title: string;
  type_id: number;
  state_id: number;
  description: string;
  amount: number;
  category_id: string;
  payment_method_id: string;
  date: string; // NOTE: ISO 8601 format
}

export interface CreateRecordResponse {
  status: string;
}

export interface UpdateRecordRequest {
  id: string;
  title: string;
  type_id: number;
  state_id: number;
  description: string;
  amount: number;
  category_id: string;
  payment_method_id: string;
  date: string; // NOTE: ISO 8601 format
}

export interface UpdateRecordResponse {
  status: string;
  id: string;
}

// Categories
export interface Category {
  id: string;
  label: string;
}

export interface CategoriesResponse {
  categories: Category[];
}

export interface CreateCategoryRequest {
  label: string;
}

export interface CreateCategoryResponse {
  status: string;
  id: string;
}

export interface CreateCategoryResponse {
  status: string;
  id: string;
}

export interface UpdateCategoryRequest {
  id: string;
  label: string;
}

export interface UpdateCategoryResponse {
  status: string;
  id: string;
}

// Payment methods
export interface PaymentMethod {
  id: string;
  label: string;
  // withdrawal_day_of_month
  // 0: none, -1: last day of month
  withdrawal_day_of_month: number;
}

export interface PaymentMethodsResponse {
  payment_methods: PaymentMethod[];
}

export interface CreatePaymentMethodRequest {
  label: string;
  withdrawal_day_of_month: number;
}

export interface CreatePaymentMethodResponse {
  status: string;
  id: string;
}

export interface UpdatePaymentMethodRequest {
  id: string;
  label: string;
  withdrawal_day_of_month: number;
}

export interface UpdatePaymentMethodResponse {
  status: string;
  id: string;
}

// Invoice records
export interface InvoiceRecord {
  id: string;
  state: string;
  state_id: number;
  amount: number;
  payment_method: string;
  payment_method_id: string;
  withdrawal_date: string; // NOTE: ISO 8601 format
}

export interface InvoiceRecordsResponse {
  records: InvoiceRecord[];
}

export interface CreateInvoiceRecordRequest {
  amount: number;
  state_id: number;
  payment_method_id: string;
  withdrawal_date: string; // NOTE: ISO 8601 format
}

export interface UpdateInvoiceRecordRequest {
  id: string;
  amount: number;
  state_id: number;
  withdrawal_date: string; // NOTE: ISO 8601 format
}
