import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';

/// Animated success checkmark that draws in with a circle.
class ConnectionSuccessAnimation extends StatefulWidget {
  /// Callback when animation completes.
  final VoidCallback? onComplete;

  /// Size of the animation.
  final double size;

  const ConnectionSuccessAnimation({
    super.key,
    this.onComplete,
    this.size = 120,
  });

  @override
  State<ConnectionSuccessAnimation> createState() =>
      _ConnectionSuccessAnimationState();
}

class _ConnectionSuccessAnimationState
    extends State<ConnectionSuccessAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _circleAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Circle draws from 0% to 100% in first 600ms
    _circleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    // Check draws from 0% to 100% in next 400ms
    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );

    _controller.forward().then((_) {
      // Wait a bit before calling onComplete
      Future.delayed(const Duration(milliseconds: 300), () {
        widget.onComplete?.call();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _SuccessCheckmarkPainter(
              circleProgress: _circleAnimation.value,
              checkProgress: _checkAnimation.value,
            ),
          );
        },
      ),
    );
  }
}

class _SuccessCheckmarkPainter extends CustomPainter {
  final double circleProgress;
  final double checkProgress;

  _SuccessCheckmarkPainter({
    required this.circleProgress,
    required this.checkProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // Draw circle
    final circlePaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final circleRect = Rect.fromCircle(center: center, radius: radius);
    final circleSweepAngle = 2 * 3.14159 * circleProgress;

    canvas.drawArc(
      circleRect,
      -3.14159 / 2, // Start from top
      circleSweepAngle,
      false,
      circlePaint,
    );

    // Draw checkmark
    if (checkProgress > 0) {
      final checkPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      // Checkmark path
      final checkPath = Path();

      // Start point (left point of check)
      final startX = center.dx - radius * 0.4;
      final startY = center.dy;

      // Middle point (bottom point of check)
      final midX = center.dx - radius * 0.1;
      final midY = center.dy + radius * 0.3;

      // End point (top right point of check)
      final endX = center.dx + radius * 0.4;
      final endY = center.dy - radius * 0.3;

      checkPath.moveTo(startX, startY);

      if (checkProgress <= 0.5) {
        // Draw first half of checkmark
        final progress = checkProgress * 2;
        final currentX = startX + (midX - startX) * progress;
        final currentY = startY + (midY - startY) * progress;
        checkPath.lineTo(currentX, currentY);
      } else {
        // Draw second half of checkmark
        checkPath.lineTo(midX, midY);
        final progress = (checkProgress - 0.5) * 2;
        final currentX = midX + (endX - midX) * progress;
        final currentY = midY + (endY - midY) * progress;
        checkPath.lineTo(currentX, currentY);
      }

      canvas.drawPath(checkPath, checkPaint);
    }
  }

  @override
  bool shouldRepaint(_SuccessCheckmarkPainter oldDelegate) {
    return oldDelegate.circleProgress != circleProgress ||
        oldDelegate.checkProgress != checkProgress;
  }
}
