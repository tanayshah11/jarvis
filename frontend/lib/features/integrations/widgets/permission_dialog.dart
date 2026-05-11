import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../models/integration.dart';
import 'service_icon.dart';

/// Dialog shown before connecting to an integration, explaining permissions.
class PermissionDialog extends StatelessWidget {
  /// The integration to show permissions for.
  final Integration integration;

  /// Callback when user confirms connection.
  final VoidCallback onConfirm;

  /// Callback when user cancels.
  final VoidCallback onCancel;

  const PermissionDialog({
    super.key,
    required this.integration,
    required this.onConfirm,
    required this.onCancel,
  });

  String get _privacyDescription {
    switch (integration.privacy) {
      case PrivacyLevel.onDevice:
        return 'All data stays on your device. Nothing is sent to external servers.';
      case PrivacyLevel.withConsent:
        return 'Data will be shared with ${integration.name} with your consent. You can revoke access at any time.';
      case PrivacyLevel.apiKey:
        return 'Your API key will be securely stored and used to access ${integration.name}.';
    }
  }

  bool get _isCloudService {
    return integration.privacy == PrivacyLevel.withConsent;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with service icon
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    children: [
                      ServiceIcon(
                        serviceId: integration.id,
                        size: 64,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Connect ${integration.name}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        integration.description,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Divider
                Container(
                  height: 0.5,
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),

                // Capabilities section
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Jarvis will be able to:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ...integration.capabilities.map((capability) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: Row(
                              children: [
                                Icon(
                                  CupertinoIcons.checkmark_circle_fill,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Text(
                                    _formatCapability(capability),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                      const SizedBox(height: AppSpacing.md),

                      // Privacy warning
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: integration.privacy == PrivacyLevel.onDevice
                              ? AppColors.primary.withValues(alpha: 0.15)
                              : AppColors.surfaceLight.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: integration.privacy == PrivacyLevel.onDevice
                                ? AppColors.primary.withValues(alpha: 0.3)
                                : AppColors.textMuted.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              integration.privacy == PrivacyLevel.onDevice
                                  ? CupertinoIcons.lock_shield_fill
                                  : CupertinoIcons.info_circle_fill,
                              size: 18,
                              color: integration.privacy == PrivacyLevel.onDevice
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _privacyDescription,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: integration.privacy == PrivacyLevel.onDevice
                                          ? AppColors.primary
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                  if (_isCloudService) ...[
                                    const SizedBox(height: AppSpacing.xs),
                                    const Text(
                                      'Learn more about privacy',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.primary,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Action buttons
                Padding(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.xl,
                    right: AppSpacing.xl,
                    bottom: AppSpacing.xl,
                  ),
                  child: Column(
                    children: [
                      // Connect button
                      GestureDetector(
                        onTap: onConfirm,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
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
                          child: Text(
                            integration.privacy == PrivacyLevel.onDevice
                                ? 'Enable'
                                : 'Connect',
                            style: const TextStyle(
                              color: AppColors.background,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // Cancel button
                      GestureDetector(
                        onTap: onCancel,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.sm,
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
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

  String _formatCapability(String capability) {
    switch (capability.toLowerCase()) {
      case 'search':
        return 'Search your data';
      case 'read':
        return 'Read your data';
      case 'write':
      case 'create':
        return 'Create new items';
      case 'update':
        return 'Update existing items';
      case 'delete':
        return 'Delete items';
      case 'send':
        return 'Send messages';
      case 'play':
        return 'Control playback';
      case 'pause':
        return 'Pause playback';
      case 'next':
        return 'Skip tracks';
      default:
        return capability.substring(0, 1).toUpperCase() + capability.substring(1);
    }
  }
}
