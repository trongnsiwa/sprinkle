import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/colors.dart';
import '../utils/typography.dart';
import '../viewmodels/camera_viewmodel.dart';
import '../viewmodels/streak_viewmodel.dart';
import '../models/visit_record.dart';
import '../services/user_service.dart';
import '../widgets/custom_shutter.dart';
import '../widgets/friend_tile.dart';
import '../widgets/sprinkle_toast.dart';
import '../widgets/square_preview.dart';
import 'add_edit_view.dart';
import 'explore_view.dart';
import 'profile_view.dart';

class CameraView extends ConsumerStatefulWidget {
  const CameraView({super.key});

  @override
  ConsumerState<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends ConsumerState<CameraView>
    with WidgetsBindingObserver {
  bool _isFlashing = false;
  bool _isFriendsSheetOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cameraViewModelProvider.notifier).loadLatestThumbnail();
      ref.read(cameraViewModelProvider.notifier).checkPermission();
      ref.read(updateStreakProvider);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(cameraViewModelProvider.notifier).checkPermission();
    }
  }

  void _triggerShutterFlash() {
    setState(() {
      _isFlashing = true;
    });
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() {
          _isFlashing = false;
        });
      }
    });
  }

  void _openAddSheet(String path) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: AddEditView(initialCapturedImagePath: path),
      ),
    );

    ref.read(cameraViewModelProvider.notifier).setShowingSheet(false);
  }

  void _openFriendsSheet() async {
    setState(() {
      _isFriendsSheetOpen = true;
    });

    final currentUser = await UserService.instance.getOrCreateCurrentUser();
    final friends = await UserService.instance.getFriends(currentUser.uuid);

    final Map<String, VisitRecord?> latestMemories = {};
    for (final friend in friends) {
      latestMemories[friend.uuid] =
          await UserService.instance.getLatestMemoryForUser(friend.uuid);
    }

    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (modalContext) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Material(
          color: const Color(0xFF1C1C1E),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '👥 FRIENDS (${friends.length})',
                        style: AppTypography.sectionTitle,
                      ),
                      IconButton(
                        onPressed: () => Navigator.maybePop(modalContext),
                        icon: const Icon(Icons.close_rounded, color: Colors.white70),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (friends.isEmpty) ...[
                    const SizedBox(height: 16),
                    const Text('👥', style: TextStyle(fontSize: 44)),
                    const SizedBox(height: 12),
                    const Text(
                      'No friends yet',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Follow others to see their memories here.',
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                  ] else ...[
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.45,
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: friends.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 4),
                        itemBuilder: (context, index) {
                          final friend = friends[index];
                          final memory = latestMemories[friend.uuid];
                          return FriendTile(
                            user: friend,
                            latestMemory: memory,
                            onTap: () {
                              Navigator.maybePop(modalContext);
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ProfileView(userId: friend.uuid),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (mounted) {
      setState(() {
        _isFriendsSheetOpen = false;
      });
    }
  }

  void _openExplore() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ExploreView()),
    );
  }

  void _openProfileModal() async {
    final user = await UserService.instance.getOrCreateCurrentUser();
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ProfileView(userId: user.uuid),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cameraState = ref.watch(cameraViewModelProvider);
    final viewModel = ref.read(cameraViewModelProvider.notifier);

    if (!cameraState.isAuthorized && !cameraState.isMockMode) {
      final isPermDenied = cameraState.isPermanentlyDenied;
      return Scaffold(
        backgroundColor: const Color(0xFF1C1C1E),
        body: SafeArea(
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
                      color: AppColors.primary.withValues(alpha: 0.20),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 36,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    isPermDenied
                        ? 'Camera Access Permanently Denied'
                        : 'Camera Access Required',
                    style: AppTypography.headlineMedium.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isPermDenied
                        ? 'Camera access is disabled in settings. Please enable camera permission for Sprinkle in your device settings or use gallery mode.'
                        : 'Sprinkle needs access to your camera to record memories.',
                    style: AppTypography.bodySmall.copyWith(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  if (isPermDenied) ...[
                    ElevatedButton(
                      onPressed: () => viewModel.openAppSettings(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Open Settings', style: AppTypography.labelBold),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => viewModel.reloadCamera(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white38),
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Reload Camera', style: AppTypography.labelBold),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => viewModel.enableMockMode(),
                      child: Text(
                        'Use Gallery Instead',
                        style: AppTypography.labelBold.copyWith(color: Colors.white70),
                      ),
                    ),
                  ] else ...[
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
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => viewModel.enableMockMode(),
                      child: Text(
                        'Use Gallery Instead',
                        style: AppTypography.labelBold.copyWith(color: Colors.white70),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    }

    final controller = viewModel.controller;
    final screenSize = MediaQuery.of(context).size;
    final maxPreviewHeight = screenSize.height * 0.48;
    final squareSize = (screenSize.width - 16.0).clamp(0.0, maxPreviewHeight);

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.velocity.pixelsPerSecond.dy < -500) {
            _openExplore();
          }
        },
        child: Container(
          color: Colors.black,
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              // Main Layout Column
              SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 56), // Top bar space
                    const Spacer(),

                    // Square 1:1 Preview Card with Neutral Glow & No Border
                    SquarePreview(
                      controller: controller,
                      isInitialized: cameraState.isCameraInitialized,
                      isMockMode: cameraState.isMockMode,
                      width: squareSize,
                      borderRadius: 32.0,
                      isCircle: false,
                      isFlashing: _isFlashing,
                      isFlashOn: cameraState.isFlashOn,
                      onFlashToggle: () => viewModel.toggleFlash(),
                    ),

                    const SizedBox(height: 20),

                    // Pure Camera Actions (Gallery, CustomShutter, Flip Camera)
                    _CameraActions(
                      isCapturing: cameraState.isCapturing,
                      onGalleryTap: () async {
                        final path = await viewModel.pickImageFromGallery();
                        if (path != null) {
                          _openAddSheet(path);
                        }
                      },
                      onShutterTap: () async {
                        HapticFeedback.mediumImpact();
                        _triggerShutterFlash();
                        final capturedPath = await viewModel.capturePhoto();
                        if (capturedPath != null) {
                          _openAddSheet(capturedPath);
                        }
                      },
                      onCameraSwitchTap: () {
                        if (cameraState.isMockMode) {
                          SprinkleToast.show(
                            context,
                            'Switched camera mode!',
                            type: ToastType.neutral,
                            duration: const Duration(seconds: 1),
                          );
                        } else {
                          viewModel.switchCamera();
                        }
                      },
                    ),

                    const SizedBox(height: 28),
                    const Spacer(),
                  ],
                ),
              ),

              // Minimal Locket Top Bar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _TopBar(
                  isFriendsSheetOpen: _isFriendsSheetOpen,
                  onAvatarTap: _openProfileModal,
                  onFriendsTap: _openFriendsSheet,
                ),
              ),

              // Subtle BETA Badge in top-right corner
              if (cameraState.isMockMode)
                Positioned(
                  top: 48,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Text(
                      'BETA',
                      style: AppTypography.caption.copyWith(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final bool isFriendsSheetOpen;
  final VoidCallback onAvatarTap;
  final VoidCallback onFriendsTap;

  const _TopBar({
    required this.isFriendsSheetOpen,
    required this.onAvatarTap,
    required this.onFriendsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left: 40pt circular avatar (gradient ring, white person icon)
            GestureDetector(
              onTap: onAvatarTap,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: AppColors.primaryGradient),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 22,
                  color: Colors.white,
                ),
              ),
            ),

            // Center: "Friends" label with a small red dot next to it (70% opacity)
            GestureDetector(
              onTap: onFriendsTap,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Friends',
                    style: AppTypography.labelBold.copyWith(
                      color: Colors.white.withValues(alpha: 0.70),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF3B30),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),

            // Right: Streak badge (🔥 X) - only visible if streak > 0
            Consumer(
              builder: (context, ref, child) {
                final streakAsync = ref.watch(streakProvider);
                return streakAsync.when(
                  data: (streak) {
                    if (streak == 0) return const SizedBox(width: 40);
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Text('🔥', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                          Text(
                            '$streak',
                            style: AppTypography.badgeNumber.copyWith(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  loading: () => const SizedBox(width: 40),
                  error: (_, _) => const SizedBox(width: 40),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CameraActions extends StatelessWidget {
  final bool isCapturing;
  final VoidCallback onGalleryTap;
  final VoidCallback onShutterTap;
  final VoidCallback onCameraSwitchTap;

  const _CameraActions({
    required this.isCapturing,
    required this.onGalleryTap,
    required this.onShutterTap,
    required this.onCameraSwitchTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: 48pt circular photo picker / gallery icon button matching flip button
          GestureDetector(
            onTap: onGalleryTap,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.12),
              ),
              child: const Icon(
                Icons.photo_library_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),

          // Center: CustomShutter Button
          CustomShutter(
            isEnabled: !isCapturing,
            onTap: onShutterTap,
          ),

          // Right: Flip Camera Button
          GestureDetector(
            onTap: onCameraSwitchTap,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.12),
              ),
              child: const Icon(
                Icons.flip_camera_ios_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
