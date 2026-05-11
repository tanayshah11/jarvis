import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/jarvis_text_field.dart';
import '../../../core/widgets/jarvis_button.dart';
import '../../../core/widgets/animated_content.dart';
import '../providers/password_reset_provider.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String? token;

  const ResetPasswordScreen({super.key, this.token});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _passwordsMatch = false;

  // Password requirements
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_updatePasswordRequirements);
    _confirmPasswordController.addListener(_checkPasswordsMatch);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _updatePasswordRequirements() {
    final password = _passwordController.text;
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
      _hasNumber = RegExp(r'[0-9]').hasMatch(password);
      _hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
    });
    _checkPasswordsMatch();
  }

  void _checkPasswordsMatch() {
    setState(() {
      _passwordsMatch = _passwordController.text.isNotEmpty &&
          _confirmPasswordController.text.isNotEmpty &&
          _passwordController.text == _confirmPasswordController.text;
    });
  }

  bool get _allRequirementsMet =>
      _hasMinLength && _hasUppercase && _hasNumber && _hasSpecialChar;

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_allRequirementsMet) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please meet all password requirements'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (widget.token == null || widget.token!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid reset token'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final notifier = ref.read(passwordResetProvider.notifier);
    final success = await notifier.resetPassword(
      widget.token!,
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      // Show success message
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.surfaceLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          title: const Icon(
            Icons.check_circle_outline,
            size: 64,
            color: AppColors.primary,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Password Reset Successful',
                style: AppTypography.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Your password has been successfully reset. You can now sign in with your new password.',
                style: AppTypography.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            JarvisButton(
              text: 'Sign In',
              onPressed: () {
                context.go('/login');
              },
              fullWidth: true,
            ),
          ],
        ),
      );
    } else {
      final error = ref.read(passwordResetProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Failed to reset password'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final resetState = ref.watch(passwordResetProvider);
    final isLoading = resetState.status == PasswordResetStatus.resetting;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: AppColors.primary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.xxxl),

              // Key icon with AnimatedContent
              AnimatedContent(
                delay: Duration.zero,
                duration: const Duration(milliseconds: 400),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surfaceLight,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.key,
                    size: 48,
                    color: AppColors.primary,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xxxl),

              // Title
              AnimatedContent(
                delay: const Duration(milliseconds: 100),
                duration: const Duration(milliseconds: 400),
                child: Text(
                  'Create New Password',
                  style: AppTypography.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Description
              AnimatedContent(
                delay: const Duration(milliseconds: 200),
                duration: const Duration(milliseconds: 400),
                child: Text(
                  'Your new password must be different from previously used passwords.',
                  style: AppTypography.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: AppSpacing.xxxl),

              // Form with staggered animations
              Form(
                key: _formKey,
                child: StaggeredAnimatedContent(
                  startDelay: const Duration(milliseconds: 300),
                  itemDelay: const Duration(milliseconds: 100),
                  itemDuration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  children: [
                    // New password input
                    JarvisTextField(
                      controller: _passwordController,
                      hintText: 'New password',
                      prefixIcon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (!_allRequirementsMet) {
                          return 'Please meet all password requirements';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Password requirements checklist
                    _PasswordRequirementsChecklist(
                      hasMinLength: _hasMinLength,
                      hasUppercase: _hasUppercase,
                      hasNumber: _hasNumber,
                      hasSpecialChar: _hasSpecialChar,
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Confirm password input
                    JarvisTextField(
                      controller: _confirmPasswordController,
                      hintText: 'Confirm new password',
                      prefixIcon: Icons.lock_outline,
                      obscureText: _obscureConfirmPassword,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _handleResetPassword(),
                      suffixIcon: _passwordsMatch
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.textSecondary,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                            ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppSpacing.xxxl),

                    // Reset Password button with ScaleOnPress
                    ScaleOnPress(
                      onPressed: _handleResetPassword,
                      child: JarvisButton(
                        text: 'Reset Password',
                        onPressed: isLoading ? null : _handleResetPassword,
                        isLoading: isLoading,
                        fullWidth: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PasswordRequirementsChecklist extends StatelessWidget {
  final bool hasMinLength;
  final bool hasUppercase;
  final bool hasNumber;
  final bool hasSpecialChar;

  const _PasswordRequirementsChecklist({
    required this.hasMinLength,
    required this.hasUppercase,
    required this.hasNumber,
    required this.hasSpecialChar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password must contain:',
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _RequirementItem(
            text: 'At least 8 characters',
            isMet: hasMinLength,
          ),
          const SizedBox(height: AppSpacing.sm),
          _RequirementItem(
            text: 'One uppercase letter',
            isMet: hasUppercase,
          ),
          const SizedBox(height: AppSpacing.sm),
          _RequirementItem(
            text: 'One number',
            isMet: hasNumber,
          ),
          const SizedBox(height: AppSpacing.sm),
          _RequirementItem(
            text: 'One special character',
            isMet: hasSpecialChar,
          ),
        ],
      ),
    );
  }
}

class _RequirementItem extends StatelessWidget {
  final String text;
  final bool isMet;

  const _RequirementItem({
    required this.text,
    required this.isMet,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.cancel,
          size: 20,
          color: isMet ? AppColors.primary : AppColors.textMuted,
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          text,
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: isMet ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: isMet ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
