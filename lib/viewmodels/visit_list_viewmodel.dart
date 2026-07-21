import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/visit_record.dart';
import '../services/database_service.dart';
import '../services/image_service.dart';

class VisitListState {
  final List<VisitRecord> visits;
  final bool isLoading;
  final String? errorMessage;

  VisitListState({
    this.visits = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  VisitListState copyWith({
    List<VisitRecord>? visits,
    bool? isLoading,
    String? errorMessage,
  }) {
    return VisitListState(
      visits: visits ?? this.visits,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class VisitListViewModel extends StateNotifier<VisitListState> {
  VisitListViewModel() : super(VisitListState()) {
    fetchVisits();
  }

  Future<void> fetchVisits() async {
    try {
      state = state.copyWith(isLoading: true);
      final visits = await DatabaseService.instance.getAllVisits();
      state = state.copyWith(visits: visits, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> deleteVisit(String uuid) async {
    try {
      final visit = await DatabaseService.instance.getVisitByUuid(uuid);
      if (visit != null && visit.imageFileName != null) {
        await ImageService.deleteImage(visit.imageFileName!);
      }
      final success = await DatabaseService.instance.deleteVisit(uuid);
      if (success) {
        await fetchVisits();
      }
      return success;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }
}

final visitListViewModelProvider =
    StateNotifierProvider<VisitListViewModel, VisitListState>((ref) {
  return VisitListViewModel();
});

final visitStreamProvider = StreamProvider<List<VisitRecord>>((ref) {
  return DatabaseService.instance.watchVisits();
});
