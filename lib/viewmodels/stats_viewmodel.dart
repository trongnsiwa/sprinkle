import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';

final todaySpotsProvider = FutureProvider<int>((ref) async {
  final visits = await DatabaseService.instance.getAllVisits();
  final today = DateTime.now();
  return visits.where((v) =>
    v.timestamp.year == today.year &&
    v.timestamp.month == today.month &&
    v.timestamp.day == today.day
  ).length;
});
