import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/streak_service.dart';

final streakProvider = FutureProvider<int>((ref) async {
  return await StreakService.getStreak();
});

final updateStreakProvider = FutureProvider<int>((ref) async {
  final streak = await StreakService.updateStreak();
  ref.invalidate(streakProvider);
  return streak;
});
