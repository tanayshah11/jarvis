# Jarvis Authentication Screens

Complete implementation of all authentication screens following the Stitch UI design specifications.

## Screens Implemented

### 1. Splash Screen (`splash_screen.dart`)
**Route:** `/splash`

**Features:**
- Pure black background
- Centered gold orb logo with glow effect
- "LOREM IPSUM" placeholder text inside the orb
- "J A R V I S" text below with letter spacing
- Animated loading bar at bottom (gold progress on dark background)
- Auto-navigates to login screen after 3 seconds

**Key Components:**
- `JarvisGoldOrb` widget with placeholder text enabled
- Animated progress bar with gold color
- Fade-in and scale animations using flutter_animate

---

### 2. Login Screen (`new_login_screen.dart`)
**Route:** `/login`

**Features:**
- Smaller gold orb at top (80px)
- "JARVIS" text with letter spacing
- "Welcome back" title (white, bold)
- "Sign in to continue" subtitle (gray)
- Email input field (dark background, mail icon)
- Password input field (dark background, lock icon, visibility toggle)
- "Forgot password?" link (gold text, right-aligned)
- "Sign In" button (gold, full-width)
- "or" divider line
- Two social login buttons (Apple and Google icons in dark cards)
- "Don't have an account? Sign Up" link at bottom
- Form validation with error messages
- Loading state during authentication

**Navigation:**
- Taps "Forgot password?" → `/forgot-password`
- Taps "Sign Up" → `/sign-up`
- Successful login → `/chat` or `/onboarding` (based on profile status)

---

### 3. Sign Up Screen (`sign_up_screen.dart`)
**Route:** `/sign-up`

**Features:**
- Back button (gold chevron) in app bar
- "JARVIS" title in app bar with letter spacing
- "Create Account" title
- "Join Jarvis to get started" subtitle
- Full name input (WHITE background)
- Email input (WHITE background)
- Password input with visibility toggle (WHITE background)
- **Password strength indicator:**
  - 4 segments that fill based on strength
  - Colors: Red (weak) → Orange (medium) → Gold (strong/very strong)
  - Labels: "Weak", "Medium", "Strong", "Very Strong"
- Confirm password input (WHITE background, green checkmark when matching)
- Terms checkbox with "I agree to the Terms of Service and Privacy Policy" (gold links)
- "Create Account" button (gold, full-width)
- "or sign up with" divider
- Apple/Google social login buttons (dark cards)
- "Already have an account? Sign In" link at bottom

**Password Strength Calculation:**
- Weak: < 8 characters
- Medium: 8+ characters
- Strong: 8+ characters + uppercase + numbers
- Very Strong: 8+ characters + uppercase + numbers + special characters

**Validation:**
- All fields required
- Email format validation
- Password minimum length (8 characters)
- Password confirmation must match
- Terms checkbox must be checked

---

### 4. Forgot Password Screen (`forgot_password_screen.dart`)
**Route:** `/forgot-password`

**Features:**
- Back button (gold chevron)
- Lock icon in dark circle with gold glow (100px)
- "Reset Password" title (white, bold)
- Description: "Enter your email address and we'll send you a link to reset your password."
- Email input (dark background, mail icon)
- "Send Reset Link" button (gold, full-width)
- "Back to Sign In" link (gold)

**Flow:**
1. User enters email
2. Taps "Send Reset Link"
3. Shows loading state (2 seconds)
4. Displays success message with check icon
5. Shows "Back to Sign In" button

**Success Message:**
- Green checkmark icon
- "Check Your Email" heading
- "We've sent a password reset link to [email]" message
- Animated fade-in and scale effect

---

### 5. Reset Password Screen (`reset_password_screen.dart`)
**Route:** `/reset-password?token=xxx`

**Features:**
- Back button (gold chevron)
- Key icon with gold glow at top (100px)
- "Create New Password" title (white, bold)
- Description: "Your new password must be different from previously used passwords."
- New password input (dark background, lock icon, visibility toggle)
- **Password requirements checklist:**
  - ✓/✗ At least 8 characters
  - ✓/✗ One uppercase letter
  - ✓/✗ One number
  - ✓/✗ One special character
  - Requirements update in real-time as user types
  - Gold checkmark when met, gray X when not met
- Confirm password input (dark background, green checkmark when matching)
- "Reset Password" button (gold, full-width)

**Validation:**
- All password requirements must be met
- Passwords must match
- Shows validation errors in form

**Success Flow:**
1. User enters new password meeting all requirements
2. Confirms password
3. Taps "Reset Password"
4. Shows loading state
5. Displays success dialog
6. Dialog includes:
   - Check circle icon
   - "Password Reset Successful" title
   - Success message
   - "Sign In" button that navigates to `/login`

---

## Shared Components

### JarvisGoldOrb
Located in: `/lib/core/widgets/jarvis_gold_orb.dart`

**Parameters:**
- `size` (double): Size of the orb (default: 120)
- `showGlow` (bool): Whether to show glow effect (default: true)
- `showPlaceholderText` (bool): Whether to show "LOREM IPSUM" text (default: false)
- `animate` (bool): Whether to animate with shimmer and pulse (default: true)

**Features:**
- Radial gradient (gold center to dark edges)
- Multiple glow layers with varying opacity
- Inner highlight for 3D effect
- Optional animated shimmer and pulse effects
- Placeholder text overlay for splash screen

### JarvisTextField
Located in: `/lib/core/widgets/jarvis_text_field.dart`

**Variants:**
- `JarvisTextField.dark()`: Dark background (default)
- `JarvisTextField.white()`: White background (for sign-up screen)

**Parameters:**
- `controller`: TextEditingController
- `hintText`: Placeholder text
- `labelText`: Optional label above field
- `prefixIcon`: Icon on the left
- `suffixIcon`: Widget on the right
- `obscureText`: For password fields
- `validator`: Form validation function
- `onChanged`: Callback when text changes
- `onSubmitted`: Callback on enter/done
- `showCheckmark`: Shows green checkmark (for password confirmation)

**Features:**
- Animated focus border (gold)
- Focus shadow effect
- Custom colors based on variant
- Built-in validation support
- Accessibility support

### JarvisButton
Located in: `/lib/core/widgets/jarvis_button.dart`

**Types:**
- `primary`: Gold gradient with shadow
- `secondary`: Dark background with border
- `ghost`: Transparent with border
- `danger`: Red background

**Features:**
- Loading state with spinner
- Haptic feedback on tap
- Press animation (scale down)
- Disabled state styling
- Full-width option

---

## State Management

### AuthController
Located in: `/lib/features/auth/auth_controller.dart`

**Provider:** `authControllerProvider`

**State Properties:**
- `status`: AuthStatus (initial, authenticated, unauthenticated, loading)
- `userId`: Current user ID
- `email`: User email
- `error`: Error message
- `hasProfile`: Whether user has completed onboarding

**Methods:**
- `login(email, password)`: Authenticate user
- `register(email, password)`: Create new account
- `logout()`: Sign out user
- `checkAuthStatus()`: Verify current auth state
- `setHasProfile(bool)`: Update profile status
- `clearError()`: Clear error message

### PasswordResetProvider
Located in: `/lib/features/auth/providers/password_reset_provider.dart`

**Provider:** `passwordResetProvider`

**State Properties:**
- `status`: PasswordResetStatus (initial, sending, sent, error, resetting, success)
- `error`: Error message
- `email`: Email for reset

**Methods:**
- `sendResetLink(email)`: Send password reset email
- `resetPassword(token, newPassword)`: Reset password with token
- `reset()`: Clear state

---

## Routing

All routes are configured in `/lib/router.dart`:

```dart
/splash              → SplashScreen (initial route)
/login               → NewLoginScreen
/sign-up             → SignUpScreen
/forgot-password     → ForgotPasswordScreen
/reset-password      → ResetPasswordScreen (with token param)
/onboarding          → OnboardingScreen
```

**Route Guards:**
- Unauthenticated users redirected to `/login`
- Authenticated users on auth screens redirected to `/chat` or `/onboarding`
- Splash screen always shows first on app launch

---

## Design System Colors

Using `JarvisColors` from `/lib/core/theme/jarvis_colors.dart`:

**Key Colors:**
- `background`: #000000 (pure black)
- `primaryGold`: #D4AF37 (main gold accent)
- `secondaryGold`: #B8962E (darker gold)
- `goldGlow`: #E8C547 (lighter gold for effects)
- `textPrimary`: #FFFFFF (white)
- `textSecondary`: #8E8E93 (gray)
- `error`: #FF453A (red)
- `success`: #34C759 (green)
- `cardBackground`: #1C1C1E (dark card)
- `inputBackground`: #2C2C2E (dark input)
- `whiteBackground`: #FFFFFF (white for sign-up inputs)

---

## Animations

All screens use `flutter_animate` package for smooth transitions:

- Fade-in animations with staggered delays
- Scale animations for icons and orbs
- Slide-up animations for text
- Shimmer effects on gold orb
- Shake animation for error messages
- Progress bar animation for splash screen

**Animation Timings:**
- Fade-in: 600ms
- Delays: 100-200ms between elements
- Splash loading: 2500ms
- Auto-navigation: 3000ms

---

## Form Validation

### Login Screen
- Email: Required, must contain @
- Password: Required

### Sign Up Screen
- Full name: Required
- Email: Required, must contain @
- Password: Required, minimum 8 characters
- Confirm password: Required, must match password
- Terms: Must be checked

### Forgot Password Screen
- Email: Required, must contain @

### Reset Password Screen
- New password: Required, must meet all requirements:
  - At least 8 characters
  - One uppercase letter
  - One number
  - One special character
- Confirm password: Required, must match new password

---

## TODO Items (for future implementation)

1. **API Integration:**
   - Replace mock delays with actual API calls
   - Implement proper error handling from backend
   - Add retry logic for failed requests

2. **Social Login:**
   - Implement Apple Sign In
   - Implement Google Sign In
   - Add loading states for social auth

3. **Password Reset:**
   - Implement email sending service
   - Add token validation
   - Add token expiration handling

4. **Accessibility:**
   - Add screen reader labels
   - Improve keyboard navigation
   - Add focus management

5. **Testing:**
   - Unit tests for validation logic
   - Widget tests for all screens
   - Integration tests for auth flow

6. **Analytics:**
   - Track screen views
   - Track button clicks
   - Track auth success/failure rates

---

## Usage Example

```dart
import 'package:go_router/go_router.dart';

// Navigate to login
context.go('/login');

// Navigate to sign up
context.push('/sign-up');

// Navigate to forgot password
context.push('/forgot-password');

// Navigate to reset password with token
context.push('/reset-password?token=abc123');

// Navigate after successful auth
final authState = ref.read(authControllerProvider);
if (authState.hasProfile) {
  context.go('/chat');
} else {
  context.go('/onboarding');
}
```

---

## File Structure

```
lib/features/auth/
├── auth_controller.dart           # Main auth state management
├── login_screen.dart              # Old login (kept for reference)
├── register_screen.dart           # Old register (kept for reference)
├── screens/
│   ├── splash_screen.dart         # New splash screen
│   ├── new_login_screen.dart      # New login screen
│   ├── sign_up_screen.dart        # New sign up screen
│   ├── forgot_password_screen.dart # Forgot password screen
│   ├── reset_password_screen.dart  # Reset password screen
│   └── screens_export.dart        # Export file
└── providers/
    └── password_reset_provider.dart # Password reset state

lib/core/widgets/
├── jarvis_gold_orb.dart           # Gold orb widget
├── jarvis_text_field.dart         # Text field widget
├── jarvis_button.dart             # Button widget
└── ...
```
