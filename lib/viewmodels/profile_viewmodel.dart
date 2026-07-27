import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../models/visit_record.dart';
import '../services/supabase_service.dart';
import '../services/user_service.dart';

class ProfileState {
  final User? user;
  final bool isLoading;
  final bool isCurrentUser;
  final bool isFollowing;
  final bool isFriend;
  final int memoriesCount;
  final int friendsCount;
  final int followersCount;
  final int followingCount;
  final List<VisitRecord> memories;

  const ProfileState({
    this.user,
    this.isLoading = true,
    this.isCurrentUser = false,
    this.isFollowing = false,
    this.isFriend = false,
    this.memoriesCount = 0,
    this.friendsCount = 0,
    this.followersCount = 0,
    this.followingCount = 0,
    this.memories = const [],
  });

  ProfileState copyWith({
    User? user,
    bool? isLoading,
    bool? isCurrentUser,
    bool? isFollowing,
    bool? isFriend,
    int? memoriesCount,
    int? friendsCount,
    int? followersCount,
    int? followingCount,
    List<VisitRecord>? memories,
  }) {
    return ProfileState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
      isFollowing: isFollowing ?? this.isFollowing,
      isFriend: isFriend ?? this.isFriend,
      memoriesCount: memoriesCount ?? this.memoriesCount,
      friendsCount: friendsCount ?? this.friendsCount,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      memories: memories ?? this.memories,
    );
  }
}

class ProfileViewModel extends StateNotifier<ProfileState> {
  final String targetUserId;
  final UserService _userService = UserService.instance;

  ProfileViewModel(this.targetUserId) : super(const ProfileState()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true);

    final currentUser = await _userService.getOrCreateCurrentUser();
    final isMe = currentUser.uuid == targetUserId;

    final targetUser = isMe
        ? currentUser
        : await _userService.getUserByUuid(targetUserId);

    if (targetUser == null) {
      state = state.copyWith(isLoading: false);
      return;
    }

    final memories = await _userService.getUserVisits(targetUser.uuid);

    bool isFollowing = false;
    bool isFriend = false;

    if (!isMe) {
      isFollowing = await _userService.isFollowing(currentUser.uuid, targetUser.uuid);
      isFriend = await _userService.isFriend(currentUser.uuid, targetUser.uuid);

      // Cloud truth sync if Supabase session is active
      if (SupabaseService.instance.currentUser != null) {
        try {
          final cloudIsFollowing = await SupabaseService.instance.isFollowing(targetUser.uuid);
          final cloudIsFollowedBy = await SupabaseService.instance.isFollowedBy(targetUser.uuid);

          if (cloudIsFollowing != isFollowing) {
            if (cloudIsFollowing) {
              await _userService.followUser(currentUser.uuid, targetUser.uuid);
            } else {
              await _userService.unfollowUser(currentUser.uuid, targetUser.uuid);
            }
            isFollowing = cloudIsFollowing;
          }

          if (cloudIsFollowedBy) {
            await _userService.followUser(targetUser.uuid, currentUser.uuid);
          } else {
            await _userService.unfollowUser(targetUser.uuid, currentUser.uuid);
          }

          isFriend = cloudIsFollowing && cloudIsFollowedBy;
        } catch (_) {
          // Fall back to local status on error
        }
      }
    }

    final friendsCount = await _userService.getFriendsCount(targetUser.uuid);
    final followersCount = await _userService.getFollowersCount(targetUser.uuid);
    final followingCount = await _userService.getFollowingCount(targetUser.uuid);

    state = ProfileState(
      user: targetUser,
      isLoading: false,
      isCurrentUser: isMe,
      isFollowing: isFollowing,
      isFriend: isFriend,
      memoriesCount: memories.length,
      friendsCount: friendsCount,
      followersCount: followersCount,
      followingCount: followingCount,
      memories: memories,
    );
  }

  Future<bool> toggleFollow() async {
    if (state.user == null || state.isCurrentUser) return true;

    final oldState = state;
    final currentUser = await _userService.getOrCreateCurrentUser();
    final targetId = state.user!.uuid;
    final willFollow = !state.isFollowing;

    final newFollowersCount = willFollow
        ? state.followersCount + 1
        : (state.followersCount > 0 ? state.followersCount - 1 : 0);

    // Optimistic local update
    if (willFollow) {
      await _userService.followUser(currentUser.uuid, targetId);
    } else {
      await _userService.unfollowUser(currentUser.uuid, targetId);
    }

    final isFriend = await _userService.isFriend(currentUser.uuid, targetId);
    final friendsCount = await _userService.getFriendsCount(state.user!.uuid);

    state = state.copyWith(
      isFollowing: willFollow,
      isFriend: isFriend,
      followersCount: newFollowersCount,
      friendsCount: friendsCount,
    );

    // Cloud sync if logged into Supabase
    if (SupabaseService.instance.currentUser != null) {
      try {
        if (willFollow) {
          await SupabaseService.instance.followUser(targetId);
        } else {
          await SupabaseService.instance.unfollowUser(targetId);
        }
      } catch (_) {
        // Revert local Isar and state on failure
        if (willFollow) {
          await _userService.unfollowUser(currentUser.uuid, targetId);
        } else {
          await _userService.followUser(currentUser.uuid, targetId);
        }
        state = oldState;
        return false;
      }
    }

    return true;
  }

  Future<void> updateProfile({required String name, required String bio, required String avatar}) async {
    if (state.user == null || !state.isCurrentUser) return;

    final user = state.user!
      ..name = name
      ..bio = bio
      ..avatar = avatar;

    await _userService.updateUser(user);
    try {
      await SupabaseService.instance.updateProfile(
        name: name,
        bio: bio,
        avatar: avatar,
      );
    } catch (_) {}
    await loadProfile();
  }
}

final profileViewModelProvider = StateNotifierProvider.family<ProfileViewModel, ProfileState, String>(
  (ref, userId) => ProfileViewModel(userId),
);
