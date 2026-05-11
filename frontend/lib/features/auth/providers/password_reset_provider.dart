import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';

// Password reset state
enum PasswordResetStatus { initial, sending, sent, error, resetting, success }

class PasswordResetState {
  final PasswordResetStatus status;
  final String? error;
  final String? email;

  const PasswordResetState({
    this.status = PasswordResetStatus.initial,
    this.error,
    this.email,
  });

  PasswordResetState copyWith({
    PasswordResetStatus? status,
    String? error,
    String? email,
  }) {
    return PasswordResetState(
      status: status ?? this.status,
      error: error,
      email: email ?? this.email,
    );
  }
}

// Password reset provider using Riverpod 2.x Notifier API
final passwordResetProvider =
    NotifierProvider<PasswordResetNotifier, PasswordResetState>(
  PasswordResetNotifier.new,
);

class PasswordResetNotifier extends Notifier<PasswordResetState> {
  ApiClient get apiClient => ref.read(apiClientProvider);

  @override
  PasswordResetState build() => const PasswordResetState();

  Future<bool> sendResetLink(String email) async {
    state = state.copyWith(
      status: PasswordResetStatus.sending,
      error: null,
      email: email,
    );

    try {
      await apiClient.post('/auth/forgot-password', data: {
        'email': email,
      });

      state = state.copyWith(status: PasswordResetStatus.sent);
      return true;
    } catch (e) {
      String errorMessage = 'Failed to send reset link. Please try again.';

      if (e is DioException) {
        final statusCode = e.response?.statusCode;
        final detail = e.response?.data?['detail'];

        if (statusCode == 404) {
          errorMessage = detail ?? 'Email not found';
        } else if (statusCode == 422) {
          errorMessage = 'Invalid email format';
        } else if (e.type == DioExceptionType.connectionError) {
          errorMessage = 'Unable to connect. Check your internet.';
        }
      }

      state = state.copyWith(
        status: PasswordResetStatus.error,
        error: errorMessage,
      );
      return false;
    }
  }

  Future<bool> resetPassword(String token, String newPassword) async {
    state = state.copyWith(
      status: PasswordResetStatus.resetting,
      error: null,
    );

    try {
      await apiClient.post('/auth/reset-password', data: {
        'token': token,
        'new_password': newPassword,
      });

      state = state.copyWith(status: PasswordResetStatus.success);
      return true;
    } catch (e) {
      String errorMessage = 'Failed to reset password. Please try again.';

      if (e is DioException) {
        final statusCode = e.response?.statusCode;
        final detail = e.response?.data?['detail'];

        if (statusCode == 400) {
          errorMessage = detail ?? 'Invalid or expired reset token';
        } else if (statusCode == 422) {
          errorMessage = 'Invalid password format';
        } else if (e.type == DioExceptionType.connectionError) {
          errorMessage = 'Unable to connect. Check your internet.';
        }
      }

      state = state.copyWith(
        status: PasswordResetStatus.error,
        error: errorMessage,
      );
      return false;
    }
  }

  void reset() {
    state = const PasswordResetState();
  }
}
