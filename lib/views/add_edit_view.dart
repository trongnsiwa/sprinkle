import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:confetti/confetti.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../models/visit_record.dart';
import '../providers/feed_provider.dart';
import '../utils/colors.dart';
import '../utils/typography.dart';
import '../viewmodels/add_edit_viewmodel.dart';
import '../viewmodels/stats_viewmodel.dart';
import '../viewmodels/visit_list_viewmodel.dart';
import '../views/main_tab_view.dart';
import '../widgets/custom_thumbnail.dart';
import '../widgets/sprinkle_button.dart';
import '../widgets/sprinkle_text_field.dart';
import '../widgets/sprinkle_toast.dart';
import '../widgets/vibe_picker.dart';

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
  late final TextEditingController _nameController;
  late final TextEditingController _notesController;
  late final TextEditingController _tagsController;
  late final ConfettiController _confettiController;

  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _tagsFocusNode = FocusNode();
  final FocusNode _notesFocusNode = FocusNode();

  bool _showSavedSuccess = false;

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
    _nameFocusNode.dispose();
    _tagsFocusNode.dispose();
    _notesFocusNode.dispose();
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

  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2C2C2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: Colors.white),
              title: const Text('Take Photo', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.maybePop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: Colors.white),
              title: const Text('Choose from Gallery', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.maybePop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addEditViewModelProvider);
    final viewModel = ref.read(addEditViewModelProvider.notifier);
    final isEdit = widget.existingVisit != null;
    final mediaQuery = MediaQuery.of(context);
    final maxHeight = mediaQuery.size.height * 0.9;

    final tagChips = state.tags.map((tag) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.secondary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: AppColors.secondary.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Text(
          '#$tag',
          style: AppTypography.labelBold.copyWith(
            color: AppColors.secondary,
            fontSize: 12,
          ),
        ),
      );
    }).toList();

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: maxHeight,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1C1C1E),
              borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Pinned Header Section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Drag Handle
                        Center(
                          child: Container(
                            width: 36,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Title Row & Close Icon
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isEdit ? 'Edit Memory' : 'New Memory',
                              style: AppTypography.headlineMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.maybePop(context),
                              icon: const Icon(Icons.close_rounded, color: Colors.white70),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Scrollable Form Body
                  Flexible(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.only(
                        left: 20.0,
                        right: 20.0,
                        top: 16.0,
                        bottom: mediaQuery.viewInsets.bottom + 24.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image Selection Area
                          Center(
                            child: GestureDetector(
                              onTap: _showImagePickerSheet,
                              child: Stack(
                                children: [
                                  if (state.selectedImagePath != null)
                                    Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: Colors.white24, width: 1.5),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primary.withValues(alpha: 0.2),
                                            blurRadius: 10,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(18.5),
                                        child: Image.file(
                                          File(state.selectedImagePath!),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    )
                                  else if (state.existingImageFileName != null)
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: Colors.white24, width: 1.5),
                                      ),
                                      child: CustomThumbnail(
                                        imageFileName: state.existingImageFileName,
                                        size: 120.0,
                                        borderRadius: 18.5,
                                      ),
                                    )
                                  else
                                    Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2C2C2E),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.15),
                                        ),
                                      ),
                                      child: const Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add_a_photo_rounded,
                                            size: 36,
                                            color: Colors.white54,
                                          ),
                                          SizedBox(height: 6),
                                          Text(
                                            'Add Photo',
                                            style: TextStyle(
                                              color: Colors.white54,
                                              fontSize: 12,
                                            ),
                                          ),
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
                          const SizedBox(height: 20),

                          // Store Name Input (Location Icon)
                          SprinkleTextField(
                            label: 'PLACE / STORE NAME',
                            hint: 'e.g. Arabica Coffee',
                            controller: _nameController,
                            focusNode: _nameFocusNode,
                            textInputAction: TextInputAction.next,
                            onSubmitted: (_) => FocusScope.of(context).requestFocus(_tagsFocusNode),
                            prefixIcon: const Icon(Icons.location_on_rounded),
                            isDark: true,
                            onChanged: (val) => viewModel.setName(val),
                          ),
                          const SizedBox(height: 20),

                          // Vibe Check Rating Input (Glass Container)
                          VibePicker(
                            rating: state.rating,
                            isDark: true,
                            onRatingChanged: (val) => viewModel.setRating(val),
                          ),
                          const SizedBox(height: 20),

                          // Tags Input (Tag Icon + Inline Chips, No Raw Text Duplication)
                          SprinkleTextField(
                            label: 'TAGS',
                            hint: '#cafe #coffee #matcha',
                            controller: _tagsController,
                            focusNode: _tagsFocusNode,
                            textInputAction: TextInputAction.next,
                            onSubmitted: (_) => FocusScope.of(context).requestFocus(_notesFocusNode),
                            prefixIcon: const Icon(Icons.local_offer_rounded),
                            isDark: true,
                            chips: tagChips.isNotEmpty ? tagChips : null,
                            onChanged: (val) => viewModel.parseAndSetTags(val),
                          ),
                          const SizedBox(height: 20),

                          // Notes Input (Notes Icon + Character Counter)
                          SprinkleTextField(
                            label: 'NOTES',
                            hint: 'Add memories, drinks tried, or special notes...',
                            controller: _notesController,
                            focusNode: _notesFocusNode,
                            prefixIcon: const Icon(Icons.edit_note_rounded),
                            isDark: true,
                            style: SprinkleTextFieldStyle.outline,
                            maxLines: 3,
                            maxLength: 200,
                            onChanged: (val) => viewModel.setNotes(val),
                          ),
                          const SizedBox(height: 24),

                          // Save Button
                          SprinkleButton(
                            label: _showSavedSuccess
                                ? 'Collected! ✨'
                                : (isEdit ? 'Update Memory' : 'Save Memory'),
                            isLoading: state.isSaving,
                            isEnabled: state.isValid && !state.isSaving,
                            isDark: true,
                            icon: _showSavedSuccess
                                ? const Icon(Icons.check_circle_rounded, color: Colors.white, size: 22)
                                : null,
                            onPressed: () async {
                              final savedRecord = await viewModel.save();
                              if (!mounted) return;
                              if (savedRecord != null) {
                                setState(() {
                                  _showSavedSuccess = true;
                                });
                                _confettiController.play();
                                ref.read(visitListViewModelProvider.notifier).fetchVisits();
                                ref.invalidate(todaySpotsProvider);
                                ref.invalidate(feedStreamProvider);
                                ref.read(currentTabProvider.notifier).state = 2;

                                if (context.mounted) {
                                  SprinkleToast.show(
                                    context,
                                    'Collected! ✨',
                                    type: ToastType.success,
                                    duration: const Duration(milliseconds: 1200),
                                  );
                                }
                                await Future.delayed(const Duration(milliseconds: 500));
                                if (context.mounted) {
                                  Navigator.maybePop(context, savedRecord);
                                }
                              }
                            },
                          ),
                        ],
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
