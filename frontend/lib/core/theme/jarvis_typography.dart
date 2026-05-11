import 'package:flutter/material.dart';
import 'jarvis_colors.dart';

/// Jarvis Design System Typography
///
/// Defines all text styles used throughout the application.
/// Follows a consistent type scale with proper hierarchy.
class JarvisTypography {
  JarvisTypography._();

  // Font Family
  static const String _fontFamily = 'SF Pro Display';

  // Display Text Styles (Large headings)
  /// Display Large - 57px, Bold
  static const TextStyle displayLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 57,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
    color: JarvisColors.textPrimary,
  );

  /// Display Medium - 45px, Bold
  static const TextStyle displayMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 45,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
    color: JarvisColors.textPrimary,
  );

  /// Display Small - 36px, Bold
  static const TextStyle displaySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.3,
    color: JarvisColors.textPrimary,
  );

  // Headline Text Styles
  /// Headline Large - 32px, SemiBold
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: -0.2,
    color: JarvisColors.textPrimary,
  );

  /// Headline Medium - 28px, SemiBold
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: -0.2,
    color: JarvisColors.textPrimary,
  );

  /// Headline Small - 24px, SemiBold
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.1,
    color: JarvisColors.textPrimary,
  );

  // Title Text Styles
  /// Title Large - 22px, SemiBold
  static const TextStyle titleLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0,
    color: JarvisColors.textPrimary,
  );

  /// Title Medium - 16px, SemiBold
  static const TextStyle titleMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.15,
    color: JarvisColors.textPrimary,
  );

  /// Title Small - 14px, SemiBold
  static const TextStyle titleSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.1,
    color: JarvisColors.textPrimary,
  );

  // Body Text Styles
  /// Body Large - 16px, Regular
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.5,
    color: JarvisColors.textPrimary,
  );

  /// Body Medium - 14px, Regular
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.25,
    color: JarvisColors.textPrimary,
  );

  /// Body Small - 12px, Regular
  static const TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.4,
    color: JarvisColors.textPrimary,
  );

  // Label Text Styles (for buttons, chips, etc.)
  /// Label Large - 14px, Medium
  static const TextStyle labelLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.1,
    color: JarvisColors.textPrimary,
  );

  /// Label Medium - 12px, Medium
  static const TextStyle labelMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.5,
    color: JarvisColors.textPrimary,
  );

  /// Label Small - 11px, Medium
  static const TextStyle labelSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.5,
    color: JarvisColors.textPrimary,
  );

  // Button Text Styles
  /// Button Large - 16px, SemiBold
  static const TextStyle buttonLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.5,
    color: JarvisColors.textOnGold,
  );

  /// Button Medium - 14px, SemiBold
  static const TextStyle buttonMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.5,
    color: JarvisColors.textOnGold,
  );

  /// Button Small - 12px, SemiBold
  static const TextStyle buttonSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.5,
    color: JarvisColors.textOnGold,
  );

  // Specialized Text Styles
  /// Caption - 12px, Regular (for secondary information)
  static const TextStyle caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.3,
    letterSpacing: 0.4,
    color: JarvisColors.textSecondary,
  );

  /// Overline - 10px, Medium, Uppercase (for labels)
  static const TextStyle overline = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.6,
    letterSpacing: 1.5,
    color: JarvisColors.textSecondary,
  );

  /// Code - Monospace font for code snippets
  static const TextStyle code = TextStyle(
    fontFamily: 'SF Mono',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0,
    color: JarvisColors.primaryGold,
  );

  // Helper methods to create variations

  /// Creates a copy of the text style with gold color
  static TextStyle gold(TextStyle style) {
    return style.copyWith(color: JarvisColors.primaryGold);
  }

  /// Creates a copy of the text style with secondary text color
  static TextStyle secondary(TextStyle style) {
    return style.copyWith(color: JarvisColors.textSecondary);
  }

  /// Creates a copy of the text style with tertiary text color
  static TextStyle tertiary(TextStyle style) {
    return style.copyWith(color: JarvisColors.textTertiary);
  }

  /// Creates a copy of the text style with error color
  static TextStyle error(TextStyle style) {
    return style.copyWith(color: JarvisColors.error);
  }

  /// Creates a copy of the text style with success color
  static TextStyle success(TextStyle style) {
    return style.copyWith(color: JarvisColors.success);
  }

  /// Creates a copy of the text style with white color
  static TextStyle white(TextStyle style) {
    return style.copyWith(color: JarvisColors.textPrimary);
  }

  /// Creates a copy of the text style with black color (for gold backgrounds)
  static TextStyle black(TextStyle style) {
    return style.copyWith(color: JarvisColors.textOnGold);
  }
}
