import { format, differenceInDays, parseISO } from 'date-fns';

export function today(): string {
  return format(new Date(), 'yyyy-MM-dd');
}

export function formatVisitDate(dateStr: string): string {
  try {
    return format(parseISO(dateStr), 'd MMM yyyy');
  } catch {
    return dateStr;
  }
}

/** Returns the number of calendar days from today until dateStr (negative = past). */
export function getDaysUntil(dateStr: string): number {
  const target = parseISO(dateStr);
  const now = new Date();
  now.setHours(0, 0, 0, 0);
  return differenceInDays(target, now);
}

/** @deprecated Use getDaysUntil */
export const daysUntil = getDaysUntil;

export function isOverdue(dateStr: string): boolean {
  return getDaysUntil(dateStr) < 0;
}

export function formatDaysRemaining(dateStr: string): string {
  const days = getDaysUntil(dateStr);
  if (days < 0) return 'Overdue';
  if (days === 0) return 'Today';
  if (days === 1) return 'Tomorrow';
  return `${days} days left`;
}

export function formatCurrency(amount: number | undefined | null, currency = 'INR'): string {
  if (amount == null) return '';
  const symbols: Record<string, string> = { INR: '₹', USD: '$', EUR: '€' };
  const symbol = symbols[currency] ?? currency + ' ';
  return `${symbol}${amount.toLocaleString()}`;
}
