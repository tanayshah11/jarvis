import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/spacing.dart';
import '../../core/theme/typography.dart';
import '../../core/widgets/animated_content.dart';
import '../../core/widgets/animated_gradient.dart';
import '../../core/widgets/jarvis_avatar.dart';
import '../../core/widgets/particle_field.dart';
import '../../core/widgets/gold_slider.dart';
import '../../core/widgets/state_widgets.dart';
import '../../core/storage/secure_storage.dart';
import '../../data/data_service.dart';
import '../auth/auth_controller.dart';
import '../profile/profile_model.dart';
import '../settings/providers/settings_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  ProfileModel? _profile;
  bool _isLoading = true;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final secureStorage = ref.read(secureStorageProvider);
      final dataService = ref.read(dataServiceProvider);
      final authState = ref.read(authControllerProvider);

      _userEmail = authState.email;

      final userId = await secureStorage.getUserId();
      if (userId == null) {
        setState(() => _isLoading = false);
        return;
      }

      final profile = await dataService.database.getProfileByUserId(userId);
      if (profile != null) {
        Map<String, dynamic>? prefsJson;
        if (profile.preferences != null) {
          prefsJson = jsonDecode(profile.preferences!) as Map<String, dynamic>;
        }

        setState(() {
          _profile = ProfileModel(
            id: profile.id,
            userId: profile.userId,
            city: prefsJson?['city'] as String?,
            budgetLevel: prefsJson?['budget_level'] as String?,
            vibes: (prefsJson?['vibes'] as List<dynamic>?)?.cast<String>() ?? [],
            preferredAiProvider: AiProvider.fromString(profile.preferredAiProvider),
          );
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const Positioned.fill(
            child: AnimatedGradient(child: SizedBox.expand()),
          ),
          _isLoading
              ? const LoadingStateWidget(message: 'Loading profile...')
              : CustomScrollView(
                  slivers: [
                    // Premium Header
                    SliverToBoxAdapter(
                      child: _ProfileHeader(
                        email: _userEmail,
                        profile: _profile,
                      ),
                    ),

                    // Main content sections with staggered animations
                    SliverToBoxAdapter(
                      child: StaggeredAnimatedContent(
                        itemDuration: const Duration(milliseconds: 400),
                        itemDelay: const Duration(milliseconds: 100),
                        curve: Curves.easeOutCubic,
                        children: [
                          // Preferences Section
                          _PreferencesSection(profile: _profile),

                          // AI Settings Section
                          const _AiSettingsSection(),

                          // Account Section
                          _AccountSection(
                            onLogout: () async {
                              final router = GoRouter.of(context);
                              await ref.read(authControllerProvider.notifier).logout();
                              router.go('/login');
                            },
                          ),
                        ],
                      ),
                    ),

                    // Bottom padding
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 100),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}

/// Premium profile header with avatar and particles
class _ProfileHeader extends StatelessWidget {
  final String? email;
  final ProfileModel? profile;

  const _ProfileHeader({
    this.email,
    this.profile,
  });

  String get _displayName {
    if (email != null) {
      final name = email!.split('@').first;
      return name.substring(0, 1).toUpperCase() + name.substring(1);
    }
    return 'User';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          // Back button and title row
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.pop();
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Profile',
                  style: AppTypography.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                const SizedBox(width: 36), // Balance
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Avatar with particles
          SizedBox(
            width: 160,
            height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const ParticleField(size: 80, particleCount: 10),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const JarvisAvatar(size: 80),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 600.ms).scale(
                begin: const Offset(0.8, 0.8),
                curve: Curves.easeOutBack,
              ),

          const SizedBox(height: AppSpacing.lg),

          // Name with verification
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _displayName,
                style: AppTypography.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.black,
                  size: 12,
                ),
              ),
            ],
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 4),

          // Email
          Text(
            email ?? 'No email',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ).animate().fadeIn(delay: 250.ms),

          const SizedBox(height: 4),

          // Member since
          Text(
            'Member since ${DateTime.now().year}',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
            ),
          ).animate().fadeIn(delay: 300.ms),

          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

/// User preferences section
class _PreferencesSection extends StatelessWidget {
  final ProfileModel? profile;

  const _PreferencesSection({this.profile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preferences',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _PreferenceCard(
                  icon: Icons.location_on_rounded,
                  label: 'Location',
                  value: profile?.city ?? 'Not set',
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _PreferenceCard(
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'Budget',
                  value: profile?.budgetLevel ?? 'Not set',
                ),
              ),
            ],
          ),
          if (profile?.vibes.isNotEmpty ?? false) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        color: AppColors.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Vibes',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (profile?.vibes ?? []).map((vibe) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          vibe,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PreferenceCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _PreferenceCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// AI provider settings section
class _AiSettingsSection extends ConsumerStatefulWidget {
  const _AiSettingsSection();

  @override
  ConsumerState<_AiSettingsSection> createState() => _AiSettingsSectionState();
}

class _AiSettingsSectionState extends ConsumerState<_AiSettingsSection> {
  @override
  Widget build(BuildContext context) {
    final aiSettings = ref.watch(settingsProvider).ai;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Settings',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // AI Provider
                Text(
                  'AI Provider',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AiProvider.values.map((provider) {
                    final isSelected = aiSettings.aiProvider == provider;
                    return ScaleOnPress(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        ref.read(settingsProvider.notifier).setAiProvider(provider);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.primary.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          provider.displayName,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.black
                                : AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: AppSpacing.lg),
                const Divider(color: AppColors.surface, height: 1),
                const SizedBox(height: AppSpacing.lg),

                // Creativity Slider
                Text(
                  'Creativity',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                GoldSlider(
                  value: aiSettings.creativity,
                  onChanged: (_) {
                    // Visual feedback only - API call on change end
                  },
                  onChangeEnd: (value) {
                    // Snap to 0.0, 0.5, or 1.0 and save to backend
                    final snappedValue = (value * 2).round() / 2;
                    ref.read(settingsProvider.notifier).setCreativity(snappedValue);
                  },
                  min: 0.0,
                  max: 1.0,
                  divisions: 2,
                  showLabels: true,
                  labels: const ['Low', 'Med', 'High'],
                ),

                const SizedBox(height: AppSpacing.lg),

                // Response Length Selector
                Text(
                  'Response Length',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    _ResponseLengthChip(
                      label: 'Short',
                      isSelected: aiSettings.responseLength == ResponseLength.short,
                      onTap: () => ref.read(settingsProvider.notifier).setResponseLength(ResponseLength.short),
                    ),
                    const SizedBox(width: 8),
                    _ResponseLengthChip(
                      label: 'Medium',
                      isSelected: aiSettings.responseLength == ResponseLength.medium,
                      onTap: () => ref.read(settingsProvider.notifier).setResponseLength(ResponseLength.medium),
                    ),
                    const SizedBox(width: 8),
                    _ResponseLengthChip(
                      label: 'Long',
                      isSelected: aiSettings.responseLength == ResponseLength.long,
                      onTap: () => ref.read(settingsProvider.notifier).setResponseLength(ResponseLength.long),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Response length chip selector
class _ResponseLengthChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ResponseLengthChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ScaleOnPress(
        onPressed: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.15)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.primary.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

/// Account management section
class _AccountSection extends StatelessWidget {
  final VoidCallback onLogout;

  const _AccountSection({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _AccountTile(
            icon: Icons.logout_rounded,
            label: 'Sign Out',
            isDestructive: true,
            onTap: () => _showLogoutConfirmation(context),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              onLogout();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _AccountTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleOnPress(
      onPressed: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isDestructive
                ? AppColors.error.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.05),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? AppColors.error : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color:
                      isDestructive ? AppColors.error : AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDestructive
                  ? AppColors.error.withValues(alpha: 0.5)
                  : AppColors.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
