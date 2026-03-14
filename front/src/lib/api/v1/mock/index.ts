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
        description: '3月分の給与',
        record_type_id: 1,
        state_id: 1,
        category_id: 'X2yLmV9P',
        payment_method_id: 'M3wEcL1X'
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
        description: '技術書籍「Ruby超入門」',
        record_type_id: 2,
        state_id: 2,
        category_id: 'EDU123',
        payment_method_id: 'CC456'
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
        description: '社員食堂にて',
        record_type_id: 2,
        state_id: 2,
        category_id: 'F3aBcT8Z',
        payment_method_id: 'P7rTvK2Q'
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
      },
      {
        id: 'EDU123',
        label: '教育'
      },
      {
        id: 'ENT789',
        label: 'エンタメ'
      },
      {
        id: 'TRA456',
        label: '交通費'
      },
      {
        id: 'UTL321',
        label: '光熱費'
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

// export const deleteCategory = async (
//   req: apitype.CommonIdRequest
// ): Promise<apitype.CommonResponse> => {
//   console.log('mock: deleteRecord.', req);
//   return { status: 'success', id: 'dummy' };
// };

// Payment Methods
export const fetchPaymentMethods = async (): Promise<apitype.PaymentMethodsResponse> => {
  console.log('mock: fetchPaymentMethods.');
  return {
    payment_methods: [
      {
        id: 'P7rTvK2Q',
        label: '現金',
        withdrawal_day_of_month: 0,
        closing_day_of_month: 0
      },
      {
        id: 'M3wEcL1X',
        label: '銀行振込',
        withdrawal_day_of_month: 25,
        closing_day_of_month: 0
      },
      {
        id: 'CC456',
        label: 'クレジットカード',
        withdrawal_day_of_month: 27,
        closing_day_of_month: 15
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

// export const deletePaymentMethod = async (
//   req: apitype.CommonIdRequest
// ): Promise<apitype.CommonResponse> => {
//   console.log('mock: deleteRecord.', req);
//   return { status: 'success', id: 'dummy' };
// };

// Invoice Records
export const fetchInvoiceRecords = async (query?: string): Promise<apitype.InvoiceRecordsResponse> => {
  console.log('mock: fetchInvoiceRecords.', query);
  return {
    records: [
      {
        id: 'INV001',
        state: '支払済',
        state_id: 2,
        amount: 45000,
        payment_method: 'クレジットカード',
        payment_method_id: 'CC456',
        withdrawal_date: '2024-03-27'
      },
      {
        id: 'INV002',
        state: '検討中',
        state_id: 1,
        amount: 15800,
        payment_method: '銀行振込',
        payment_method_id: 'M3wEcL1X',
        withdrawal_date: '2024-03-25'
      },
      {
        id: 'INV003',
        state: '支払済',
        state_id: 2,
        amount: 3200,
        payment_method: 'クレジットカード',
        payment_method_id: 'CC456',
        withdrawal_date: '2024-04-27'
      }
    ]
  };
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

export const deleteInvoiceRecord = async (
  req: apitype.CommonIdRequest
): Promise<apitype.CommonResponse> => {
  console.log('mock: deleteRecord.', req);
  return { status: 'success', id: 'dummy' };
};

// View - Category Aggregation
export const fetchCategoryAggregation = async (
  params: string
): Promise<apitype.CategoryAggregationResponse> => {
  console.log('mock: fetchCategoryAggregation.', params);
  return {
    aggregations: [
      {
        category_id: 'F3aBcT8Z',
        category: '食費',
        total_amount: 12450,
        record_count: 5,
        records: [
          {
            id: 'A7f9D1bC',
            type: '支出',
            title: 'ランチ代',
            amount: 850,
            state: '支払済',
            category: '食費',
            payment_method: '現金',
            date: '2024-03-25',
            description: '社員食堂にて',
            record_type_id: 2,
            state_id: 2,
            category_id: 'F3aBcT8Z',
            payment_method_id: 'P7rTvK2Q'
          },
          {
            id: 'F2d8K3mN',
            type: '支出',
            title: 'スーパーマーケット',
            amount: 4500,
            state: '支払済',
            category: '食費',
            payment_method: 'クレジットカード',
            date: '2024-03-23',
            description: '週末の買い物',
            record_type_id: 2,
            state_id: 2,
            category_id: 'F3aBcT8Z',
            payment_method_id: 'CC456'
          },
          {
            id: 'G8h1L5pQ',
            type: '支出',
            title: 'コンビニ',
            amount: 1200,
            state: '支払済',
            category: '食費',
            payment_method: '現金',
            date: '2024-03-24',
            description: '昼食と飲み物',
            record_type_id: 2,
            state_id: 2,
            category_id: 'F3aBcT8Z',
            payment_method_id: 'P7rTvK2Q'
          },
          {
            id: 'H9j2M6qR',
            type: '支出',
            title: 'カフェ',
            amount: 2900,
            state: '支払済',
            category: '食費',
            payment_method: 'クレジットカード',
            date: '2024-03-22',
            description: 'ランチミーティング',
            record_type_id: 2,
            state_id: 2,
            category_id: 'F3aBcT8Z',
            payment_method_id: 'CC456'
          },
          {
            id: 'I0k3N7rS',
            type: '支出',
            title: 'ディナー',
            amount: 3000,
            state: '支払済',
            category: '食費',
            payment_method: 'クレジットカード',
            date: '2024-03-21',
            description: '居酒屋',
            record_type_id: 2,
            state_id: 2,
            category_id: 'F3aBcT8Z',
            payment_method_id: 'CC456'
          }
        ]
      },
      {
        category_id: 'EDU123',
        category: '教育',
        total_amount: 5600,
        record_count: 2,
        records: [
          {
            id: 'hY3Nc7Q1',
            type: '支出',
            title: '書籍購入',
            amount: 1600,
            state: '支払済',
            category: '教育',
            payment_method: 'クレジットカード',
            date: '2024-03-24',
            description: '技術書籍「Ruby超入門」',
            record_type_id: 2,
            state_id: 2,
            category_id: 'EDU123',
            payment_method_id: 'CC456'
          },
          {
            id: 'J1l4O8sT',
            type: '支出',
            title: 'オンライン講座',
            amount: 4000,
            state: '支払済',
            category: '教育',
            payment_method: 'クレジットカード',
            date: '2024-03-20',
            description: 'Udemy講座購入',
            record_type_id: 2,
            state_id: 2,
            category_id: 'EDU123',
            payment_method_id: 'CC456'
          }
        ]
      },
      {
        category_id: 'X2yLmV9P',
        category: '給与',
        total_amount: 280000,
        record_count: 1,
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
            description: '3月分の給与',
            record_type_id: 1,
            state_id: 1,
            category_id: 'X2yLmV9P',
            payment_method_id: 'M3wEcL1X'
          }
        ]
      }
    ]
  };
};

// Invoice Records Withdrawal Aggregation
export const fetchInvoiceRecordsWithdrawalAggregation = async (
  req: apitype.InvoiceRecordsWithdrawalAggregationRequest
): Promise<apitype.InvoiceRecordsWithdrawalAggregationResponse> => {
  console.log('mock: fetchInvoiceRecordsWithdrawalAggregation.', req);
  return {
    aggregation: {
      payment_method_id: 'CC456',
      payment_method: 'クレジットカード',
      total_amount: 14100,
      begin_date: '2024-02-16',
      end_date: '2024-03-15',
      records: [
        {
          id: 'hY3Nc7Q1',
          type: '支出',
          title: '書籍購入',
          amount: 1600,
          state: '支払済',
          category: '教育',
          payment_method: 'クレジットカード',
          date: '2024-03-10',
          description: '技術書籍「Ruby超入門」',
          record_type_id: 2,
          state_id: 2,
          category_id: 'EDU123',
          payment_method_id: 'CC456'
        },
        {
          id: 'F2d8K3mN',
          type: '支出',
          title: 'スーパーマーケット',
          amount: 4500,
          state: '支払済',
          category: '食費',
          payment_method: 'クレジットカード',
          date: '2024-03-05',
          description: '週末の買い物',
          record_type_id: 2,
          state_id: 2,
          category_id: 'F3aBcT8Z',
          payment_method_id: 'CC456'
        },
        {
          id: 'H9j2M6qR',
          type: '支出',
          title: 'カフェ',
          amount: 2900,
          state: '支払済',
          category: '食費',
          payment_method: 'クレジットカード',
          date: '2024-02-28',
          description: 'ランチミーティング',
          record_type_id: 2,
          state_id: 2,
          category_id: 'F3aBcT8Z',
          payment_method_id: 'CC456'
        },
        {
          id: 'I0k3N7rS',
          type: '支出',
          title: 'ディナー',
          amount: 3000,
          state: '支払済',
          category: '食費',
          payment_method: 'クレジットカード',
          date: '2024-02-25',
          description: '居酒屋',
          record_type_id: 2,
          state_id: 2,
          category_id: 'F3aBcT8Z',
          payment_method_id: 'CC456'
        },
        {
          id: 'K2m5P9tU',
          type: '支出',
          title: 'サブスクリプション',
          amount: 2100,
          state: '支払済',
          category: 'エンタメ',
          payment_method: 'クレジットカード',
          date: '2024-02-20',
          description: 'Netflix月額料金',
          record_type_id: 2,
          state_id: 2,
          category_id: 'ENT789',
          payment_method_id: 'CC456'
        }
      ]
    }
  };
};
