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
  static final Color outline = neutralLight.withValues(alpha: 0.3);

  // --- NEW: Gradient Accents (Sunset ➔ Teal) ---
  static const List<Color> primaryGradient = [
    Color(0xFFFF512F), // Vibrant Orange-Red
    Color(0xFFDD2475), // Deep Pink
  ];
  static const List<Color> secondaryGradient = [
    Color(0xFF00C9FF), // Bright Cyan
    Color(0xFF92FE9D), // Mint Green
  ];

  // --- NEW: Deep Space Background Gradient (for Camera & Lists) ---
  static const List<Color> backgroundGradient = [
    Color(0xFF0B0C10), // Almost black
    Color(0xFF1F2833), // Deep slate blue
  ];
  static const List<Color> backgroundGradientVibrant = [
    Color(0xFF1A0B2E), // Deep dark purple (base)
    Color(0xFF3B1E6B), // Rich vivid purple
    Color(0xFF9D4EDD), // Bright magenta/purple glow (center)
    Color(0xFFFF6B6B), // Splash of coral at the very bottom
  ];

  // --- NEW: Glassmorphism tokens ---
  static const Color glassBorder = Color(0x26FFFFFF); // 15% white
  static const Color glassBackground = Color(0x0DFFFFFF); // 5% white

  // --- NEW: Cream & Candy Warm Palette ---
  static const Color warmBackground = Color(0xFFFFF8F0);   // Soft cream
  static const Color warmPeach = Color(0xFFFFE5D9);        // Light peach
  static const Color warmCoral = Color(0xFFFF6B6B);        // Keep primary coral
  static const Color warmMint = Color(0xFF9AD0C2);         // Soft mint accent
  static const Color warmYellow = Color(0xFFFED766);       // Playful yellow
  static const Color warmShadow = Color(0x33FF6B6B);       // Coral at 20% for shadows
}

