import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/colors.dart';

/// Large animated service icon for OAuth flow screens.
class ServiceIcon extends StatelessWidget {
  /// The service ID (e.g., "spotify", "github", "google").
  final String serviceId;

  /// Size of the icon.
  final double size;

  /// Whether to animate with a subtle pulse.
  final bool animate;

  const ServiceIcon({
    super.key,
    required this.serviceId,
    this.size = 80,
    this.animate = false,
  });

  IconData _getIconForService(String serviceId) {
    switch (serviceId.toLowerCase()) {
      case 'spotify':
        return CupertinoIcons.music_note_2;
      case 'github':
        return CupertinoIcons.square_stack_3d_up;
      case 'google':
        return CupertinoIcons.at;
      case 'gmail':
        return CupertinoIcons.mail;
      case 'calendar':
      case 'google_calendar':
        return CupertinoIcons.calendar;
      case 'drive':
      case 'google_drive':
        return CupertinoIcons.folder;
      case 'photos':
      case 'google_photos':
        return CupertinoIcons.photo;
      case 'contacts':
        return CupertinoIcons.person_2;
      case 'notion':
        return CupertinoIcons.doc_text;
      case 'slack':
        return CupertinoIcons.chat_bubble_2;
      case 'twitter':
      case 'x':
        return CupertinoIcons.at;
      default:
        return CupertinoIcons.app;
    }
  }

  Color _getColorForService(String serviceId) {
    switch (serviceId.toLowerCase()) {
      case 'spotify':
        return const Color(0xFF1DB954); // Spotify green
      case 'github':
        return Colors.white;
      case 'google':
      case 'gmail':
        return const Color(0xFFEA4335); // Google red
      case 'calendar':
      case 'google_calendar':
        return const Color(0xFF4285F4); // Google blue
      case 'drive':
      case 'google_drive':
        return const Color(0xFF34A853); // Google green
      case 'photos':
      case 'google_photos':
        return const Color(0xFFFBBC04); // Google yellow
      case 'notion':
        return Colors.white;
      case 'slack':
        return const Color(0xFF4A154B); // Slack purple
      case 'twitter':
      case 'x':
        return Colors.white;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final icon = _getIconForService(serviceId);
    final color = _getColorForService(serviceId);

    Widget iconWidget = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(size * 0.25),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Icon(
        icon,
        size: size * 0.5,
        color: color,
      ),
    );

    if (animate) {
      return iconWidget
          .animate(onPlay: (controller) => controller.repeat())
          .scale(
            duration: 2.seconds,
            begin: const Offset(1.0, 1.0),
            end: const Offset(1.05, 1.05),
            curve: Curves.easeInOut,
          )
          .then()
          .scale(
            duration: 2.seconds,
            begin: const Offset(1.05, 1.05),
            end: const Offset(1.0, 1.0),
            curve: Curves.easeInOut,
          );
    }

    return iconWidget;
  }
}
