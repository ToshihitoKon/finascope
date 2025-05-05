import type * as apitype from '../types';

// Records
export const fetchRecords = async (params: string): Promise<apitype.RecordsResponse> => {
  console.log('mock: fetchRecords.', params);
  return {
    records: [
      {
        id: 'Xz82Klm9',
        type: '収入',
        title: '給与振込',
        amount: 280000,
        state: '検討中',
        category: '給与',
        payment_method: '銀行振込',
        date: '2024-03-20',
        description: '3月分の給与'
      },
      {
        id: 'hY3Nc7Q1',
        type: '支出',
        title: '書籍購入',
        amount: 1600,
        state: '支払済',
        category: '教育',
        payment_method: 'クレジットカード',
        date: '2024-03-24',
        description: '技術書籍「Ruby超入門」'
      },
      {
        id: 'A7f9D1bC',
        type: '支出',
        title: 'ランチ代',
        amount: 850,
        state: '支払済',
        category: '食費',
        payment_method: '現金',
        date: '2024-03-25',
        description: '社員食堂にて'
      }
    ]
  };
};

export const createRecord = async (
  req: apitype.CreateRecordRequest
): Promise<apitype.CreateRecordResponse> => {
  console.log('mock: createRecord.', req);
  return { status: 'success', id: 'dummy' };
};

export const updateRecord = async (
  req: apitype.UpdateRecordRequest
): Promise<apitype.UpdateRecordResponse> => {
  console.log('mock: updateRecord.', req);
  return { status: 'success', id: 'dummy' };
};

export const deleteRecord = async (
  req: apitype.CommonIdRequest
): Promise<apitype.CommonResponse> => {
  console.log('mock: deleteRecord.', req);
  return { status: 'success', id: 'dummy' };
};

// Categories
export const fetchCategories = async (): Promise<apitype.CategoriesResponse> => {
  return {
    categories: [
      {
        id: 'F3aBcT8Z',
        label: '食費'
      },
      {
        id: 'X2yLmV9P',
        label: '給与'
      }
    ]
  };
};

export const createCategory = async (
  req: apitype.CreateCategoryRequest
): Promise<apitype.CreateCategoryResponse> => {
  console.log('mock: createCategory.', req);
  return { status: 'success', id: 'dummy' };
};

export const updateCategory = async (
  req: apitype.UpdateCategoryRequest
): Promise<apitype.UpdateCategoryResponse> => {
  console.log('mock: updateCategory.', req);
  return { status: 'success', id: 'dummy' };
};

// Payment Methods
export const fetchPaymentMethods = async (): Promise<apitype.PaymentMethodsResponse> => {
  console.log('mock: fetchPaymentMethods.');
  return {
    payment_methods: [
      {
        id: 'P7rTvK2Q',
        label: '現金'
      },
      {
        id: 'M3wEcL1X',
        label: '銀行振込'
      }
    ]
  };
};
export const createPaymentMethod = async (
  req: apitype.CreatePaymentMethodRequest
): Promise<apitype.CreatePaymentMethodResponse> => {
  console.log('mock: createPaymentMethod.', req);
  return { status: 'success', id: 'dummy' };
};

export const updatePaymentMethod = async (
  req: apitype.UpdatePaymentMethodRequest
): Promise<apitype.UpdatePaymentMethodResponse> => {
  console.log('mock: updateCategory.', req);
  return { status: 'success', id: 'dummy' };
};

// Invoice Records
export const fetchInvoiceRecords = async (): Promise<apitype.InvoiceRecordsResponse> => {
  console.log('mock: fetchInvoiceRecords.');
  return {};
};

export const createInvoiceRecord = async (
  req: apitype.CreateInvoiceRecordRequest
): Promise<apitype.CommonResponse> => {
  console.log('mock: createInvoiceRecord.', req);
  return { status: 'success', id: 'dummy' };
};

export const updateInvoiceRecord = async (
  req: apitype.UpdateInvoiceRecordRequest
): Promise<apitype.CommonResponse> => {
  console.log('mock: updateInvoiceRecord.', req);
  return { status: 'success', id: 'dummy' };
};
