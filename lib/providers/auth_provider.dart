import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart' as app_model;
import '../services/supabase_service.dart';
import '../services/user_service.dart';

final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

final currentAppUserProvider = FutureProvider.autoDispose<app_model.User>((ref) async {
  final supabaseUser = SupabaseService.instance.currentUser;
  if (supabaseUser != null) {
    final profile = await SupabaseService.instance.getUserProfile(supabaseUser.id);
    if (profile != null) return profile;
  }
  return await UserService.instance.getOrCreateCurrentUser();
});
