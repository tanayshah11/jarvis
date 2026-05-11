import 'package:flutter/material.dart';

/// Midnight Carbon & Amber Gradients
class AppGradients {
  const AppGradients._();

  // ============================================
  // BACKGROUNDS
  // ============================================
  static const LinearGradient background = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0B0F14), Color(0xFF111827)],
  );

  static const LinearGradient backgroundAnimated = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0B0F14), Color(0xFF0F172A)],
  );

  // ============================================
  // GLASS - Subtle white tint
  // ============================================
  static const LinearGradient glass = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x0AFFFFFF), Color(0x05FFFFFF)],
  );

  static const LinearGradient glassElevated = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x0FFFFFFF), Color(0x08FFFFFF)],
  );

  static const LinearGradient glassSubtle = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x08FFFFFF), Color(0x03FFFFFF)],
  );

  static const LinearGradient glassPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x16F2C14E), Color(0x08F2C14E)],
  );

  // ============================================
  // AMBER ACCENTS
  // ============================================
  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF2C14E), Color(0xFFC98C2D)],
  );

  static const LinearGradient primaryVertical = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF2D58A), Color(0xFFE7B95F)],
  );

  static const LinearGradient accent = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE7B95F), Color(0xFFC98C2D)],
  );

  // ============================================
  // SEMANTIC
  // ============================================
  static const LinearGradient success = LinearGradient(
    colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
  );

  static const LinearGradient warning = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
  );

  static const LinearGradient error = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
  );

  // ============================================
  // SPECIAL
  // ============================================
  static const LinearGradient shimmer = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0x00FFFFFF), Color(0x15FFFFFF), Color(0x00FFFFFF)],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient borderFocused = LinearGradient(
    colors: [Color(0xFFF2C14E), Color(0xFFF2D58A), Color(0xFFF2C14E)],
  );

  // Message styles - NO bubbles, just clean
  static const LinearGradient messageBubbleUser = LinearGradient(
    colors: [Color(0xFF1F2937), Color(0xFF111827)],
  );

  static const LinearGradient messageBubbleAI = LinearGradient(
    colors: [Color(0xFF111827), Color(0xFF0B0F14)],
  );

  static const LinearGradient personalityCard = LinearGradient(
    colors: [Color(0xFF111827), Color(0xFF0B0F14)],
  );

  static const LinearGradient hologram = LinearGradient(
    colors: [Color(0xFFF2C14E), Color(0xFFF2D58A)],
  );

  static const LinearGradient arcReactor = LinearGradient(
    colors: [Color(0xFFF2C14E), Color(0xFFC98C2D)],
  );
}
