import 'package:flutter/material.dart';
import 'jarvis_colors.dart';

/// Jarvis Design System Decorations
///
/// Pre-configured BoxDecorations for consistent styling across
/// cards, inputs, buttons, and other UI elements.
class JarvisDecorations {
  JarvisDecorations._();

  // Border Radius Constants
  static const BorderRadius radiusSmall = BorderRadius.all(Radius.circular(8));
  static const BorderRadius radiusMedium = BorderRadius.all(
    Radius.circular(12),
  );
  static const BorderRadius radiusLarge = BorderRadius.all(Radius.circular(16));
  static const BorderRadius radiusXLarge = BorderRadius.all(
    Radius.circular(24),
  );

  // Card Decorations

  /// Standard dark card decoration with rounded corners
  static BoxDecoration card({Color? color, BorderRadius? borderRadius}) {
    return BoxDecoration(
      color: color ?? JarvisColors.cardBackground,
      borderRadius: borderRadius ?? radiusLarge,
      border: Border.all(color: JarvisColors.border, width: 1),
    );
  }

  /// Card with gold accent border
  static BoxDecoration cardGold({Color? color, BorderRadius? borderRadius}) {
    return BoxDecoration(
      color: color ?? JarvisColors.cardBackground,
      borderRadius: borderRadius ?? radiusLarge,
      border: Border.all(color: JarvisColors.borderGold, width: 1),
    );
  }

  /// Card with subtle gradient background
  static BoxDecoration cardGradient({BorderRadius? borderRadius}) {
    return BoxDecoration(
      gradient: JarvisColors.cardGradient,
      borderRadius: borderRadius ?? radiusLarge,
      border: Border.all(color: JarvisColors.border, width: 1),
    );
  }

  /// Elevated card with shadow
  static BoxDecoration cardElevated({
    Color? color,
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      color: color ?? JarvisColors.cardBackground,
      borderRadius: borderRadius ?? radiusLarge,
      border: Border.all(color: JarvisColors.border, width: 1),
      boxShadow: [
        BoxShadow(
          color: JarvisColors.goldOverlay10,
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // Input Field Decorations

  /// Standard dark input decoration
  static BoxDecoration input({
    Color? color,
    BorderRadius? borderRadius,
    bool focused = false,
  }) {
    return BoxDecoration(
      color: color ?? JarvisColors.inputBackground,
      borderRadius: borderRadius ?? radiusLarge,
      border: Border.all(
        color: focused ? JarvisColors.borderFocus : JarvisColors.border,
        width: focused ? 2 : 1,
      ),
    );
  }

  /// White input decoration (for sign up screen)
  static BoxDecoration inputWhite({
    BorderRadius? borderRadius,
    bool focused = false,
  }) {
    return BoxDecoration(
      color: JarvisColors.whiteBackground,
      borderRadius: borderRadius ?? radiusLarge,
      border: Border.all(
        color: focused ? JarvisColors.borderFocus : JarvisColors.border,
        width: focused ? 2 : 1,
      ),
    );
  }

  /// Input with error state
  static BoxDecoration inputError({Color? color, BorderRadius? borderRadius}) {
    return BoxDecoration(
      color: color ?? JarvisColors.inputBackground,
      borderRadius: borderRadius ?? radiusLarge,
      border: Border.all(color: JarvisColors.error, width: 2),
    );
  }

  // Button Decorations

  /// Primary gold button decoration
  static BoxDecoration buttonPrimary({
    BorderRadius? borderRadius,
    bool disabled = false,
  }) {
    return BoxDecoration(
      color: disabled
          ? JarvisColors.secondaryGold.withValues(alpha: 0.5)
          : JarvisColors.primaryGold,
      borderRadius: borderRadius ?? radiusLarge,
      boxShadow: disabled
          ? null
          : [
              BoxShadow(
                color: JarvisColors.goldOverlay30,
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
    );
  }

  /// Primary gold button with gradient
  static BoxDecoration buttonPrimaryGradient({
    BorderRadius? borderRadius,
    bool disabled = false,
  }) {
    return BoxDecoration(
      gradient: disabled ? null : JarvisColors.goldGradient,
      color: disabled
          ? JarvisColors.secondaryGold.withValues(alpha: 0.5)
          : null,
      borderRadius: borderRadius ?? radiusLarge,
      boxShadow: disabled
          ? null
          : [
              BoxShadow(
                color: JarvisColors.goldOverlay30,
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
    );
  }

  /// Secondary button decoration (dark with gold border)
  static BoxDecoration buttonSecondary({
    BorderRadius? borderRadius,
    bool disabled = false,
  }) {
    return BoxDecoration(
      color: JarvisColors.cardBackground,
      borderRadius: borderRadius ?? radiusLarge,
      border: Border.all(
        color: disabled ? JarvisColors.textSecondary : JarvisColors.borderGold,
        width: 2,
      ),
    );
  }

  /// Tertiary button decoration (transparent)
  static BoxDecoration buttonTertiary({BorderRadius? borderRadius}) {
    return BoxDecoration(
      color: Colors.transparent,
      borderRadius: borderRadius ?? radiusLarge,
    );
  }

  /// Destructive button decoration (red)
  static BoxDecoration buttonDestructive({
    BorderRadius? borderRadius,
    bool disabled = false,
  }) {
    return BoxDecoration(
      color: disabled
          ? JarvisColors.error.withValues(alpha: 0.5)
          : JarvisColors.error,
      borderRadius: borderRadius ?? radiusLarge,
    );
  }

  // Special Effect Decorations

  /// Gold orb decoration with glow effect
  static BoxDecoration goldOrb({required double size, bool glowing = true}) {
    return BoxDecoration(
      shape: BoxShape.circle,
      gradient: JarvisColors.goldGlowGradient,
      boxShadow: glowing
          ? [
              BoxShadow(
                color: JarvisColors.primaryGold.withValues(alpha: 0.6),
                blurRadius: size * 0.3,
                spreadRadius: size * 0.1,
              ),
              BoxShadow(
                color: JarvisColors.goldGlow.withValues(alpha: 0.3),
                blurRadius: size * 0.5,
                spreadRadius: size * 0.15,
              ),
            ]
          : null,
    );
  }

  /// Glass morphism effect decoration
  static BoxDecoration glassMorphism({
    BorderRadius? borderRadius,
    double opacity = 0.1,
  }) {
    return BoxDecoration(
      color: JarvisColors.whiteBackground.withValues(alpha: opacity),
      borderRadius: borderRadius ?? radiusLarge,
      border: Border.all(
        color: JarvisColors.whiteBackground.withValues(alpha: 0.2),
        width: 1,
      ),
    );
  }

  // Divider Decorations

  /// Horizontal divider
  static BoxDecoration divider({double height = 1, Color? color}) {
    return BoxDecoration(color: color ?? JarvisColors.border);
  }

  /// Gold divider
  static BoxDecoration dividerGold({double height = 1}) {
    return BoxDecoration(color: JarvisColors.primaryGold);
  }

  // Badge/Chip Decorations

  /// Badge decoration (small rounded chip)
  static BoxDecoration badge({Color? color, Color? borderColor}) {
    return BoxDecoration(
      color: color ?? JarvisColors.cardBackground,
      borderRadius: const BorderRadius.all(Radius.circular(100)),
      border: borderColor != null
          ? Border.all(color: borderColor, width: 1)
          : null,
    );
  }

  /// Gold badge decoration
  static BoxDecoration badgeGold() {
    return BoxDecoration(
      color: JarvisColors.primaryGold,
      borderRadius: const BorderRadius.all(Radius.circular(100)),
    );
  }

  /// Success badge decoration
  static BoxDecoration badgeSuccess() {
    return BoxDecoration(
      color: JarvisColors.success,
      borderRadius: const BorderRadius.all(Radius.circular(100)),
    );
  }

  /// Error badge decoration
  static BoxDecoration badgeError() {
    return BoxDecoration(
      color: JarvisColors.error,
      borderRadius: const BorderRadius.all(Radius.circular(100)),
    );
  }

  // Input Decorations for TextField

  /// Standard input decoration for TextField widget
  static InputDecoration textFieldDecoration({
    String? hintText,
    String? labelText,
    String? errorText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool filled = true,
    Color? fillColor,
  }) {
    return InputDecoration(
      hintText: hintText,
      labelText: labelText,
      errorText: errorText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: filled,
      fillColor: fillColor ?? JarvisColors.inputBackground,
      border: OutlineInputBorder(
        borderRadius: radiusLarge,
        borderSide: const BorderSide(color: JarvisColors.border, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: radiusLarge,
        borderSide: const BorderSide(color: JarvisColors.border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: radiusLarge,
        borderSide: const BorderSide(color: JarvisColors.borderFocus, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: radiusLarge,
        borderSide: const BorderSide(color: JarvisColors.error, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: radiusLarge,
        borderSide: const BorderSide(color: JarvisColors.error, width: 2),
      ),
      hintStyle: const TextStyle(color: JarvisColors.textSecondary),
      labelStyle: const TextStyle(color: JarvisColors.textSecondary),
      errorStyle: const TextStyle(color: JarvisColors.error),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
