# Jarvis Design System - Quick Reference

## Import Everything

```dart
import 'package:jarvis/core/theme/theme.dart';
import 'package:jarvis/core/widgets/widgets.dart';
```

## Colors Cheat Sheet

| Purpose | Color | Hex | Variable |
|---------|-------|-----|----------|
| Background | Pure Black | `#000000` | `JarvisColors.background` |
| Cards | Dark Gray | `#1C1C1E` | `JarvisColors.cardBackground` |
| Inputs | Darker Gray | `#2C2C2E` | `JarvisColors.inputBackground` |
| Primary Gold | Gold | `#D4AF37` | `JarvisColors.primaryGold` |
| Secondary Gold | Darker Gold | `#B8962E` | `JarvisColors.secondaryGold` |
| Text Primary | White | `#FFFFFF` | `JarvisColors.textPrimary` |
| Text Secondary | Gray | `#8E8E93` | `JarvisColors.textSecondary` |
| Success | Green | `#34C759` | `JarvisColors.success` |
| Error | Red | `#FF453A` | `JarvisColors.error` |
| Warning | Yellow | `#FFD60A` | `JarvisColors.warning` |

## Typography Cheat Sheet

| Style | Size | Weight | Usage |
|-------|------|--------|-------|
| `displayLarge` | 57px | Bold | Hero text |
| `displayMedium` | 45px | Bold | Large titles |
| `displaySmall` | 36px | Bold | Section titles |
| `headlineLarge` | 32px | SemiBold | Page headers |
| `headlineMedium` | 28px | SemiBold | Sub-headers |
| `headlineSmall` | 24px | SemiBold | Card titles |
| `titleLarge` | 22px | SemiBold | List titles |
| `titleMedium` | 16px | SemiBold | Item titles |
| `titleSmall` | 14px | SemiBold | Small titles |
| `bodyLarge` | 16px | Regular | Main text |
| `bodyMedium` | 14px | Regular | Secondary text |
| `bodySmall` | 12px | Regular | Fine print |
| `buttonLarge` | 16px | SemiBold | Large buttons |
| `buttonMedium` | 14px | SemiBold | Standard buttons |
| `buttonSmall` | 12px | SemiBold | Small buttons |

## Widget Quick Examples

### Gold Orb
```dart
// Small, Medium, Large
JarvisGoldOrb.small()
JarvisGoldOrb.medium()
JarvisGoldOrb.large()

// Custom
JarvisGoldOrb.custom(customSize: 100)

// With icon
JarvisGoldOrbIcon(icon: Icons.check)

// Loading
JarvisGoldOrbLoading()
```

### Buttons
```dart
// Primary (Gold)
JarvisButton.primary(
  text: 'Continue',
  onPressed: () {},
)

// Secondary (Gold border)
JarvisButton.secondary(
  text: 'Cancel',
  onPressed: () {},
)

// Tertiary (Transparent)
JarvisButton.tertiary(
  text: 'Skip',
  onPressed: () {},
)

// Destructive (Red)
JarvisButton.destructive(
  text: 'Delete',
  onPressed: () {},
)

// With icon
JarvisButton.primary(
  text: 'Next',
  icon: Icons.arrow_forward,
  onPressed: () {},
)

// Full width
JarvisButton.primary(
  text: 'Submit',
  fullWidth: true,
  onPressed: () {},
)

// Loading state
JarvisButton.primary(
  text: 'Loading',
  isLoading: true,
  onPressed: null,
)
```

### Text Fields
```dart
// Dark (default)
JarvisTextField.dark(
  controller: controller,
  hintText: 'Email',
  prefixIcon: Icons.email,
)

// White (for light backgrounds)
JarvisTextField.white(
  controller: controller,
  hintText: 'Password',
  obscureText: true,
)

// With label
JarvisTextField.dark(
  controller: controller,
  hintText: 'Username',
  labelText: 'Username',
)

// With error
JarvisTextField.dark(
  controller: controller,
  hintText: 'Email',
  errorText: 'Invalid email',
)
```

### App Bars
```dart
// Standard
JarvisAppBar(title: 'Settings')

// With logo
JarvisAppBarWithLogo(
  actions: [
    IconButton(
      icon: Icon(Icons.settings),
      onPressed: () {},
    ),
  ],
)

// Sliver (for scrolling)
JarvisSliverAppBar(
  title: 'Profile',
  pinned: true,
  expandedHeight: 200,
)
```

### Cards
```dart
JarvisCard(
  child: Text('Content'),
  onTap: () {},
  elevated: true,
)
```

## Common Patterns

### Screen Layout
```dart
Scaffold(
  backgroundColor: JarvisColors.background,
  appBar: JarvisAppBar(title: 'Title'),
  body: SingleChildScrollView(
    padding: EdgeInsets.all(24),
    child: Column(
      children: [
        // Your content
      ],
    ),
  ),
)
```

### Form
```dart
Column(
  children: [
    JarvisTextField.dark(
      controller: emailController,
      hintText: 'Email',
      prefixIcon: Icons.email,
    ),
    SizedBox(height: 16),
    JarvisTextField.dark(
      controller: passwordController,
      hintText: 'Password',
      obscureText: true,
    ),
    SizedBox(height: 32),
    JarvisButton.primary(
      text: 'Sign In',
      fullWidth: true,
      onPressed: handleSignIn,
    ),
  ],
)
```

### Card with Content
```dart
JarvisCard(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Title',
        style: JarvisTypography.titleLarge,
      ),
      SizedBox(height: 8),
      Text(
        'Description',
        style: JarvisTypography.bodyMedium.copyWith(
          color: JarvisColors.textSecondary,
        ),
      ),
    ],
  ),
)
```

### Loading State
```dart
Center(
  child: JarvisGoldOrbLoading(
    size: JarvisOrbSize.medium,
  ),
)
```

## Border Radius

```dart
JarvisDecorations.radiusSmall    // 8px
JarvisDecorations.radiusMedium   // 12px
JarvisDecorations.radiusLarge    // 16px
JarvisDecorations.radiusXLarge   // 24px
```

## Spacing Guide

Use multiples of 8 for consistent spacing:
- 8px - Tight spacing
- 16px - Standard spacing
- 24px - Medium spacing
- 32px - Large spacing
- 48px - Extra large spacing

## Remember

1. Always use `const` constructors when possible
2. Import from barrel files: `theme.dart` and `widgets.dart`
3. Use `JarvisColors` instead of hardcoded colors
4. Use `JarvisTypography` instead of custom TextStyle
5. Background should always be `JarvisColors.background`
6. Interactive elements use `JarvisColors.primaryGold`
7. Secondary text uses `JarvisColors.textSecondary`
