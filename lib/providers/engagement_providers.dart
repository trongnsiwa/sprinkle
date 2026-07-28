import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/comment.dart';
import '../services/supabase_service.dart';

class LikeState {
  final bool isLiked;
  final int likeCount;
  final bool isLoading;

  const LikeState({
    this.isLiked = false,
    this.likeCount = 0,
    this.isLoading = true,
  });

  LikeState copyWith({
    bool? isLiked,
    int? likeCount,
    bool? isLoading,
  }) {
    return LikeState(
      isLiked: isLiked ?? this.isLiked,
      likeCount: likeCount ?? this.likeCount,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class LikeNotifier extends StateNotifier<LikeState> {
  final String memoryUuid;

  LikeNotifier(this.memoryUuid) : super(const LikeState()) {
    loadLikeState();
  }

  Future<void> loadLikeState() async {
    try {
      final isLiked = await SupabaseService.instance.isLikedByCurrentUser(memoryUuid);
      final count = await SupabaseService.instance.getLikeCount(memoryUuid);
      state = LikeState(
        isLiked: isLiked,
        likeCount: count,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('[LikeNotifier] Error loading like state: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> toggleLike() async {
    if (SupabaseService.instance.currentUser == null) {
      debugPrint('[LikeNotifier] Cannot toggle like: Guest mode active');
      return false;
    }

    final previousState = state;
    final newIsLiked = !state.isLiked;
    final newCount = newIsLiked ? state.likeCount + 1 : (state.likeCount > 0 ? state.likeCount - 1 : 0);

    // Optimistic state update
    state = state.copyWith(
      isLiked: newIsLiked,
      likeCount: newCount,
    );

    try {
      await SupabaseService.instance.toggleLike(memoryUuid);
      return true;
    } catch (e) {
      debugPrint('[LikeNotifier] Toggle like failed: $e, reverting optimistic state');
      // Revert on failure
      state = previousState;
      return false;
    }
  }
}

final likeStateProvider = StateNotifierProvider.family<LikeNotifier, LikeState, String>(
  (ref, memoryUuid) => LikeNotifier(memoryUuid),
);

final commentCountProvider = FutureProvider.family<int, String>((ref, memoryUuid) async {
  return await SupabaseService.instance.getCommentCount(memoryUuid);
});

final commentsStreamProvider = StreamProvider.family<List<Comment>, String>((ref, memoryUuid) async* {
  final initialComments = await SupabaseService.instance.getComments(memoryUuid);
  yield initialComments;

  try {
    while (true) {
      await Future.delayed(const Duration(seconds: 5));
      final updated = await SupabaseService.instance.getComments(memoryUuid);
      yield updated;
    }
  } catch (_) {
    yield initialComments;
  }
});
