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

export interface UpdateCategoryRequest {
  id: string;
  label: string;
}

export interface CreateCategoryResponse {
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

// Invoice records
export interface InvoiceRecord {
  id: string;
  state: string;
  amount: number;
  payment_method: string;
  withdrawal_date: string; // NOTE: ISO 8601 format
}

export interface InvoiceRecordsResponse {
  records: InvoiceRecord[];
}

export interface CreateInvoiceRecordRequest {
  amount: number;
  payment_method_id: string;
  withdrawal_date: string; // NOTE: ISO 8601 format
}

export interface CreateInvoiceRecordResponse {
  status: string;
  id: string;
}
