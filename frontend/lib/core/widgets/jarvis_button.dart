import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/jarvis_colors.dart';
import '../theme/jarvis_typography.dart';
import '../theme/jarvis_decorations.dart';
import 'animations/jarvis_spinner.dart';

/// Jarvis Button Widget
///
/// Primary and secondary button styles following the Jarvis Design System.
class JarvisButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final JarvisButtonVariant variant;
  final JarvisButtonSize size;
  final bool isLoading;
  final IconData? icon;
  final bool fullWidth;
  final bool enableHaptics;

  const JarvisButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = JarvisButtonVariant.primary,
    this.size = JarvisButtonSize.medium,
    this.isLoading = false,
    this.icon,
    this.fullWidth = false,
    this.enableHaptics = true,
  });

  /// Primary gold button (gold filled)
  const JarvisButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.size = JarvisButtonSize.medium,
    this.isLoading = false,
    this.icon,
    this.fullWidth = false,
    this.enableHaptics = true,
  }) : variant = JarvisButtonVariant.primary;

  /// Secondary button (dark with gold border)
  const JarvisButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.size = JarvisButtonSize.medium,
    this.isLoading = false,
    this.icon,
    this.fullWidth = false,
    this.enableHaptics = true,
  }) : variant = JarvisButtonVariant.secondary;

  /// Tertiary button (transparent)
  const JarvisButton.tertiary({
    super.key,
    required this.text,
    this.onPressed,
    this.size = JarvisButtonSize.medium,
    this.isLoading = false,
    this.icon,
    this.fullWidth = false,
    this.enableHaptics = true,
  }) : variant = JarvisButtonVariant.tertiary;

  /// Destructive button (red)
  const JarvisButton.destructive({
    super.key,
    required this.text,
    this.onPressed,
    this.size = JarvisButtonSize.medium,
    this.isLoading = false,
    this.icon,
    this.fullWidth = false,
    this.enableHaptics = true,
  }) : variant = JarvisButtonVariant.destructive;

  @override
  State<JarvisButton> createState() => _JarvisButtonState();
}

class _JarvisButtonState extends State<JarvisButton> {
  bool _isPressed = false;

  BoxDecoration get _decoration {
    final isDisabled = widget.onPressed == null;

    switch (widget.variant) {
      case JarvisButtonVariant.primary:
        return JarvisDecorations.buttonPrimaryGradient(disabled: isDisabled);
      case JarvisButtonVariant.secondary:
        return JarvisDecorations.buttonSecondary(disabled: isDisabled);
      case JarvisButtonVariant.tertiary:
        return JarvisDecorations.buttonTertiary();
      case JarvisButtonVariant.destructive:
        return JarvisDecorations.buttonDestructive(disabled: isDisabled);
    }
  }

  Color get _textColor {
    final isDisabled = widget.onPressed == null;

    switch (widget.variant) {
      case JarvisButtonVariant.primary:
        return isDisabled
            ? JarvisColors.textOnGold.withValues(alpha: 0.5)
            : JarvisColors.textOnGold;
      case JarvisButtonVariant.secondary:
        return isDisabled
            ? JarvisColors.textSecondary
            : JarvisColors.primaryGold;
      case JarvisButtonVariant.tertiary:
        return isDisabled
            ? JarvisColors.textSecondary
            : JarvisColors.primaryGold;
      case JarvisButtonVariant.destructive:
        return isDisabled
            ? JarvisColors.textPrimary.withValues(alpha: 0.5)
            : JarvisColors.textPrimary;
    }
  }

  TextStyle get _textStyle {
    switch (widget.size) {
      case JarvisButtonSize.small:
        return JarvisTypography.buttonSmall;
      case JarvisButtonSize.medium:
        return JarvisTypography.buttonMedium;
      case JarvisButtonSize.large:
        return JarvisTypography.buttonLarge;
    }
  }

  EdgeInsets get _padding {
    switch (widget.size) {
      case JarvisButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case JarvisButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
      case JarvisButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 20);
    }
  }

  double get _iconSize {
    switch (widget.size) {
      case JarvisButtonSize.small:
        return 16;
      case JarvisButtonSize.medium:
        return 20;
      case JarvisButtonSize.large:
        return 24;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null;

    return GestureDetector(
      onTapDown: isDisabled
          ? null
          : (_) {
              setState(() => _isPressed = true);
            },
      onTapUp: isDisabled
          ? null
          : (_) {
              setState(() => _isPressed = false);
            },
      onTapCancel: isDisabled
          ? null
          : () {
              setState(() => _isPressed = false);
            },
      onTap: widget.isLoading || isDisabled
          ? null
          : () {
              if (widget.enableHaptics) {
                HapticFeedback.lightImpact();
              }
              widget.onPressed?.call();
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.diagonal3Values(
          _isPressed ? 0.98 : 1.0,
          _isPressed ? 0.98 : 1.0,
          1.0,
        ),
        padding: _padding,
        decoration: _decoration,
        child: widget.fullWidth
            ? Center(child: _buildContent())
            : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (widget.isLoading) {
      return SizedBox(
        height: _iconSize,
        width: _iconSize,
        child: JarvisSpinner(
          size: _iconSize,
          strokeWidth: 1.5,
        ),
      );
    }

    return Row(
      mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, size: _iconSize, color: _textColor),
          const SizedBox(width: 8),
        ],
        Text(widget.text, style: _textStyle.copyWith(color: _textColor)),
      ],
    );
  }
}

/// Button variant enumeration
enum JarvisButtonVariant {
  /// Primary gold button
  primary,

  /// Secondary button with gold border
  secondary,

  /// Tertiary transparent button
  tertiary,

  /// Destructive red button
  destructive,
}

/// Button size enumeration
enum JarvisButtonSize {
  /// Small button
  small,

  /// Medium button (default)
  medium,

  /// Large button
  large,
}
