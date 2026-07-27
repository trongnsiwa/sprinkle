import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart' as app_model;
import '../models/visit_record.dart';

class SupabaseService {
  static SupabaseService? _instance;

  SupabaseService._();

  static SupabaseService get instance {
    _instance ??= SupabaseService._();
    return _instance!;
  }

  SupabaseClient get _client => Supabase.instance.client;

  /// Current authenticated Supabase Auth User
  User? get currentUser => _client.auth.currentUser;

  /// Current authenticated session
  Session? get currentSession => _client.auth.currentSession;

  /// Sign Up with Email & Password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
    String avatar = '📸',
  }) async {
    final response = await _client.auth.signUp(
      email: email.trim(),
      password: password.trim(),
      data: {
        'name': name.trim(),
        'avatar': avatar,
      },
    );

    if (response.user != null) {
      await _client.from('users').upsert({
        'uid': response.user!.id,
        'name': name.trim(),
        'avatar': avatar,
        'bio': 'Capturing everyday coffee & moments ✨',
        'created_at': DateTime.now().toIso8601String(),
      });
    }

    return response;
  }

  /// Sign In with Email & Password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  /// Sign Out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Fetch user profile by UID
  Future<app_model.User?> getUserProfile(String uid) async {
    try {
      final data = await _client
          .from('users')
          .select()
          .eq('uid', uid)
          .maybeSingle();

      if (data == null) return null;

      final isMe = currentUser?.id == uid;
      return app_model.User()
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
    try {
      final uid = currentUser?.id ?? 'guest';
      final path = '$uid/$memoryUuid.jpg';

      await _client.storage.from('memory-images').upload(
            path,
            imageFile,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true,
            ),
          );

      return _client.storage.from('memory-images').getPublicUrl(path);
    } catch (_) {
      return null;
    }
  }

  /// Upload memory to Supabase `memories` table
  Future<void> uploadMemory(VisitRecord record, {String? imageUrl}) async {
    final uid = currentUser?.id ?? record.userId ?? 'user_me';
    await _client.from('memories').upsert({
      'uuid': record.uuid,
      'user_id': uid,
      'name': record.name,
      'notes': record.notes,
      'rating': record.rating,
      'timestamp': record.timestamp.toIso8601String(),
      'image_url': imageUrl,
      'address': record.address ?? record.name,
      'tags': record.tags,
    });
  }

  /// Fetch memories for a specific user
  Future<List<VisitRecord>> getMemoriesForUser(String userId) async {
    try {
      final List<dynamic> data = await _client
          .from('memories')
          .select()
          .eq('user_id', userId)
          .order('timestamp', ascending: false);

      return data.map((json) {
        return VisitRecord()
          ..uuid = json['uuid']
          ..userId = json['user_id']
          ..name = json['name'] ?? ''
          ..notes = json['notes']
          ..rating = (json['rating'] as num?)?.toDouble() ?? 5.0
          ..timestamp = DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now()
          ..address = json['address']
          ..tags = (json['tags'] as List?)?.cast<String>() ?? [];
      }).toList();
    } catch (_) {
      return [];
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
}
