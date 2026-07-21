import 'package:flutter/material.dart';
import 'colors.dart';

/// Typography text styles for Sprinkle design system using SVN-Gilroy font family
abstract class AppTypography {
  static const String fontFamily = 'SVN-Gilroy';

  /// Display Large: 34pt Bold (700)
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 34.0,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 41 / 34,
    color: AppColors.neutral,
  );

  /// Headline Large: 28pt Bold (700)
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28.0,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.0,
    height: 34 / 28,
    color: AppColors.neutral,
  );

  /// Headline Medium: 20pt Semibold (600)
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.0,
    height: 25 / 20,
    color: AppColors.neutral,
  );

  /// Body Large: 17pt Regular (400)
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.0,
    height: 22 / 17,
    color: AppColors.neutral,
  );

  /// Body Small: 15pt Regular (400)
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.0,
    height: 20 / 15,
    color: AppColors.neutralLight,
  );

  /// Label Bold: 13pt Semibold (600)
  static const TextStyle labelBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    height: 18 / 13,
    color: AppColors.neutral,
  );

  /// Caption: 12pt Regular (400)
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.0,
    height: 16 / 12,
    color: AppColors.neutralLight,
  );
}
