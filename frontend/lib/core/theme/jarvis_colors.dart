import 'package:flutter/material.dart';

/// Jarvis Design System Color Palette
///
/// Based on Stitch UI design specifications with dark theme
/// and gold accent colors.
class JarvisColors {
  JarvisColors._();

  // Background Colors
  /// Pure black background - #000000
  static const Color background = Color(0xFF000000);

  /// Dark gray for cards and elevated surfaces - #1C1C1E
  static const Color cardBackground = Color(0xFF1C1C1E);

  /// Darker gray for inputs and secondary surfaces - #2C2C2E
  static const Color inputBackground = Color(0xFF2C2C2E);

  /// White background for specific use cases (e.g., sign up screen)
  static const Color whiteBackground = Color(0xFFFFFFFF);

  // Primary Colors (Gold/Yellow)
  /// Primary gold accent - #D4AF37
  static const Color primaryGold = Color(0xFFD4AF37);

  /// Darker gold for hover/pressed states - #B8962E
  static const Color secondaryGold = Color(0xFFB8962E);

  /// Gold with glow effect (lighter) - #E8C547
  static const Color goldGlow = Color(0xFFE8C547);

  /// Warning yellow - #FFD60A
  static const Color warning = Color(0xFFFFD60A);

  // Text Colors
  /// Primary text - #FFFFFF
  static const Color textPrimary = Color(0xFFFFFFFF);

  /// Secondary text - #8E8E93
  static const Color textSecondary = Color(0xFF8E8E93);

  /// Tertiary text (even more muted) - #636366
  static const Color textTertiary = Color(0xFF636366);

  /// Text on gold background - #000000
  static const Color textOnGold = Color(0xFF000000);

  // Semantic Colors
  /// Success green - #34C759
  static const Color success = Color(0xFF34C759);

  /// Error/Destructive red - #FF453A
  static const Color error = Color(0xFFFF453A);

  /// Info blue - #0A84FF
  static const Color info = Color(0xFF0A84FF);

  // Border Colors
  /// Subtle border for cards - #2C2C2E
  static const Color border = Color(0xFF2C2C2E);

  /// Gold border for emphasis - #D4AF37
  static const Color borderGold = Color(0xFFD4AF37);

  /// Focus border (brighter gold) - #E8C547
  static const Color borderFocus = Color(0xFFE8C547);

  // Overlay Colors
  /// Black overlay with 50% opacity
  static const Color overlay = Color(0x80000000);

  /// Gold overlay with 10% opacity for glow effects
  static const Color goldOverlay10 = Color(0x1AD4AF37);

  /// Gold overlay with 20% opacity
  static const Color goldOverlay20 = Color(0x33D4AF37);

  /// Gold overlay with 30% opacity
  static const Color goldOverlay30 = Color(0x4DD4AF37);

  // Gradient Colors
  /// Gold gradient start
  static const Color gradientGoldStart = Color(0xFFE8C547);

  /// Gold gradient end
  static const Color gradientGoldEnd = Color(0xFFB8962E);

  // Gradients
  /// Primary gold gradient (top to bottom)
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [gradientGoldStart, gradientGoldEnd],
  );

  /// Radial gold glow gradient for orb effect
  static const RadialGradient goldGlowGradient = RadialGradient(
    colors: [
      goldGlow,
      primaryGold,
      secondaryGold,
    ],
    stops: [0.0, 0.6, 1.0],
  );

  /// Dark card gradient (subtle)
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1C1C1E),
      Color(0xFF2C2C2E),
    ],
  );
}
