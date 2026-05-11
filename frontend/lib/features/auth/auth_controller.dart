import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/storage/local_storage.dart';
import '../../data/data_service.dart';
import 'services/google_auth_service.dart';

// Auth state
enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthState {
  final AuthStatus status;
  final String? userId;
  final String? email;
  final String? error;
  final bool hasProfile;

  const AuthState({
    this.status = AuthStatus.initial,
    this.userId,
    this.email,
    this.error,
    this.hasProfile = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? userId,
    String? email,
    String? error,
    bool? hasProfile,
  }) {
    return AuthState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      error: error,
      hasProfile: hasProfile ?? this.hasProfile,
    );
  }
}

// Auth controller provider
final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);

class AuthController extends Notifier<AuthState> {
  // Use getters to access providers - avoids late initialization issues on rebuild
  ApiClient get apiClient => ref.read(apiClientProvider);
  SecureStorage get secureStorage => ref.read(secureStorageProvider);
  LocalStorage get localStorage => ref.read(localStorageProvider);
  DataService get dataService => ref.read(dataServiceProvider);
  GoogleAuthService get googleAuthService => ref.read(googleAuthServiceProvider);

  @override
  AuthState build() {
    return const AuthState();
  }

  Future<void> checkAuthStatus() async {
    final token = await secureStorage.getToken();
    if (token != null) {
      try {
        final response = await apiClient.get('/auth/me');
        final userData = response.data;
        final userId = userData['id'] as String;

        // Check if user has a profile in local DB (if data service is ready)
        bool hasProfile = false;
        try {
          if (dataService.isInitialized) {
            final profile = await dataService.database.getProfileByUserId(userId);
            hasProfile = profile != null;
          }
        } catch (_) {
          // Data service not ready yet
        }

        state = state.copyWith(
          status: AuthStatus.authenticated,
          userId: userId,
          email: userData['email'],
          hasProfile: hasProfile,
        );
      } catch (e) {
        await secureStorage.deleteToken();
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<bool> register(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);

    try {
      await apiClient.post('/auth/register', data: {
        'email': email,
        'password': password,
      });

      // After registration, log in automatically
      return await login(email, password);
    } catch (e) {
      String errorMessage = 'Registration failed. Please try again.';

      if (e is DioException) {
        final statusCode = e.response?.statusCode;
        final detail = e.response?.data?['detail'];

        if (statusCode == 400) {
          errorMessage = detail ?? 'Email already registered';
        } else if (statusCode == 422) {
          errorMessage = 'Invalid email or password format';
        } else if (e.type == DioExceptionType.connectionError) {
          errorMessage = 'Unable to connect. Check your internet.';
        }
      }

      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: errorMessage,
      );
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);

    try {
      final response = await apiClient.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final token = response.data['access_token'];
      await secureStorage.saveToken(token);

      // Get user info
      final userResponse = await apiClient.get('/auth/me');
      final userData = userResponse.data;
      final userId = userData['id'] as String;

      await secureStorage.saveUserId(userId);

      // Check if user has a profile in local DB (if data service is ready)
      bool hasProfile = false;
      try {
        if (dataService.isInitialized) {
          final profile = await dataService.database.getProfileByUserId(userId);
          hasProfile = profile != null;
        }
      } catch (_) {
        // Data service not ready yet, profile check will happen later
      }

      state = state.copyWith(
        status: AuthStatus.authenticated,
        userId: userId,
        email: userData['email'],
        hasProfile: hasProfile,
      );

      return true;
    } catch (e) {
      String errorMessage = 'Login failed. Please try again.';

      if (e is DioException) {
        final statusCode = e.response?.statusCode;
        final detail = e.response?.data?['detail'];

        if (statusCode == 401) {
          errorMessage = detail ?? 'Invalid email or password';
        } else if (statusCode == 422) {
          errorMessage = 'Invalid email format';
        } else if (e.type == DioExceptionType.connectionError) {
          errorMessage = 'Unable to connect. Check your internet.';
        }
      }

      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: errorMessage,
      );
      return false;
    }
  }

  /// Sign in or register with Google
  Future<bool> loginWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading, error: null);

    try {
      // Trigger Google Sign-In flow
      final googleResult = await googleAuthService.signIn();

      if (googleResult == null) {
        // User cancelled
        state = state.copyWith(status: AuthStatus.unauthenticated);
        return false;
      }

      // Send Google credentials to backend for authentication
      final response = await apiClient.post('/auth/google', data: {
        'email': googleResult.email,
        'id_token': googleResult.idToken,
        'access_token': googleResult.accessToken,
        'display_name': googleResult.displayName,
      });

      final token = response.data['access_token'];
      await secureStorage.saveToken(token);

      // Get user info
      final userResponse = await apiClient.get('/auth/me');
      final userData = userResponse.data;
      final userId = userData['id'] as String;

      await secureStorage.saveUserId(userId);

      // Check if user has a profile in local DB
      bool hasProfile = false;
      try {
        if (dataService.isInitialized) {
          final profile = await dataService.database.getProfileByUserId(userId);
          hasProfile = profile != null;
        }
      } catch (_) {
        // Data service not ready yet
      }

      state = state.copyWith(
        status: AuthStatus.authenticated,
        userId: userId,
        email: userData['email'],
        hasProfile: hasProfile,
      );

      return true;
    } catch (e) {
      String errorMessage = 'Google sign-in failed. Please try again.';

      if (e is DioException) {
        final statusCode = e.response?.statusCode;
        final detail = e.response?.data?['detail'];

        if (statusCode == 401) {
          errorMessage = detail ?? 'Authentication failed';
        } else if (e.type == DioExceptionType.connectionError) {
          errorMessage = 'Unable to connect. Check your internet.';
        }
      }

      // Sign out from Google on failure
      await googleAuthService.signOut();

      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: errorMessage,
      );
      return false;
    }
  }

  Future<void> logout() async {
    // Sign out from Google if signed in
    await googleAuthService.signOut();
    await secureStorage.clearAll();
    await localStorage.clearAll();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void setHasProfile(bool value) {
    state = state.copyWith(hasProfile: value);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
