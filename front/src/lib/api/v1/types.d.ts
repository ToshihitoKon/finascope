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

export interface PutRecordRequest {
  title: string;
  type_id: number;
  state_id: number;
  description: string;
  amount: number;
  category_id: string;
  payment_method_id: string;
  date: string; // NOTE: ISO 8601 format
}

export interface PutRecordResponse {
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

export interface PutCategoryRequest {
  todo;
}

export interface PutCategoryResponse {
  todo;
}

// Payment methods
export interface PaymentMethod {
  id: string;
  label: string;
}

export interface PaymentMethodsResponse {
  payment_methods: PaymentMethod[];
}

export interface PutPaymentMethodRequest {
  todo;
}

export interface PutPaymentMethodResponse {
  todo;
}

// Invoice records
export interface InvoiceRecord {
  todo;
}

export interface InvoiceRecordsResponse {
  todo;
}

export interface PutInvoiceRecordRequest {
  todo;
}

export interface PutInvoiceRecordResponse {
  todo;
}
