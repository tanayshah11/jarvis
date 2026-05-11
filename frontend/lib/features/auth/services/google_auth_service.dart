import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Google authentication result
class GoogleAuthResult {
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? idToken;
  final String? accessToken;

  const GoogleAuthResult({
    required this.email,
    this.displayName,
    this.photoUrl,
    this.idToken,
    this.accessToken,
  });
}

/// Google authentication service provider
final googleAuthServiceProvider = Provider<GoogleAuthService>((ref) {
  return GoogleAuthService();
});

/// Service for handling Google Sign-In (v7 API)
class GoogleAuthService {
  // Get singleton instance
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _initialized = false;

  /// Initialize Google Sign-In (must be called before other methods)
  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await _googleSignIn.initialize();
      _initialized = true;
    }
  }

  /// Sign in with Google
  /// Returns [GoogleAuthResult] on success, null if cancelled
  /// Throws exception on error
  Future<GoogleAuthResult?> signIn() async {
    try {
      await _ensureInitialized();

      // Sign out first to ensure account picker is shown
      await _googleSignIn.signOut();

      // Authenticate (get user info) - scopeHint for combined auth+authz flow
      final GoogleSignInAccount account = await _googleSignIn.authenticate(
        scopeHint: ['email', 'profile'],
      );

      // Get ID token from authentication
      final idToken = account.authentication.idToken;

      // Request authorization for scopes to get access token
      final authResult = await account.authorizationClient.authorizeScopes(
        ['email', 'profile'],
      );

      return GoogleAuthResult(
        email: account.email,
        displayName: account.displayName,
        photoUrl: account.photoUrl,
        idToken: idToken,
        accessToken: authResult.accessToken,
      );
    } on GoogleSignInException catch (e) {
      // User cancelled or other sign-in exception
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return null;
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign out from Google
  Future<void> signOut() async {
    await _ensureInitialized();
    await _googleSignIn.signOut();
  }

  /// Disconnect (revoke access) from Google
  Future<void> disconnect() async {
    await _ensureInitialized();
    await _googleSignIn.disconnect();
  }
}
