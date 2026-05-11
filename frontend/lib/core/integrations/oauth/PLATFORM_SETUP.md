# Platform Setup for OAuth

This guide covers platform-specific configuration required for OAuth to work on iOS and Android.

## Custom URL Scheme

The OAuth flow requires a custom URL scheme to handle redirect callbacks from the authorization server. We use `com.jarvis://oauth` as the default redirect URI.

## iOS Configuration

### 1. Update Info.plist

Add the following to `ios/Runner/Info.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- ... existing keys ... -->

    <!-- OAuth URL Scheme -->
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>CFBundleURLName</key>
            <string>com.jarvis</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>com.jarvis</string>
            </array>
        </dict>
    </array>

</dict>
</plist>
```

### 2. Verify Bundle Identifier

Make sure your bundle identifier in `ios/Runner.xcodeproj/project.pbxproj` matches your OAuth app configuration.

### 3. Test URL Scheme

After building the app, you can test the URL scheme works:

```bash
# Open this URL on your iOS device/simulator
xcrun simctl openurl booted "com.jarvis://oauth?code=test"
```

## Android Configuration

### 1. Update AndroidManifest.xml

Add the following to `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application>
        <!-- ... existing activities ... -->

        <!-- OAuth Callback Activity -->
        <activity
            android:name="com.linusu.flutter_web_auth_2.CallbackActivity"
            android:exported="true">
            <intent-filter android:label="flutter_web_auth">
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data android:scheme="com.jarvis" android:host="oauth" />
            </intent-filter>
        </activity>

    </application>
</manifest>
```

### 2. Update build.gradle (if needed)

Ensure minimum SDK version supports OAuth (typically API 21+):

`android/app/build.gradle`:
```gradle
android {
    defaultConfig {
        minSdkVersion 21  // or higher
        // ...
    }
}
```

### 3. Test URL Scheme

After building the app, you can test the URL scheme:

```bash
# On Android device/emulator
adb shell am start -W -a android.intent.action.VIEW -d "com.jarvis://oauth?code=test" com.yourpackage
```

## Provider-Specific Setup

### Spotify

**Developer Dashboard**: https://developer.spotify.com/dashboard

1. Create or select your app
2. Click "Edit Settings"
3. Add Redirect URI: `com.jarvis://oauth`
4. Save changes
5. Copy your Client ID

**Notes**:
- Spotify supports PKCE (no client secret needed for mobile)
- Test with user account that has Spotify Premium for playback features

### GitHub

**Developer Settings**: https://github.com/settings/developers

1. Click "New OAuth App"
2. Fill in:
   - Application name: Jarvis
   - Homepage URL: https://yourapp.com
   - Authorization callback URL: `com.jarvis://oauth`
3. Generate a new client secret
4. Copy Client ID and Client Secret

**Notes**:
- GitHub requires client secret (no PKCE for public clients)
- Store client secret securely (environment variables, never in code)

### Google

**Google Cloud Console**: https://console.cloud.google.com/apis/credentials

1. Create OAuth 2.0 Client ID
2. Select application type:
   - **For iOS**: Choose "iOS"
     - Bundle ID: com.yourcompany.jarvis
   - **For Android**: Choose "Android"
     - Package name: com.yourcompany.jarvis
     - SHA-1 certificate fingerprint (get with `keytool`)
3. Add authorized redirect URI: `com.jarvis://oauth`
4. Enable required APIs (Gmail, Calendar, etc.)

**Get Android SHA-1**:
```bash
# Debug keystore
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# Release keystore
keytool -list -v -keystore /path/to/release.keystore -alias your_alias
```

**Notes**:
- Need separate OAuth clients for iOS and Android
- Requires consent screen configuration
- Add test users during development

### Microsoft (Azure AD)

**Azure Portal**: https://portal.azure.com/#view/Microsoft_AAD_RegisteredApps

1. Click "New registration"
2. Fill in:
   - Name: Jarvis
   - Supported account types: Choose based on your needs
   - Redirect URI: Public client/native > `com.jarvis://oauth`
3. Go to "Authentication"
4. Enable "Allow public client flows"
5. Add platform: Mobile and desktop applications
6. Add redirect URI: `com.jarvis://oauth`

**Notes**:
- Use "common" tenant for multi-tenant
- Enable "offline_access" scope for refresh tokens
- Configure API permissions for services you'll use

## Security Considerations

### 1. Custom URL Scheme Security

⚠️ **Important**: Custom URL schemes are not secure against malicious apps that might register the same scheme.

For production apps, consider:
- Using Universal Links (iOS) / App Links (Android)
- Validating state parameter in OAuth callback
- Using PKCE for all flows

### 2. Universal Links (iOS)

For production, use Universal Links instead of custom URL schemes:

`ios/Runner/Runner.entitlements`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.developer.associated-domains</key>
    <array>
        <string>applinks:yourapp.com</string>
    </array>
</dict>
</plist>
```

Host `apple-app-site-association` file at `https://yourapp.com/.well-known/apple-app-site-association`

### 3. App Links (Android)

For production, use App Links:

`android/app/src/main/AndroidManifest.xml`:
```xml
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data
        android:scheme="https"
        android:host="yourapp.com"
        android:pathPrefix="/oauth" />
</intent-filter>
```

Host `assetlinks.json` at `https://yourapp.com/.well-known/assetlinks.json`

### 4. Client Secrets

Never hardcode client secrets in your app. Use:

- Environment variables during build
- Remote config (Firebase Remote Config)
- Backend proxy for sensitive OAuth flows

Example with environment variables:

```dart
// Define at build time
flutter run --dart-define=GITHUB_CLIENT_SECRET=your_secret

// Access in code
const githubSecret = String.fromEnvironment('GITHUB_CLIENT_SECRET');
```

## Testing

### Local Testing

1. **iOS Simulator**: OAuth redirects work in simulator
2. **Android Emulator**: OAuth redirects work in emulator
3. **Physical Devices**: Recommended for final testing

### Test Checklist

- [ ] URL scheme registered in platform manifests
- [ ] OAuth app configured with correct redirect URI
- [ ] Client ID/Secret properly configured
- [ ] Required scopes enabled in OAuth app
- [ ] Consent screen configured (Google)
- [ ] Test users added (for restricted apps)
- [ ] HTTPS enforced for all OAuth endpoints
- [ ] Error handling tested (cancel, deny, network error)
- [ ] Token refresh works after expiration
- [ ] Logout revokes tokens properly

### Common Issues

**"Invalid redirect URI"**
- Check URL scheme spelling (case-sensitive)
- Verify scheme registered in both platform manifest AND OAuth app
- Ensure no trailing slashes

**"Browser not opening"**
- Check `url_launcher` can open URLs
- Test with: `launchUrl(Uri.parse('https://google.com'))`
- Check iOS Info.plist has `LSApplicationQueriesSchemes`

**"App not responding to callback"**
- Verify callback activity/URL type is registered
- Check Logcat/Console for URL scheme handling
- Test URL scheme manually (see test commands above)

**"Token refresh fails"**
- Ensure refresh token was requested (offline_access scope)
- Check token endpoint URL is correct
- Verify client credentials are valid

## Next Steps

1. Configure URL schemes in platform manifests
2. Register OAuth apps with each provider
3. Test OAuth flow on physical devices
4. Implement Universal/App Links for production
5. Set up secure client secret management
6. Add analytics/logging for OAuth events
7. Implement error recovery UI
8. Add unit/integration tests
