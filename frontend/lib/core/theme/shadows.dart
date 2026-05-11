import 'package:flutter/material.dart';

/// Shadow System - Amber glows
class AppShadows {
  const AppShadows._();

  // Standard shadows - very subtle
  static const List<BoxShadow> subtle = [];

  static const List<BoxShadow> medium = [];

  static const List<BoxShadow> elevated = [
    BoxShadow(
      color: Color(0x20000000),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> floating = [
    BoxShadow(
      color: Color(0x30000000),
      blurRadius: 30,
      offset: Offset(0, 12),
    ),
  ];

  // Gold glow
  static const List<BoxShadow> primaryGlow = [
    BoxShadow(
      color: Color(0x40F2C14E),
      blurRadius: 20,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> primaryGlowIntense = [
    BoxShadow(
      color: Color(0x60F2C14E),
      blurRadius: 30,
      offset: Offset(0, 6),
    ),
  ];

  static const List<BoxShadow> accentGlow = [
    BoxShadow(
      color: Color(0x40E7B95F),
      blurRadius: 20,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> arcReactorGlow = [
    BoxShadow(
      color: Color(0x50F2C14E),
      blurRadius: 40,
    ),
  ];

  static const List<BoxShadow> successGlow = [
    BoxShadow(
      color: Color(0x4022C55E),
      blurRadius: 20,
    ),
  ];

  static const List<BoxShadow> errorGlow = [
    BoxShadow(
      color: Color(0x40EF4444),
      blurRadius: 20,
    ),
  ];

  static const List<BoxShadow> warningGlow = [
    BoxShadow(
      color: Color(0x40F59E0B),
      blurRadius: 20,
    ),
  ];

  static const List<BoxShadow> innerSubtle = [];

  static const List<BoxShadow> innerCyanGlow = [];
}
