import { browser } from '$app/environment';

const LS_KEY = 'finascope_flags_useMockApi';

export const flags = {
  get useMockApi(): boolean {
    if (!browser) return false;
    return localStorage.getItem(LS_KEY) === 'true';
  }
};

export const setMockApi = (value: boolean): void => {
  if (!browser) return;
  localStorage.setItem(LS_KEY, String(value));
};
