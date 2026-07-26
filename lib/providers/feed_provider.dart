import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/visit_record.dart';
import '../services/database_service.dart';

final feedStreamProvider = StreamProvider.autoDispose<List<VisitRecord>>((ref) async* {
  // Emit local Isar cached visits first for immediate UI
  final localVisits = await DatabaseService.instance.getAllVisits();
  yield localVisits;

  // Stream memories table real-time changes if Supabase is connected
  try {
    final client = Supabase.instance.client;
    final stream = client
        .from('memories')
        .stream(primaryKey: ['id'])
        .order('timestamp', ascending: false);

    await for (final data in stream) {
      final remoteVisits = data.map((json) {
        return VisitRecord()
          ..uuid = json['uuid']
          ..userId = json['user_id']
          ..name = json['name'] ?? ''
          ..notes = json['notes']
          ..rating = (json['rating'] as num?)?.toDouble() ?? 5.0
          ..timestamp = DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now()
          ..address = json['address'];
      }).toList();

      yield remoteVisits.isNotEmpty ? remoteVisits : localVisits;
    }
  } catch (_) {
    yield localVisits;
  }
});
