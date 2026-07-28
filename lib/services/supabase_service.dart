import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../models/comment.dart';
import '../models/user.dart';
import '../models/visit_record.dart';
import 'database_service.dart';
import 'image_service.dart';
import 'user_service.dart';

class SupabaseService {
  static SupabaseService? _instance;

  SupabaseService._();

  static SupabaseService get instance {
    _instance ??= SupabaseService._();
    return _instance!;
  }

  sb.SupabaseClient get _client => sb.Supabase.instance.client;

  /// Current authenticated Supabase Auth User
  sb.User? get currentUser => _client.auth.currentUser;

  /// Current authenticated session
  sb.Session? get currentSession => _client.auth.currentSession;

  /// Sign Up with Email & Password
  Future<sb.AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
    String avatar = '📸',
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'name': name,
        'avatar': avatar,
      },
    );

    final user = response.user;
    if (user != null) {
      await _client.from('users').upsert({
        'uid': user.id,
        'name': name,
        'avatar': avatar,
        'bio': 'Exploring spots & memories ✨',
      });
    }

    return response;
  }

  /// Sign In with Email & Password
  Future<sb.AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign Out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Fetch user profile by UID
  Future<User?> getUserProfile(String uid) async {
    try {
      final data = await _client
          .from('users')
          .select()
          .eq('uid', uid)
          .maybeSingle();

      if (data == null) return null;

      final isMe = currentUser?.id == uid;
      return User()
        ..uuid = data['uid'] ?? uid
        ..name = data['name'] ?? 'User'
        ..avatar = data['avatar'] ?? '📸'
        ..bio = data['bio']
        ..createdAt = DateTime.tryParse(data['created_at'] ?? '') ?? DateTime.now()
        ..isCurrentUser = isMe;
    } catch (_) {
      return null;
    }
  }

  /// Update user profile in Supabase
  Future<void> updateProfile({
    required String name,
    required String bio,
    required String avatar,
  }) async {
    final uid = currentUser?.id;
    if (uid == null) return;

    await _client.from('users').upsert({
      'uid': uid,
      'name': name.trim(),
      'bio': bio.trim(),
      'avatar': avatar,
    });
  }

  /// Upload memory image to Supabase Storage bucket ('memory-images')
  Future<String?> uploadMemoryImage(File imageFile, String memoryUuid) async {
    final sbUser = currentUser;
    if (sbUser == null) {
      debugPrint('[SupabaseService] Guest mode active - skipping cloud image upload');
      return null;
    }

    try {
      final uid = sbUser.id;
      final path = '$uid/$memoryUuid.jpg';

      debugPrint('[SupabaseService] Uploading image for memory $memoryUuid to storage path: $path');
      await _client.storage.from('memory-images').upload(
            path,
            imageFile,
            fileOptions: const sb.FileOptions(
              cacheControl: '3600',
              upsert: true,
            ),
          );

      final publicUrl = _client.storage.from('memory-images').getPublicUrl(path);
      debugPrint('[SupabaseService] Successfully uploaded image. Public URL: $publicUrl');
      return publicUrl;
    } catch (e) {
      debugPrint('[SupabaseService] Error uploading memory image: $e');
      return null;
    }
  }

  /// Get the primary key `id` (UUID) from `public.users` matching `currentUser.id` (`uid` in Supabase)
  Future<String?> getCurrentUserIdInUsersTable() async {
    final sbUser = currentUser;
    if (sbUser == null) return null;

    try {
      final data = await _client
          .from('users')
          .select('id')
          .eq('uid', sbUser.id)
          .maybeSingle();

      if (data != null && data['id'] != null) {
        return data['id'] as String;
      }

      // If user row in public.users does not exist yet, create default profile row
      debugPrint('[SupabaseService] Public user record missing for auth UID ${sbUser.id}. Creating default row...');
      final inserted = await _client.from('users').upsert({
        'uid': sbUser.id,
        'name': sbUser.email?.split('@').first ?? 'Sprinkle User',
        'avatar': '📸',
        'bio': 'Exploring spots & memories ✨',
      }).select('id').single();

      return inserted['id'] as String?;
    } catch (e) {
      debugPrint('[SupabaseService] Error resolving public user ID: $e');
      return null;
    }
  }

  /// Upload memory to Supabase `memories` table
  Future<void> uploadMemory(VisitRecord record, {String? imageUrl, String? publicUserId}) async {
    final sbUser = currentUser;
    if (sbUser == null) {
      debugPrint('[SupabaseService] Guest mode active - skipping cloud memory upload for ${record.uuid}');
      return;
    }

    final userId = publicUserId ?? await getCurrentUserIdInUsersTable();
    if (userId == null) {
      debugPrint('[SupabaseService] Could not resolve public.users.id for user ${sbUser.id}');
      throw Exception('Failed to resolve cloud user profile');
    }

    debugPrint('[SupabaseService] Uploading memory ${record.uuid} for public user $userId');
    try {
      await _client.from('memories').upsert({
        'uuid': record.uuid,
        'user_id': userId,
        'name': record.name,
        'notes': record.notes,
        'rating': record.rating,
        'timestamp': record.timestamp.toIso8601String(),
        'image_url': imageUrl,
        'address': record.address ?? record.name,
        'tags': record.tags,
      });
      debugPrint('[SupabaseService] Successfully uploaded memory ${record.uuid} to Supabase');
    } catch (e) {
      debugPrint('[SupabaseService] Failed to upload memory ${record.uuid}: $e');
      rethrow;
    }
  }

  /// Fetch memories for a specific user
  Future<List<VisitRecord>> getMemoriesForUser(String userId) async {
    try {
      final List<dynamic> data = await _client
          .from('memories')
          .select()
          .eq('user_id', userId)
          .order('timestamp', ascending: false);

      final List<VisitRecord> records = [];
      for (final json in data) {
        String? localImageFileName;
        final remoteImageUrl = json['image_url'] as String?;
        if (remoteImageUrl != null && remoteImageUrl.isNotEmpty) {
          localImageFileName = await ImageService.downloadAndSaveImage(remoteImageUrl);
        }

        final record = VisitRecord()
          ..uuid = json['uuid']
          ..userId = json['user_id']
          ..name = json['name'] ?? ''
          ..notes = json['notes']
          ..rating = (json['rating'] as num?)?.toDouble() ?? 5.0
          ..timestamp = DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now()
          ..address = json['address']
          ..imageFileName = localImageFileName
          ..imageUrl = remoteImageUrl
          ..tags = (json['tags'] as List?)?.cast<String>() ?? [];
        records.add(record);
      }
      return records;
    } catch (_) {
      return [];
    }
  }

  /// Fetch user memories from Supabase and cache them into local Isar DB
  Future<List<VisitRecord>> fetchAndSyncUserMemories(String authUid) async {
    try {
      debugPrint('[SupabaseService] Syncing user memories for auth UID: $authUid');
      final publicUserId = await getCurrentUserIdInUsersTable();
      final targetId = publicUserId ?? authUid;

      final memories = await getMemoriesForUser(targetId);
      debugPrint('[SupabaseService] Fetched ${memories.length} memories from Supabase');

      for (final record in memories) {
        record.userId = authUid;
        await DatabaseService.instance.saveVisit(record);
      }
      return memories;
    } catch (e) {
      debugPrint('[SupabaseService] Error syncing user memories: $e');
      return [];
    }
  }

  /// Sync user profile & memories from Supabase to local Isar DB upon login
  Future<void> syncAllDataOnLogin() async {
    final sbUser = currentUser;
    if (sbUser == null) return;
    await syncUserData(sbUser.id);
  }

  /// Sync user profile & memories for a specific user from Supabase to local Isar DB
  Future<void> syncUserData(String userId) async {
    try {
      debugPrint('[SupabaseService] Executing full cloud syncUserData for user $userId...');
      final cloudProfile = await getUserProfile(userId);
      if (cloudProfile != null) {
        final db = await DatabaseService.instance.isar;
        await db.writeTxn(() async {
          final existing = await db.users.filter().uuidEqualTo(userId).findFirst();
          if (existing != null) {
            existing.name = cloudProfile.name;
            existing.avatar = cloudProfile.avatar;
            existing.bio = cloudProfile.bio;
            existing.isCurrentUser = currentUser?.id == userId;
            await db.users.put(existing);
          } else {
            cloudProfile.isCurrentUser = currentUser?.id == userId;
            await db.users.put(cloudProfile);
          }
        });
      }

      await fetchAndSyncUserMemories(userId);
      debugPrint('[SupabaseService] Full cloud syncUserData completed successfully for $userId.');
    } catch (e) {
      debugPrint('[SupabaseService] Error during syncUserData: $e');
    }
  }

  /// Delete memory from Supabase
  Future<void> deleteMemory(String uuid) async {
    try {
      await _client.from('memories').delete().eq('uuid', uuid);
    } catch (_) {}
  }

  /// Follow target user
  Future<void> followUser(String targetUserId) async {
    final myUid = currentUser?.id;
    if (myUid == null || myUid == targetUserId) return;

    await _client.from('follows').upsert({
      'follower_id': myUid,
      'followee_id': targetUserId,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// Unfollow target user
  Future<void> unfollowUser(String targetUserId) async {
    final myUid = currentUser?.id;
    if (myUid == null) return;

    await _client
        .from('follows')
        .delete()
        .eq('follower_id', myUid)
        .eq('followee_id', targetUserId);
  }

  /// Check if current user is following targetUserId
  Future<bool> isFollowing(String targetUserId) async {
    final myUid = currentUser?.id;
    if (myUid == null) return false;

    try {
      final res = await _client
          .from('follows')
          .select()
          .eq('follower_id', myUid)
          .eq('followee_id', targetUserId)
          .maybeSingle();

      return res != null;
    } catch (_) {
      return false;
    }
  }

  /// Check if targetUserId is following current user
  Future<bool> isFollowedBy(String targetUserId) async {
    final myUid = currentUser?.id;
    if (myUid == null) return false;

    try {
      final res = await _client
          .from('follows')
          .select()
          .eq('follower_id', targetUserId)
          .eq('followee_id', myUid)
          .maybeSingle();

      return res != null;
    } catch (_) {
      return false;
    }
  }

  /// Ensure memory exists in cloud before engagement operations. If missing, attempt auto-upload.
  Future<bool> ensureMemoryExistsInCloud(String memoryUuid) async {
    try {
      final existing = await _client
          .from('memories')
          .select('uuid')
          .eq('uuid', memoryUuid)
          .maybeSingle();

      if (existing != null) return true;

      debugPrint('[SupabaseService] Memory $memoryUuid missing in cloud, attempting auto-sync from local Isar...');
      final localRecord = await UserService.instance.getVisitRecordByUuid(memoryUuid);
      if (localRecord != null) {
        String? imageUrl;
        if (localRecord.imageFileName != null && localRecord.imageFileName!.isNotEmpty) {
          final imageFile = await ImageService.getImageFile(localRecord.imageFileName!);
          if (imageFile != null) {
            imageUrl = await uploadMemoryImage(imageFile, localRecord.uuid);
          }
        }
        await uploadMemory(localRecord, imageUrl: imageUrl);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[SupabaseService] ensureMemoryExistsInCloud error for $memoryUuid: $e');
      return false;
    }
  }

  // --- LIKES & COMMENTS ---

  /// Get like count for a memory
  Future<int> getLikeCount(String memoryUuid) async {
    try {
      final res = await _client
          .from('memory_likes')
          .select()
          .eq('memory_uuid', memoryUuid);
      return (res as List).length;
    } catch (_) {
      return 0;
    }
  }

  /// Check if memory is liked by current user
  Future<bool> isLikedByCurrentUser(String memoryUuid) async {
    final myUid = currentUser?.id;
    if (myUid == null) return false;

    try {
      final res = await _client
          .from('memory_likes')
          .select()
          .eq('memory_uuid', memoryUuid)
          .eq('user_id', myUid)
          .maybeSingle();
      return res != null;
    } catch (_) {
      return false;
    }
  }

  /// Toggle like for a memory. Returns new liked state.
  Future<bool> toggleLike(String memoryUuid) async {
    final myUid = currentUser?.id;
    if (myUid == null) {
      debugPrint('[SupabaseService] toggleLike failed: User not authenticated');
      throw Exception('User not authenticated');
    }

    // Ensure target memory is present in cloud database
    final existsInCloud = await ensureMemoryExistsInCloud(memoryUuid);
    if (!existsInCloud) {
      debugPrint('[SupabaseService] toggleLike failed: Memory $memoryUuid is not in cloud database.');
      throw Exception('Memory is not synced to cloud yet. Please try again later.');
    }

    try {
      final isLiked = await isLikedByCurrentUser(memoryUuid);
      if (isLiked) {
        debugPrint('[SupabaseService] Removing like for memory $memoryUuid by user $myUid');
        await _client
            .from('memory_likes')
            .delete()
            .eq('memory_uuid', memoryUuid)
            .eq('user_id', myUid);
        return false;
      } else {
        debugPrint('[SupabaseService] Inserting like for memory $memoryUuid by user $myUid');
        await _client.from('memory_likes').insert({
          'memory_uuid': memoryUuid,
          'user_id': myUid,
          'created_at': DateTime.now().toIso8601String(),
        });
        return true;
      }
    } catch (e) {
      debugPrint('[SupabaseService] toggleLike error for memory $memoryUuid: $e');
      rethrow;
    }
  }

  /// Get comment count for a memory
  Future<int> getCommentCount(String memoryUuid) async {
    try {
      final res = await _client
          .from('memory_comments')
          .select()
          .eq('memory_uuid', memoryUuid);
      return (res as List).length;
    } catch (_) {
      return 0;
    }
  }

  /// Get comments for a memory
  Future<List<Comment>> getComments(String memoryUuid) async {
    try {
      final List<dynamic> data = await _client
          .from('memory_comments')
          .select()
          .eq('memory_uuid', memoryUuid)
          .order('created_at', ascending: true);

      final List<Comment> comments = [];
      for (final json in data) {
        final uid = json['user_id'] as String?;
        String name = 'Sprinkle User';
        String avatar = '📸';
        if (uid != null) {
          final profile = await getUserProfile(uid);
          if (profile != null) {
            name = profile.name;
            avatar = profile.avatar;
          }
        }
        comments.add(Comment.fromJson(json, name: name, avatar: avatar));
      }
      return comments;
    } catch (_) {
      return [];
    }
  }

  /// Add comment to a memory
  Future<Comment?> addComment(String memoryUuid, String content) async {
    final myUid = currentUser?.id;
    if (myUid == null) {
      debugPrint('[SupabaseService] addComment failed: User not authenticated');
      throw Exception('User not authenticated');
    }

    final trimmed = content.trim();
    if (trimmed.isEmpty) return null;

    // Ensure target memory is present in cloud database
    final existsInCloud = await ensureMemoryExistsInCloud(memoryUuid);
    if (!existsInCloud) {
      debugPrint('[SupabaseService] addComment failed: Memory $memoryUuid is not in cloud database.');
      throw Exception('Memory is not synced to cloud yet. Please try again later.');
    }

    try {
      debugPrint('[SupabaseService] Inserting comment for memory $memoryUuid by user $myUid');
      final data = await _client.from('memory_comments').insert({
        'memory_uuid': memoryUuid,
        'user_id': myUid,
        'content': trimmed,
        'created_at': DateTime.now().toIso8601String(),
      }).select().single();

      final profile = await getUserProfile(myUid);
      return Comment.fromJson(
        data,
        name: profile?.name ?? 'You',
        avatar: profile?.avatar ?? '📸',
      );
    } catch (e) {
      debugPrint('[SupabaseService] addComment error for memory $memoryUuid: $e');
      rethrow;
    }
  }
}
