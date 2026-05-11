import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../theme/colors.dart';

/// Animated particle field that orbits around a central point
/// Creates a premium, living feel around the Jarvis avatar
class ParticleField extends StatefulWidget {
  final double size;
  final int particleCount;
  final Color? color;

  const ParticleField({
    super.key,
    required this.size,
    this.particleCount = 12,
    this.color,
  });

  @override
  State<ParticleField> createState() => _ParticleFieldState();
}

class _ParticleFieldState extends State<ParticleField>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _particles = List.generate(widget.particleCount, (index) {
      return _Particle(
        angle: (index * 2 * math.pi / widget.particleCount) +
            _random.nextDouble() * 0.5,
        radius: widget.size / 2 + 20 + _random.nextDouble() * 30,
        speed: 0.3 + _random.nextDouble() * 0.4,
        size: 2 + _random.nextDouble() * 4,
        opacity: 0.3 + _random.nextDouble() * 0.5,
        pulseOffset: _random.nextDouble() * math.pi * 2,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size + 100, widget.size + 100),
          painter: _ParticlePainter(
            particles: _particles,
            progress: _controller.value,
            color: widget.color ?? AppColors.primary,
            centerOffset: Offset(
              (widget.size + 100) / 2,
              (widget.size + 100) / 2,
            ),
          ),
        );
      },
    );
  }
}

class _Particle {
  final double angle;
  final double radius;
  final double speed;
  final double size;
  final double opacity;
  final double pulseOffset;

  _Particle({
    required this.angle,
    required this.radius,
    required this.speed,
    required this.size,
    required this.opacity,
    required this.pulseOffset,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final Color color;
  final Offset centerOffset;

  _ParticlePainter({
    required this.particles,
    required this.progress,
    required this.color,
    required this.centerOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      // Calculate current position
      final currentAngle = particle.angle + (progress * 2 * math.pi * particle.speed);
      final x = centerOffset.dx + math.cos(currentAngle) * particle.radius;
      final y = centerOffset.dy + math.sin(currentAngle) * particle.radius;

      // Pulse effect
      final pulse = (math.sin(progress * math.pi * 4 + particle.pulseOffset) + 1) / 2;
      final currentSize = particle.size * (0.7 + pulse * 0.3);
      final currentOpacity = particle.opacity * (0.5 + pulse * 0.5);

      // Draw glow
      final glowPaint = Paint()
        ..color = color.withValues(alpha: currentOpacity * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(Offset(x, y), currentSize * 2, glowPaint);

      // Draw particle
      final paint = Paint()
        ..color = color.withValues(alpha: currentOpacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), currentSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Floating particles that drift upward
class FloatingParticles extends StatefulWidget {
  final double width;
  final double height;
  final int particleCount;
  final Color? color;

  const FloatingParticles({
    super.key,
    required this.width,
    required this.height,
    this.particleCount = 20,
    this.color,
  });

  @override
  State<FloatingParticles> createState() => _FloatingParticlesState();
}

class _FloatingParticlesState extends State<FloatingParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_FloatingParticle> _particles;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _particles = List.generate(widget.particleCount, (index) {
      return _FloatingParticle(
        x: _random.nextDouble() * widget.width,
        startY: _random.nextDouble() * widget.height,
        speed: 0.5 + _random.nextDouble() * 0.5,
        size: 1.5 + _random.nextDouble() * 2.5,
        opacity: 0.2 + _random.nextDouble() * 0.4,
        drift: (_random.nextDouble() - 0.5) * 20,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.width, widget.height),
          painter: _FloatingParticlePainter(
            particles: _particles,
            progress: _controller.value,
            color: widget.color ?? AppColors.primary,
            height: widget.height,
          ),
        );
      },
    );
  }
}

class _FloatingParticle {
  final double x;
  final double startY;
  final double speed;
  final double size;
  final double opacity;
  final double drift;

  _FloatingParticle({
    required this.x,
    required this.startY,
    required this.speed,
    required this.size,
    required this.opacity,
    required this.drift,
  });
}

class _FloatingParticlePainter extends CustomPainter {
  final List<_FloatingParticle> particles;
  final double progress;
  final Color color;
  final double height;

  _FloatingParticlePainter({
    required this.particles,
    required this.progress,
    required this.color,
    required this.height,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      // Calculate Y position (moving upward)
      final yOffset = (progress * particle.speed * height) % height;
      var y = particle.startY - yOffset;
      if (y < 0) y += height;

      // Calculate X with slight drift
      final x = particle.x + math.sin(progress * math.pi * 2 + particle.startY) * particle.drift;

      // Fade out at top
      final fadeZone = height * 0.2;
      var fadeOpacity = particle.opacity;
      if (y < fadeZone) {
        fadeOpacity *= y / fadeZone;
      }

      // Draw particle with glow
      final glowPaint = Paint()
        ..color = color.withValues(alpha: fadeOpacity * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(Offset(x, y), particle.size * 1.5, glowPaint);

      final paint = Paint()
        ..color = color.withValues(alpha: fadeOpacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FloatingParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
