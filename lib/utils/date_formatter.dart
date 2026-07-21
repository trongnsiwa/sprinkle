import 'package:intl/intl.dart';

extension DateTimeFormatter on DateTime {
  /// Returns a friendly formatted date string, e.g., "June 15, 2026 at 2:30 PM"
  String toFriendlyString() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateToCheck = DateTime(year, month, day);

    final timeStr = DateFormat('h:mm a').format(this);

    if (dateToCheck == today) {
      return 'Today at $timeStr';
    } else if (dateToCheck == today.subtract(const Duration(days: 1))) {
      return 'Yesterday at $timeStr';
    } else if (year == now.year) {
      return '${DateFormat('MMMM d').format(this)} at $timeStr';
    } else {
      return '${DateFormat('MMMM d, yyyy').format(this)} at $timeStr';
    }
  }

  /// Returns short date string, e.g. "MMM d, yyyy"
  String toShortDateString() {
    return DateFormat('MMM d, yyyy').format(this);
  }
}
