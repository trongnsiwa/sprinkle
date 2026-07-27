import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';
import '../models/visit_record.dart';
import '../services/database_service.dart';
import '../services/image_service.dart';
import '../services/supabase_service.dart';
import '../services/user_service.dart';

class AddEditState {
  final String? existingUuid;
  final String name;
  final String notes;
  final double rating;
  final List<String> tags;
  final String? selectedImagePath;
  final String? existingImageFileName;
  final bool isSaving;
  final String? errorMessage;

  AddEditState({
    this.existingUuid,
    this.name = '',
    this.notes = '',
    this.rating = 0.0,
    this.tags = const [],
    this.selectedImagePath,
    this.existingImageFileName,
    this.isSaving = false,
    this.errorMessage,
  });

  bool get isValid => name.trim().isNotEmpty;

  AddEditState copyWith({
    String? existingUuid,
    String? name,
    String? notes,
    double? rating,
    List<String>? tags,
    String? selectedImagePath,
    String? existingImageFileName,
    bool? isSaving,
    String? errorMessage,
  }) {
    return AddEditState(
      existingUuid: existingUuid ?? this.existingUuid,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      rating: rating ?? this.rating,
      tags: tags ?? this.tags,
      selectedImagePath: selectedImagePath ?? this.selectedImagePath,
      existingImageFileName: existingImageFileName ?? this.existingImageFileName,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
    );
  }
}

class AddEditViewModel extends StateNotifier<AddEditState> {
  AddEditViewModel() : super(AddEditState());

  void init({VisitRecord? existingRecord, String? initialCapturedImagePath}) {
    if (existingRecord != null) {
      state = AddEditState(
        existingUuid: existingRecord.uuid,
        name: existingRecord.name,
        notes: existingRecord.notes ?? '',
        rating: existingRecord.rating,
        tags: List.from(existingRecord.tags),
        existingImageFileName: existingRecord.imageFileName,
      );
    } else {
      state = AddEditState(
        selectedImagePath: initialCapturedImagePath,
      );
    }
  }

  void setName(String name) {
    state = state.copyWith(name: name);
  }

  void setNotes(String notes) {
    state = state.copyWith(notes: notes);
  }

  void setRating(double rating) {
    state = state.copyWith(rating: rating);
  }

  void setTags(List<String> tags) {
    state = state.copyWith(tags: tags);
  }

  void parseAndSetTags(String tagInput) {
    final rawTags = tagInput
        .split(RegExp(r'[\s,#]+'))
        .map((t) => t.trim().replaceAll('#', ''))
        .where((t) => t.isNotEmpty)
        .toList();
    state = state.copyWith(tags: rawTags);
  }

  void setSelectedImagePath(String? path) {
    state = state.copyWith(selectedImagePath: path);
  }

  Future<VisitRecord?> save() async {
    if (!state.isValid || state.isSaving) return null;

    try {
      state = state.copyWith(isSaving: true);

      String? imageFileName = state.existingImageFileName;

      if (state.selectedImagePath != null && state.selectedImagePath!.isNotEmpty) {
        final file = File(state.selectedImagePath!);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          imageFileName = await ImageService.saveImage(bytes);
        }
      }

      double? latitude;
      double? longitude;

      try {
        final query = state.name.trim();
        if (query.isNotEmpty) {
          final locations = await locationFromAddress(query);
          if (locations.isNotEmpty) {
            latitude = locations.first.latitude;
            longitude = locations.first.longitude;
          }
        }
      } catch (_) {
        try {
          final pos = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(timeLimit: Duration(seconds: 3)),
          );
          latitude = pos.latitude;
          longitude = pos.longitude;
        } catch (_) {}
      }

      final uuid = state.existingUuid ?? const Uuid().v4();
      final currentUser = await UserService.instance.getOrCreateCurrentUser();
      final userId = SupabaseService.instance.currentUser?.id ?? currentUser.uuid;

      final record = VisitRecord()
        ..uuid = uuid
        ..userId = userId
        ..name = state.name.trim()
        ..notes = state.notes.trim().isEmpty ? null : state.notes.trim()
        ..rating = state.rating
        ..timestamp = DateTime.now()
        ..imageFileName = imageFileName
        ..address = state.name.trim()
        ..latitude = latitude
        ..longitude = longitude
        ..tags = state.tags;

      await DatabaseService.instance.saveVisit(record);

      // Background Supabase Storage & Database Sync
      try {
        String? downloadUrl;
        if (state.selectedImagePath != null && state.selectedImagePath!.isNotEmpty) {
          final file = File(state.selectedImagePath!);
          if (await file.exists()) {
            downloadUrl = await SupabaseService.instance.uploadMemoryImage(file, record.uuid);
          }
        }

        await SupabaseService.instance.uploadMemory(record, imageUrl: downloadUrl);
      } catch (_) {}

      state = state.copyWith(isSaving: false);
      return record;
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: e.toString());
      return null;
    }
  }
}

final addEditViewModelProvider =
    StateNotifierProvider.autoDispose<AddEditViewModel, AddEditState>((ref) {
  return AddEditViewModel();
});
