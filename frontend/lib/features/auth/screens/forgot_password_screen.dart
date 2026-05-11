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

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendResetLink() async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(passwordResetProvider.notifier);
    final success = await notifier.sendResetLink(_emailController.text);

    if (!success && mounted) {
      final error = ref.read(passwordResetProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Failed to send reset link'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final resetState = ref.watch(passwordResetProvider);
    final isLoading = resetState.status == PasswordResetStatus.sending;
    final emailSent = resetState.status == PasswordResetStatus.sent;

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

              // Lock icon with AnimatedContent
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
                    Icons.lock_outline,
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
                  'Reset Password',
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
                  'Enter your email address and we\'ll send you a link to reset your password.',
                  style: AppTypography.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: AppSpacing.xxxl),

              if (!emailSent) ...[
                // Email input form with staggered animations
                Form(
                  key: _formKey,
                  child: StaggeredAnimatedContent(
                    startDelay: const Duration(milliseconds: 300),
                    itemDelay: const Duration(milliseconds: 100),
                    itemDuration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
                    children: [
                      JarvisTextField(
                        controller: _emailController,
                        hintText: 'Email',
                        prefixIcon: Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _handleSendResetLink(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: AppSpacing.xxl),

                      // Send Reset Link button with ScaleOnPress
                      ScaleOnPress(
                        onPressed: _handleSendResetLink,
                        child: JarvisButton(
                          text: 'Send Reset Link',
                          onPressed: isLoading ? null : _handleSendResetLink,
                          isLoading: isLoading,
                          fullWidth: true,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // Back to Sign In link
                      Center(
                        child: GestureDetector(
                          onTap: () => context.pop(),
                          child: Text(
                            'Back to Sign In',
                            style: AppTypography.textTheme.bodyMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Success message with AnimatedContent
                AnimatedContent(
                  delay: Duration.zero,
                  duration: const Duration(milliseconds: 400),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          size: 64,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'Check Your Email',
                          style: AppTypography.textTheme.titleLarge?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'We\'ve sent a password reset link to ${_emailController.text}',
                          style: AppTypography.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),

                // Back to Sign In button with animations
                AnimatedContent(
                  delay: const Duration(milliseconds: 100),
                  duration: const Duration(milliseconds: 400),
                  child: ScaleOnPress(
                    onPressed: () => context.pop(),
                    child: JarvisButton.secondary(
                      text: 'Back to Sign In',
                      onPressed: () => context.pop(),
                      fullWidth: true,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
