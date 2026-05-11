import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'jarvis_colors.dart';
import 'jarvis_typography.dart';
import 'jarvis_decorations.dart';

/// Jarvis Design System Theme Configuration
///
/// Provides the complete ThemeData configuration for the Jarvis app,
/// including color scheme, typography, and component themes.
class JarvisTheme {
  JarvisTheme._();

  /// The main dark theme for Jarvis
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        brightness: Brightness.dark,
        primary: JarvisColors.primaryGold,
        onPrimary: JarvisColors.textOnGold,
        primaryContainer: JarvisColors.secondaryGold,
        onPrimaryContainer: JarvisColors.textOnGold,
        secondary: JarvisColors.secondaryGold,
        onSecondary: JarvisColors.textOnGold,
        tertiary: JarvisColors.goldGlow,
        onTertiary: JarvisColors.textOnGold,
        error: JarvisColors.error,
        onError: JarvisColors.textPrimary,
        surface: JarvisColors.cardBackground,
        onSurface: JarvisColors.textPrimary,
        surfaceContainerHighest: JarvisColors.inputBackground,
        onSurfaceVariant: JarvisColors.textSecondary,
        outline: JarvisColors.border,
        outlineVariant: JarvisColors.borderGold,
        shadow: JarvisColors.overlay,
        scrim: JarvisColors.overlay,
        inverseSurface: JarvisColors.whiteBackground,
        onInverseSurface: JarvisColors.background,
        inversePrimary: JarvisColors.secondaryGold,
      ),

      // Scaffold Background
      scaffoldBackgroundColor: JarvisColors.background,
      canvasColor: JarvisColors.background,
      cardColor: JarvisColors.cardBackground,
      dividerColor: JarvisColors.border,

      // Typography
      textTheme: const TextTheme(
        displayLarge: JarvisTypography.displayLarge,
        displayMedium: JarvisTypography.displayMedium,
        displaySmall: JarvisTypography.displaySmall,
        headlineLarge: JarvisTypography.headlineLarge,
        headlineMedium: JarvisTypography.headlineMedium,
        headlineSmall: JarvisTypography.headlineSmall,
        titleLarge: JarvisTypography.titleLarge,
        titleMedium: JarvisTypography.titleMedium,
        titleSmall: JarvisTypography.titleSmall,
        bodyLarge: JarvisTypography.bodyLarge,
        bodyMedium: JarvisTypography.bodyMedium,
        bodySmall: JarvisTypography.bodySmall,
        labelLarge: JarvisTypography.labelLarge,
        labelMedium: JarvisTypography.labelMedium,
        labelSmall: JarvisTypography.labelSmall,
      ),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: JarvisColors.primaryGold, size: 24),
        actionsIconTheme: IconThemeData(
          color: JarvisColors.primaryGold,
          size: 24,
        ),
        titleTextStyle: JarvisTypography.titleLarge,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
          statusBarColor: Colors.transparent,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: JarvisColors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: JarvisDecorations.radiusLarge,
          side: const BorderSide(color: JarvisColors.border, width: 1),
        ),
        margin: const EdgeInsets.all(0),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: JarvisColors.primaryGold,
          foregroundColor: JarvisColors.textOnGold,
          disabledBackgroundColor: JarvisColors.secondaryGold.withValues(
            alpha: 0.5,
          ),
          disabledForegroundColor: JarvisColors.textOnGold.withValues(
            alpha: 0.5,
          ),
          elevation: 0,
          shadowColor: JarvisColors.goldOverlay30,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size(88, 48),
          shape: RoundedRectangleBorder(
            borderRadius: JarvisDecorations.radiusLarge,
          ),
          textStyle: JarvisTypography.buttonMedium,
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: JarvisColors.primaryGold,
          backgroundColor: JarvisColors.cardBackground,
          disabledForegroundColor: JarvisColors.textSecondary,
          side: const BorderSide(color: JarvisColors.borderGold, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size(88, 48),
          shape: RoundedRectangleBorder(
            borderRadius: JarvisDecorations.radiusLarge,
          ),
          textStyle: JarvisTypography.buttonMedium.copyWith(
            color: JarvisColors.primaryGold,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: JarvisColors.primaryGold,
          disabledForegroundColor: JarvisColors.textSecondary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          minimumSize: const Size(64, 40),
          shape: RoundedRectangleBorder(
            borderRadius: JarvisDecorations.radiusLarge,
          ),
          textStyle: JarvisTypography.buttonMedium.copyWith(
            color: JarvisColors.primaryGold,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: JarvisColors.inputBackground,
        hintStyle: const TextStyle(color: JarvisColors.textSecondary),
        labelStyle: const TextStyle(color: JarvisColors.textSecondary),
        errorStyle: const TextStyle(color: JarvisColors.error),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: JarvisDecorations.radiusLarge,
          borderSide: const BorderSide(color: JarvisColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: JarvisDecorations.radiusLarge,
          borderSide: const BorderSide(color: JarvisColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: JarvisDecorations.radiusLarge,
          borderSide: const BorderSide(
            color: JarvisColors.borderFocus,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: JarvisDecorations.radiusLarge,
          borderSide: const BorderSide(color: JarvisColors.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: JarvisDecorations.radiusLarge,
          borderSide: const BorderSide(color: JarvisColors.error, width: 2),
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(color: JarvisColors.textPrimary, size: 24),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: JarvisColors.border,
        thickness: 1,
        space: 1,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: JarvisColors.cardBackground,
        deleteIconColor: JarvisColors.textSecondary,
        disabledColor: JarvisColors.cardBackground.withValues(alpha: 0.5),
        selectedColor: JarvisColors.primaryGold,
        secondarySelectedColor: JarvisColors.secondaryGold,
        shadowColor: Colors.transparent,
        elevation: 0,
        pressElevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: JarvisTypography.labelMedium,
        secondaryLabelStyle: JarvisTypography.labelMedium.copyWith(
          color: JarvisColors.textOnGold,
        ),
        brightness: Brightness.dark,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(100)),
          side: const BorderSide(color: JarvisColors.border, width: 1),
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: JarvisColors.cardBackground,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: JarvisDecorations.radiusXLarge,
          side: const BorderSide(color: JarvisColors.border, width: 1),
        ),
        titleTextStyle: JarvisTypography.titleLarge,
        contentTextStyle: JarvisTypography.bodyMedium,
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: JarvisColors.cardBackground,
        modalBackgroundColor: JarvisColors.cardBackground,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          side: BorderSide(color: JarvisColors.border, width: 1),
        ),
      ),

      // Snack Bar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: JarvisColors.cardBackground,
        contentTextStyle: JarvisTypography.bodyMedium,
        actionTextColor: JarvisColors.primaryGold,
        behavior: SnackBarBehavior.floating,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: JarvisDecorations.radiusLarge,
          side: const BorderSide(color: JarvisColors.border, width: 1),
        ),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: JarvisColors.primaryGold,
        linearTrackColor: JarvisColors.border,
        circularTrackColor: JarvisColors.border,
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return JarvisColors.textOnGold;
          }
          return JarvisColors.textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return JarvisColors.primaryGold;
          }
          return JarvisColors.border;
        }),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return JarvisColors.primaryGold;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(JarvisColors.textOnGold),
        side: const BorderSide(color: JarvisColors.border, width: 2),
      ),

      // Radio Theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return JarvisColors.primaryGold;
          }
          return JarvisColors.border;
        }),
      ),

      // Slider Theme
      sliderTheme: const SliderThemeData(
        activeTrackColor: JarvisColors.primaryGold,
        inactiveTrackColor: JarvisColors.border,
        thumbColor: JarvisColors.primaryGold,
        overlayColor: JarvisColors.goldOverlay20,
        valueIndicatorColor: JarvisColors.primaryGold,
        valueIndicatorTextStyle: TextStyle(color: JarvisColors.textOnGold),
      ),

      // Navigation Bar Theme
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: JarvisColors.cardBackground,
        indicatorColor: JarvisColors.primaryGold,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: JarvisColors.textOnGold,
              size: 24,
            );
          }
          return const IconThemeData(
            color: JarvisColors.textSecondary,
            size: 24,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return JarvisTypography.labelSmall.copyWith(
              color: JarvisColors.primaryGold,
            );
          }
          return JarvisTypography.labelSmall.copyWith(
            color: JarvisColors.textSecondary,
          );
        }),
        height: 80,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: JarvisColors.cardBackground,
        selectedItemColor: JarvisColors.primaryGold,
        unselectedItemColor: JarvisColors.textSecondary,
        selectedLabelStyle: JarvisTypography.labelSmall,
        unselectedLabelStyle: JarvisTypography.labelSmall,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Tab Bar Theme
      tabBarTheme: const TabBarThemeData(
        labelColor: JarvisColors.primaryGold,
        unselectedLabelColor: JarvisColors.textSecondary,
        indicatorColor: JarvisColors.primaryGold,
        labelStyle: JarvisTypography.labelLarge,
        unselectedLabelStyle: JarvisTypography.labelLarge,
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: JarvisColors.primaryGold,
        foregroundColor: JarvisColors.textOnGold,
        elevation: 4,
        focusElevation: 6,
        hoverElevation: 6,
        highlightElevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: JarvisDecorations.radiusLarge,
        ),
      ),

      // List Tile Theme
      listTileTheme: const ListTileThemeData(
        tileColor: Colors.transparent,
        selectedTileColor: JarvisColors.goldOverlay10,
        iconColor: JarvisColors.textPrimary,
        textColor: JarvisColors.textPrimary,
        selectedColor: JarvisColors.primaryGold,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Tooltip Theme
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: JarvisColors.cardBackground,
          borderRadius: JarvisDecorations.radiusMedium,
          border: Border.all(color: JarvisColors.border, width: 1),
        ),
        textStyle: JarvisTypography.bodySmall,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  /// System UI overlay style for status bar and navigation bar
  static const SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
    statusBarBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.light,
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: JarvisColors.background,
    systemNavigationBarIconBrightness: Brightness.light,
    systemNavigationBarDividerColor: Colors.transparent,
  );

  /// Apply the system UI overlay style
  static void setSystemUIOverlayStyle() {
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}
