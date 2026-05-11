import 'package:flutter/material.dart';

/// Midnight Carbon & Amber Color Palette
class AppColors {
  const AppColors._();

  // ============================================
  // CARBON - Background & Surfaces
  // ============================================
  static const Color background = Color(0xFF0B0F14);      // Midnight carbon
  static const Color surface = Color(0xFF111827);         // Deep slate
  static const Color surfaceLight = Color(0xFF1F2937);    // Slate 800

  // ============================================
  // AMBER - Accent
  // ============================================
  static const Color primary = Color(0xFFF2C14E);         // Warm amber
  static const Color primaryDark = Color(0xFFC98C2D);     // Burnt amber
  static const Color accent = Color(0xFFE7B95F);          // Soft amber
  static const Color accentLight = Color(0xFFF2D58A);     // Light amber

  // ============================================
  // SEMANTIC
  // ============================================
  static const Color success = Color(0xFF22C55E);         // Green
  static const Color warning = Color(0xFFF59E0B);         // Amber
  static const Color error = Color(0xFFEF4444);           // Red

  // ============================================
  // TEXT - High contrast
  // ============================================
  static const Color textPrimary = Color(0xFFF8FAFC);     // Slate 50
  static const Color textSecondary = Color(0xFFCBD5E1);   // Slate 300
  static const Color textMuted = Color(0xFF94A3B8);       // Slate 400

  // ============================================
  // GRADIENTS
  // ============================================
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFF2C14E), Color(0xFFC98C2D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFF2D58A), Color(0xFFE7B95F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [
      Color(0x0DFFFFFF),
      Color(0x05FFFFFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
