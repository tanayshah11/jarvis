import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/colors.dart';
import '../models/oauth_flow_state.dart';

/// Animated indicator for OAuth flow states.
class OAuthStateIndicator extends StatelessWidget {
  /// The current OAuth flow state.
  final OAuthFlowState state;

  /// Optional error message for error state.
  final String? errorMessage;

  const OAuthStateIndicator({
    super.key,
    required this.state,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case OAuthFlowState.launching:
      case OAuthFlowState.exchangingCode:
        return _buildSpinningIndicator();
      case OAuthFlowState.waitingForAuth:
        return _buildPulsingDots();
      case OAuthFlowState.success:
        return _buildSuccessCheckmark();
      case OAuthFlowState.error:
        return _buildErrorIndicator();
      case OAuthFlowState.cancelled:
        return _buildCancelledIndicator();
      case OAuthFlowState.idle:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSpinningIndicator() {
    return const CupertinoActivityIndicator(
      color: AppColors.primary,
      radius: 16,
    );
  }

  Widget _buildPulsingDots() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDot(delay: 0),
        const SizedBox(width: 8),
        _buildDot(delay: 200),
        const SizedBox(width: 8),
        _buildDot(delay: 400),
      ],
    );
  }

  Widget _buildDot({required int delay}) {
    return Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        )
        .animate(onPlay: (controller) => controller.repeat())
        .fadeOut(
          duration: 1.2.seconds,
          delay: delay.milliseconds,
          curve: Curves.easeInOut,
        )
        .then()
        .fadeIn(duration: 1.2.seconds, curve: Curves.easeInOut);
  }

  Widget _buildSuccessCheckmark() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        CupertinoIcons.checkmark,
        color: AppColors.primary,
        size: 36,
      ),
    ).animate().scale(
      duration: 300.milliseconds,
      begin: const Offset(0, 0),
      end: const Offset(1, 1),
      curve: Curves.elasticOut,
    );
  }

  Widget _buildErrorIndicator() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            CupertinoIcons.xmark,
            color: AppColors.error,
            size: 36,
          ),
        ).animate().shake(
          duration: 500.milliseconds,
          hz: 4,
          offset: const Offset(10, 0),
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: 16),
          Text(
            errorMessage!,
            style: const TextStyle(color: AppColors.error, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildCancelledIndicator() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.textSecondary.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        CupertinoIcons.xmark,
        color: AppColors.textSecondary,
        size: 36,
      ),
    ).animate().fadeIn(duration: 300.milliseconds);
  }
}
