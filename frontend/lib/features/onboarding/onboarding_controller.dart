import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/storage/local_storage.dart';
import '../../core/storage/secure_storage.dart';
import '../../data/data_service.dart';
import '../../data/database/database.dart';
import '../auth/auth_controller.dart';

// Profile data model
class ProfileData {
  final String? city;
  final String? budgetLevel;
  final List<String> vibes;

  const ProfileData({
    this.city,
    this.budgetLevel,
    this.vibes = const [],
  });

  ProfileData copyWith({
    String? city,
    String? budgetLevel,
    List<String>? vibes,
  }) {
    return ProfileData(
      city: city ?? this.city,
      budgetLevel: budgetLevel ?? this.budgetLevel,
      vibes: vibes ?? this.vibes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'budget_level': budgetLevel,
      'vibes': vibes,
    };
  }

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      city: json['city'] as String?,
      budgetLevel: json['budget_level'] as String?,
      vibes: (json['vibes'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }
}

// Onboarding state
class OnboardingState {
  final ProfileData profile;
  final bool isLoading;
  final String? error;

  const OnboardingState({
    this.profile = const ProfileData(),
    this.isLoading = false,
    this.error,
  });

  OnboardingState copyWith({
    ProfileData? profile,
    bool? isLoading,
    String? error,
  }) {
    return OnboardingState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final onboardingControllerProvider =
    NotifierProvider<OnboardingController, OnboardingState>(
        OnboardingController.new);

class OnboardingController extends Notifier<OnboardingState> {
  // Use getters to access providers - avoids late initialization issues on rebuild
  LocalStorage get localStorage => ref.read(localStorageProvider);
  SecureStorage get secureStorage => ref.read(secureStorageProvider);
  DataService get dataService => ref.read(dataServiceProvider);
  AuthController get authController => ref.read(authControllerProvider.notifier);

  @override
  OnboardingState build() {
    return const OnboardingState();
  }

  void setCity(String city) {
    state = state.copyWith(
      profile: state.profile.copyWith(city: city),
    );
  }

  void setBudgetLevel(String level) {
    state = state.copyWith(
      profile: state.profile.copyWith(budgetLevel: level),
    );
  }

  void toggleVibe(String vibe) {
    final currentVibes = List<String>.from(state.profile.vibes);
    if (currentVibes.contains(vibe)) {
      currentVibes.remove(vibe);
    } else {
      currentVibes.add(vibe);
    }
    state = state.copyWith(
      profile: state.profile.copyWith(vibes: currentVibes),
    );
  }

  Future<bool> saveProfile() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final userId = await secureStorage.getUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Ensure data service is initialized
      if (!dataService.isInitialized) {
        await dataService.initialize();
      }

      // Save to local Drift database
      final db = dataService.database;
      final existingProfile = await db.getProfileByUserId(userId);

      if (existingProfile != null) {
        // Update existing profile - preferences is nullable so needs Value wrapper
        await db.updateProfile(
          existingProfile.copyWith(
            preferences: Value(jsonEncode(state.profile.toJson())),
            updatedAt: DateTime.now(),
          ),
        );
      } else {
        // Create new profile
        await db.insertProfile(ProfilesCompanion.insert(
          id: const Uuid().v4(),
          userId: userId,
          preferences: Value(jsonEncode(state.profile.toJson())),
        ));
      }

      // Also save to localStorage for quick access
      await localStorage.saveProfile(state.profile.toJson());

      // Update auth state to indicate profile exists
      authController.setHasProfile(true);

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      // ignore: avoid_print
      print('saveProfile error: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to save profile: $e',
      );
      return false;
    }
  }
}
