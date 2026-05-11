import 'package:flutter/cupertino.dart';

import 'adaptive_colors.dart';

/// iOS-native Cupertino theme configuration for Jarvis
/// Supports both light and dark modes with Gold accent.
class JarvisCupertinoTheme {
  const JarvisCupertinoTheme._();

  /// Dark theme - Primary theme for Jarvis
  static CupertinoThemeData dark() {
    return const CupertinoThemeData(
      brightness: Brightness.dark,
      primaryColor: AdaptiveColors.primary,
      primaryContrastingColor: CupertinoColors.white,
      scaffoldBackgroundColor: Color(0xFF000000),
      barBackgroundColor: Color(0xF01C1C1E), // 94% opacity
      textTheme: CupertinoTextThemeData(
        primaryColor: AdaptiveColors.primary,
        textStyle: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 17,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.41,
          color: CupertinoColors.white,
        ),
        actionTextStyle: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 17,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.41,
          color: AdaptiveColors.primary,
        ),
        navTitleTextStyle: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.41,
          color: CupertinoColors.white,
        ),
        navLargeTitleTextStyle: TextStyle(
          fontFamily: '.SF Pro Display',
          fontSize: 34,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.37,
          color: CupertinoColors.white,
        ),
        tabLabelTextStyle: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
        ),
        navActionTextStyle: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 17,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.41,
          color: AdaptiveColors.primary,
        ),
        pickerTextStyle: TextStyle(
          fontFamily: '.SF Pro Display',
          fontSize: 21,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.41,
          color: CupertinoColors.white,
        ),
        dateTimePickerTextStyle: TextStyle(
          fontFamily: '.SF Pro Display',
          fontSize: 21,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.41,
          color: CupertinoColors.white,
        ),
      ),
    );
  }

  /// Light theme - Alternative theme
  static CupertinoThemeData light() {
    return const CupertinoThemeData(
      brightness: Brightness.light,
      primaryColor: AdaptiveColors.primary,
      primaryContrastingColor: CupertinoColors.white,
      scaffoldBackgroundColor: Color(0xFFF5F5F7),
      barBackgroundColor: Color(0xF0F2F2F7), // 94% opacity
      textTheme: CupertinoTextThemeData(
        primaryColor: AdaptiveColors.primary,
        textStyle: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 17,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.41,
          color: CupertinoColors.black,
        ),
        actionTextStyle: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 17,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.41,
          color: AdaptiveColors.primary,
        ),
        navTitleTextStyle: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.41,
          color: CupertinoColors.black,
        ),
        navLargeTitleTextStyle: TextStyle(
          fontFamily: '.SF Pro Display',
          fontSize: 34,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.37,
          color: CupertinoColors.black,
        ),
        tabLabelTextStyle: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
        ),
        navActionTextStyle: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 17,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.41,
          color: AdaptiveColors.primary,
        ),
        pickerTextStyle: TextStyle(
          fontFamily: '.SF Pro Display',
          fontSize: 21,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.41,
          color: CupertinoColors.black,
        ),
        dateTimePickerTextStyle: TextStyle(
          fontFamily: '.SF Pro Display',
          fontSize: 21,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.41,
          color: CupertinoColors.black,
        ),
      ),
    );
  }

  /// Get theme based on brightness
  static CupertinoThemeData fromBrightness(Brightness brightness) {
    return brightness == Brightness.dark ? dark() : light();
  }
}

/// iOS-native text styles following Human Interface Guidelines
class JarvisTextStyles {
  const JarvisTextStyles._();

  // Large Title - 34pt Bold
  static TextStyle largeTitle(BuildContext context) {
    final isDark = AdaptiveColors.isDark(context);
    return TextStyle(
      fontFamily: '.SF Pro Display',
      fontSize: 34,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.37,
      color: isDark ? CupertinoColors.white : CupertinoColors.black,
    );
  }

  // Title 1 - 28pt Bold
  static TextStyle title1(BuildContext context) {
    final isDark = AdaptiveColors.isDark(context);
    return TextStyle(
      fontFamily: '.SF Pro Display',
      fontSize: 28,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.36,
      color: isDark ? CupertinoColors.white : CupertinoColors.black,
    );
  }

  // Title 2 - 22pt Bold
  static TextStyle title2(BuildContext context) {
    final isDark = AdaptiveColors.isDark(context);
    return TextStyle(
      fontFamily: '.SF Pro Display',
      fontSize: 22,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.35,
      color: isDark ? CupertinoColors.white : CupertinoColors.black,
    );
  }

  // Title 3 - 20pt Semibold
  static TextStyle title3(BuildContext context) {
    final isDark = AdaptiveColors.isDark(context);
    return TextStyle(
      fontFamily: '.SF Pro Display',
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.38,
      color: isDark ? CupertinoColors.white : CupertinoColors.black,
    );
  }

  // Headline - 17pt Semibold
  static TextStyle headline(BuildContext context) {
    final isDark = AdaptiveColors.isDark(context);
    return TextStyle(
      fontFamily: '.SF Pro Text',
      fontSize: 17,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.41,
      color: isDark ? CupertinoColors.white : CupertinoColors.black,
    );
  }

  // Body - 17pt Regular
  static TextStyle body(BuildContext context) {
    final isDark = AdaptiveColors.isDark(context);
    return TextStyle(
      fontFamily: '.SF Pro Text',
      fontSize: 17,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.41,
      color: isDark ? CupertinoColors.white : CupertinoColors.black,
    );
  }

  // Callout - 16pt Regular
  static TextStyle callout(BuildContext context) {
    final isDark = AdaptiveColors.isDark(context);
    return TextStyle(
      fontFamily: '.SF Pro Text',
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.32,
      color: isDark ? CupertinoColors.white : CupertinoColors.black,
    );
  }

  // Subheadline - 15pt Regular
  static TextStyle subheadline(BuildContext context) {
    final isDark = AdaptiveColors.isDark(context);
    return TextStyle(
      fontFamily: '.SF Pro Text',
      fontSize: 15,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.24,
      color: isDark ? CupertinoColors.white : CupertinoColors.black,
    );
  }

  // Footnote - 13pt Regular
  static TextStyle footnote(BuildContext context) {
    final isDark = AdaptiveColors.isDark(context);
    return TextStyle(
      fontFamily: '.SF Pro Text',
      fontSize: 13,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.08,
      color: isDark ? CupertinoColors.white : CupertinoColors.black,
    );
  }

  // Caption 1 - 12pt Regular
  static TextStyle caption1(BuildContext context) {
    final isDark = AdaptiveColors.isDark(context);
    return TextStyle(
      fontFamily: '.SF Pro Text',
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      color: isDark ? CupertinoColors.white : CupertinoColors.black,
    );
  }

  // Caption 2 - 11pt Regular
  static TextStyle caption2(BuildContext context) {
    final isDark = AdaptiveColors.isDark(context);
    return TextStyle(
      fontFamily: '.SF Pro Text',
      fontSize: 11,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.07,
      color: isDark ? CupertinoColors.white : CupertinoColors.black,
    );
  }

  // Secondary text variants
  static TextStyle bodySecondary(BuildContext context) {
    return body(context).copyWith(
      color: AdaptiveColors.textSecondary(context),
    );
  }

  static TextStyle footnoteSecondary(BuildContext context) {
    return footnote(context).copyWith(
      color: AdaptiveColors.textSecondary(context),
    );
  }

  static TextStyle caption1Secondary(BuildContext context) {
    return caption1(context).copyWith(
      color: AdaptiveColors.textSecondary(context),
    );
  }
}
