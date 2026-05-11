import 'package:flutter/cupertino.dart';

/// Adaptive color system that supports both light and dark modes
/// while maintaining the Carbon/Amber brand identity.
class AdaptiveColors {
  const AdaptiveColors._();

  // ============================================
  // AMBER - Primary brand color (consistent across modes)
  // ============================================
  static const Color primary = Color(0xFFF2C14E);
  static const Color primaryDark = Color(0xFFC98C2D);
  static const Color primaryLight = Color(0xFFF2D58A);

  // ============================================
  // BACKGROUNDS - Adapt to brightness
  // ============================================
  static Color background(BuildContext context) {
    final brightness = CupertinoTheme.of(context).brightness ?? Brightness.dark;
    return brightness == Brightness.dark
        ? const Color(0xFF0B0F14)  // Midnight carbon
        : const Color(0xFFF7F5F2); // Warm light
  }

  static Color backgroundElevated(BuildContext context) {
    final brightness = CupertinoTheme.of(context).brightness ?? Brightness.dark;
    return brightness == Brightness.dark
        ? const Color(0xFF111827)  // Deep slate
        : const Color(0xFFFFFFFF); // White
  }

  // ============================================
  // SURFACES - Card backgrounds, sheets, etc.
  // ============================================
  static Color surface(BuildContext context) {
    final brightness = CupertinoTheme.of(context).brightness ?? Brightness.dark;
    return brightness == Brightness.dark
        ? const Color(0xFF111827)  // Deep slate
        : const Color(0xFFFFFFFF); // White
  }

  static Color surfaceSecondary(BuildContext context) {
    final brightness = CupertinoTheme.of(context).brightness ?? Brightness.dark;
    return brightness == Brightness.dark
        ? const Color(0xFF1F2937)  // Slate 800
        : const Color(0xFFF3F4F6); // Light slate
  }

  static Color surfaceTertiary(BuildContext context) {
    final brightness = CupertinoTheme.of(context).brightness ?? Brightness.dark;
    return brightness == Brightness.dark
        ? const Color(0xFF374151)  // Slate 700
        : const Color(0xFFE5E7EB); // Slate 200
  }

  // ============================================
  // TEXT COLORS - Adapt to brightness
  // ============================================
  static Color textPrimary(BuildContext context) {
    final brightness = CupertinoTheme.of(context).brightness ?? Brightness.dark;
    return brightness == Brightness.dark
        ? const Color(0xFFF8FAFC)  // Slate 50
        : const Color(0xFF0F172A); // Slate 900
  }

  static Color textSecondary(BuildContext context) {
    final brightness = CupertinoTheme.of(context).brightness ?? Brightness.dark;
    return brightness == Brightness.dark
        ? const Color(0xFFCBD5E1)  // Slate 300
        : const Color(0xFF475569); // Slate 600
  }

  static Color textTertiary(BuildContext context) {
    final brightness = CupertinoTheme.of(context).brightness ?? Brightness.dark;
    return brightness == Brightness.dark
        ? const Color(0xFF94A3B8)  // Slate 400
        : const Color(0xFF64748B); // Slate 500
  }

  static Color textPlaceholder(BuildContext context) {
    final brightness = CupertinoTheme.of(context).brightness ?? Brightness.dark;
    return brightness == Brightness.dark
        ? const Color(0xFF64748B)  // Slate 500
        : const Color(0xFF94A3B8); // Slate 400
  }

  // ============================================
  // SEPARATORS & BORDERS
  // ============================================
  static Color separator(BuildContext context) {
    final brightness = CupertinoTheme.of(context).brightness ?? Brightness.dark;
    return brightness == Brightness.dark
        ? const Color(0xFF2B3340)  // Slate 800
        : const Color(0xFFD1D5DB); // Slate 300
  }

  static Color border(BuildContext context) {
    final brightness = CupertinoTheme.of(context).brightness ?? Brightness.dark;
    return brightness == Brightness.dark
        ? const Color(0xFF2B3340)
        : const Color(0xFFD1D5DB);
  }

  // ============================================
  // SEMANTIC COLORS
  // ============================================
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // ============================================
  // TAB BAR COLORS
  // ============================================
  static Color tabBarBackground(BuildContext context) {
    final brightness = CupertinoTheme.of(context).brightness ?? Brightness.dark;
    return brightness == Brightness.dark
        ? const Color(0xFF111827).withValues(alpha: 0.94)
        : const Color(0xFFF3F4F6).withValues(alpha: 0.94);
  }

  static Color tabBarInactive(BuildContext context) {
    final brightness = CupertinoTheme.of(context).brightness ?? Brightness.dark;
    return brightness == Brightness.dark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
  }

  // ============================================
  // NAVIGATION BAR
  // ============================================
  static Color navBarBackground(BuildContext context) {
    final brightness = CupertinoTheme.of(context).brightness ?? Brightness.dark;
    return brightness == Brightness.dark
        ? const Color(0xFF111827).withValues(alpha: 0.94)
        : const Color(0xFFF3F4F6).withValues(alpha: 0.94);
  }

  // ============================================
  // FILL COLORS (for buttons, etc.)
  // ============================================
  static Color fillPrimary(BuildContext context) {
    final brightness = CupertinoTheme.of(context).brightness ?? Brightness.dark;
    return brightness == Brightness.dark
        ? const Color(0xFF94A3B8).withValues(alpha: 0.30)
        : const Color(0xFF94A3B8).withValues(alpha: 0.20);
  }

  static Color fillSecondary(BuildContext context) {
    final brightness = CupertinoTheme.of(context).brightness ?? Brightness.dark;
    return brightness == Brightness.dark
        ? const Color(0xFF94A3B8).withValues(alpha: 0.24)
        : const Color(0xFF94A3B8).withValues(alpha: 0.16);
  }

  // ============================================
  // AMBER GLASS EFFECT (branded surfaces)
  // ============================================
  static Color goldGlass(BuildContext context) {
    final brightness = CupertinoTheme.of(context).brightness ?? Brightness.dark;
    return brightness == Brightness.dark
        ? primary.withValues(alpha: 0.08)
        : primary.withValues(alpha: 0.05);
  }

  static Color goldGlassBorder(BuildContext context) {
    final brightness = CupertinoTheme.of(context).brightness ?? Brightness.dark;
    return brightness == Brightness.dark
        ? primary.withValues(alpha: 0.20)
        : primary.withValues(alpha: 0.15);
  }

  // ============================================
  // HELPER - Get brightness from context
  // ============================================
  static Brightness brightness(BuildContext context) {
    return CupertinoTheme.of(context).brightness ?? Brightness.dark;
  }

  static bool isDark(BuildContext context) {
    return brightness(context) == Brightness.dark;
  }
}
