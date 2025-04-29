export const ApiBaseUrl = '/api';

// api/constants.ts
export const States = [
  { id: 0, label: '予定' },
  { id: 1, label: '支払済' },
  { id: 2, label: '検討中' },
  { id: 3, label: 'やめた' }
];

export const RecordTypes = [
  { id: 0, label: '支出' },
  { id: 1, label: '収入' },
  { id: 2, label: '何？' }
];

export const InvoiceRecordStates = [
  { id: 0, label: '未確定' },
  { id: 1, label: '確定' },
  { id: 2, label: '処理済み' }
];
