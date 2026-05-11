import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/widgets/jarvis_avatar.dart';
import '../../../data/data_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  bool _animationComplete = false;
  String _statusText = 'Initializing...';
  int _statusIndex = 0;

  // Bootup duration synced with Jarvis sound + small buffer
  static const _bootupDuration = Duration(seconds: 11);

  // Status messages with specific timing (in milliseconds) to match audio pacing
  // Format: [message, delay from start]
  static const List<(String, int)> _timedMessages = [
    ('Initializing...', 0),
    ('Loading neural networks...', 1500),
    ('Connecting to core systems...', 3200),
    ('Calibrating AI matrix...', 5000),
    ('Running diagnostics...', 6500),
    ('Systems online...', 8000),
    ('Ready to assist.', 9500),
  ];

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: _bootupDuration,
    );

    _progressController.forward();

    // Initialize DataService
    _initializeDataService();

    // Cycle through status messages during bootup
    _cycleStatusMessages();

    // Mark animation as complete after bootup sound finishes
    Future.delayed(_bootupDuration, () {
      if (mounted) {
        _animationComplete = true;
        _navigateIfReady();
      }
    });
  }

  void _cycleStatusMessages() {
    // Use specific timings to match the audio pacing
    for (int i = 0; i < _timedMessages.length; i++) {
      final (message, delay) = _timedMessages[i];
      Future.delayed(Duration(milliseconds: delay), () {
        if (mounted) {
          setState(() {
            _statusIndex = i;
            _statusText = message;
          });
        }
      });
    }
  }

  Future<void> _initializeDataService() async {
    try {
      final dataService = ref.read(dataServiceProvider);
      await dataService.initialize();
    } catch (e) {
      // Log error - initialization happens in background
      debugPrint('DataService initialization error: $e');
    }
  }

  void _navigateIfReady() {
    // Navigate to boot transition after bootup sequence completes
    if (_animationComplete && mounted) {
      context.go('/boot-transition');
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),

            // Gold orb
            const JarvisAvatar(size: 140)
                .animate()
                .fadeIn(duration: 800.ms)
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.0, 1.0),
                  duration: 800.ms,
                ),

            const SizedBox(height: AppSpacing.xl),

            // JARVIS text with letter spacing
            Text(
              'J A R V I S',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 32,
                fontWeight: FontWeight.w300,
                letterSpacing: 12,
              ),
            ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideY(
                  begin: 0.3,
                  end: 0,
                  duration: 600.ms,
                ),

            const SizedBox(height: AppSpacing.lg),

            // Status text that cycles during bootup
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.2),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: Text(
                _statusText,
                key: ValueKey<int>(_statusIndex),
                style: TextStyle(
                  color: AppColors.primary.withValues(alpha: 0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1,
                ),
              ),
            ).animate().fadeIn(delay: 1000.ms, duration: 400.ms),

            const Spacer(flex: 3),

            // Loading bar at bottom
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
              child: AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) {
                  return Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: LinearProgressIndicator(
                        value: _progressController.value,
                        backgroundColor: Colors.transparent,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),
                  );
                },
              ).animate().fadeIn(delay: 800.ms, duration: 400.ms),
            ),

            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }
}
