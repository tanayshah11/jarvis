import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/colors.dart';

/// GoldSwitch Widget
///
/// Custom toggle switch with gold accent when on, featuring smooth
/// spring animation and optional glow effect when active.
class GoldSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;
  final bool showLabel;
  final bool enableHaptics;
  final bool enabled;
  final double width;
  final double height;

  const GoldSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.showLabel = true,
    this.enableHaptics = true,
    this.enabled = true,
    this.width = 52.0,
    this.height = 28.0,
  });

  @override
  State<GoldSwitch> createState() => _GoldSwitchState();
}

class _GoldSwitchState extends State<GoldSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _thumbAnimation;
  late Animation<double> _glowAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _thumbAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    if (widget.value) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(GoldSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      if (widget.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.enabled || widget.onChanged == null) return;

    if (widget.enableHaptics) {
      HapticFeedback.lightImpact();
    }

    widget.onChanged!(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showLabel && widget.label != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.label!,
            style: TextStyle(
              color: widget.enabled
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
          _buildSwitch(),
        ],
      );
    }

    return _buildSwitch();
  }

  Widget _buildSwitch() {
    return GestureDetector(
      onTapDown: widget.enabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: widget.enabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: widget.enabled ? () => setState(() => _isPressed = false) : null,
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            transform: Matrix4.diagonal3Values(
              _isPressed ? 0.95 : 1.0,
              _isPressed ? 0.95 : 1.0,
              1.0,
            ),
            child: _SwitchTrack(
              value: widget.value,
              enabled: widget.enabled,
              thumbAnimation: _thumbAnimation,
              glowAnimation: _glowAnimation,
              width: widget.width,
              height: widget.height,
            ),
          );
        },
      ),
    );
  }
}

/// Switch track container with animated background
class _SwitchTrack extends StatelessWidget {
  final bool value;
  final bool enabled;
  final Animation<double> thumbAnimation;
  final Animation<double> glowAnimation;
  final double width;
  final double height;

  const _SwitchTrack({
    required this.value,
    required this.enabled,
    required this.thumbAnimation,
    required this.glowAnimation,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final Color trackColor = enabled
        ? (value ? AppColors.primary : AppColors.surfaceLight)
        : AppColors.surface;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: trackColor,
        borderRadius: BorderRadius.circular(height / 2),
        border: Border.all(
          color: enabled && value
              ? AppColors.accentLight.withValues(alpha: 0.5)
              : AppColors.surfaceLight.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: enabled && value
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: glowAnimation.value * 0.4),
                  blurRadius: 12 * glowAnimation.value,
                  spreadRadius: 2 * glowAnimation.value,
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          // Animated gradient overlay when active
          if (enabled && value)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: glowAnimation.value * 0.3,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accentLight.withValues(alpha: 0.3),
                      AppColors.primary.withValues(alpha: 0.1),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(height / 2),
                ),
              ),
            ),
          // Thumb
          _SwitchThumb(
            value: value,
            enabled: enabled,
            thumbAnimation: thumbAnimation,
            trackWidth: width,
            trackHeight: height,
          ),
        ],
      ),
    );
  }
}

/// Switch thumb with smooth animation
class _SwitchThumb extends StatelessWidget {
  final bool value;
  final bool enabled;
  final Animation<double> thumbAnimation;
  final double trackWidth;
  final double trackHeight;

  const _SwitchThumb({
    required this.value,
    required this.enabled,
    required this.thumbAnimation,
    required this.trackWidth,
    required this.trackHeight,
  });

  @override
  Widget build(BuildContext context) {
    final double thumbSize = trackHeight - 6;
    final double thumbPadding = 3.0;
    final double maxOffset = trackWidth - thumbSize - (thumbPadding * 2);

    return AnimatedBuilder(
      animation: thumbAnimation,
      builder: (context, child) {
        final double offset = thumbAnimation.value * maxOffset;

        return Positioned(
          left: thumbPadding + offset,
          top: thumbPadding,
          child: Container(
            width: thumbSize,
            height: thumbSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: enabled && value
                  ? RadialGradient(
                      colors: [
                        AppColors.accentLight,
                        AppColors.primary,
                        AppColors.primaryDark,
                      ],
                      stops: const [0.0, 0.6, 1.0],
                    )
                  : null,
              color: enabled && !value
                  ? AppColors.textSecondary
                  : (enabled ? null : AppColors.textMuted),
              boxShadow: [
                BoxShadow(
                  color: enabled && value
                      ? AppColors.primary.withValues(alpha: 0.3)
                      : Colors.black.withValues(alpha: 0.2),
                  blurRadius: enabled && value ? 8 : 4,
                  spreadRadius: enabled && value ? 1 : 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: enabled && value
                ? Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.4),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.7],
                        center: const Alignment(-0.3, -0.3),
                      ),
                    ),
                  )
                : null,
          ),
        );
      },
    );
  }
}
