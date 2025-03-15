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
    name: string;
    typeLabel: string;
    stateLabel: string;
    description: string;
    amount: number;
    categoryLabel: string;
    date: string; // NOTE: ISO 8601 format
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
