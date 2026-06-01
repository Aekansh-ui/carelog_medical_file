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

/** Returns whole years of age from a YYYY-MM-DD date of birth. Returns 0 if DOB is in the future. */
export function computeAge(dob: string): number {
  const birth = parseISO(dob);
  const now = new Date();
  let age = now.getFullYear() - birth.getFullYear();
  const monthDiff = now.getMonth() - birth.getMonth();
  if (monthDiff < 0 || (monthDiff === 0 && now.getDate() < birth.getDate())) {
    age--;
  }
  return Math.max(0, age);
}

export type ExpiryStatus = 'none' | 'active' | 'expiring' | 'expired';

/**
 * Classifies an insurance/policy expiry date relative to today.
 * `soonDays` controls the "expiring soon" window.
 */
export function getExpiryStatus(
  validUntil: string | undefined | null,
  soonDays = 30,
): { status: ExpiryStatus; label: string } {
  if (!validUntil) return { status: 'none', label: '' };
  const days = getDaysUntil(validUntil);
  if (days < 0) return { status: 'expired', label: 'Expired' };
  if (days === 0) return { status: 'expiring', label: 'Expires today' };
  if (days <= soonDays) return { status: 'expiring', label: `Expires in ${days} day${days === 1 ? '' : 's'}` };
  return { status: 'active', label: `Valid till ${formatVisitDate(validUntil)}` };
}

export function formatCurrency(amount: number | undefined | null, currency = 'INR'): string {
  if (amount == null) return '';
  const symbols: Record<string, string> = { INR: '₹', USD: '$', EUR: '€' };
  const symbol = symbols[currency] ?? currency + ' ';
  return `${symbol}${amount.toLocaleString()}`;
}
