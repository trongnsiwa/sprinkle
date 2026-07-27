import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../models/visit_record.dart';
import '../services/image_service.dart';
import '../utils/colors.dart';
import '../utils/typography.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../widgets/custom_thumbnail.dart';
import '../widgets/profile_header.dart';
import 'edit_profile_view.dart';
import 'settings_view.dart';
import 'visit_detail_view.dart';
import '../widgets/sprinkle_toast.dart';

class ProfileView extends ConsumerStatefulWidget {
  final String userId;

  const ProfileView({
    super.key,
    required this.userId,
  });

  @override
  ConsumerState<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> {
  void _openDetail(BuildContext context, VisitRecord visit) async {
    File? imageFile;
    if (visit.imageFileName != null && visit.imageFileName!.isNotEmpty) {
      imageFile = await ImageService.getImageFile(visit.imageFileName!);
      if (imageFile != null && context.mounted) {
        await precacheImage(FileImage(imageFile), context);
      }
    }
    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => VisitDetailView(
            visit: visit,
            resolvedImageFile: imageFile,
          ),
        ),
      );
    }
  }

  void _showEditProfileSheet(BuildContext context, ProfileViewModel viewModel, User user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditProfileView(
        user: user,
        viewModel: viewModel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileViewModelProvider(widget.userId));
    final viewModel = ref.read(profileViewModelProvider(widget.userId).notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      body: SafeArea(
        child: state.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : state.user == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('😕', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        const Text(
                          'User not found',
                          style: AppTypography.headlineMedium,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => Navigator.maybePop(context),
                          child: const Text('Go Back'),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => viewModel.loadProfile(),
                    color: AppColors.primary,
                    backgroundColor: const Color(0xFF2C2C2E),
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        // Pinned SliverAppBar Header
                        SliverAppBar(
                          pinned: true,
                          backgroundColor: const Color(0xFF1C1C1E),
                          elevation: 0,
                          leading: IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                            onPressed: () => Navigator.maybePop(context),
                          ),
                          title: Text(
                            state.isCurrentUser ? 'MY PROFILE' : 'PROFILE',
                            style: AppTypography.sectionTitle.copyWith(
                              color: Colors.white,
                              letterSpacing: 2.0,
                            ),
                          ),
                          centerTitle: true,
                          actions: [
                            if (state.isCurrentUser)
                              IconButton(
                                icon: const Icon(Icons.settings_rounded, color: Colors.white, size: 22),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const SettingsView(),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),

                        // Profile Header Info
                        SliverToBoxAdapter(
                          child: ProfileHeader(
                            user: state.user!,
                            isCurrentUser: state.isCurrentUser,
                            isFollowing: state.isFollowing,
                            isFriend: state.isFriend,
                            memoriesCount: state.memoriesCount,
                            friendsCount: state.friendsCount,
                            onFollowPressed: () async {
                              final success = await viewModel.toggleFollow();
                              if (!success && context.mounted) {
                                SprinkleToast.show(
                                  context,
                                  'Failed to update follow status. Please try again.',
                                  type: ToastType.error,
                                );
                              }
                            },
                            onEditProfilePressed: () => _showEditProfileSheet(
                              context,
                              viewModel,
                              state.user!,
                            ),
                          ),
                        ),

                      // Memories Section Header
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          child: Row(
                            children: [
                              const Icon(Icons.grid_view_rounded, color: Colors.white70, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'MEMORIES (${state.memories.length})',
                                style: AppTypography.sectionTitle.copyWith(
                                  color: Colors.white70,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // 3-Column Memories Grid
                      if (state.memories.isEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(40.0),
                            child: Column(
                              children: [
                                const Text('✨', style: TextStyle(fontSize: 40)),
                                const SizedBox(height: 12),
                                Text(
                                  'No memories collected yet',
                                  style: AppTypography.bodyLarge.copyWith(color: Colors.white60),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          sliver: SliverGrid(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final visit = state.memories[index];
                                return GestureDetector(
                                  onTap: () => _openDetail(context, visit),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        CustomThumbnail(
                                          imageFileName: visit.imageFileName,
                                          size: double.infinity,
                                          borderRadius: 16,
                                        ),

                                        // Rating Overlay Star Badge
                                        Positioned(
                                          bottom: 8,
                                          left: 8,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withValues(alpha: 0.7),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.star_rounded, color: AppColors.starGold, size: 13),
                                                const SizedBox(width: 3),
                                                Text(
                                                  visit.rating.toStringAsFixed(1),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    decoration: TextDecoration.none,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              childCount: state.memories.length,
                            ),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: 1.0,
                            ),
                          ),
                        ),

                      const SliverToBoxAdapter(
                        child: SizedBox(height: 40),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
