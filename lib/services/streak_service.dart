import 'package:shared_preferences/shared_preferences.dart';

class StreakService {
  static const String _lastActiveKey = 'last_active_date';
  static const String _streakKey = 'streak_count';

  /// Get the current streak count
  static Future<int> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_streakKey) ?? 0;
  }

  /// Update streak based on today's activity
  static Future<int> updateStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayString = _dateToString(today);

    final lastActiveString = prefs.getString(_lastActiveKey);
    final currentStreak = prefs.getInt(_streakKey) ?? 0;

    // If already active today, return current streak (minimum 1 if zero)
    if (lastActiveString == todayString) {
      return currentStreak == 0 ? 1 : currentStreak;
    }

    // If last active was yesterday, increment streak
    final yesterday = today.subtract(const Duration(days: 1));
    final yesterdayString = _dateToString(yesterday);

    int newStreak;
    if (lastActiveString == yesterdayString) {
      newStreak = currentStreak + 1;
    } else {
      // Gap detected → reset streak to 1
      newStreak = 1;
    }

    await prefs.setString(_lastActiveKey, todayString);
    await prefs.setInt(_streakKey, newStreak);
    return newStreak;
  }

  static String _dateToString(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }
}
