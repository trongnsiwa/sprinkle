import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/user_service.dart';

final currentUserProvider = FutureProvider<User>((ref) async {
  return await UserService.instance.getOrCreateCurrentUser();
});
