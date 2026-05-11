import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';

class IntegrationsVisual extends StatefulWidget {
  final double size;

  const IntegrationsVisual({
    super.key,
    this.size = 280,
  });

  @override
  State<IntegrationsVisual> createState() => _IntegrationsVisualState();
}

class _IntegrationsVisualState extends State<IntegrationsVisual>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 20000),
    )..repeat();

    _rotationAnimation = Tween<double>(begin: 0.0, end: math.pi * 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _IntegrationsPainter(
              rotation: _rotationAnimation.value,
            ),
          ),
        );
      },
    );
  }
}

class _IntegrationsPainter extends CustomPainter {
  final double rotation;

  _IntegrationsPainter({required this.rotation});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final orbitRadius = size.width * 0.35;

    // Paint for connecting lines
    final linePaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.3)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Paint for circles
    final circlePaint = Paint()
      ..color = AppColors.surfaceLight
      ..style = PaintingStyle.fill;

    final circleBorderPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Central sparkle icon
    final centralRadius = 32.0;
    final centralCirclePaint = Paint()
      ..shader = AppColors.primaryGradient.createShader(
        Rect.fromCircle(center: center, radius: centralRadius),
      )
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, centralRadius, centralCirclePaint);

    // Draw sparkle icon
    _drawIcon(canvas, Icons.auto_awesome, center, centralRadius);

    // Service icons (6 icons)
    final icons = [
      Icons.email_outlined, // Gmail
      Icons.calendar_today_outlined, // Google Calendar
      Icons.tag_outlined, // Slack
      Icons.note_outlined, // Notion
      Icons.music_note_outlined, // Spotify
      Icons.g_mobiledata, // Google
    ];

    // Draw orbiting service icons
    for (int i = 0; i < 6; i++) {
      final angle = (math.pi * 2 / 6) * i - math.pi / 2 + rotation * 0.1;

      final iconPos = Offset(
        center.dx + math.cos(angle) * orbitRadius,
        center.dy + math.sin(angle) * orbitRadius,
      );

      // Draw connecting line
      canvas.drawLine(center, iconPos, linePaint);

      // Draw service circle
      final serviceRadius = 22.0;
      canvas.drawCircle(iconPos, serviceRadius, circlePaint);
      canvas.drawCircle(iconPos, serviceRadius, circleBorderPaint);

      // Draw service icon
      _drawIcon(canvas, icons[i], iconPos, serviceRadius);
    }
  }

  void _drawIcon(Canvas canvas, IconData icon, Offset position, double circleRadius) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontFamily: icon.fontFamily,
          fontSize: circleRadius > 30 ? 24 : 18,
          color: AppColors.primary,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        position.dx - textPainter.width / 2,
        position.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(_IntegrationsPainter oldDelegate) {
    return oldDelegate.rotation != rotation;
  }
}
