import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTypography {
  const AppTypography._();

  static TextTheme get textTheme {
    final display = GoogleFonts.spaceGroteskTextTheme();
    return display.copyWith(
      displayLarge: GoogleFonts.spaceGrotesk(
        color: AppColors.textPrimary,
        fontSize: 34,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
        height: 1.12,
      ),
      displayMedium: GoogleFonts.spaceGrotesk(
        color: AppColors.textPrimary,
        fontSize: 30,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
        height: 1.16,
      ),
      headlineMedium: GoogleFonts.spaceGrotesk(
        color: AppColors.textPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
        height: 1.24,
      ),
      titleLarge: GoogleFonts.spaceGrotesk(
        color: AppColors.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        height: 1.3,
      ),
      titleMedium: GoogleFonts.spaceGrotesk(
        color: AppColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.35,
      ),
      bodyLarge: GoogleFonts.manrope(
        color: AppColors.textPrimary,
        fontSize: 16,
        height: 1.55,
        letterSpacing: 0.1,
      ),
      bodyMedium: GoogleFonts.manrope(
        color: AppColors.textSecondary,
        fontSize: 15,
        height: 1.55,
        letterSpacing: 0.1,
      ),
      labelLarge: GoogleFonts.manrope(
        color: AppColors.textPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      ),
      labelSmall: GoogleFonts.manrope(
        color: AppColors.textMuted,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      ),
    );
  }

  static TextStyle get mono {
    return GoogleFonts.jetBrainsMono(
      color: AppColors.textSecondary,
      fontSize: 12.5,
      height: 1.4,
    );
  }
}
