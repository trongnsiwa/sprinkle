import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:confetti/confetti.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../models/visit_record.dart';
import '../utils/colors.dart';
import '../utils/typography.dart';
import '../viewmodels/add_edit_viewmodel.dart';
import '../viewmodels/stats_viewmodel.dart';
import '../viewmodels/visit_list_viewmodel.dart';
import '../widgets/custom_thumbnail.dart';

class AddEditView extends ConsumerStatefulWidget {
  final VisitRecord? existingVisit;
  final String? initialCapturedImagePath;

  const AddEditView({
    super.key,
    this.existingVisit,
    this.initialCapturedImagePath,
  });

  @override
  ConsumerState<AddEditView> createState() => _AddEditViewState();
}

class _AddEditViewState extends ConsumerState<AddEditView> {
  late TextEditingController _nameController;
  late TextEditingController _notesController;
  late TextEditingController _tagsController;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _nameController = TextEditingController(text: widget.existingVisit?.name ?? '');
    _notesController = TextEditingController(text: widget.existingVisit?.notes ?? '');
    _tagsController = TextEditingController(
      text: widget.existingVisit?.tags.map((t) => '#$t').join(' ') ?? '',
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(addEditViewModelProvider.notifier).init(
            existingRecord: widget.existingVisit,
            initialCapturedImagePath: widget.initialCapturedImagePath,
          );
      if (widget.existingVisit == null) {
        _fetchLocation();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _nameController.dispose();
    _notesController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _fetchLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 3),
        ),
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty && mounted) {
        final place = placemarks.first;
        final parts = <String>[];
        if (place.name != null && place.name!.isNotEmpty) parts.add(place.name!);
        if (place.locality != null && place.locality!.isNotEmpty) parts.add(place.locality!);
        final name = parts.join(', ');

        if (_nameController.text.isEmpty && name.isNotEmpty) {
          _nameController.text = name;
          ref.read(addEditViewModelProvider.notifier).setName(name);
        }
      }
    } catch (_) {}
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      ref.read(addEditViewModelProvider.notifier).setSelectedImagePath(pickedFile.path);
    }
  }

  Widget _buildVibeCheck(AddEditState state) {
    final vibes = [
      {'emoji': '🤯', 'value': 5.0},
      {'emoji': '😍', 'value': 4.0},
      {'emoji': '😐', 'value': 3.0},
      {'emoji': '🤮', 'value': 1.0},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('VIBE CHECK', style: AppTypography.sectionTitle),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: vibes.map((vibe) {
            final isSelected = state.rating == vibe['value'];
            return GestureDetector(
              onTap: () => ref
                  .read(addEditViewModelProvider.notifier)
                  .setRating(vibe['value'] as double),
              child: AnimatedScale(
                scale: isSelected ? 1.25 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.18)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(30),
                    border: isSelected
                        ? Border.all(color: AppColors.primary, width: 2)
                        : Border.all(color: Colors.transparent, width: 2),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.25),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    vibe['emoji'] as String,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        if (state.rating > 0)
          Center(
            child: Text(
              '${state.rating.toStringAsFixed(1)} / 5.0',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addEditViewModelProvider);
    final viewModel = ref.read(addEditViewModelProvider.notifier);

    final isEdit = widget.existingVisit != null;

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)), // rounded-xl
          ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Indicator Bar
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.neutralLight.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEdit ? 'Edit Memory' : 'New Memory',
                    style: AppTypography.headlineMedium,
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: AppColors.neutralLight),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Image Selection Area
              Center(
                child: GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => SafeArea(
                        child: Wrap(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.camera_alt_rounded),
                              title: const Text('Take Photo'),
                              onTap: () {
                                Navigator.pop(context);
                                _pickImage(ImageSource.camera);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.photo_library_rounded),
                              title: const Text('Choose from Gallery'),
                              onTap: () {
                                Navigator.pop(context);
                                _pickImage(ImageSource.gallery);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: Stack(
                    children: [
                      if (state.selectedImagePath != null)
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            image: DecorationImage(
                              image: FileImage(File(state.selectedImagePath!)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      else if (state.existingImageFileName != null)
                        CustomThumbnail(
                          imageFileName: state.existingImageFileName,
                          size: 120.0,
                          borderRadius: 20.0,
                        )
                      else
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.neutralUltraLight,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.neutralLight.withValues(alpha: 0.3),
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo_rounded,
                                size: 36,
                                color: AppColors.neutralLight,
                              ),
                              SizedBox(height: 6),
                              Text('Add Photo', style: AppTypography.caption),
                            ],
                          ),
                        ),
                      Positioned(
                        right: 4,
                        bottom: 4,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Store Name Input
              const Text('PLACE / STORE NAME', style: AppTypography.labelBold),
              const SizedBox(height: 6),
              TextField(
                controller: _nameController,
                style: AppTypography.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'e.g. Arabica Coffee',
                  hintStyle: AppTypography.bodyLarge.copyWith(color: AppColors.neutralLight),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.neutralLight.withValues(alpha: 0.3)),
                  ),
                ),
                onChanged: (val) => viewModel.setName(val),
              ),
              const SizedBox(height: 20),

              // Vibe Check Rating Input
              _buildVibeCheck(state),
              const SizedBox(height: 20),

              // Tags Input
              const Text('TAGS', style: AppTypography.labelBold),
              const SizedBox(height: 6),
              TextField(
                controller: _tagsController,
                style: AppTypography.bodyLarge,
                decoration: InputDecoration(
                  hintText: '#cafe #coffee #matcha',
                  hintStyle: AppTypography.bodyLarge.copyWith(color: AppColors.neutralLight),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.neutralLight.withValues(alpha: 0.3)),
                  ),
                ),
                onChanged: (val) => viewModel.parseAndSetTags(val),
              ),
              const SizedBox(height: 20),

              // Notes Input
              const Text('NOTES', style: AppTypography.labelBold),
              const SizedBox(height: 6),
              TextField(
                controller: _notesController,
                style: AppTypography.bodyLarge,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Add memories, drinks tried, or special notes...',
                  hintStyle: AppTypography.bodyLarge.copyWith(color: AppColors.neutralLight),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppColors.neutralLight.withValues(alpha: 0.3)),
                  ),
                ),
                onChanged: (val) => viewModel.setNotes(val),
              ),
              const SizedBox(height: 28),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: state.isValid && !state.isSaving
                      ? () async {
                          final messenger = ScaffoldMessenger.of(context);
                          final navigator = Navigator.of(context);
                          final savedRecord = await viewModel.save();
                          if (savedRecord != null && mounted) {
                            _confettiController.play();
                            ref.read(visitListViewModelProvider.notifier).fetchVisits();
                            ref.invalidate(todaySpotsProvider);
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Row(
                                  children: [
                                    Icon(Icons.check_circle_rounded, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text('Collected! ✨', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                backgroundColor: AppColors.primary,
                                duration: Duration(milliseconds: 1200),
                              ),
                            );
                            await Future.delayed(const Duration(milliseconds: 400));
                            if (mounted) navigator.pop(savedRecord);
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: state.isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          isEdit ? 'Update Memory' : 'Save Memory',
                          style: AppTypography.headlineMedium.copyWith(color: Colors.white, fontSize: 18),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    Positioned(
        top: 10,
        child: ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          colors: const [
            AppColors.primary,
            AppColors.secondary,
            Color(0xFFFFD700),
            Color(0xFFFF6B6B),
            Color(0xFF4ECDC4),
          ],
          numberOfParticles: 35,
          gravity: 0.25,
        ),
      ),
    ],
  );
}
}


