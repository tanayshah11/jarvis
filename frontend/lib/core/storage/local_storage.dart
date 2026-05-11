import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final localStorageProvider = Provider<LocalStorage>((ref) {
  return LocalStorage();
});

class LocalStorage {
  static const String _profileKey = 'user_profile';
  static const String _settingsPrefix = 'setting_';

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  Future<void> init() async {
    // No initialization needed for flutter_secure_storage
  }

  // Profile methods
  Future<void> saveProfile(Map<String, dynamic> profile) async {
    final profileJson = jsonEncode(profile);
    await _storage.write(key: _profileKey, value: profileJson);
  }

  Future<Map<String, dynamic>?> getProfile() async {
    final profileJson = await _storage.read(key: _profileKey);
    if (profileJson != null) {
      return jsonDecode(profileJson) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> deleteProfile() async {
    await _storage.delete(key: _profileKey);
  }

  // Settings methods
  Future<void> saveSetting(String key, dynamic value) async {
    final valueJson = jsonEncode(value);
    await _storage.write(key: '$_settingsPrefix$key', value: valueJson);
  }

  Future<dynamic> getSetting(String key) async {
    final valueJson = await _storage.read(key: '$_settingsPrefix$key');
    if (valueJson != null) {
      return jsonDecode(valueJson);
    }
    return null;
  }

  Future<void> deleteSetting(String key) async {
    await _storage.delete(key: '$_settingsPrefix$key');
  }

  Future<void> clearAll() async {
    // Clear profile and all settings
    // Note: This will only clear items managed by this class
    await deleteProfile();

    // Get all keys and delete settings
    final allKeys = await _storage.readAll();
    for (final key in allKeys.keys) {
      if (key.startsWith(_settingsPrefix)) {
        await _storage.delete(key: key);
      }
    }
  }
}
