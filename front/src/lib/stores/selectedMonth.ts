import { writable, derived } from 'svelte/store';

const now = new Date();
export const selectedYear = writable<number>(now.getFullYear());
export const selectedMonth = writable<number>(now.getMonth() + 1);

export const selectedMonthRange = derived(
  [selectedYear, selectedMonth],
  ([$year, $month]) => {
    const begin = `${$year}-${String($month).padStart(2, '0')}-01`;
    const lastDay = new Date($year, $month, 0).getDate();
    const end = `${$year}-${String($month).padStart(2, '0')}-${String(lastDay).padStart(2, '0')}`;
    return { beginDate: begin, endDate: end };
  }
);
