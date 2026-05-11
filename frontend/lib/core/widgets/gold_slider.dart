import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/colors.dart';

/// GoldSlider Widget
///
/// Custom slider with gold track and thumb, featuring a glow effect
/// on the active portion and optional labels below.
class GoldSlider extends StatefulWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onChangeStart;
  final ValueChanged<double>? onChangeEnd;
  final double min;
  final double max;
  final int? divisions;
  final bool showLabels;
  final List<String>? labels;
  final bool enableHaptics;
  final double height;
  final bool enabled;

  const GoldSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.showLabels = false,
    this.labels,
    this.enableHaptics = true,
    this.height = 4.0,
    this.enabled = true,
  });

  @override
  State<GoldSlider> createState() => _GoldSliderState();
}

class _GoldSliderState extends State<GoldSlider>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(
        parent: _glowController,
        curve: Curves.easeInOut,
      ),
    );
    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void _handleChangeStart(double value) {
    if (!widget.enabled) return;
    setState(() => _isDragging = true);
    if (widget.enableHaptics) {
      HapticFeedback.lightImpact();
    }
    widget.onChangeStart?.call(value);
  }

  void _handleChange(double value) {
    if (!widget.enabled) return;
    widget.onChanged(value);
  }

  void _handleChangeEnd(double value) {
    if (!widget.enabled) return;
    setState(() => _isDragging = false);
    if (widget.enableHaptics) {
      HapticFeedback.mediumImpact();
    }
    widget.onChangeEnd?.call(value);
  }

  List<String> get _displayLabels {
    if (widget.labels != null) {
      return widget.labels!;
    }
    return ['Low', 'Med', 'High'];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 48,
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: widget.height,
              thumbShape: _GoldThumbShape(
                isDragging: _isDragging,
                enabled: widget.enabled,
              ),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 0),
              activeTrackColor: Colors.transparent,
              inactiveTrackColor: Colors.transparent,
              thumbColor: Colors.transparent,
              trackShape: _GoldTrackShape(
                glowAnimation: _glowAnimation,
                enabled: widget.enabled,
              ),
            ),
            child: Slider(
              value: widget.value.clamp(widget.min, widget.max),
              min: widget.min,
              max: widget.max,
              divisions: widget.divisions,
              onChangeStart: _handleChangeStart,
              onChanged: widget.enabled ? _handleChange : null,
              onChangeEnd: _handleChangeEnd,
            ),
          ),
        ),
        if (widget.showLabels) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _displayLabels.map((label) {
              return Text(
                label,
                style: TextStyle(
                  color: widget.enabled
                      ? AppColors.textSecondary
                      : AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

/// Custom track shape with gold glow effect
class _GoldTrackShape extends RoundedRectSliderTrackShape {
  final Animation<double> glowAnimation;
  final bool enabled;

  const _GoldTrackShape({
    required this.glowAnimation,
    required this.enabled,
  });

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = true,
    double additionalActiveTrackHeight = 0.0,
  }) {
    final Canvas canvas = context.canvas;
    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final double trackHeight = sliderTheme.trackHeight ?? 4.0;
    final Rect activeRect = Rect.fromLTRB(
      trackRect.left,
      trackRect.top,
      thumbCenter.dx,
      trackRect.bottom,
    );
    final Rect inactiveRect = Rect.fromLTRB(
      thumbCenter.dx,
      trackRect.top,
      trackRect.right,
      trackRect.bottom,
    );

    // Inactive track (dark gray)
    final inactivePaint = Paint()
      ..color = enabled
          ? AppColors.surfaceLight.withValues(alpha: 0.5)
          : AppColors.surface.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        inactiveRect,
        Radius.circular(trackHeight / 2),
      ),
      inactivePaint,
    );

    if (!enabled) {
      // Disabled active track (muted gold)
      final disabledPaint = Paint()
        ..color = AppColors.primary.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          activeRect,
          Radius.circular(trackHeight / 2),
        ),
        disabledPaint,
      );
      return;
    }

    // Active track glow effect
    final glowPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: glowAnimation.value * 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        activeRect.inflate(4),
        Radius.circular(trackHeight / 2 + 4),
      ),
      glowPaint,
    );

    // Active track (gold)
    final activePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.accentLight,
          AppColors.primary,
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(activeRect)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        activeRect,
        Radius.circular(trackHeight / 2),
      ),
      activePaint,
    );
  }
}

/// Custom thumb shape with gold color and scaling animation
class _GoldThumbShape extends SliderComponentShape {
  final bool isDragging;
  final bool enabled;

  const _GoldThumbShape({
    required this.isDragging,
    required this.enabled,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size.fromRadius(12.0);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;
    const double thumbRadius = 12.0;
    final double effectiveRadius =
        thumbRadius * (isDragging ? 1.2 : 1.0) * enableAnimation.value;

    if (!enabled) {
      // Disabled thumb
      final disabledPaint = Paint()
        ..color = AppColors.primary.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, effectiveRadius, disabledPaint);
      return;
    }

    // Thumb shadow/glow
    final glowPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: isDragging ? 0.4 : 0.2)
      ..maskFilter = MaskFilter.blur(
        BlurStyle.normal,
        isDragging ? 12 : 8,
      );

    canvas.drawCircle(center, effectiveRadius + 4, glowPaint);

    // Thumb gradient
    final thumbPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.accentLight,
          AppColors.primary,
          AppColors.primaryDark,
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: effectiveRadius))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, effectiveRadius, thumbPaint);

    // Thumb highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(center.dx - effectiveRadius * 0.3, center.dy - effectiveRadius * 0.3),
      effectiveRadius * 0.4,
      highlightPaint,
    );

    // Thumb border
    final borderPaint = Paint()
      ..color = AppColors.accentLight.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(center, effectiveRadius, borderPaint);
  }
}
