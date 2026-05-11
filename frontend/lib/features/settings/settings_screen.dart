import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/spacing.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/widgets/animated_content.dart';
import '../../core/widgets/animated_gradient.dart';
import '../auth/auth_controller.dart';
import 'providers/settings_provider.dart';
import 'widgets/settings_section.dart';
import 'widgets/settings_tile.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final settingsState = ref.watch(settingsProvider);
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Animated gradient background
          const Positioned.fill(
            child: AnimatedGradient(child: SizedBox.expand()),
          ),

          // Content
          CustomScrollView(
            slivers: [
              // Custom header
              SliverToBoxAdapter(
                child: _buildHeader(context, topPadding),
              ),

              // Settings sections with staggered animations
              SliverToBoxAdapter(
                child: StaggeredAnimatedContent(
                  itemDuration: const Duration(milliseconds: 400),
                  itemDelay: const Duration(milliseconds: 100),
                  curve: Curves.easeOutCubic,
                  children: [
                    // Appearance Section
                    SettingsSection(
                      title: 'APPEARANCE',
                      children: [
                        ScaleOnPress(
                          onPressed: () => _showThemePicker(context, ref, themeMode),
                          child: SettingsTile(
                            title: 'Theme',
                            subtitle: _getThemeModeLabel(themeMode),
                            icon: CupertinoIcons.moon_fill,
                            iconColor: AppColors.accentLight,
                            onTap: () => _showThemePicker(context, ref, themeMode),
                          ),
                        ),
                      ],
                    ),

                    // Account Section
                    SettingsSection(
                      title: 'ACCOUNT',
                      children: [
                        ScaleOnPress(
                          onPressed: () => context.push('/settings/profile'),
                          child: SettingsTile(
                            title: 'Profile',
                            subtitle: 'Edit your profile',
                            icon: CupertinoIcons.person_fill,
                            iconColor: AppColors.primary,
                            onTap: () => context.push('/settings/profile'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ScaleOnPress(
                          onPressed: () => _showNotificationsPicker(context, ref, settingsState.notificationMode),
                          child: SettingsTile(
                            title: 'Notifications',
                            subtitle: settingsState.notificationMode,
                            icon: CupertinoIcons.bell_fill,
                            iconColor: AppColors.accent,
                            onTap: () => _showNotificationsPicker(context, ref, settingsState.notificationMode),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ScaleOnPress(
                          onPressed: () => context.push('/settings/help'),
                          child: SettingsTile(
                            title: 'Help & Support',
                            subtitle: 'Get assistance',
                            icon: CupertinoIcons.question_circle_fill,
                            iconColor: AppColors.accentLight,
                            onTap: () => context.push('/settings/help'),
                          ),
                        ),
                      ],
                    ),

                    // Memory Section
                    SettingsSection(
                      title: 'MEMORY',
                      children: [
                        ScaleOnPress(
                          onPressed: () => context.go('/memory'),
                          child: SettingsTile(
                            title: 'Memory Hub',
                            subtitle: 'Manage your knowledge graph',
                            icon: CupertinoIcons.lightbulb_fill,
                            iconColor: AppColors.warning,
                            onTap: () => context.go('/memory'),
                          ),
                        ),
                      ],
                    ),

                    // Privacy Section
                    SettingsSection(
                      title: 'PRIVACY',
                      children: [
                        SettingsTile(
                          title: 'Memory Extraction',
                          subtitle: 'Learn from your conversations',
                          icon: CupertinoIcons.sparkles,
                          iconColor: AppColors.primary,
                          showChevron: false,
                          trailing: CupertinoSwitch(
                            value: settingsState.privacy.enableMemoryExtraction,
                            activeTrackColor: AppColors.primary,
                            onChanged: (value) {
                              HapticFeedback.selectionClick();
                              ref.read(settingsProvider.notifier).setMemoryExtractionEnabled(value);
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        SettingsTile(
                          title: 'Anonymize Data',
                          subtitle: 'Mask names before AI processing',
                          icon: CupertinoIcons.eye_slash_fill,
                          iconColor: AppColors.accent,
                          showChevron: false,
                          trailing: CupertinoSwitch(
                            value: settingsState.privacy.enableAnonymization,
                            activeTrackColor: AppColors.primary,
                            onChanged: (value) {
                              HapticFeedback.selectionClick();
                              ref.read(settingsProvider.notifier).setAnonymizationEnabled(value);
                            },
                          ),
                        ),
                      ],
                    ),

                    // About Section
                    SettingsSection(
                      title: 'ABOUT',
                      children: [
                        SettingsTile(
                          title: 'Version',
                          subtitle: '2.5.1',
                          icon: CupertinoIcons.info_circle_fill,
                          iconColor: AppColors.textSecondary,
                          showChevron: false,
                        ),
                        const SizedBox(height: 8),
                        ScaleOnPress(
                          onPressed: () => _showComingSoon(context, 'Privacy Policy'),
                          child: SettingsTile(
                            title: 'Privacy Policy',
                            subtitle: 'View our privacy policy',
                            icon: CupertinoIcons.lock_shield_fill,
                            iconColor: AppColors.primary,
                            trailing: const Icon(
                              CupertinoIcons.arrow_up_right_square,
                              color: AppColors.textMuted,
                              size: 16,
                            ),
                            onTap: () => _showComingSoon(context, 'Privacy Policy'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ScaleOnPress(
                          onPressed: () => _showComingSoon(context, 'Terms of Service'),
                          child: SettingsTile(
                            title: 'Terms of Service',
                            subtitle: 'View terms and conditions',
                            icon: CupertinoIcons.doc_text_fill,
                            iconColor: AppColors.accentLight,
                            trailing: const Icon(
                              CupertinoIcons.arrow_up_right_square,
                              color: AppColors.textMuted,
                              size: 16,
                            ),
                            onTap: () => _showComingSoon(context, 'Terms of Service'),
                          ),
                        ),
                      ],
                    ),

                    // Sign Out Button
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.xl,
                      ),
                      child: ScaleOnPress(
                        onPressed: () => _handleLogout(context, ref),
                        child: _SignOutButton(
                          onTap: () => _handleLogout(context, ref),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom padding for tab bar
              SliverToBoxAdapter(
                child: SizedBox(height: 100 + bottomPadding),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double topPadding) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.only(
            top: topPadding + AppSpacing.md,
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: AppColors.background.withValues(alpha: 0.8),
            border: Border(
              bottom: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.2),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              // Back button
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.go('/chat');
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    CupertinoIcons.chevron_left,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
              ),
              // Title centered
              Expanded(
                child: Text(
                  'Settings',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // Spacer for symmetry
              const SizedBox(width: 36),
            ],
          ),
        ),
      ),
    );
  }


  String _getThemeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  void _showThemePicker(
      BuildContext context, WidgetRef ref, ThemeMode currentMode) {
    HapticFeedback.mediumImpact();
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Choose Theme'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              ref
                  .read(themeModeProvider.notifier)
                  .setThemeMode(ThemeMode.system);
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (currentMode == ThemeMode.system)
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(
                      CupertinoIcons.checkmark_circle_fill,
                      color: CupertinoColors.activeBlue,
                      size: 20,
                    ),
                  ),
                const Text('System'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              ref
                  .read(themeModeProvider.notifier)
                  .setThemeMode(ThemeMode.light);
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (currentMode == ThemeMode.light)
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(
                      CupertinoIcons.checkmark_circle_fill,
                      color: CupertinoColors.activeBlue,
                      size: 20,
                    ),
                  ),
                const Text('Light'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (currentMode == ThemeMode.dark)
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(
                      CupertinoIcons.checkmark_circle_fill,
                      color: CupertinoColors.activeBlue,
                      size: 20,
                    ),
                  ),
                const Text('Dark'),
              ],
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _showNotificationsPicker(
      BuildContext context, WidgetRef ref, String currentMode) {
    HapticFeedback.mediumImpact();
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Notification Mode'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              ref
                  .read(settingsProvider.notifier)
                  .setNotificationMode('All');
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (currentMode == 'All')
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(
                      CupertinoIcons.checkmark_circle_fill,
                      color: CupertinoColors.activeBlue,
                      size: 20,
                    ),
                  ),
                const Text('All'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              ref
                  .read(settingsProvider.notifier)
                  .setNotificationMode('Priority Only');
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (currentMode == 'Priority Only')
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(
                      CupertinoIcons.checkmark_circle_fill,
                      color: CupertinoColors.activeBlue,
                      size: 20,
                    ),
                  ),
                const Text('Priority Only'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              ref
                  .read(settingsProvider.notifier)
                  .setNotificationMode('Off');
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (currentMode == 'Off')
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(
                      CupertinoIcons.checkmark_circle_fill,
                      color: CupertinoColors.activeBlue,
                      size: 20,
                    ),
                  ),
                const Text('Off'),
              ],
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    showCupertinoDialog<void>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Coming Soon'),
        content: Text('$feature will be available in a future update.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    HapticFeedback.mediumImpact();
    final confirm = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(authControllerProvider.notifier).logout();
      if (context.mounted) {
        context.go('/login');
      }
    }
  }
}

class _SignOutButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SignOutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.error.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
            child: Center(
              child: Text(
                'Sign Out',
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
