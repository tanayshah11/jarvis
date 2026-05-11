import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/colors.dart';
import '../models/integration.dart';
import 'connection_status.dart';

/// A glassmorphism card displaying an integration service.
class IntegrationCard extends StatelessWidget {
  /// The integration to display.
  final Integration integration;

  /// Callback when the card is tapped.
  final VoidCallback? onTap;

  const IntegrationCard({
    super.key,
    required this.integration,
    this.onTap,
  });

  IconData _getIcon() {
    if (integration.iconName != null) {
      switch (integration.iconName) {
        case 'mail':
          return CupertinoIcons.mail;
        case 'person':
          return CupertinoIcons.person_2;
        case 'calendar':
          return CupertinoIcons.calendar;
        case 'music_note':
          return CupertinoIcons.music_note;
        case 'square_stack_3d_up':
          return CupertinoIcons.square_stack_3d_up;
        case 'doc_text':
          return CupertinoIcons.doc_text;
        case 'calendar_today':
          return CupertinoIcons.calendar_today;
        case 'photo':
          return CupertinoIcons.photo;
        default:
          return CupertinoIcons.app;
      }
    }
    return CupertinoIcons.app;
  }

  Color _getIconColor() {
    if (integration.status == IntegrationStatus.connected) {
      return AppColors.primary;
    }
    return AppColors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap != null
          ? () {
              HapticFeedback.selectionClick();
              onTap!();
            }
          : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: integration.status == IntegrationStatus.connected
                    ? AppColors.primary.withValues(alpha: 0.3)
                    : AppColors.primary.withValues(alpha: 0.1),
                width: integration.status == IntegrationStatus.connected ? 1 : 0.5,
              ),
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getIconColor().withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIcon(),
                    color: _getIconColor(),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              integration.name,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          ConnectionStatus(status: integration.status),
                        ],
                      ),
                      if (integration.accountInfo != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          integration.accountInfo!,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                      if (integration.privacy == PrivacyLevel.onDevice &&
                          integration.accountInfo == null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.lock_shield,
                              size: 12,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Stays on device',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
