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

// Requests
export interface PutRecordRequest {
  name: string;
  typeId: number;
  stateId: number;
  description: string;
  amount: number;
  categoryId: string;
  date: string; // NOTE: ISO 8601 format
}

// Responses
export interface CategoriesResponse {
  categories: Category[];
}

export interface RecordsResponse {
  records: Record[];
}
