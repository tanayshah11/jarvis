import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';

class KnowledgeGraphVisual extends StatefulWidget {
  final double size;

  const KnowledgeGraphVisual({
    super.key,
    this.size = 280,
  });

  @override
  State<KnowledgeGraphVisual> createState() => _KnowledgeGraphVisualState();
}

class _KnowledgeGraphVisualState extends State<KnowledgeGraphVisual>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _breatheAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _breatheAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
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
      animation: _breatheAnimation,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _KnowledgeGraphPainter(
              breatheValue: _breatheAnimation.value,
            ),
          ),
        );
      },
    );
  }
}

class _KnowledgeGraphPainter extends CustomPainter {
  final double breatheValue;

  _KnowledgeGraphPainter({required this.breatheValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.35;

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

    // Central brain icon circle
    final centralRadius = 32.0;
    final centralCirclePaint = Paint()
      ..shader = AppColors.primaryGradient.createShader(
        Rect.fromCircle(center: center, radius: centralRadius),
      )
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, centralRadius, centralCirclePaint);

    // Orbiting icons positions (4 icons)
    final icons = [
      Icons.person_outline,
      Icons.calendar_today_outlined,
      Icons.folder_outlined,
      Icons.location_on_outlined,
    ];

    // Draw connections and orbiting circles
    for (int i = 0; i < 4; i++) {
      final angle = (math.pi * 2 / 4) * i - math.pi / 2;
      final offset = math.sin(breatheValue * math.pi) * 5;
      final orbitRadius = radius + offset;

      final iconPos = Offset(
        center.dx + math.cos(angle) * orbitRadius,
        center.dy + math.sin(angle) * orbitRadius,
      );

      // Draw connecting line
      canvas.drawLine(center, iconPos, linePaint);

      // Draw orbiting circle
      final iconCircleRadius = 24.0;
      canvas.drawCircle(iconPos, iconCircleRadius, circlePaint);
      canvas.drawCircle(iconPos, iconCircleRadius, circleBorderPaint);

      // Draw icon
      _drawIcon(canvas, icons[i], iconPos, iconCircleRadius);
    }
  }

  void _drawIcon(Canvas canvas, IconData icon, Offset position, double circleRadius) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontFamily: icon.fontFamily,
          fontSize: 20,
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
  bool shouldRepaint(_KnowledgeGraphPainter oldDelegate) {
    return oldDelegate.breatheValue != breatheValue;
  }
}
