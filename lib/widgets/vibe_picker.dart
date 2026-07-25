import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/colors.dart';
import '../utils/typography.dart';

class VibePicker extends StatelessWidget {
  final double rating;
  final ValueChanged<double> onRatingChanged;
  final bool isDark;

  const VibePicker({
    super.key,
    required this.rating,
    required this.onRatingChanged,
    this.isDark = true,
  });

  static const vibes = [
    {'emoji': '🤯', 'value': 5.0},
    {'emoji': '😍', 'value': 4.0},
    {'emoji': '😐', 'value': 3.0},
    {'emoji': '🙁', 'value': 2.0},
    {'emoji': '🤮', 'value': 1.0},
  ];

  @override
  Widget build(BuildContext context) {
    const labelColor = AppColors.primary;
    final containerColor = isDark
        ? const Color(0xFF2C2C2E)
        : AppColors.neutralUltraLight;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : AppColors.neutralLight.withValues(alpha: 0.3);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.emoji_emotions_rounded,
            color: labelColor,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'VIBE CHECK',
                  style: AppTypography.labelBold.copyWith(
                    color: labelColor,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: vibes.map((vibe) {
                          final vibeValue = vibe['value'] as double;
                          final isSelected = rating == vibeValue;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6.0),
                            child: GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                onRatingChanged(vibeValue);
                              },
                              child: AnimatedScale(
                                scale: isSelected ? 1.15 : 1.0,
                                duration: const Duration(milliseconds: 150),
                                child: Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary.withValues(alpha: 0.25)
                                        : (isDark ? const Color(0xFF1C1C1E) : Colors.white),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected ? AppColors.primary : Colors.white10,
                                      width: isSelected ? 1.5 : 1.0,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: AppColors.primary.withValues(alpha: 0.3),
                                              blurRadius: 8,
                                              spreadRadius: 0,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      vibe['emoji'] as String,
                                      style: const TextStyle(fontSize: 22),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    if (rating > 0)
                      Text(
                        '${rating.toStringAsFixed(1)} / 5.0',
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
