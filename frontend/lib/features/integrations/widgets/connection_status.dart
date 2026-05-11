import 'package:flutter/cupertino.dart';
import '../../../core/theme/colors.dart';
import '../models/integration.dart';

/// Widget displaying the connection status of an integration.
class ConnectionStatus extends StatelessWidget {
  /// The integration status to display.
  final IntegrationStatus status;

  const ConnectionStatus({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case IntegrationStatus.connected:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Connected',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );

      case IntegrationStatus.connecting:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 12,
              height: 12,
              child: CupertinoActivityIndicator(
                color: AppColors.primary,
                radius: 6,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Connecting...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );

      case IntegrationStatus.error:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.exclamationmark_circle,
              color: AppColors.error,
              size: 14,
            ),
            const SizedBox(width: 6),
            Text(
              'Error',
              style: TextStyle(
                color: AppColors.error,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );

      case IntegrationStatus.disconnected:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Connect',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              CupertinoIcons.arrow_right,
              color: AppColors.primary,
              size: 14,
            ),
          ],
        );
    }
  }
}
