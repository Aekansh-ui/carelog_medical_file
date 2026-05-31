export function formatCurrency(amount: number | undefined | null, currency = 'INR'): string {
  if (amount == null) return '';
  const symbols: Record<string, string> = { INR: '₹', USD: '$', EUR: '€' };
  const symbol = symbols[currency] ?? currency + ' ';
  return `${symbol}${amount.toLocaleString()}`;
}

export function truncateText(text: string, maxLength: number): string {
  if (text.length <= maxLength) return text;
  return text.slice(0, maxLength).trimEnd() + '…';
}

export function formatFileSize(bytes: number): string {
  if (bytes < 1024) return `${bytes} B`;
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`;
  return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
}

/**
 * Formats a phone number string for display.
 * - 10 digits (Indian mobile): XXXXX XXXXX
 * - 11 digits starting with 0 (Indian landline): 0XXXX XXXXXX
 * - Anything else: returned as-is after stripping non-digit/+ chars
 */
export function formatPhoneNumber(phone: string): string {
  const digits = phone.replace(/[^\d+]/g, '');

  // Strip leading country code +91 for Indian numbers before formatting
  const local = digits.startsWith('+91') ? digits.slice(3) : digits;

  if (local.length === 10) {
    return `${local.slice(0, 5)} ${local.slice(5)}`;
  }

  if (local.length === 11 && local.startsWith('0')) {
    return `${local.slice(0, 5)} ${local.slice(5)}`;
  }

  return phone;
}
