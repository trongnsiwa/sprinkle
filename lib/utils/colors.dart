import 'package:flutter/material.dart';

/// Semantic colors for Sprinkle design system
abstract class AppColors {
  /// Primary: #FF6B6B (Shutter fill, active tab tint, key CTAs)
  static const Color primary = Color(0xFFFF6B6B);
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// Secondary: #4ECDC4 (Tags, subtle accents)
  static const Color secondary = Color(0xFF4ECDC4);
  static const Color onSecondary = Color(0xFFFFFFFF);

  /// Neutral & Support
  static const Color neutral = Color(0xFF1A1A1A);
  static const Color neutralLight = Color(0xFF8E8E93);
  static const Color neutralUltraLight = Color(0xFFF2F2F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color starGold = Color(0xFFFF9500);
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);

  /// Semantic Aliases
  static const Color background = neutralUltraLight;
  static const Color onBackground = neutral;
  static final Color outline = neutralLight.withOpacity(0.3);
}
