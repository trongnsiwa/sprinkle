import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import '../models/visit_record.dart';
import '../services/image_service.dart';
import '../utils/colors.dart';
import '../utils/date_formatter.dart';
import '../utils/typography.dart';
import '../viewmodels/visit_list_viewmodel.dart';
import '../widgets/star_rating.dart';

class FeedComment {
  final String id;
  final String userName;
  final String text;
  final DateTime timestamp;

  FeedComment({
    required this.id,
    required this.userName,
    required this.text,
    required this.timestamp,
  });
}

class FeedCardData {
  final String id;
  final String authorName;
  final String placeName;
  final String? address;
  final double rating;
  final String? notes;
  final String timestampText;
  final String? imageFileName;
  final IconData avatarIcon;
  final int? defaultLikes;
  final List<FeedComment>? defaultComments;

  FeedCardData({
    required this.id,
    required this.authorName,
    required this.placeName,
    this.address,
    required this.rating,
    this.notes,
    required this.timestampText,
    this.imageFileName,
    this.avatarIcon = Icons.person_rounded,
    this.defaultLikes = 12,
    this.defaultComments = const [],
  });

  int get safeDefaultLikes => defaultLikes ?? 12;
  List<FeedComment> get safeDefaultComments => defaultComments ?? const [];
}

class FeedView extends ConsumerStatefulWidget {
  const FeedView({super.key});

  @override
  ConsumerState<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends ConsumerState<FeedView> {
  late PageController _pageController;

  // Local state per card item ID
  final Map<String, bool> _likedMap = {};
  final Map<String, int> _likeCountMap = {};
  final Map<String, List<FeedComment>> _commentsMap = {};

  final List<FeedCardData> _mockCards = [
    FeedCardData(
      id: 'mock_1',
      authorName: 'Alex Rivers',
      placeName: 'The Coffee Collective',
      address: 'The Coffee Collective',
      rating: 4.8,
      notes: 'Best oat milk cortado in town! Cozy interior vibes ☕️✨',
      timestampText: '2h ago',
      avatarIcon: Icons.coffee_rounded,
      defaultLikes: 14,
      defaultComments: [
        FeedComment(
          id: 'c1',
          userName: 'Jordan Lee',
          text: 'Love their cortado! Try the blueberry scone next time 😋',
          timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
        ),
        FeedComment(
          id: 'c2',
          userName: 'Taylor Swift',
          text: 'Adding this to my list! 🔥',
          timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        ),
      ],
    ),
    FeedCardData(
      id: 'mock_2',
      authorName: 'Jordan Lee',
      placeName: 'Matcha Mama Cafe',
      address: 'Matcha Mama Cafe',
      rating: 5.0,
      notes: 'Iced ceremonial matcha latte + coconut bowl! 🍵🥥',
      timestampText: '4h ago',
      avatarIcon: Icons.local_drink_rounded,
      defaultLikes: 24,
      defaultComments: [
        FeedComment(
          id: 'c3',
          userName: 'Alex Rivers',
          text: 'The coconut bowl looks incredible!',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ],
    ),
    FeedCardData(
      id: 'mock_3',
      authorName: 'Taylor Swift',
      placeName: 'Sunset Vista Overlook',
      address: 'Sunset Vista Overlook',
      rating: 4.9,
      notes: 'Golden hour view was unreal today. Highly recommend visiting at 6 PM! 🌅',
      timestampText: '6h ago',
      avatarIcon: Icons.wb_sunny_rounded,
      defaultLikes: 45,
      defaultComments: [
        FeedComment(
          id: 'c4',
          userName: 'Morgan Chen',
          text: 'Stunning sunset photo! 🌅',
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        ),
      ],
    ),
  ];

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

  bool _isLiked(FeedCardData item) {
    return _likedMap[item.id] ?? false;
  }

  int _getLikeCount(FeedCardData item) {
    return _likeCountMap[item.id] ?? item.safeDefaultLikes;
  }

  List<FeedComment> _getComments(FeedCardData item) {
    return _commentsMap[item.id] ?? List.from(item.safeDefaultComments);
  }

  void _toggleLike(FeedCardData item) {
    HapticFeedback.lightImpact();
    setState(() {
      final current = _isLiked(item);
      final count = _getLikeCount(item);
      _likedMap[item.id] = !current;
      _likeCountMap[item.id] = !current ? count + 1 : (count - 1).clamp(0, 9999);
    });
  }

  Future<void> _openInMaps(String placeQuery) async {
    final encodedQuery = Uri.encodeComponent(placeQuery);
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encodedQuery');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch Google Maps')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error launching maps: $e')),
        );
      }
    }
  }

  void _shareMemory(String placeName) {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Shared "$placeName" memory!'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showCommentsBottomSheet(BuildContext context, FeedCardData item) {
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1C1C1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final comments = _getComments(item);

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 16,
                left: 20,
                right: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Drag Handle & Title
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Comments (${comments.length})',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white70),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 8),

                  // Comment List
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 280),
                    child: comments.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: Text(
                                'No comments yet. Be the first to comment!',
                                style: TextStyle(color: Colors.white54, fontSize: 13),
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: comments.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final comment = comments[index];
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor: AppColors.primary.withValues(alpha: 0.25),
                                    child: const Icon(Icons.person, size: 14, color: Colors.white),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              comment.userName,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              comment.timestamp.toFriendlyString(),
                                              style: const TextStyle(
                                                color: Colors.white38,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          comment.text,
                                          style: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.9),
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                  ),

                  const SizedBox(height: 16),

                  // Comment Input Bar
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: commentController,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Add a comment...',
                            hintStyle: const TextStyle(color: Colors.white38),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.08),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send_rounded, color: AppColors.primary),
                        onPressed: () {
                          final text = commentController.text.trim();
                          if (text.isNotEmpty) {
                            final newComment = FeedComment(
                              id: const Uuid().v4(),
                              userName: 'You',
                              text: text,
                              timestamp: DateTime.now(),
                            );

                            setState(() {
                              final currentList = _getComments(item);
                              _commentsMap[item.id] = [...currentList, newComment];
                            });

                            setModalState(() {});
                            commentController.clear();
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<FeedCardData> _buildCombinedFeed(List<VisitRecord> userVisits) {
    final List<FeedCardData> list = [];

    for (final visit in userVisits) {
      list.add(
        FeedCardData(
          id: visit.uuid,
          authorName: 'You',
          placeName: visit.name,
          address: visit.address ?? visit.name,
          rating: visit.rating,
          notes: visit.notes,
          timestampText: visit.timestamp.toFriendlyString(),
          imageFileName: visit.imageFileName,
          avatarIcon: Icons.person_rounded,
          defaultLikes: 8,
          defaultComments: [
            FeedComment(
              id: 'user_c1',
              userName: 'Alex Rivers',
              text: 'Nice memory! Looks great 📸',
              timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
            ),
          ],
        ),
      );
    }

    list.addAll(_mockCards);
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final visitsAsync = ref.watch(visitStreamProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: visitsAsync.when(
        data: (userVisits) {
          final items = _buildCombinedFeed(userVisits);

          return PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildStoryStyleCard(item);
            },
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

  Widget _buildStoryStyleCard(FeedCardData item) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isLiked = _isLiked(item);
    final likeCount = _getLikeCount(item);
    final comments = _getComments(item);

    return Container(
      color: Colors.black,
      child: Column(
        children: [
          // 1. Header (Pinned Top Edge inside SafeArea)
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left: CircleAvatar + Name + Time
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.primary,
                        child: Icon(item.avatarIcon, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.authorName,
                            style: AppTypography.labelBold.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            item.timestampText,
                            style: AppTypography.caption.copyWith(
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Right: Share & Maps Icon Buttons
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _shareMemory(item.placeName),
                        child: const Icon(
                          Icons.share_rounded,
                          size: 22,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () => _openInMaps(item.address ?? item.placeName),
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

          // 2. Top Spacer (flex: 1)
          const Spacer(flex: 1),

          // 3. Middle Section (Centered Content Block: Image + 16pt Gap + Footer)
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Media: Full-Width Edge-to-Edge 1:1 Photo with 32pt Squircle Radius & Glowing Primary Shadow
              Container(
                width: screenWidth,
                height: screenWidth,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32.0),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 40,
                      spreadRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32.0),
                  child: _buildSquarePhoto(item.imageFileName),
                ),
              ),

              const SizedBox(height: 16), // Tight 16pt gap

              // Footer Details
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Place Name
                    Text(
                      item.placeName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.headlineMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Rating
                    Row(
                      children: [
                        StarRating(rating: item.rating, starSize: 16),
                        const SizedBox(width: 6),
                        Text(
                          '(${item.rating.toStringAsFixed(1)})',
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    // Notes (if available)
                    if (item.notes != null && item.notes!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.notes!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),

                    // Social Reactions Row (Like & Comment)
                    Row(
                      children: [
                        // Like Button + Count
                        GestureDetector(
                          onTap: () => _toggleLike(item),
                          child: Row(
                            children: [
                              Icon(
                                isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                color: isLiked ? const Color(0xFFFF3B30) : Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '$likeCount',
                                style: AppTypography.caption.copyWith(
                                  color: isLiked
                                      ? const Color(0xFFFF3B30)
                                      : Colors.white.withValues(alpha: 0.7),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Comment Button + Count
                        GestureDetector(
                          onTap: () => _showCommentsBottomSheet(context, item),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.chat_bubble_outline_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${comments.length}',
                                style: AppTypography.caption.copyWith(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 4. Bottom Spacer (flex: 1)
          const Spacer(flex: 1),

          SizedBox(height: 80 + bottomPadding),
        ],
      ),
    );
  }

  Widget _buildSquarePhoto(String? imageFileName) {
    if (imageFileName != null && imageFileName.isNotEmpty) {
      return FutureBuilder<File?>(
        future: ImageService.getImageFile(imageFileName),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return Image.file(
              snapshot.data!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            );
          }
          return _buildSquareFallback();
        },
      );
    }
    return _buildSquareFallback();
  }

  Widget _buildSquareFallback() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF2C2C2E),
            Color(0xFF1C1C1E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.photo_camera_rounded,
          size: 48,
          color: Colors.white.withValues(alpha: 0.2),
        ),
      ),
    );
  }
}
