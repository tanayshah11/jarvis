import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/colors.dart';
import '../theme/spacing.dart';

/// Standard app screen header with consistent styling and animations
class ScreenHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final bool centerTitle;
  final bool showBackButton;
  final Color? backgroundColor;
  final bool animate;

  const ScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.actions,
    this.centerTitle = false,
    this.showBackButton = true,
    this.backgroundColor,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget child = Container(
      color: backgroundColor ?? AppColors.background,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment:
              centerTitle ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            // Header row with back button and actions
            Row(
              children: [
                // Back button
                if (showBackButton)
                  CupertinoButton(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    onPressed: onBack ?? () => Navigator.of(context).pop(),
                    child: const Icon(
                      CupertinoIcons.chevron_left,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),

                // Title (with flex if not centered)
                if (!centerTitle && showBackButton)
                  const SizedBox(width: AppSpacing.sm),

                Flexible(
                  child: Column(
                    crossAxisAlignment: centerTitle
                        ? CrossAxisAlignment.center
                        : CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          height: 1.25,
                        ),
                        textAlign: centerTitle ? TextAlign.center : TextAlign.start,
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          subtitle!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                          textAlign: centerTitle ? TextAlign.center : TextAlign.start,
                        ),
                      ],
                    ],
                  ),
                ),

                // Actions
                if (actions != null && actions!.isNotEmpty) ...[
                  const Spacer(),
                  ...actions!,
                ],
              ],
            ),
          ],
        ),
      ),
    );

    // Apply entrance animation if enabled
    if (animate) {
      return child
          .animate()
          .fadeIn(duration: 400.ms)
          .slideY(
            begin: -0.1,
            end: 0,
            duration: 400.ms,
            curve: Curves.easeOutCubic,
          );
    }

    return child;
  }
}

/// Sliver version for use with CustomScrollView
class SliverScreenHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final bool centerTitle;
  final bool showBackButton;
  final Color? backgroundColor;
  final bool animate;

  const SliverScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.actions,
    this.centerTitle = false,
    this.showBackButton = true,
    this.backgroundColor,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: ScreenHeader(
        title: title,
        subtitle: subtitle,
        onBack: onBack,
        actions: actions,
        centerTitle: centerTitle,
        showBackButton: showBackButton,
        backgroundColor: backgroundColor,
        animate: animate,
      ),
    );
  }
}
