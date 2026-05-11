# Integrations Hub UI Reference

## Screen Layout

```
┌─────────────────────────────────────────────┐
│  ←  Integrations                            │  ← Blurred header
├─────────────────────────────────────────────┤
│                                             │
│  Connect services to enhance Jarvis         │  ← Subtitle
│                                             │
│  ━━━ CONNECTED                              │  ← Section header
│  ┌─────────────────────────────────────┐    │
│  │ 📧 [Gmail]         ● Connected      │    │  ← Connected card
│  │    john@gmail.com                   │    │
│  └─────────────────────────────────────┘    │
│  ┌─────────────────────────────────────┐    │
│  │ 👤 [Contacts]      ● Connected      │    │
│  │    🔒 Stays on device               │    │  ← Privacy badge
│  └─────────────────────────────────────┘    │
│                                             │
│  ━━━ AVAILABLE                              │
│  ┌─────────────────────────────────────┐    │
│  │ 📅 [Calendar]      Connect →        │    │  ← Available card
│  └─────────────────────────────────────┘    │
│  ┌─────────────────────────────────────┐    │
│  │ 🎵 [Spotify]       Connect →        │    │
│  └─────────────────────────────────────┘    │
│  ┌─────────────────────────────────────┐    │
│  │ 💻 [GitHub]        Connect →        │    │
│  └─────────────────────────────────────┘    │
│  ┌─────────────────────────────────────┐    │
│  │ 📝 [Notion]        Connect →        │    │
│  └─────────────────────────────────────┘    │
│                                             │
│  ━━━ DEVICE                                 │
│  ┌─────────────────────────────────────┐    │
│  │ 📅 [Apple Cal]     Connect →        │    │
│  └─────────────────────────────────────┘    │
│  ┌─────────────────────────────────────┐    │
│  │ 🖼  [Photos]        Connect →        │    │
│  └─────────────────────────────────────┘    │
│                                             │
└─────────────────────────────────────────────┘
```

## Card States

### Connected State
```
┌─────────────────────────────────────┐
│ [📧]  Gmail           ● Connected   │  ← Gold border (0.3 alpha)
│       john@gmail.com                │  ← Account info
└─────────────────────────────────────┘
   ↑                      ↑
  Icon with              Green dot +
  gold bg                gold text
```

### Disconnected State (OAuth)
```
┌─────────────────────────────────────┐
│ [📅]  Google Calendar  Connect →    │  ← Light border (0.1 alpha)
└─────────────────────────────────────┘
   ↑                      ↑
  Icon with              Gold text +
  gray bg                arrow icon
```

### Disconnected State (Local)
```
┌─────────────────────────────────────┐
│ [👤]  Contacts         Connect →    │
│       🔒 Stays on device            │  ← Privacy badge
└─────────────────────────────────────┘
```

### Connecting State
```
┌─────────────────────────────────────┐
│ [📧]  Gmail           ⌛ Connecting  │
└─────────────────────────────────────┘
                         ↑
                      Spinner animation
```

## Permission Dialog

When user taps "Connect →":

```
┌───────────────────────────────────┐
│   Connect Gmail                   │
│                                   │
│ Access your emails                │
│                                   │
│ This integration will be able to: │
│   ✓ Search your data              │
│   ✓ Read your data                │
│   ✓ Send messages                 │
│                                   │
│ ┌─────────────────────────────┐   │
│ │ ℹ️  Data will be shared      │   │
│ │    with Gmail with your      │   │
│ │    consent. You can revoke   │   │
│ │    access at any time.       │   │
│ └─────────────────────────────┘   │
│                                   │
│     [Cancel]      [Connect]       │
│                      ↑ Gold       │
└───────────────────────────────────┘
```

For local integrations:

```
┌───────────────────────────────────┐
│   Connect Contacts                │
│                                   │
│ Search your contacts              │
│                                   │
│ This integration will be able to: │
│   ✓ Search your data              │
│   ✓ Read your data                │
│                                   │
│ ┌─────────────────────────────┐   │
│ │ 🔒 All data stays on your    │   │
│ │    device. Nothing is sent   │   │
│ │    to external servers.      │   │
│ └─────────────────────────────┘   │
│                                   │
│     [Cancel]      [Enable]        │
└───────────────────────────────────┘
```

## Disconnect Dialog

When user taps a connected integration:

```
┌───────────────────────────────────┐
│   Disconnect Gmail                │
│                                   │
│ Are you sure you want to          │
│ disconnect Gmail? Jarvis will     │
│ no longer be able to access this  │
│ service.                          │
│                                   │
│     [Cancel]      [Disconnect]    │
│                      ↑ Red        │
└───────────────────────────────────┘
```

## Color Scheme

- **Background**: Pure black (#000000)
- **Cards**: Near black with blur (#0A0A0A @ 60% alpha)
- **Gold Accent**: #D4AF37
- **Text Primary**: White (#FFFFFF)
- **Text Secondary**: Gray (#888888)
- **Border (normal)**: White @ 10% alpha
- **Border (connected)**: Gold @ 30% alpha

## Animations

1. **Card tap**: Scale down to 98% on press
2. **Connecting**: Spinner rotation
3. **Background**: Animated gradient blobs (5s & 7s cycles)
4. **Status change**: Fade between states (200ms)

## Icons Used (CupertinoIcons)

- Gmail: `mail`
- Contacts: `person_2`
- Calendar: `calendar` / `calendar_today`
- Spotify: `music_note`
- GitHub: `square_stack_3d_up`
- Notion: `doc_text`
- Photos: `photo`
- Lock/Privacy: `lock_shield`
- Back: `back`
- Arrow: `arrow_right`
- Connected: Green dot (custom)
- Checkmark: `checkmark_circle_fill`
- Info: `info_circle`

## Navigation Flow

```
Settings Screen
    ↓ Tap "Integrations"
Integrations Hub
    ↓ Tap disconnected card
Permission Dialog
    ↓ Tap "Connect"
(Connecting animation)
    ↓ 2 seconds
Connected state (card updates)

    OR

Integrations Hub
    ↓ Tap connected card
Disconnect Dialog
    ↓ Tap "Disconnect"
Disconnected state (card updates)
```

## Sections Logic

**CONNECTED Section** - Shows if:
- Any OAuth integration has `status = connected`
- Any local integration has `status = connected`

**AVAILABLE Section** - Shows if:
- Any OAuth integration has `status = disconnected`

**DEVICE Section** - Shows if:
- Any local integration has `status = disconnected`

## Responsive Behavior

- Header adjusts for safe area (notch/status bar)
- Bottom padding for tab bar (100px + safe area)
- ScrollView for long integration lists
- Cards are full width with 16px horizontal padding
- 8px vertical spacing between cards

## Glassmorphism Effect

```dart
// Card background
color: AppColors.surface.withValues(alpha: 0.6)
blur: sigmaX: 10, sigmaY: 10
border: 0.5px white @ 10% alpha

// Icon container
color: iconColor.withValues(alpha: 0.15)
borderRadius: 12px
size: 48x48px
icon size: 24px

// Header
blur: sigmaX: 20, sigmaY: 20
background: black @ 80% alpha
border bottom: gold @ 20% alpha
```

## Haptic Feedback Events

- Card tap: `selectionClick()`
- Dialog open: `mediumImpact()`
- Back button: `lightImpact()`
