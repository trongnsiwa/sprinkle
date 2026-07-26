import 'package:flutter/material.dart';
import '../models/user.dart';
import '../utils/colors.dart';
import '../utils/typography.dart';
import 'follow_button.dart';

class ProfileHeader extends StatelessWidget {
  final User user;
  final bool isCurrentUser;
  final bool isFollowing;
  final bool isFriend;
  final int memoriesCount;
  final int friendsCount;
  final VoidCallback onFollowPressed;
  final VoidCallback onEditProfilePressed;

  const ProfileHeader({
    super.key,
    required this.user,
    required this.isCurrentUser,
    required this.isFollowing,
    required this.isFriend,
    required this.memoriesCount,
    required this.friendsCount,
    required this.onFollowPressed,
    required this.onEditProfilePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),

        // 80pt Avatar with Gradient Ring
        Container(
          width: 88,
          height: 88,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: AppColors.primaryGradient,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF1C1C1E),
            ),
            child: Center(
              child: Text(
                user.avatar,
                style: const TextStyle(fontSize: 42),
              ),
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Name
        Text(
          user.name,
          style: AppTypography.headlineLarge.copyWith(color: Colors.white),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 6),

        // Bio
        if (user.bio != null && user.bio!.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              user.bio!,
              style: AppTypography.bodySmall.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
        ] else ...[
          const SizedBox(height: 12),
        ],

        // Stats Counters Row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStatItem('MEMORIES', memoriesCount),
            Container(
              height: 24,
              width: 1,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              color: Colors.white.withValues(alpha: 0.15),
            ),
            _buildStatItem('FRIENDS', friendsCount),
          ],
        ),

        const SizedBox(height: 20),

        // Action Button (Edit Profile vs Follow/Unfollow)
        if (isCurrentUser)
          GestureDetector(
            onTap: onEditProfilePressed,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit_rounded, color: Colors.white, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          FollowButton(
            isFollowing: isFollowing,
            isFriend: isFriend,
            onPressed: onFollowPressed,
          ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildStatItem(String label, int value) {
    return Column(
      children: [
        Text(
          '$value',
          style: const TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: Colors.white.withValues(alpha: 0.5),
            letterSpacing: 1.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
