import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/visit_record.dart';
import '../providers/feed_provider.dart';
import '../services/image_service.dart';
import '../services/supabase_service.dart';
import '../utils/colors.dart';
import '../utils/date_formatter.dart';
import '../utils/typography.dart';
import '../widgets/sprinkle_button.dart';
import '../widgets/sprinkle_toast.dart';
import '../widgets/star_rating.dart';
import 'main_tab_view.dart';
import 'profile_view.dart';

class FeedView extends ConsumerStatefulWidget {
  const FeedView({super.key});

  @override
  ConsumerState<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends ConsumerState<FeedView> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _shareMemory(String placeName) {
    HapticFeedback.mediumImpact();
    SprinkleToast.show(
      context,
      'Sharing "$placeName"... ✨',
      type: ToastType.info,
    );
  }

  void _openInMaps(String address) async {
    HapticFeedback.lightImpact();
    final query = Uri.encodeComponent(address);
    final googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        SprinkleToast.show(
          context,
          'Could not launch maps app',
          type: ToastType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedAsync = ref.watch(feedStreamProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: feedAsync.when(
        data: (visits) {
          if (visits.isEmpty) {
            return Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 1. Visual Element Container with Primary Glow
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: 0.15),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            blurRadius: 24,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('🌟', style: TextStyle(fontSize: 40)),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 2. Typography
                    Text(
                      'No memories from friends yet',
                      style: AppTypography.headlineMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Capture your first memory or follow friends to see their moments here.',
                      style: AppTypography.bodyLarge.copyWith(
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // 3. CTA Button
                    SprinkleButton(
                      label: 'Capture First Memory',
                      icon: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                      onPressed: () {
                        ref.read(currentTabProvider.notifier).state = 1;
                      },
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(feedStreamProvider);
            },
            color: AppColors.primary,
            backgroundColor: const Color(0xFF1C1C1E),
            child: PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: visits.length,
              itemBuilder: (context, index) {
                final visit = visits[index];
                return _buildRealFeedCard(visit);
              },
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, _) => Center(
          child: Text('Error: $err', style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildRealFeedCard(VisitRecord visit) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final authorUserId = visit.userId ?? 'user_me';

    return FutureBuilder(
      future: SupabaseService.instance.getUserProfile(authorUserId),
      builder: (context, snapshot) {
        final authorName = snapshot.data?.name ?? (authorUserId == 'user_me' ? 'You' : 'Friend');
        final avatarEmoji = snapshot.data?.avatar ?? '📸';

        return Container(
          color: Colors.black,
          width: screenWidth,
          child: Column(
            children: [
              // 1. Top Section (Author Info & Actions)
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left: Author Avatar & Name (Tappable)
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ProfileView(userId: authorUserId),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: AppColors.primary.withValues(alpha: 0.25),
                              child: Text(avatarEmoji, style: const TextStyle(fontSize: 18)),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  authorName,
                                  style: AppTypography.labelBold.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  visit.timestamp.toFriendlyString(),
                                  style: AppTypography.caption.copyWith(
                                    color: Colors.white.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Right: Share & Maps Buttons
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => _shareMemory(visit.name),
                            child: const Icon(
                              Icons.share_rounded,
                              size: 22,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () => _openInMaps(visit.address ?? visit.name),
                            child: const Icon(
                              Icons.map_rounded,
                              size: 22,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 1),

              // 2. Middle Section (Image + Content Block)
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Full-Width Photo Container
                  Container(
                    width: screenWidth,
                    height: screenWidth,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1E),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 28,
                          spreadRadius: 0,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: visit.imageFileName != null && visit.imageFileName!.isNotEmpty
                        ? FutureBuilder<File?>(
                            future: ImageService.getImageFile(visit.imageFileName!),
                            builder: (context, snapshot) {
                              if (snapshot.hasData && snapshot.data != null) {
                                return Image.file(
                                  snapshot.data!,
                                  fit: BoxFit.cover,
                                  width: screenWidth,
                                  height: screenWidth,
                                );
                              }
                              return Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: AppColors.primaryGradient,
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(Icons.photo_rounded, size: 64, color: Colors.white38),
                                ),
                              );
                            },
                          )
                        : Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: AppColors.primaryGradient,
                              ),
                            ),
                            child: const Center(
                              child: Icon(Icons.photo_rounded, size: 64, color: Colors.white38),
                            ),
                          ),
                  ),

                  const SizedBox(height: 16),

                  // Metadata Text Block
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Expanded(
                              child: Text(
                                visit.name,
                                style: AppTypography.headlineLarge.copyWith(
                                  color: Colors.white,
                                  fontSize: 22,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            StarRating(
                              rating: visit.rating,
                              starSize: 16,
                            ),
                          ],
                        ),
                        if (visit.notes != null && visit.notes!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            visit.notes!,
                            style: AppTypography.bodyLarge.copyWith(
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              const Spacer(flex: 2),
              SizedBox(height: bottomPadding + 8),
            ],
          ),
        );
      },
    );
  }
}
