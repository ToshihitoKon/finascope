export const ApiBaseUrl = '/api';

// api/constants.ts
export const States = [
  { id: 0, label: '予定' },
  { id: 1, label: '支払済' },
  { id: 2, label: '検討中' },
  { id: 3, label: 'やめた' }
];

export const getStateLabel = (id: number): string => {
  const state = States.find((s) => s.id === id);
  return state ? state.label : 'Unknown';
};

export const RecordTypes = [
  { id: 0, label: '支出' },
  { id: 1, label: '収入' },
  { id: 2, label: '何？' }
];

export const getRecordTypeLabel = (id: number): string => {
  const type = RecordTypes.find((t) => t.id === id);
  return type ? type.label : 'Unknown';
};

export const InvoiceRecordStates = [
  { id: 0, label: '未確定' },
  { id: 1, label: '確定' },
  { id: 2, label: '処理済み' }
];

export const getInvoiceRecordStateLabel = (id: number): string => {
  const state = InvoiceRecordStates.find((s) => s.id === id);
  return state ? state.label : 'Unknown';
};
