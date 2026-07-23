import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/spot.dart';

final exploreSpotsProvider = StateNotifierProvider<ExploreViewModel, List<Spot>>((ref) {
  return ExploreViewModel();
});

class ExploreViewModel extends StateNotifier<List<Spot>> {
  ExploreViewModel() : super(_generateMockSpots());

  static List<Spot> _generateMockSpots() {
    return [
      Spot(
        id: '1',
        name: 'The Coffee Collective',
        rating: 4.8,
        friendName: 'Alex',
        friendAvatar: '🧑‍🎤',
      ),
      Spot(
        id: '2',
        name: 'Hanoi Social Club',
        rating: 4.6,
        friendName: 'Taylor',
        friendAvatar: '🧑‍💻',
      ),
      Spot(
        id: '3',
        name: 'Craft Beer Pub',
        rating: 4.3,
        friendName: 'Jordan',
        friendAvatar: '🧑‍🍳',
      ),
      Spot(
        id: '4',
        name: 'Hidden Speakeasy',
        rating: 4.9,
        friendName: 'Sam',
        friendAvatar: '🧑‍🎓',
      ),
      Spot(
        id: '5',
        name: 'Sunset Rooftop',
        rating: 4.7,
        friendName: 'Morgan',
        friendAvatar: '🧑‍✈️',
      ),
    ];
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
    state = _generateMockSpots();
  }
}
