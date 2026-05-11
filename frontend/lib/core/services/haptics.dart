import 'package:flutter/services.dart';

/// Haptic feedback service for premium tactile interactions
class AppHaptics {
  const AppHaptics._();

  /// Light tap feedback - for button presses, selections
  static Future<void> lightTap() async {
    await HapticFeedback.lightImpact();
  }

  /// Medium impact - for send message, confirmations
  static Future<void> mediumImpact() async {
    await HapticFeedback.mediumImpact();
  }

  /// Heavy impact - for important actions, deletions
  static Future<void> heavyImpact() async {
    await HapticFeedback.heavyImpact();
  }

  /// Selection changed - for toggles, pickers, pull-to-refresh
  static Future<void> selectionClick() async {
    await HapticFeedback.selectionClick();
  }

  /// Success feedback - for completed actions
  static Future<void> success() async {
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
  }

  /// Error feedback - for failed actions
  static Future<void> error() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.heavyImpact();
  }

  /// Warning feedback - for cautionary actions
  static Future<void> warning() async {
    await HapticFeedback.mediumImpact();
  }

  /// Vibrate - for critical notifications
  static Future<void> vibrate() async {
    await HapticFeedback.vibrate();
  }

  /// Soft tap - subtle feedback for scrolling, hovering
  static Future<void> softTap() async {
    await HapticFeedback.selectionClick();
  }

  /// Button press feedback
  static Future<void> buttonPress() async {
    await HapticFeedback.lightImpact();
  }

  /// Button release feedback
  static Future<void> buttonRelease() async {
    await HapticFeedback.selectionClick();
  }

  /// Send message feedback
  static Future<void> sendMessage() async {
    await HapticFeedback.mediumImpact();
  }

  /// Receive message feedback
  static Future<void> receiveMessage() async {
    await HapticFeedback.lightImpact();
  }

  /// Pull to refresh started
  static Future<void> pullToRefreshStart() async {
    await HapticFeedback.selectionClick();
  }

  /// Pull to refresh triggered
  static Future<void> pullToRefreshTrigger() async {
    await HapticFeedback.mediumImpact();
  }

  /// Long press started
  static Future<void> longPressStart() async {
    await HapticFeedback.selectionClick();
  }

  /// Slider tick
  static Future<void> sliderTick() async {
    await HapticFeedback.selectionClick();
  }

  /// Tab change
  static Future<void> tabChange() async {
    await HapticFeedback.lightImpact();
  }

  /// Page transition
  static Future<void> pageTransition() async {
    await HapticFeedback.selectionClick();
  }

  /// Swipe action
  static Future<void> swipeAction() async {
    await HapticFeedback.mediumImpact();
  }

  /// Delete action
  static Future<void> deleteAction() async {
    await HapticFeedback.heavyImpact();
  }
}

/// Extension to easily add haptics to GestureDetector callbacks
extension HapticGestureExtension on VoidCallback {
  VoidCallback withHaptic(Future<void> Function() haptic) {
    return () {
      haptic();
      this();
    };
  }
}
