import type * as apitype from '../types';

export const fetchCategories = async (): Promise<apitype.CategoriesResponse> => {
  return {
    categories: [
      { id: '01JNB8PFPXAC808XH263PS7TW9', label: 'DIALOGUE+' },
      { id: '01JNB8PNR9RT2HF21PVRFSW5NV', label: 'その他' }
    ]
  };
};

export const fetchRecords = async (): Promise<apitype.RecordsResponse> => {
  return {
    records: [
      {
        id: '01JNBK19Q5E0CQC3A9D7QS56Z7',
        type_label: '支出',
        title: 'DIALOGUE+ カクノゴトキロックンロールチケ',
        state_label: '支払済',
        description: '全通',
        amount: 66800,
        category_label: 'DIALOGUE+',
        payment_method_label: 'クレジットカード',
        date: '2025-02-20T00:00:00Z'
      },
      {
        id: '01JPCSYGCCMKYC4YMP7Z6ZB3K9',
        title: 'DIALOGUE+3 きゃにめ版',
        type_label: '支出',
        state_label: '支払済',
        description: '81直筆サインあたった神回',
        amount: 8800,
        category_label: 'DIALOGUE+',
        payment_method_label: 'クレジットカード',
        date: '2025-02-20T00:00:00Z'
      }
    ]
  };
};

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
        id: 'H1qWeR4K',
        label: '教育'
      },
      {
        id: 'D8nBpS6M',
        label: '交通費'
      }
    ]
  };
};
