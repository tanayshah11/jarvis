import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/colors.dart';

/// Premium loading spinner with 3 concentric rotating gold rings
///
/// Features:
/// - 3 concentric rings with different rotation speeds
/// - Varying opacity (outer more transparent)
/// - Gold glow effect in center
/// - Optional pulsing center animation
/// - Configurable size
class JarvisSpinner extends StatefulWidget {
  /// Size of the spinner (diameter)
  final double size;

  /// Whether to show pulsing animation in the center
  final bool showPulse;

  /// Stroke width of the rings
  final double strokeWidth;

  const JarvisSpinner({
    super.key,
    this.size = 60.0,
    this.showPulse = true,
    this.strokeWidth = 2.0,
  });

  @override
  State<JarvisSpinner> createState() => _JarvisSpinnerState();
}

class _JarvisSpinnerState extends State<JarvisSpinner>
    with TickerProviderStateMixin {
  late AnimationController _outerRingController;
  late AnimationController _middleRingController;
  late AnimationController _innerRingController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    // Outer ring - slowest rotation (3 seconds)
    _outerRingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    // Middle ring - medium rotation (2 seconds)
    _middleRingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    // Inner ring - fastest rotation (1.2 seconds)
    _innerRingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    // Center pulse animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _outerRingController.dispose();
    _middleRingController.dispose();
    _innerRingController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _outerRingController,
          _middleRingController,
          _innerRingController,
          _pulseController,
        ]),
        builder: (context, child) {
          return CustomPaint(
            painter: _JarvisSpinnerPainter(
              outerRingRotation: _outerRingController.value * 2 * math.pi,
              middleRingRotation: _middleRingController.value * 2 * math.pi,
              innerRingRotation: _innerRingController.value * 2 * math.pi,
              pulseValue: _pulseController.value,
              showPulse: widget.showPulse,
              strokeWidth: widget.strokeWidth,
            ),
          );
        },
      ),
    );
  }
}

/// Custom painter for drawing the three concentric rings
class _JarvisSpinnerPainter extends CustomPainter {
  final double outerRingRotation;
  final double middleRingRotation;
  final double innerRingRotation;
  final double pulseValue;
  final bool showPulse;
  final double strokeWidth;

  _JarvisSpinnerPainter({
    required this.outerRingRotation,
    required this.middleRingRotation,
    required this.innerRingRotation,
    required this.pulseValue,
    required this.showPulse,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw center glow
    _drawCenterGlow(canvas, center, radius);

    // Draw three rings (outer to inner)
    _drawRing(
      canvas,
      center,
      radius * 0.9,
      outerRingRotation,
      0.3, // Most transparent
      strokeWidth * 0.8,
    );

    _drawRing(
      canvas,
      center,
      radius * 0.65,
      middleRingRotation,
      0.5, // Medium opacity
      strokeWidth,
    );

    _drawRing(
      canvas,
      center,
      radius * 0.4,
      innerRingRotation,
      0.7, // Least transparent
      strokeWidth * 1.2,
    );

    // Draw pulsing center if enabled
    if (showPulse) {
      _drawPulsingCenter(canvas, center, radius);
    }
  }

  /// Draws the gold glow effect in the center
  void _drawCenterGlow(Canvas canvas, Offset center, double radius) {
    final glowPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    canvas.drawCircle(center, radius * 0.25, glowPaint);

    // Inner glow
    final innerGlowPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawCircle(center, radius * 0.15, innerGlowPaint);
  }

  /// Draws a single rotating ring
  void _drawRing(
    Canvas canvas,
    Offset center,
    double radius,
    double rotation,
    double opacity,
    double strokeWidth,
  ) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw arc segments to create a ring with gaps
    const segmentCount = 8;
    const gapAngle = math.pi / 32; // Small gap between segments

    for (int i = 0; i < segmentCount; i++) {
      final startAngle = (i * 2 * math.pi / segmentCount) + rotation + gapAngle;
      final sweepAngle = (2 * math.pi / segmentCount) - (2 * gapAngle);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }

    // Add glow to the ring
    final glowPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: opacity * 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 2
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    for (int i = 0; i < segmentCount; i++) {
      final startAngle = (i * 2 * math.pi / segmentCount) + rotation + gapAngle;
      final sweepAngle = (2 * math.pi / segmentCount) - (2 * gapAngle);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        glowPaint,
      );
    }
  }

  /// Draws the pulsing center dot
  void _drawPulsingCenter(Canvas canvas, Offset center, double radius) {
    // Calculate pulse scale and opacity
    final scale = 1.0 + (pulseValue * 0.5);
    final opacity = 0.5 + (pulseValue * 0.5);

    // Outer pulse ring
    final pulsePaint = Paint()
      ..color = AppColors.primary.withValues(alpha: opacity * 0.3)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.12 * scale, pulsePaint);

    // Inner solid dot
    final dotPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.08, dotPaint);

    // Center glow for pulse
    final centerGlowPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: opacity * 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawCircle(center, radius * 0.08 * scale, centerGlowPaint);
  }

  @override
  bool shouldRepaint(_JarvisSpinnerPainter oldDelegate) {
    return oldDelegate.outerRingRotation != outerRingRotation ||
        oldDelegate.middleRingRotation != middleRingRotation ||
        oldDelegate.innerRingRotation != innerRingRotation ||
        oldDelegate.pulseValue != pulseValue;
  }
}
