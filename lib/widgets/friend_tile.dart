import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/visit_record.dart';
import '../utils/colors.dart';
import '../utils/typography.dart';
import 'custom_thumbnail.dart';

class FriendTile extends StatelessWidget {
  final User user;
  final VisitRecord? latestMemory;
  final VoidCallback onTap;

  const FriendTile({
    super.key,
    required this.user,
    this.latestMemory,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String subtitleText = 'Active recently';
    if (latestMemory != null) {
      subtitleText = 'Visited ${latestMemory!.name}';
    } else if (user.bio != null && user.bio!.isNotEmpty) {
      subtitleText = user.bio!;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            // 40pt Avatar Circle
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.18),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  user.avatar,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Friend Name & Status
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitleText,
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // Latest Memory Thumbnail or Arrow
            if (latestMemory?.imageFileName != null &&
                latestMemory!.imageFileName!.isNotEmpty)
              CustomThumbnail(
                imageFileName: latestMemory!.imageFileName,
                size: 40,
                borderRadius: 10,
              )
            else
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.white.withValues(alpha: 0.4),
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}
