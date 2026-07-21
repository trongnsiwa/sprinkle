import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/colors.dart';
import '../utils/typography.dart';
import '../viewmodels/camera_viewmodel.dart';
import '../widgets/custom_shutter.dart';
import '../widgets/custom_thumbnail.dart';
import 'add_edit_view.dart';
import 'main_tab_view.dart';

class CameraView extends ConsumerStatefulWidget {
  const CameraView({super.key});

  @override
  ConsumerState<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends ConsumerState<CameraView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cameraViewModelProvider.notifier).loadLatestThumbnail();
    });
  }

  void _openAddSheet(String path) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddEditView(initialCapturedImagePath: path),
    );
    ref.read(cameraViewModelProvider.notifier).setShowingSheet(false);
  }

  @override
  Widget build(BuildContext context) {
    final cameraState = ref.watch(cameraViewModelProvider);
    final viewModel = ref.read(cameraViewModelProvider.notifier);

    if (!cameraState.isAuthorized) {
      return Container(
        color: Colors.black,
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 36,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Camera Access Required',
                    style: AppTypography.headlineMedium.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Sprinkle needs access to your camera to record memories.',
                    style: AppTypography.bodySmall.copyWith(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => viewModel.requestPermission(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Grant Permission', style: AppTypography.labelBold),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final controller = viewModel.controller;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full Screen Camera Preview
          if (cameraState.isCameraInitialized && controller != null)
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: controller.value.previewSize?.height ?? 1,
                  height: controller.value.previewSize?.width ?? 1,
                  child: CameraPreview(controller),
                ),
              ),
            )
          else
            const Positioned.fill(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),

          // Top Bar Overlay
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top-Left: 40pt Avatar + Friends label
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          ref.read(currentTabProvider.notifier).state = 0; // Go to Friends
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            size: 24,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Friends',
                        style: AppTypography.caption.copyWith(
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),

                  // Top-Right: Flash Toggle
                  IconButton(
                    onPressed: () => viewModel.toggleFlash(),
                    icon: Icon(
                      cameraState.isFlashOn
                          ? Icons.flash_on_rounded
                          : Icons.flash_off_rounded,
                      size: 20,
                      color: cameraState.isFlashOn
                          ? const Color(0xFFFFCC00)
                          : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Controls (Centered group, 40pt spacing, 40pt above bottom safe area)
          Positioned(
            left: 0,
            right: 0,
            bottom: 40 + MediaQuery.of(context).padding.bottom + 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Left: 50pt circle thumbnail
                GestureDetector(
                  onTap: () {
                    ref.read(currentTabProvider.notifier).state = 2; // Open Memories tab
                  },
                  child: CustomThumbnail(
                    imageFile: cameraState.latestThumbnailFile,
                    size: 50.0,
                    isCircle: true,
                    hasBorder: true,
                  ),
                ),

                const SizedBox(width: 40),

                // Centre: Shutter Button
                CustomShutter(
                  isEnabled: !cameraState.isCapturing,
                  onTap: () async {
                    final capturedPath = await viewModel.capturePhoto();
                    if (capturedPath != null) {
                      _openAddSheet(capturedPath);
                    }
                  },
                ),

                const SizedBox(width: 40),

                // Right: 50pt empty spacer for symmetry
                const SizedBox(width: 50, height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
