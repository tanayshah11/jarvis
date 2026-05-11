import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Onboarding state
class OnboardingState {
  final int currentPage;
  final bool isCompleted;

  const OnboardingState({
    this.currentPage = 0,
    this.isCompleted = false,
  });

  OnboardingState copyWith({
    int? currentPage,
    bool? isCompleted,
  }) {
    return OnboardingState(
      currentPage: currentPage ?? this.currentPage,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

/// Onboarding notifier
class OnboardingNotifier extends Notifier<OnboardingState> {
  @override
  OnboardingState build() {
    _loadOnboardingStatus();
    return const OnboardingState();
  }

  static const String _onboardingCompletedKey = 'onboarding_completed';

  /// Load onboarding completion status from SharedPreferences
  Future<void> _loadOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isCompleted = prefs.getBool(_onboardingCompletedKey) ?? false;
    state = state.copyWith(isCompleted: isCompleted);
  }

  /// Set the current page
  void setCurrentPage(int page) {
    state = state.copyWith(currentPage: page);
  }

  /// Mark onboarding as completed
  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompletedKey, true);
    state = state.copyWith(isCompleted: true);
  }

  /// Check if onboarding is completed
  Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingCompletedKey) ?? false;
  }

  /// Reset onboarding (for testing)
  Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_onboardingCompletedKey);
    state = const OnboardingState();
  }
}

/// Onboarding provider
final onboardingProvider = NotifierProvider<OnboardingNotifier, OnboardingState>(
  OnboardingNotifier.new,
);
