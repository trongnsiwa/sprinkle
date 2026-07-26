import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import '../models/follow.dart';
import '../models/user.dart';
import '../models/visit_record.dart';
import 'database_service.dart';

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
    var user = await db.users.filter().isCurrentUserEqualTo(true).findFirst();

    if (user == null) {
      user = User()
        ..uuid = 'user_me'
        ..name = 'You'
        ..avatar = '📸'
        ..bio = 'Capturing everyday coffee & moments ✨'
        ..createdAt = DateTime.now()
        ..isCurrentUser = true;

      await db.writeTxn(() async {
        await db.users.put(user!);
      });

      // Also seed mock users and relationships if initial launch
      await seedMockUsers();
    }

    return user;
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

  /// Seed mock users and default friendship data
  Future<void> seedMockUsers() async {
    final db = await DatabaseService.instance.isar;

    final mockUsersData = [
      {
        'uuid': 'user_alex',
        'name': 'Alex',
        'avatar': '☕',
        'bio': 'Specialty coffee & roaster reviews ☕☕',
      },
      {
        'uuid': 'user_taylor',
        'name': 'Taylor',
        'avatar': '🌿',
        'bio': 'Nature walks & cozy matcha spots 🍵',
      },
      {
        'uuid': 'user_jordan',
        'name': 'Jordan',
        'avatar': '🍕',
        'bio': 'Weekend food explorer & late night bites 🌙',
      },
    ];

    for (final data in mockUsersData) {
      final uuid = data['uuid']!;
      final existing = await db.users.filter().uuidEqualTo(uuid).findFirst();
      if (existing == null) {
        final user = User()
          ..uuid = uuid
          ..name = data['name']!
          ..avatar = data['avatar']!
          ..bio = data['bio']!
          ..createdAt = DateTime.now().subtract(const Duration(days: 30))
          ..isCurrentUser = false;

        await db.writeTxn(() async {
          await db.users.put(user);
        });

        // Seed initial follow relationships (Alex & Taylor follow 'user_me')
        if (uuid == 'user_alex' || uuid == 'user_taylor') {
          await followUser(uuid, 'user_me');
          await followUser('user_me', uuid); // Mutual friends!
        }
      }
    }
  }
}
