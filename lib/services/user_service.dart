import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import '../models/follow.dart';
import '../models/user.dart';
import '../models/visit_record.dart';
import 'database_service.dart';
import 'supabase_service.dart';

class UserService {
  static UserService? _instance;

  UserService._();

  static UserService get instance {
    _instance ??= UserService._();
    return _instance!;
  }

  /// Get or create the primary local user ("You")
  Future<User> getOrCreateCurrentUser() async {
    final db = await DatabaseService.instance.isar;
    final sbUser = SupabaseService.instance.currentUser;

    if (sbUser != null) {
      final targetUuid = sbUser.id;
      var user = await db.users.filter().uuidEqualTo(targetUuid).findFirst();

      if (user == null) {
        // Check if old 'user_me' exists to migrate
        final oldMe = await db.users.filter().uuidEqualTo('user_me').findFirst();

        final newUser = User()
          ..uuid = targetUuid
          ..name = sbUser.userMetadata?['name'] ?? oldMe?.name ?? 'You'
          ..avatar = sbUser.userMetadata?['avatar'] ?? oldMe?.avatar ?? '📸'
          ..bio = oldMe?.bio ?? 'Capturing everyday coffee & moments ✨'
          ..createdAt = oldMe?.createdAt ?? DateTime.now()
          ..isCurrentUser = true;

        await db.writeTxn(() async {
          // Unset isCurrentUser on any other user records
          final currentUsers = await db.users.filter().isCurrentUserEqualTo(true).findAll();
          for (final u in currentUsers) {
            u.isCurrentUser = false;
            await db.users.put(u);
          }

          await db.users.put(newUser);

          // Migrate VisitRecord and Follow entries from 'user_me' to targetUuid
          if (oldMe != null) {
            final visitsToMigrate = await db.visitRecords.filter().userIdEqualTo('user_me').or().userIdIsNull().findAll();
            for (final visit in visitsToMigrate) {
              visit.userId = targetUuid;
              await db.visitRecords.put(visit);
            }

            final followsAsFollower = await db.follows.filter().followerIdEqualTo('user_me').findAll();
            for (final f in followsAsFollower) {
              f.followerId = targetUuid;
              await db.follows.put(f);
            }

            final followsAsFollowee = await db.follows.filter().followeeIdEqualTo('user_me').findAll();
            for (final f in followsAsFollowee) {
              f.followeeId = targetUuid;
              await db.follows.put(f);
            }

            await db.users.delete(oldMe.id);
          }
        });
        return newUser;
      } else {
        if (!user.isCurrentUser) {
          await db.writeTxn(() async {
            final currentUsers = await db.users.filter().isCurrentUserEqualTo(true).findAll();
            for (final u in currentUsers) {
              u.isCurrentUser = false;
              await db.users.put(u);
            }
            user.isCurrentUser = true;
            await db.users.put(user);
          });
        }
        return user;
      }
    }

    // Guest mode: fallback to 'user_me'
    final user = await db.users.filter().uuidEqualTo('user_me').findFirst();

    if (user == null) {
      final guestUser = User()
        ..uuid = 'user_me'
        ..name = 'You'
        ..avatar = '📸'
        ..bio = 'Capturing everyday coffee & moments ✨'
        ..createdAt = DateTime.now()
        ..isCurrentUser = true;

      await db.writeTxn(() async {
        await db.users.put(guestUser);
      });

      // Purge any legacy mock users & relationships to maintain clean database
      await purgeLegacyMockData();
      return guestUser;
    } else {
      if (!user.isCurrentUser) {
        await db.writeTxn(() async {
          user.isCurrentUser = true;
          await db.users.put(user);
        });
      }
      return user;
    }
  }

  /// Get user by UUID
  Future<User?> getUserByUuid(String uuid) async {
    final db = await DatabaseService.instance.isar;
    return await db.users.filter().uuidEqualTo(uuid).findFirst();
  }

  /// Get all users in database
  Future<List<User>> getAllUsers() async {
    final db = await DatabaseService.instance.isar;
    return await db.users.where().findAll();
  }

  /// Update user profile details
  Future<void> updateUser(User user) async {
    final db = await DatabaseService.instance.isar;
    await db.writeTxn(() async {
      await db.users.put(user);
    });
  }

  /// Check if followerId is following followeeId
  Future<bool> isFollowing(String followerId, String followeeId) async {
    final db = await DatabaseService.instance.isar;
    final count = await db.follows
        .filter()
        .followerIdEqualTo(followerId)
        .and()
        .followeeIdEqualTo(followeeId)
        .count();
    return count > 0;
  }

  /// Follow target user
  Future<void> followUser(String followerId, String followeeId) async {
    if (followerId == followeeId) return;
    final db = await DatabaseService.instance.isar;
    final existing = await db.follows
        .filter()
        .followerIdEqualTo(followerId)
        .and()
        .followeeIdEqualTo(followeeId)
        .findFirst();

    if (existing == null) {
      final follow = Follow()
        ..uuid = const Uuid().v4()
        ..followerId = followerId
        ..followeeId = followeeId
        ..createdAt = DateTime.now();

      await db.writeTxn(() async {
        await db.follows.put(follow);
      });
    }
  }

  /// Unfollow target user
  Future<void> unfollowUser(String followerId, String followeeId) async {
    final db = await DatabaseService.instance.isar;
    final existing = await db.follows
        .filter()
        .followerIdEqualTo(followerId)
        .and()
        .followeeIdEqualTo(followeeId)
        .findFirst();

    if (existing != null) {
      await db.writeTxn(() async {
        await db.follows.delete(existing.id);
      });
    }
  }

  /// Check if two users are mutual friends
  Future<bool> isFriend(String userAId, String userBId) async {
    final aFollowsB = await isFollowing(userAId, userBId);
    final bFollowsA = await isFollowing(userBId, userAId);
    return aFollowsB && bFollowsA;
  }

  /// Get count of mutual friends for a user
  Future<int> getFriendsCount(String userId) async {
    final db = await DatabaseService.instance.isar;
    // Get all users this user follows
    final following = await db.follows
        .filter()
        .followerIdEqualTo(userId)
        .findAll();

    int mutualCount = 0;
    for (final record in following) {
      final isMutual = await isFollowing(record.followeeId, userId);
      if (isMutual) {
        mutualCount++;
      }
    }
    return mutualCount;
  }

  /// Get list of mutual friend User objects for a specific user
  Future<List<User>> getFriends(String userId) async {
    final db = await DatabaseService.instance.isar;
    final follows = await db.follows
        .filter()
        .followerIdEqualTo(userId)
        .findAll();

    final List<User> friends = [];
    for (final follow in follows) {
      final isMutual = await isFollowing(follow.followeeId, userId);
      if (isMutual) {
        final friend = await getUserByUuid(follow.followeeId);
        if (friend != null) {
          friends.add(friend);
        }
      }
    }
    return friends;
  }

  /// Get latest visit record for a user
  Future<VisitRecord?> getLatestMemoryForUser(String userId) async {
    final db = await DatabaseService.instance.isar;
    return await db.visitRecords
        .filter()
        .userIdEqualTo(userId)
        .sortByTimestampDesc()
        .findFirst();
  }

  /// Get followers count
  Future<int> getFollowersCount(String userId) async {
    final db = await DatabaseService.instance.isar;
    return await db.follows.filter().followeeIdEqualTo(userId).count();
  }

  /// Get following count
  Future<int> getFollowingCount(String userId) async {
    final db = await DatabaseService.instance.isar;
    return await db.follows.filter().followerIdEqualTo(userId).count();
  }

  /// Get memories for a specific user
  Future<List<VisitRecord>> getUserVisits(String userId) async {
    final db = await DatabaseService.instance.isar;
    final user = await getUserByUuid(userId);
    if (user != null && user.isCurrentUser) {
      // Return all visits without userId or with user_me
      return await db.visitRecords
          .filter()
          .userIdEqualTo(userId)
          .or()
          .userIdIsNull()
          .sortByTimestampDesc()
          .findAll();
    }
    return await db.visitRecords
        .filter()
        .userIdEqualTo(userId)
        .sortByTimestampDesc()
        .findAll();
  }

  /// Purge legacy mock users and follows from Isar database to ensure clean production DB
  Future<void> purgeLegacyMockData() async {
    final db = await DatabaseService.instance.isar;
    final mockUuids = ['user_alex', 'user_taylor', 'user_jordan'];

    for (final uuid in mockUuids) {
      final mockUser = await db.users.filter().uuidEqualTo(uuid).findFirst();
      if (mockUser != null) {
        await db.writeTxn(() async {
          await db.users.delete(mockUser.id);
        });
      }

      final follows = await db.follows
          .filter()
          .followerIdEqualTo(uuid)
          .or()
          .followeeIdEqualTo(uuid)
          .findAll();

      if (follows.isNotEmpty) {
        await db.writeTxn(() async {
          for (final f in follows) {
            await db.follows.delete(f.id);
          }
        });
      }
    }
  }
}
