import 'package:flutter/material.dart';
import '../theme/jarvis_colors.dart';
import '../theme/jarvis_typography.dart';
import '../theme/jarvis_decorations.dart';

/// Jarvis Text Field Widget
///
/// Dark and white styled text fields following the Jarvis Design System.
class JarvisTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String? labelText;
  final String? errorText;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final VoidCallback? onTap;
  final bool readOnly;
  final int maxLines;
  final TextInputAction? textInputAction;
  final void Function(String)? onSubmitted;
  final void Function(String)? onChanged;
  final JarvisTextFieldVariant variant;
  final bool enabled;

  const JarvisTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.labelText,
    this.errorText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onTap,
    this.readOnly = false,
    this.maxLines = 1,
    this.textInputAction,
    this.onSubmitted,
    this.onChanged,
    this.variant = JarvisTextFieldVariant.dark,
    this.enabled = true,
  });

  /// Dark variant text field
  const JarvisTextField.dark({
    super.key,
    required this.controller,
    required this.hintText,
    this.labelText,
    this.errorText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onTap,
    this.readOnly = false,
    this.maxLines = 1,
    this.textInputAction,
    this.onSubmitted,
    this.onChanged,
    this.enabled = true,
  }) : variant = JarvisTextFieldVariant.dark;

  /// White variant text field (for sign up screens)
  const JarvisTextField.white({
    super.key,
    required this.controller,
    required this.hintText,
    this.labelText,
    this.errorText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onTap,
    this.readOnly = false,
    this.maxLines = 1,
    this.textInputAction,
    this.onSubmitted,
    this.onChanged,
    this.enabled = true,
  }) : variant = JarvisTextFieldVariant.white;

  @override
  State<JarvisTextField> createState() => _JarvisTextFieldState();
}

class _JarvisTextFieldState extends State<JarvisTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void didUpdateWidget(JarvisTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.obscureText != widget.obscureText) {
      _obscureText = widget.obscureText;
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Color get _backgroundColor {
    return widget.variant == JarvisTextFieldVariant.white
        ? JarvisColors.whiteBackground
        : JarvisColors.inputBackground;
  }

  Color get _textColor {
    return widget.variant == JarvisTextFieldVariant.white
        ? JarvisColors.textOnGold
        : JarvisColors.textPrimary;
  }

  Color get _hintColor {
    return widget.variant == JarvisTextFieldVariant.white
        ? JarvisColors.textTertiary
        : JarvisColors.textSecondary;
  }

  Color get _iconColor {
    if (!widget.enabled) {
      return JarvisColors.textTertiary;
    }
    if (_isFocused) {
      return JarvisColors.primaryGold;
    }
    return widget.variant == JarvisTextFieldVariant.white
        ? JarvisColors.textSecondary
        : JarvisColors.textSecondary;
  }

  BoxDecoration get _decoration {
    if (widget.errorText != null) {
      return JarvisDecorations.inputError(
        color: _backgroundColor,
      );
    }

    if (widget.variant == JarvisTextFieldVariant.white) {
      return JarvisDecorations.inputWhite(
        focused: _isFocused,
      );
    }

    return JarvisDecorations.input(
      color: _backgroundColor,
      focused: _isFocused,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!,
            style: JarvisTypography.labelMedium.copyWith(
              color: JarvisColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: _decoration,
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: _obscureText,
            keyboardType: widget.keyboardType,
            enabled: widget.enabled,
            style: JarvisTypography.bodyLarge.copyWith(
              color: _textColor,
            ),
            maxLines: widget.maxLines,
            textInputAction: widget.textInputAction,
            onFieldSubmitted: widget.onSubmitted,
            onChanged: widget.onChanged,
            readOnly: widget.readOnly,
            onTap: widget.onTap,
            validator: widget.validator,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: JarvisTypography.bodyLarge.copyWith(
                color: _hintColor,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      color: _iconColor,
                    )
                  : null,
              suffixIcon: _buildSuffixIcon(),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            widget.errorText!,
            style: JarvisTypography.bodySmall.copyWith(
              color: JarvisColors.error,
            ),
          ),
        ],
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    // Password visibility toggle
    if (widget.obscureText) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: _iconColor,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }

    return widget.suffixIcon;
  }
}

/// Text field variant enumeration
enum JarvisTextFieldVariant {
  /// Dark background variant
  dark,

  /// White background variant (for sign up screens)
  white,
}
