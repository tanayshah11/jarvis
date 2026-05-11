# Jarvis Design System

A comprehensive design system for the Jarvis Flutter application, based on Stitch UI design specifications.

## Table of Contents

- [Overview](#overview)
- [Theme](#theme)
  - [Colors](#colors)
  - [Typography](#typography)
  - [Decorations](#decorations)
- [Widgets](#widgets)
  - [Gold Orb](#gold-orb)
  - [Buttons](#buttons)
  - [Text Fields](#text-fields)
  - [Cards](#cards)
  - [App Bars](#app-bars)
- [Usage Examples](#usage-examples)

## Overview

The Jarvis Design System provides a consistent, beautiful dark theme with gold accents throughout the application. It includes:

- **Theme Configuration**: Complete Material 3 theme with custom color scheme
- **Typography**: Consistent text styles following a proper hierarchy
- **Reusable Components**: Pre-built widgets following the design system
- **Decorations**: BoxDecorations for cards, inputs, buttons, and more

## Theme

### Colors

Import the color palette:

```dart
import 'package:jarvis/core/theme/jarvis_colors.dart';
```

#### Background Colors
- `JarvisColors.background` - Pure black (#000000)
- `JarvisColors.cardBackground` - Dark gray (#1C1C1E)
- `JarvisColors.inputBackground` - Darker gray (#2C2C2E)
- `JarvisColors.whiteBackground` - White (#FFFFFF)

#### Gold Colors
- `JarvisColors.primaryGold` - Primary gold accent (#D4AF37)
- `JarvisColors.secondaryGold` - Darker gold (#B8962E)
- `JarvisColors.goldGlow` - Lighter gold (#E8C547)
- `JarvisColors.warning` - Warning yellow (#FFD60A)

#### Text Colors
- `JarvisColors.textPrimary` - White (#FFFFFF)
- `JarvisColors.textSecondary` - Gray (#8E8E93)
- `JarvisColors.textTertiary` - Muted gray (#636366)
- `JarvisColors.textOnGold` - Black (#000000)

#### Semantic Colors
- `JarvisColors.success` - Green (#34C759)
- `JarvisColors.error` - Red (#FF453A)
- `JarvisColors.info` - Blue (#0A84FF)

#### Gradients
- `JarvisColors.goldGradient` - Linear gold gradient
- `JarvisColors.goldGlowGradient` - Radial gold glow for orbs
- `JarvisColors.cardGradient` - Subtle dark card gradient

### Typography

Import typography:

```dart
import 'package:jarvis/core/theme/jarvis_typography.dart';
```

#### Display Text (Large headings)
- `JarvisTypography.displayLarge` - 57px, Bold
- `JarvisTypography.displayMedium` - 45px, Bold
- `JarvisTypography.displaySmall` - 36px, Bold

#### Headline Text
- `JarvisTypography.headlineLarge` - 32px, SemiBold
- `JarvisTypography.headlineMedium` - 28px, SemiBold
- `JarvisTypography.headlineSmall` - 24px, SemiBold

#### Title Text
- `JarvisTypography.titleLarge` - 22px, SemiBold
- `JarvisTypography.titleMedium` - 16px, SemiBold
- `JarvisTypography.titleSmall` - 14px, SemiBold

#### Body Text
- `JarvisTypography.bodyLarge` - 16px, Regular
- `JarvisTypography.bodyMedium` - 14px, Regular
- `JarvisTypography.bodySmall` - 12px, Regular

#### Label Text
- `JarvisTypography.labelLarge` - 14px, Medium
- `JarvisTypography.labelMedium` - 12px, Medium
- `JarvisTypography.labelSmall` - 11px, Medium

#### Button Text
- `JarvisTypography.buttonLarge` - 16px, SemiBold
- `JarvisTypography.buttonMedium` - 14px, SemiBold
- `JarvisTypography.buttonSmall` - 12px, SemiBold

#### Helper Methods
- `JarvisTypography.gold(style)` - Apply gold color
- `JarvisTypography.secondary(style)` - Apply secondary text color
- `JarvisTypography.error(style)` - Apply error color
- `JarvisTypography.success(style)` - Apply success color

### Decorations

Import decorations:

```dart
import 'package:jarvis/core/theme/jarvis_decorations.dart';
```

#### Border Radius Constants
- `JarvisDecorations.radiusSmall` - 8px
- `JarvisDecorations.radiusMedium` - 12px
- `JarvisDecorations.radiusLarge` - 16px
- `JarvisDecorations.radiusXLarge` - 24px

#### Card Decorations
- `JarvisDecorations.card()` - Standard dark card
- `JarvisDecorations.cardGold()` - Card with gold border
- `JarvisDecorations.cardGradient()` - Card with gradient
- `JarvisDecorations.cardElevated()` - Card with shadow

#### Input Decorations
- `JarvisDecorations.input()` - Dark input field
- `JarvisDecorations.inputWhite()` - White input field
- `JarvisDecorations.inputError()` - Input with error state

#### Button Decorations
- `JarvisDecorations.buttonPrimary()` - Gold button
- `JarvisDecorations.buttonPrimaryGradient()` - Gold gradient button
- `JarvisDecorations.buttonSecondary()` - Dark with gold border
- `JarvisDecorations.buttonTertiary()` - Transparent button
- `JarvisDecorations.buttonDestructive()` - Red button

#### Special Effects
- `JarvisDecorations.goldOrb()` - Gold orb with glow
- `JarvisDecorations.glassMorphism()` - Glass effect

## Widgets

### Gold Orb

The signature Jarvis gold orb with glow effect and animation.

```dart
import 'package:jarvis/core/widgets/jarvis_gold_orb.dart';

// Named constructors for different sizes
JarvisGoldOrb.small()    // 40px
JarvisGoldOrb.medium()   // 80px (default)
JarvisGoldOrb.large()    // 200px

// Custom size
JarvisGoldOrb.custom(customSize: 120)

// With icon
JarvisGoldOrbIcon(
  icon: Icons.check,
  size: JarvisOrbSize.medium,
)

// With loading indicator
JarvisGoldOrbLoading(
  size: JarvisOrbSize.medium,
)

// Full customization
JarvisGoldOrb(
  size: JarvisOrbSize.medium,
  animated: true,
  glowing: true,
  opacity: 1.0,
  animationDuration: Duration(seconds: 2),
)
```

### Buttons

Primary and secondary button styles.

```dart
import 'package:jarvis/core/widgets/jarvis_button.dart';

// Primary gold button
JarvisButton.primary(
  text: 'Continue',
  onPressed: () {},
  icon: Icons.arrow_forward,
  fullWidth: true,
  isLoading: false,
)

// Secondary button (dark with gold border)
JarvisButton.secondary(
  text: 'Cancel',
  onPressed: () {},
)

// Tertiary button (transparent)
JarvisButton.tertiary(
  text: 'Skip',
  onPressed: () {},
)

// Destructive button (red)
JarvisButton.destructive(
  text: 'Delete',
  onPressed: () {},
)

// Different sizes
JarvisButton.primary(
  text: 'Small',
  size: JarvisButtonSize.small,
  onPressed: () {},
)

JarvisButton.primary(
  text: 'Large',
  size: JarvisButtonSize.large,
  onPressed: () {},
)
```

### Text Fields

Dark and white styled text fields.

```dart
import 'package:jarvis/core/widgets/jarvis_text_field.dart';

// Dark variant (default)
JarvisTextField.dark(
  controller: emailController,
  hintText: 'Enter your email',
  labelText: 'Email',
  prefixIcon: Icons.email,
  keyboardType: TextInputType.emailAddress,
)

// White variant (for sign up screens)
JarvisTextField.white(
  controller: passwordController,
  hintText: 'Enter your password',
  labelText: 'Password',
  obscureText: true,
  prefixIcon: Icons.lock,
)

// With error state
JarvisTextField.dark(
  controller: controller,
  hintText: 'Username',
  errorText: 'Username is required',
)

// Password field (auto includes visibility toggle)
JarvisTextField.dark(
  controller: passwordController,
  hintText: 'Password',
  obscureText: true,
)

// Custom suffix icon
JarvisTextField.dark(
  controller: controller,
  hintText: 'Search',
  suffixIcon: Icon(Icons.search),
)
```

### Cards

The existing `JarvisCard` widget already follows the design system.

```dart
import 'package:jarvis/core/widgets/jarvis_card.dart';

JarvisCard(
  child: Text('Card content'),
  onTap: () {},
  elevated: true,
  glass: false,
  showGradientBorder: true,
)
```

### App Bars

Custom app bars matching the design system.

```dart
import 'package:jarvis/core/widgets/jarvis_app_bar.dart';

// Standard app bar
JarvisAppBar(
  title: 'Settings',
  actions: [
    IconButton(
      icon: Icon(Icons.more_vert),
      onPressed: () {},
    ),
  ],
)

// App bar with logo
JarvisAppBarWithLogo(
  actions: [
    IconButton(
      icon: Icon(Icons.notifications),
      onPressed: () {},
    ),
  ],
)

// Sliver app bar for CustomScrollView
JarvisSliverAppBar(
  title: 'Profile',
  pinned: true,
  floating: false,
  expandedHeight: 200,
  flexibleSpace: FlexibleSpaceBar(
    background: // Your background widget
  ),
)
```

## Usage Examples

### Complete Screen Example

```dart
import 'package:flutter/material.dart';
import 'package:jarvis/core/theme/theme.dart';
import 'package:jarvis/core/widgets/widgets.dart';

class LoginScreen extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JarvisColors.background,
      appBar: JarvisAppBar(
        title: 'Sign In',
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Logo
            Center(
              child: JarvisGoldOrb.large(),
            ),
            SizedBox(height: 48),

            // Title
            Text(
              'Welcome Back',
              style: JarvisTypography.headlineLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Sign in to continue',
              style: JarvisTypography.bodyMedium.copyWith(
                color: JarvisColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 48),

            // Email field
            JarvisTextField.dark(
              controller: emailController,
              hintText: 'Email',
              prefixIcon: Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),

            // Password field
            JarvisTextField.dark(
              controller: passwordController,
              hintText: 'Password',
              obscureText: true,
              prefixIcon: Icons.lock,
            ),
            SizedBox(height: 32),

            // Login button
            JarvisButton.primary(
              text: 'Sign In',
              fullWidth: true,
              onPressed: () {
                // Handle login
              },
            ),
            SizedBox(height: 16),

            // Secondary button
            JarvisButton.secondary(
              text: 'Create Account',
              fullWidth: true,
              onPressed: () {
                // Navigate to sign up
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

### Applying the Theme

In your `main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:jarvis/core/theme/jarvis_theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jarvis',
      theme: JarvisTheme.darkTheme,
      home: HomeScreen(),
    );
  }
}
```

## Best Practices

1. **Use const constructors** wherever possible for better performance
2. **Import from barrel files** (`theme.dart` and `widgets.dart`) for cleaner imports
3. **Follow the color hierarchy**: Primary gold for interactive elements, secondary for supporting text
4. **Maintain consistency**: Use the provided text styles instead of creating custom ones
5. **Respect the spacing**: Use the design system's decorations for consistent border radius and padding
6. **Accessibility**: All text meets WCAG contrast requirements against the dark background

## Contributing

When adding new components to the design system:

1. Follow the existing naming conventions
2. Add proper documentation comments
3. Include usage examples
4. Update this README with new components
5. Ensure components follow Material 3 guidelines
6. Test on both iOS and Android

## File Structure

```
lib/core/
├── theme/
│   ├── jarvis_colors.dart        # Color palette
│   ├── jarvis_typography.dart    # Text styles
│   ├── jarvis_decorations.dart   # BoxDecorations
│   ├── jarvis_theme.dart         # ThemeData configuration
│   └── theme.dart                # Barrel export
├── widgets/
│   ├── jarvis_gold_orb.dart      # Gold orb widget
│   ├── jarvis_button.dart        # Button widgets
│   ├── jarvis_text_field.dart    # Text field widgets
│   ├── jarvis_card.dart          # Card widget
│   ├── jarvis_app_bar.dart       # App bar widgets
│   └── widgets.dart              # Barrel export
└── DESIGN_SYSTEM.md              # This file
```
