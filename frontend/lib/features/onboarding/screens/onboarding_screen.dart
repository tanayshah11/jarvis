import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/animations.dart';
import '../../../core/widgets/jarvis_button.dart';
import '../../../core/widgets/animated_content.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/page_indicator.dart';
import '../widgets/welcome_page.dart';
import '../widgets/memory_page.dart';
import '../widgets/integrations_page.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    ref.read(onboardingProvider.notifier).setCurrentPage(page);
    HapticFeedback.selectionClick();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: AppAnimations.medium,
        curve: AppAnimations.defaultCurve,
      );
    }
  }

  void _skipToEnd() {
    _pageController.animateToPage(
      2,
      duration: AppAnimations.medium,
      curve: AppAnimations.defaultCurve,
    );
  }

  Future<void> _handleGetStarted() async {
    HapticFeedback.mediumImpact();
    await ref.read(onboardingProvider.notifier).completeOnboarding();
    if (mounted) {
      context.go('/chat');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with skip button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.lg,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Spacer for alignment
                  const SizedBox(width: 60),

                  // Page indicators
                  PageIndicator(currentPage: _currentPage, pageCount: 3),

                  // Skip button
                  if (_currentPage < 2)
                    GestureDetector(
                      onTap: _skipToEnd,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 60),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            // PageView with 3 pages
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                physics: const BouncingScrollPhysics(),
                children: const [
                  WelcomePage(),
                  MemoryPage(),
                  IntegrationsPage(),
                ],
              ),
            ),

            // Bottom button
            Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: SizedBox(
                    width: double.infinity,
                    child: ScaleOnPress(
                      onPressed: _currentPage < 2
                          ? _nextPage
                          : _handleGetStarted,
                      child: JarvisButton(
                        text: _currentPage < 2 ? 'Continue' : 'Get Started',
                        onPressed: _currentPage < 2
                            ? _nextPage
                            : _handleGetStarted,
                        fullWidth: true,
                      ),
                    ),
                  ),
                )
                .animate()
                .fadeIn(delay: 200.ms, duration: 400.ms)
                .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic),
          ],
        ),
      ),
    );
  }
}
