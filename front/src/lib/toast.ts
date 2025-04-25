import { writable } from 'svelte/store';

export type ToastType = 'error' | 'success' | 'info';

export interface Toast {
  id: string;
  message: string;
  type: ToastType;
  duration: number;
}

const defaultDuration = 5000;

export const toasts = writable<Toast[]>([]);

/**
 * Show a toast message.
 * @param message - The message to display.
 * @param type - The type of the toast.
 * @param duration - How long (ms) the toast is visible.
 */
export function showToast(
  message: string,
  type: ToastType = 'error',
  duration: number = defaultDuration
) {
  const id =
    typeof crypto !== 'undefined' && typeof crypto.randomUUID === 'function'
      ? crypto.randomUUID()
      : Math.random().toString(36).substr(2, 9);
  toasts.update((all) => [...all, { id, message, type, duration }]);
  setTimeout(() => removeToast(id), duration);
}

/**
 * Remove a toast by id.
 */
export function removeToast(id: string) {
  toasts.update((all) => all.filter((toast) => toast.id !== id));
}