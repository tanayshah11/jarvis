import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../profile/profile_model.dart';

/// Privacy settings (stored locally on-device)
class PrivacySettings {
  final bool enableMemoryExtraction;
  final bool enableAnonymization;

  const PrivacySettings({
    this.enableMemoryExtraction = true,
    this.enableAnonymization = true, // Default to true for privacy-first
  });

  PrivacySettings copyWith({
    bool? enableMemoryExtraction,
    bool? enableAnonymization,
  }) {
    return PrivacySettings(
      enableMemoryExtraction: enableMemoryExtraction ?? this.enableMemoryExtraction,
      enableAnonymization: enableAnonymization ?? this.enableAnonymization,
    );
  }
}

/// AI settings (stored locally on-device)
class AiSettings {
  final AiProvider aiProvider;
  final double creativity;
  final ResponseLength responseLength;

  const AiSettings({
    this.aiProvider = AiProvider.groq,
    this.creativity = 0.7,
    this.responseLength = ResponseLength.medium,
  });

  AiSettings copyWith({
    AiProvider? aiProvider,
    double? creativity,
    ResponseLength? responseLength,
  }) {
    return AiSettings(
      aiProvider: aiProvider ?? this.aiProvider,
      creativity: creativity ?? this.creativity,
      responseLength: responseLength ?? this.responseLength,
    );
  }
}

/// Settings state class
class SettingsState {
  final bool notificationsEnabled;
  final String notificationMode; // "All", "Priority Only", "Off"
  final PrivacySettings privacy;
  final AiSettings ai;

  const SettingsState({
    this.notificationsEnabled = true,
    this.notificationMode = 'Priority Only',
    this.privacy = const PrivacySettings(),
    this.ai = const AiSettings(),
  });

  SettingsState copyWith({
    bool? notificationsEnabled,
    String? notificationMode,
    PrivacySettings? privacy,
    AiSettings? ai,
  }) {
    return SettingsState(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationMode: notificationMode ?? this.notificationMode,
      privacy: privacy ?? this.privacy,
      ai: ai ?? this.ai,
    );
  }
}

/// SharedPreferences provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized in main()');
});

/// Settings provider
final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(() {
  return SettingsNotifier();
});

/// Settings notifier - all settings stored locally on-device
class SettingsNotifier extends Notifier<SettingsState> {
  late SharedPreferences _prefs;

  // SharedPreferences keys
  static const _keyNotificationsEnabled = 'notifications_enabled';
  static const _keyNotificationMode = 'notification_mode';
  static const _keyMemoryExtraction = 'privacy_memory_extraction';
  static const _keyAnonymization = 'privacy_anonymization';
  static const _keyAiProvider = 'ai_provider';
  static const _keyCreativity = 'ai_creativity';
  static const _keyResponseLength = 'ai_response_length';

  @override
  SettingsState build() {
    _prefs = ref.watch(sharedPreferencesProvider);
    // Load settings synchronously from SharedPreferences
    return _loadSettingsSync();
  }

  /// Load all settings from SharedPreferences synchronously
  SettingsState _loadSettingsSync() {
    final notificationsEnabled = _prefs.getBool(_keyNotificationsEnabled) ?? true;
    final notificationMode = _prefs.getString(_keyNotificationMode) ?? 'Priority Only';

    // Privacy settings
    final enableMemoryExtraction = _prefs.getBool(_keyMemoryExtraction) ?? true;
    final enableAnonymization = _prefs.getBool(_keyAnonymization) ?? true;

    // AI settings
    final aiProviderStr = _prefs.getString(_keyAiProvider);
    final aiProvider = AiProvider.fromString(aiProviderStr);
    final creativity = _prefs.getDouble(_keyCreativity) ?? 0.7;
    final responseLengthStr = _prefs.getString(_keyResponseLength);
    final responseLength = ResponseLength.fromString(responseLengthStr);

    return SettingsState(
      notificationsEnabled: notificationsEnabled,
      notificationMode: notificationMode,
      privacy: PrivacySettings(
        enableMemoryExtraction: enableMemoryExtraction,
        enableAnonymization: enableAnonymization,
      ),
      ai: AiSettings(
        aiProvider: aiProvider,
        creativity: creativity,
        responseLength: responseLength,
      ),
    );
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs.setBool(_keyNotificationsEnabled, enabled);
    state = state.copyWith(notificationsEnabled: enabled);
  }

  Future<void> setNotificationMode(String mode) async {
    await _prefs.setString(_keyNotificationMode, mode);
    state = state.copyWith(notificationMode: mode);
  }

  /// Update memory extraction setting (local only)
  Future<void> setMemoryExtractionEnabled(bool enabled) async {
    await _prefs.setBool(_keyMemoryExtraction, enabled);
    state = state.copyWith(
      privacy: state.privacy.copyWith(enableMemoryExtraction: enabled),
    );
  }

  /// Update anonymization setting (local only)
  Future<void> setAnonymizationEnabled(bool enabled) async {
    await _prefs.setBool(_keyAnonymization, enabled);
    state = state.copyWith(
      privacy: state.privacy.copyWith(enableAnonymization: enabled),
    );
  }

  /// Update AI provider (local only)
  Future<void> setAiProvider(AiProvider provider) async {
    await _prefs.setString(_keyAiProvider, provider.value);
    state = state.copyWith(
      ai: state.ai.copyWith(aiProvider: provider),
    );
  }

  /// Update creativity setting (local only)
  Future<void> setCreativity(double creativity) async {
    await _prefs.setDouble(_keyCreativity, creativity);
    state = state.copyWith(
      ai: state.ai.copyWith(creativity: creativity),
    );
  }

  /// Update response length setting (local only)
  Future<void> setResponseLength(ResponseLength responseLength) async {
    await _prefs.setString(_keyResponseLength, responseLength.value);
    state = state.copyWith(
      ai: state.ai.copyWith(responseLength: responseLength),
    );
  }
}
