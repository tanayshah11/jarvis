import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/widgets/animated_gradient.dart';
import '../../../core/widgets/animated_content.dart';
import '../models/integration.dart';
import '../models/oauth_flow_state.dart';
import '../providers/integrations_provider.dart';
import '../widgets/connection_success_animation.dart';
import '../widgets/oauth_state_indicator.dart';
import '../widgets/service_icon.dart';

/// Full-screen OAuth authentication flow with animated states.
class OAuthFlowScreen extends ConsumerStatefulWidget {
  /// The integration ID to connect (e.g., "spotify", "github").
  final String integrationId;

  const OAuthFlowScreen({
    super.key,
    required this.integrationId,
  });

  @override
  ConsumerState<OAuthFlowScreen> createState() => _OAuthFlowScreenState();
}

class _OAuthFlowScreenState extends ConsumerState<OAuthFlowScreen> {
  OAuthFlowState _flowState = OAuthFlowState.idle;
  String? _errorMessage;
  String? _accountInfo;

  @override
  void initState() {
    super.initState();
    // Start the OAuth flow automatically
    _startOAuthFlow();
  }

  Future<void> _startOAuthFlow() async {
    try {
      // Launching state
      setState(() {
        _flowState = OAuthFlowState.launching;
      });
      HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 500));

      // Waiting for auth state
      setState(() {
        _flowState = OAuthFlowState.waitingForAuth;
      });
      HapticFeedback.mediumImpact();

      // Simulate waiting for user to complete auth in browser
      // In real implementation, this would listen for deep link callback
      await Future.delayed(const Duration(seconds: 3));

      // Exchanging code state
      setState(() {
        _flowState = OAuthFlowState.exchangingCode;
      });
      HapticFeedback.lightImpact();

      // Connect the integration
      await ref
          .read(integrationsControllerProvider.notifier)
          .connectIntegration(widget.integrationId);

      // Get the account info from the updated integration
      final integration = ref
          .read(integrationsControllerProvider)
          .integrations
          .firstWhere((i) => i.id == widget.integrationId);

      // Success state
      setState(() {
        _flowState = OAuthFlowState.success;
        _accountInfo = integration.accountInfo;
      });
      HapticFeedback.heavyImpact();

      // Auto-dismiss after showing success
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() {
        _flowState = OAuthFlowState.error;
        _errorMessage = e.toString();
      });
      HapticFeedback.heavyImpact();
    }
  }

  void _cancelFlow() {
    HapticFeedback.mediumImpact();
    setState(() {
      _flowState = OAuthFlowState.cancelled;
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.of(context).pop(false);
      }
    });
  }

  void _retry() {
    HapticFeedback.mediumImpact();
    setState(() {
      _flowState = OAuthFlowState.idle;
      _errorMessage = null;
    });
    _startOAuthFlow();
  }

  Integration _getIntegration() {
    return ref
        .read(integrationsControllerProvider)
        .integrations
        .firstWhere((i) => i.id == widget.integrationId);
  }

  @override
  Widget build(BuildContext context) {
    final integration = _getIntegration();
    final topPadding = MediaQuery.of(context).padding.top;

    return PopScope(
      canPop: _flowState.isTerminal,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && !_flowState.isTerminal) {
          _cancelFlow();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            // Animated gradient background
            const Positioned.fill(
              child: AnimatedGradient(child: SizedBox.expand()),
            ),

            // Content
            SafeArea(
              child: Column(
                children: [
                  // Close button (only show if terminal state)
                  if (_flowState.isTerminal)
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: topPadding + AppSpacing.md,
                          right: AppSpacing.lg,
                        ),
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(
                            _flowState == OAuthFlowState.success,
                          ),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.surface.withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              CupertinoIcons.xmark,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Main content
                  Expanded(
                    child: _buildContent(integration),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(Integration integration) {
    switch (_flowState) {
      case OAuthFlowState.launching:
        return _buildLaunchingState(integration);
      case OAuthFlowState.waitingForAuth:
        return _buildWaitingState(integration);
      case OAuthFlowState.exchangingCode:
        return _buildExchangingState(integration);
      case OAuthFlowState.success:
        return _buildSuccessState(integration);
      case OAuthFlowState.error:
        return _buildErrorState(integration);
      case OAuthFlowState.cancelled:
        return _buildCancelledState(integration);
      case OAuthFlowState.idle:
        return const SizedBox.shrink();
    }
  }

  Widget _buildLaunchingState(Integration integration) {
    return Center(
      child: AnimatedContent(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ServiceIcon(
              serviceId: integration.id,
              size: 80,
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              _flowState.message,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            OAuthStateIndicator(state: _flowState),
          ],
        ),
      ),
    );
  }

  Widget _buildWaitingState(Integration integration) {
    return Center(
      child: AnimatedContent(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ServiceIcon(
              serviceId: integration.id,
              size: 100,
              animate: true,
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              _flowState.message,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.lg,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Waiting for response...',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      OAuthStateIndicator(state: _flowState),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.massive),
            _buildCancelButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildExchangingState(Integration integration) {
    return Center(
      child: AnimatedContent(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ServiceIcon(
              serviceId: integration.id,
              size: 80,
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              _flowState.message,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            OAuthStateIndicator(state: _flowState),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessState(Integration integration) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ConnectionSuccessAnimation(
            size: 120,
            onComplete: () {
              // Animation complete, screen will auto-dismiss
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            _flowState.message,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (_accountInfo != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              _accountInfo!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState(Integration integration) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OAuthStateIndicator(
              state: _flowState,
              errorMessage: _errorMessage,
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              _flowState.message,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'We couldn\'t connect to ${integration.name}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.massive),
            _buildRetryButton(),
            const SizedBox(height: AppSpacing.md),
            _buildCancelButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildCancelledState(Integration integration) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OAuthStateIndicator(state: _flowState),
          const SizedBox(height: AppSpacing.xl),
          Text(
            _flowState.message,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRetryButton() {
    return ScaleOnPress(
      onPressed: _retry,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Text(
          'Try Again',
          style: TextStyle(
            color: AppColors.background,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildCancelButton() {
    return GestureDetector(
      onTap: _cancelFlow,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.sm,
        ),
        child: const Text(
          'Cancel',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
