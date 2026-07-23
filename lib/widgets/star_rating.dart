import 'package:flutter/material.dart';
import '../utils/colors.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final int maxRating;
  final double starSize;
  final ValueChanged<double>? onRatingChanged;
  final bool isInteractive;

  const StarRating({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.starSize = 18.0,
    this.onRatingChanged,
    this.isInteractive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxRating, (index) {
        final starIndex = index + 1;
        IconData iconData;
        Color color;

        if (rating >= starIndex) {
          iconData = Icons.star_rounded;
          color = AppColors.starGold;
        } else if (rating >= starIndex - 0.5) {
          iconData = Icons.star_half_rounded;
          color = AppColors.starGold;
        } else {
          iconData = Icons.star_outline_rounded;
          color = AppColors.neutralLight.withValues(alpha: 0.4);
        }

        Widget starWidget = Icon(
          iconData,
          size: starSize,
          color: color,
        );

        if (isInteractive) {
          return GestureDetector(
            onTap: () {
              onRatingChanged?.call(starIndex.toDouble());
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: starWidget,
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(right: 2.0),
          child: starWidget,
        );
      }),
    );
  }
}
