// OAuth 2.0 authentication for Jarvis integrations
//
// Provides a complete OAuth 2.0 implementation for mobile apps with:
// - PKCE support for enhanced security
// - Automatic token refresh
// - Secure token storage
// - Pre-configured providers (Spotify, GitHub, Google, Microsoft)
//
// ## Usage
//
// ### 1. Configure OAuth provider
// ```dart
// final spotifyConfig = OAuthConfig.spotify(
//   clientId: 'your-client-id',
//   scopes: ['user-read-playback-state', 'user-modify-playback-state'],
// );
// ```
//
// ### 2. Start authentication flow
// ```dart
// final flowNotifier = ref.watch(oauthFlowNotifierProvider.notifier);
// final success = await flowNotifier.startFlow(spotifyConfig);
//
// if (success) {
//   // Authentication successful
//   final tokens = flowNotifier.state.tokens;
// }
// ```
//
// ### 3. Check authentication status
// ```dart
// final isAuth = await ref.watch(
//   isAuthenticatedProvider((providerId: 'spotify', config: spotifyConfig)),
// );
// ```
//
// ### 4. Get tokens (auto-refreshes if needed)
// ```dart
// final tokens = await ref.watch(
//   tokensProvider((providerId: 'spotify', config: spotifyConfig)),
// );
// ```
//
// ### 5. Logout
// ```dart
// final flowNotifier = ref.watch(oauthFlowNotifierProvider.notifier);
// await flowNotifier.logout('spotify', config: spotifyConfig);
// ```
//
// ## Platform Configuration
//
// ### iOS (Info.plist)
// ```xml
// <key>CFBundleURLTypes</key>
// <array>
//   <dict>
//     <key>CFBundleURLSchemes</key>
//     <array>
//       <string>com.jarvis</string>
//     </array>
//   </dict>
// </array>
// ```
//
// ### Android (AndroidManifest.xml)
// ```xml
// <activity android:name="com.linusu.flutter_web_auth.CallbackActivity">
//   <intent-filter android:label="flutter_web_auth">
//     <action android:name="android.intent.action.VIEW" />
//     <category android:name="android.intent.category.DEFAULT" />
//     <category android:name="android.intent.category.BROWSABLE" />
//     <data android:scheme="com.jarvis" />
//   </intent-filter>
// </activity>
// ```

export 'oauth_config.dart';
export 'oauth_service.dart';
export 'oauth_state.dart';
