import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/typography.dart';

class SocialActivityItem {
  final String id;
  final String userName;
  final String avatarUrl;
  final String actionText;
  final String placeName;
  final String timeAgo;
  final double rating;
  final String? notes;
  final String? imageUrl;
  final int likesCount;
  final int commentsCount;
  final IconData avatarIcon;

  SocialActivityItem({
    required this.id,
    required this.userName,
    required this.avatarUrl,
    required this.actionText,
    required this.placeName,
    required this.timeAgo,
    required this.rating,
    this.notes,
    this.imageUrl,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.avatarIcon = Icons.person_rounded,
  });
}

class SocialFeedView extends StatefulWidget {
  const SocialFeedView({super.key});

  @override
  State<SocialFeedView> createState() => _SocialFeedViewState();
}

class _SocialFeedViewState extends State<SocialFeedView> {
  final Set<String> _likedIds = {};

  final List<SocialActivityItem> _activities = [
    SocialActivityItem(
      id: '1',
      userName: 'Alex Rivers',
      avatarUrl: '',
      actionText: 'captured a memory at',
      placeName: 'The Coffee Collective',
      timeAgo: '2h ago',
      rating: 4.8,
      notes: 'Best oat milk cortado in town! Cozy interior vibes ☕️✨',
      likesCount: 12,
      commentsCount: 3,
      avatarIcon: Icons.coffee_rounded,
    ),
    SocialActivityItem(
      id: '2',
      userName: 'Jordan Lee',
      avatarUrl: '',
      actionText: 'checked into',
      placeName: 'Matcha Mama Cafe',
      timeAgo: '4h ago',
      rating: 5.0,
      notes: 'Iced ceremonial matcha latte + coconut bowl! 🍵🥥',
      likesCount: 24,
      commentsCount: 7,
      avatarIcon: Icons.local_drink_rounded,
    ),
    SocialActivityItem(
      id: '3',
      userName: 'Taylor Swift',
      avatarUrl: '',
      actionText: 'explored',
      placeName: 'Sunset Vista Overlook',
      timeAgo: '6h ago',
      rating: 4.9,
      notes: 'Golden hour view was unreal today. Highly recommend visiting at 6 PM! 🌅',
      likesCount: 45,
      commentsCount: 14,
      avatarIcon: Icons.wb_sunny_rounded,
    ),
    SocialActivityItem(
      id: '4',
      userName: 'Morgan Chen',
      avatarUrl: '',
      actionText: 'discovered',
      placeName: 'Baker Street Bakery',
      timeAgo: '1d ago',
      rating: 4.7,
      notes: 'Fresh almond croissants right out of the oven! 🥐🥐',
      likesCount: 18,
      commentsCount: 2,
      avatarIcon: Icons.bakery_dining_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.people_alt_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Friends Activity',
                    style: AppTypography.headlineMedium.copyWith(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF3B30),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Live',
                          style: AppTypography.caption.copyWith(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(color: Colors.white10, height: 1),

            // Scrollable Activity Feed
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                itemCount: _activities.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final item = _activities[index];
                  final isLiked = _likedIds.contains(item.id);
                  final currentLikes = item.likesCount + (isLiked ? 1 : 0);

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161618),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Author Header
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: AppColors.primaryGradient,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                item.avatarIcon,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: item.userName,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        TextSpan(
                                          text: ' ${item.actionText}',
                                          style: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.6),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.placeName,
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              item.timeAgo,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.4),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),

                        if (item.notes != null && item.notes!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            item.notes!,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 14,
                              height: 1.35,
                            ),
                          ),
                        ],

                        const SizedBox(height: 12),

                        // Bottom Actions (Rating + Like/Comment)
                        Row(
                          children: [
                            // Rating Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    color: Colors.amber,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${item.rating}',
                                    style: const TextStyle(
                                      color: Colors.amber,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),

                            // Like Button
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isLiked) {
                                    _likedIds.remove(item.id);
                                  } else {
                                    _likedIds.add(item.id);
                                  }
                                });
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    isLiked
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    color: isLiked
                                        ? const Color(0xFFFF3B30)
                                        : Colors.white54,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$currentLikes',
                                    style: TextStyle(
                                      color: isLiked
                                          ? const Color(0xFFFF3B30)
                                          : Colors.white54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Comments
                            Row(
                              children: [
                                const Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  color: Colors.white54,
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${item.commentsCount}',
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
