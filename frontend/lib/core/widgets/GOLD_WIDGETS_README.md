# Gold Widgets Documentation

Custom Flutter widgets with gold accent styling for the Jarvis application.

## GoldSlider

A custom slider widget with gold track, thumb, and glow effects.

### Features

- Gold gradient track for active portion
- Animated glow effect on active track
- Custom thumb with radial gradient
- Optional labels below slider (Low, Med, High)
- Smooth animations and transitions
- Haptic feedback support
- Disabled state styling
- Support for discrete divisions

### Usage

```dart
import 'package:jarvis/core/widgets/widgets.dart';

// Basic slider
GoldSlider(
  value: sliderValue,
  onChanged: (value) {
    setState(() => sliderValue = value);
  },
)

// Slider with labels
GoldSlider(
  value: volumeValue,
  onChanged: (value) => setState(() => volumeValue = value),
  showLabels: true,
  labels: const ['Quiet', 'Normal', 'Loud'],
)

// Discrete slider with divisions
GoldSlider(
  value: sliderValue,
  onChanged: (value) => setState(() => sliderValue = value),
  divisions: 5,
  showLabels: true,
)

// Disabled slider
GoldSlider(
  value: 0.5,
  onChanged: (value) {},
  enabled: false,
)
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `value` | `double` | required | Current slider value |
| `onChanged` | `ValueChanged<double>` | required | Callback when value changes |
| `onChangeStart` | `ValueChanged<double>?` | `null` | Callback when drag starts |
| `onChangeEnd` | `ValueChanged<double>?` | `null` | Callback when drag ends |
| `min` | `double` | `0.0` | Minimum value |
| `max` | `double` | `1.0` | Maximum value |
| `divisions` | `int?` | `null` | Number of discrete divisions |
| `showLabels` | `bool` | `false` | Show labels below slider |
| `labels` | `List<String>?` | `['Low', 'Med', 'High']` | Custom label text |
| `enableHaptics` | `bool` | `true` | Enable haptic feedback |
| `height` | `double` | `4.0` | Track height |
| `enabled` | `bool` | `true` | Enable/disable slider |

## GoldSwitch

A custom toggle switch with gold accent when active and spring animations.

### Features

- Gold gradient when toggled on
- Smooth spring animation on toggle
- Glow effect when active
- Optional label text
- Haptic feedback support
- Disabled state styling
- Press animation feedback

### Usage

```dart
import 'package:jarvis/core/widgets/widgets.dart';

// Basic switch
GoldSwitch(
  value: switchValue,
  onChanged: (value) {
    setState(() => switchValue = value);
  },
  showLabel: false,
)

// Switch with label
GoldSwitch(
  value: notificationsEnabled,
  onChanged: (value) => setState(() => notificationsEnabled = value),
  label: 'Enable Notifications',
)

// Disabled switch
GoldSwitch(
  value: true,
  onChanged: null,
  label: 'Disabled Switch',
  enabled: false,
)
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `value` | `bool` | required | Current switch state |
| `onChanged` | `ValueChanged<bool>?` | required | Callback when value changes |
| `label` | `String?` | `null` | Label text |
| `showLabel` | `bool` | `true` | Show label if provided |
| `enableHaptics` | `bool` | `true` | Enable haptic feedback |
| `enabled` | `bool` | `true` | Enable/disable switch |
| `width` | `double` | `52.0` | Switch width |
| `height` | `double` | `28.0` | Switch height |

## Color Scheme

Both widgets use the app's gold color palette:

- **Primary Gold**: `#D4AF37` (`AppColors.primary`)
- **Dark Gold**: `#B8962E` (`AppColors.primaryDark`)
- **Light Gold**: `#E5C76B` (`AppColors.accentLight`)

## Animation Details

### GoldSlider
- **Glow Animation**: 1500ms infinite pulse (0.3 - 0.8 opacity)
- **Thumb Scale**: 1.0x to 1.2x when dragging
- **Track Transition**: 200ms ease-in-out

### GoldSwitch
- **Toggle Animation**: 250ms ease-out cubic curve
- **Glow Fade**: Synchronized with toggle animation
- **Press Scale**: 1.0x to 0.95x on tap
- **Spring Effect**: Natural elastic motion

## Integration

These widgets are automatically exported through the barrel file:

```dart
// Single import for all widgets
import 'package:jarvis/core/widgets/widgets.dart';

// Now use GoldSlider and GoldSwitch anywhere
```

## Accessibility

Both widgets include:
- Proper haptic feedback for user interactions
- Disabled states with visual feedback
- Smooth animations that respect reduced motion preferences (via Flutter's default behavior)
- Clear visual states for all interaction modes
