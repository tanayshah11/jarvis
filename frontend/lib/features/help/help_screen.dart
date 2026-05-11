import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/spacing.dart';
import '../../core/widgets/animated_gradient.dart';
import '../../core/widgets/jarvis_card.dart';
import '../../core/widgets/screen_header.dart';
import '../../core/widgets/animated_content.dart';

class HelpScreen extends ConsumerWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const Positioned.fill(
            child: AnimatedGradient(child: SizedBox.expand()),
          ),
          CustomScrollView(
            slivers: [
              SliverScreenHeader(
                title: 'Help & Support',
                subtitle: 'Get answers to common questions',
                onBack: () => context.pop(),
              ),
              SliverToBoxAdapter(
                child: AnimatedContent(
                  delay: const Duration(milliseconds: 100),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      children: [
                        _HelpSection(
                          title: 'Getting Started',
                          items: const [
                            _HelpItem(
                              title: 'How to start a conversation',
                              description: 'Tap "New chat" in the sidebar to begin a new conversation with Jarvis.',
                            ),
                            _HelpItem(
                              title: 'Using different modes',
                              description: 'Switch between Chat, Daily Brief, and Outing modes using the mode selector.',
                            ),
                            _HelpItem(
                              title: 'Managing conversations',
                              description: 'Long press on any conversation to rename, archive, or delete it.',
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        _HelpSection(
                          title: 'Features',
                          items: const [
                            _HelpItem(
                              title: 'Search conversations',
                              description: 'Use the search bar in the sidebar to quickly find past conversations.',
                            ),
                            _HelpItem(
                              title: 'Edit mode',
                              description: 'Tap the edit icon next to "New chat" to select multiple conversations for bulk actions.',
                            ),
                            _HelpItem(
                              title: 'Attachments',
                              description: 'Tap the + button in the chat input to attach photos, documents, or share your location.',
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        _HelpSection(
                          title: 'Support',
                          items: [
                            _HelpItem(
                              title: 'Contact Support',
                              description: 'Email us at support@jarvis.ai for assistance.',
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Email support@jarvis.ai'),
                                    backgroundColor: AppColors.surfaceLight,
                                  ),
                                );
                              },
                            ),
                            _HelpItem(
                              title: 'Report a Bug',
                              description: 'Found an issue? Let us know!',
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Bug reporting coming soon'),
                                    backgroundColor: AppColors.surfaceLight,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HelpSection extends StatelessWidget {
  final String title;
  final List<Widget> items;

  const _HelpSection({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return StaggeredAnimatedContent(
      itemDelay: const Duration(milliseconds: 100),
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.md,
            bottom: AppSpacing.md,
          ),
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),
        ...items,
      ],
    );
  }
}

class _HelpItem extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback? onTap;

  const _HelpItem({
    required this.title,
    required this.description,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: JarvisCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              description,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

