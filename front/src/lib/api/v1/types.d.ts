export interface RecordType {
  id: number;
  label: string;
}

export interface State {
  id: number;
  label: string;
}

export interface Category {
  id: string;
  label: string;
}

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

export interface PaymentMethod {
  id: string;
  label: string;
}

// Responses
export interface CategoriesResponse {
  categories: Category[];
}

export interface PaymentMethodsResponse {
  payment_methods: PaymentMethod[];
}

export interface RecordsResponse {
  records: Record[];
}

export interface PutRecordResponse {
  status: string;
}

// Requests
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
