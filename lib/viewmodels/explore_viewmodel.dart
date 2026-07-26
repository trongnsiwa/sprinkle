import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/spot.dart';
import '../services/database_service.dart';

final exploreSpotsProvider = StateNotifierProvider<ExploreViewModel, List<Spot>>((ref) {
  return ExploreViewModel();
});

class ExploreViewModel extends StateNotifier<List<Spot>> {
  ExploreViewModel() : super([]) {
    loadSpots();
  }

  Future<void> loadSpots() async {
    final visits = await DatabaseService.instance.getAllVisits();
    final spots = visits.map((v) => Spot(
      id: v.uuid,
      name: v.name,
      rating: v.rating,
      friendName: 'Spot',
      friendAvatar: '✨',
    )).toList();

    state = spots;
  }

  void swipeRight(String id) {
    _removeSpot(id);
  }

  void swipeLeft(String id) {
    _removeSpot(id);
  }

  void _removeSpot(String id) {
    state = state.where((spot) => spot.id != id).toList();
  }

  void reset() {
    loadSpots();
  }
}
