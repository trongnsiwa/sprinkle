import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Base shimmer container wrapper using Minimalist Premium color tokens
class SkeletonContainer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final bool isCircle;

  const SkeletonContainer({
    super.key,
    this.width = double.infinity,
    this.height = double.infinity,
    this.borderRadius = 12.0,
    this.isCircle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF2C2C2E),
      highlightColor: const Color(0xFF3A3A3C),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2E),
          shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: isCircle ? null : BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Shimmer circle for user avatars
class SkeletonAvatar extends StatelessWidget {
  final double radius;

  const SkeletonAvatar({
    super.key,
    this.radius = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonContainer(
      width: radius * 2,
      height: radius * 2,
      isCircle: true,
    );
  }
}

/// Shimmer bar for text lines
class SkeletonText extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonText({
    super.key,
    this.width = 120.0,
    this.height = 14.0,
    this.borderRadius = 6.0,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonContainer(
      width: width,
      height: height,
      borderRadius: borderRadius,
    );
  }
}

/// Skeleton grid tile for memory thumbnail grids (VisitListView / ProfileView)
class SkeletonGridItem extends StatelessWidget {
  final double borderRadius;

  const SkeletonGridItem({
    super.key,
    this.borderRadius = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SkeletonContainer(
        borderRadius: borderRadius,
      ),
    );
  }
}

/// Full card skeleton for vertical feed items (FeedView)
class SkeletonFeedCard extends StatelessWidget {
  const SkeletonFeedCard({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      color: Colors.black,
      width: screenWidth,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top author row
            Row(
              children: [
                const SkeletonAvatar(radius: 16),
                const SizedBox(width: 10),
                const SkeletonText(width: 110, height: 14),
                const Spacer(),
                const SkeletonText(width: 50, height: 12),
              ],
            ),
            const SizedBox(height: 16),

            // Main 1:1 image skeleton block
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24.0),
                child: const SkeletonContainer(
                  borderRadius: 24.0,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Bottom title & info skeleton lines
            const SkeletonText(width: 180, height: 20),
            const SizedBox(height: 8),
            const SkeletonText(width: 240, height: 14),
            const SizedBox(height: 8),
            Row(
              children: const [
                SkeletonText(width: 70, height: 14),
                SizedBox(width: 12),
                SkeletonText(width: 100, height: 14),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

/// Skeleton header layout for ProfileView
class SkeletonProfileHeader extends StatelessWidget {
  const SkeletonProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        const SkeletonAvatar(radius: 44),
        const SizedBox(height: 16),
        const SkeletonText(width: 140, height: 22),
        const SizedBox(height: 8),
        const SkeletonText(width: 220, height: 14),
        const SizedBox(height: 20),

        // Stat boxes row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: const [
                SkeletonText(width: 32, height: 20),
                SizedBox(height: 4),
                SkeletonText(width: 64, height: 11),
              ],
            ),
            const SizedBox(width: 40),
            Column(
              children: const [
                SkeletonText(width: 32, height: 20),
                SizedBox(height: 4),
                SkeletonText(width: 64, height: 11),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Edit Profile Button placeholder
        const SkeletonContainer(
          width: 130,
          height: 38,
          borderRadius: 20,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

/// Skeleton item for CommentsView sheet
class SkeletonCommentItem extends StatelessWidget {
  const SkeletonCommentItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonAvatar(radius: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonText(width: 100, height: 14),
                SizedBox(height: 6),
                SkeletonText(width: double.infinity, height: 12),
                SizedBox(height: 4),
                SkeletonText(width: 160, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
