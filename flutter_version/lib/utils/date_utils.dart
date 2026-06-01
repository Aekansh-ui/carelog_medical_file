import 'package:intl/intl.dart';

/// Date / currency helpers ported from `../carelog/src/utils/dateUtils.ts`.
/// Dates are ISO strings (`yyyy-MM-dd`) to stay byte-compatible with the RN app.

final DateFormat _ymd = DateFormat('yyyy-MM-dd');
final DateFormat _display = DateFormat('d MMM yyyy');

/// Today as `yyyy-MM-dd`.
String today() => _ymd.format(DateTime.now());

/// Pretty visit/policy date, e.g. `5 Jun 2026`. Falls back to the raw string.
String formatVisitDate(String dateStr) {
  try {
    return _display.format(DateTime.parse(dateStr));
  } catch (_) {
    return dateStr;
  }
}

/// Whole calendar days from today until [dateStr] (negative = in the past).
int getDaysUntil(String dateStr) {
  final target = DateTime.parse(dateStr);
  final targetDay = DateTime(target.year, target.month, target.day);
  final now = DateTime.now();
  final todayDay = DateTime(now.year, now.month, now.day);
  return targetDay.difference(todayDay).inDays;
}

bool isOverdue(String dateStr) => getDaysUntil(dateStr) < 0;

String formatDaysRemaining(String dateStr) {
  final days = getDaysUntil(dateStr);
  if (days < 0) return 'Overdue';
  if (days == 0) return 'Today';
  if (days == 1) return 'Tomorrow';
  return '$days days left';
}

/// Whole years of age from a `yyyy-MM-dd` DOB. 0 if the DOB is in the future.
int computeAge(String dob) {
  final birth = DateTime.parse(dob);
  final now = DateTime.now();
  var age = now.year - birth.year;
  if (now.month < birth.month ||
      (now.month == birth.month && now.day < birth.day)) {
    age--;
  }
  return age < 0 ? 0 : age;
}

/// Expiry classification for an insurance policy (mirrors RN `ExpiryStatus`).
enum ExpiryStatus { none, active, expiring, expired }

/// Result of [getExpiryStatus]: the status plus a ready-to-render label.
class ExpiryInfo {
  final ExpiryStatus status;
  final String label;
  const ExpiryInfo(this.status, this.label);
}

/// Classifies a policy expiry date relative to today. [soonDays] is the
/// "expiring soon" window (default 30, see `insurance.dart`).
ExpiryInfo getExpiryStatus(String? validUntil, {int soonDays = 30}) {
  if (validUntil == null || validUntil.isEmpty) {
    return const ExpiryInfo(ExpiryStatus.none, '');
  }
  final days = getDaysUntil(validUntil);
  if (days < 0) return const ExpiryInfo(ExpiryStatus.expired, 'Expired');
  if (days == 0) return const ExpiryInfo(ExpiryStatus.expiring, 'Expires today');
  if (days <= soonDays) {
    return ExpiryInfo(
        ExpiryStatus.expiring, 'Expires in $days day${days == 1 ? '' : 's'}');
  }
  return ExpiryInfo(ExpiryStatus.active, 'Valid till ${formatVisitDate(validUntil)}');
}

/// `₹1,200` style currency formatting (mirrors RN `formatCurrency`).
String formatCurrency(num? amount, {String currency = 'INR'}) {
  if (amount == null) return '';
  const symbols = {'INR': '₹', 'USD': '\$', 'EUR': '€'};
  final symbol = symbols[currency] ?? '$currency ';
  final formatted = NumberFormat.decimalPattern().format(amount);
  return '$symbol$formatted';
}
