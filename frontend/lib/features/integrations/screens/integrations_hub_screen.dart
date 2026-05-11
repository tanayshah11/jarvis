import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/widgets/animated_gradient.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/animated_content.dart';
import '../../../core/widgets/state_widgets.dart';
import '../models/integration.dart';
import '../providers/integrations_provider.dart';
import '../widgets/integration_card.dart';
import '../widgets/permission_dialog.dart';
import 'oauth_flow_screen.dart';

/// Screen displaying all available and connected integrations.
class IntegrationsHubScreen extends ConsumerWidget {
  const IntegrationsHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final integrationsState = ref.watch(integrationsControllerProvider);
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
              // Screen header
              SliverScreenHeader(
                title: 'Integrations',
                subtitle: 'Connect services to enhance Jarvis',
                onBack: () {
                  HapticFeedback.lightImpact();
                  context.pop();
                },
              ),

              // Loading state
              if (integrationsState.isLoading)
                const SliverFillRemaining(
                  child: LoadingStateWidget(
                    message: 'Loading integrations...',
                  ),
                ),

              // Empty state
              if (!integrationsState.isLoading &&
                  integrationsState.connectedIntegrations.isEmpty &&
                  integrationsState.availableIntegrations.isEmpty &&
                  integrationsState.deviceIntegrations.isEmpty &&
                  integrationsState.connectedDeviceIntegrations.isEmpty)
                const SliverFillRemaining(
                  child: EmptyStateWidget(
                    title: 'No Integrations',
                    message: 'No integrations are available at this time.',
                    icon: CupertinoIcons.square_stack_3d_up,
                  ),
                ),

              // Connected integrations section
              if (!integrationsState.isLoading &&
                  (integrationsState.connectedIntegrations.isNotEmpty ||
                      integrationsState.connectedDeviceIntegrations.isNotEmpty))
                SliverToBoxAdapter(
                  child: AnimatedContent(
                    delay: const Duration(milliseconds: 100),
                    child: _buildSection(
                      context: context,
                      ref: ref,
                      title: 'CONNECTED',
                      integrations: [
                        ...integrationsState.connectedIntegrations,
                        ...integrationsState.connectedDeviceIntegrations,
                      ],
                    ),
                  ),
                ),

              // Available integrations section
              if (!integrationsState.isLoading &&
                  integrationsState.availableIntegrations.isNotEmpty)
                SliverToBoxAdapter(
                  child: AnimatedContent(
                    delay: const Duration(milliseconds: 200),
                    child: _buildSection(
                      context: context,
                      ref: ref,
                      title: 'AVAILABLE',
                      integrations: integrationsState.availableIntegrations,
                    ),
                  ),
                ),

              // Device integrations section
              if (!integrationsState.isLoading &&
                  integrationsState.deviceIntegrations.isNotEmpty)
                SliverToBoxAdapter(
                  child: AnimatedContent(
                    delay: const Duration(milliseconds: 300),
                    child: _buildSection(
                      context: context,
                      ref: ref,
                      title: 'DEVICE',
                      integrations: integrationsState.deviceIntegrations,
                    ),
                  ),
                ),

              // Bottom padding
              SliverToBoxAdapter(
                child: SizedBox(height: 100 + bottomPadding),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required List<Integration> integrations,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Container(
                width: 3,
                height: 14,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Integration cards with staggered animation
          ...integrations.asMap().entries.map((entry) {
            final index = entry.key;
            final integration = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: IntegrationCard(
                integration: integration,
                onTap: () => _handleIntegrationTap(
                  context,
                  ref,
                  integration,
                ),
              ),
            )
                .animate(delay: Duration(milliseconds: 50 * index))
                .fadeIn(duration: 400.ms, curve: Curves.easeOutCubic)
                .slideX(
                  begin: 0.1,
                  end: 0,
                  duration: 400.ms,
                  curve: Curves.easeOutCubic,
                );
          }),
        ],
      ),
    );
  }

  void _handleIntegrationTap(
    BuildContext context,
    WidgetRef ref,
    Integration integration,
  ) {
    if (integration.status == IntegrationStatus.connected) {
      // Show disconnect confirmation
      _showDisconnectDialog(context, ref, integration);
    } else if (integration.status == IntegrationStatus.disconnected) {
      // Show permission dialog
      _showPermissionDialog(context, ref, integration);
    }
  }

  Future<void> _showPermissionDialog(
    BuildContext context,
    WidgetRef ref,
    Integration integration,
  ) async {
    HapticFeedback.mediumImpact();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => PermissionDialog(
        integration: integration,
        onConfirm: () => Navigator.of(ctx).pop(true),
        onCancel: () => Navigator.of(ctx).pop(false),
      ),
    );

    if (confirmed == true && context.mounted) {
      // For OAuth integrations, show OAuth flow screen
      if (integration.type == IntegrationType.oauth) {
        await _launchOAuthFlow(context, ref, integration);
      } else {
        // For local integrations, connect directly
        await ref
            .read(integrationsControllerProvider.notifier)
            .connectIntegration(integration.id);
      }
    }
  }

  Future<void> _launchOAuthFlow(
    BuildContext context,
    WidgetRef ref,
    Integration integration,
  ) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => OAuthFlowScreen(integrationId: integration.id),
        fullscreenDialog: true,
      ),
    );

    // Refresh integrations list after OAuth flow
    if (result == true && context.mounted) {
      ref.invalidate(integrationsControllerProvider);
    }
  }

  void _showDisconnectDialog(
    BuildContext context,
    WidgetRef ref,
    Integration integration,
  ) {
    HapticFeedback.mediumImpact();
    showCupertinoDialog<void>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text('Disconnect ${integration.name}'),
        content: Text(
          'Are you sure you want to disconnect ${integration.name}? Jarvis will no longer be able to access this service.',
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.of(ctx).pop();
              ref
                  .read(integrationsControllerProvider.notifier)
                  .disconnectIntegration(integration.id);
            },
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );
  }
}
