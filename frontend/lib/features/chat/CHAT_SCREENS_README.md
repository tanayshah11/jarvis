# Chat Screens Implementation

This document provides a complete overview of all chat-related screens and widgets implemented for Jarvis based on the Stitch UI design specifications.

## Directory Structure

```
lib/features/chat/
├── screens/
│   ├── chat_screen_enhanced.dart    # Enhanced chat screen with Stitch UI
│   ├── conversation_history_screen.dart
│   └── voice_mode_screen.dart       # Full-screen voice interaction
├── widgets/
│   ├── chat_input_bar.dart          # Enhanced input with attachments
│   ├── message_bubble.dart          # Message display widget
│   ├── suggestion_chip.dart         # Reusable suggestion chips
│   ├── enhanced_typing_indicator.dart # Typing indicators
│   ├── attachment_sheet.dart        # Attachment picker
│   ├── chat_sidebar.dart
│   ├── conversation_menu.dart
│   └── user_menu_sheet.dart
├── chat_controller.dart             # State management
└── chat_screen.dart                 # Original iOS-native chat screen
```

## Screens

### 1. Chat Screen Enhanced (`chat_screen_enhanced.dart`)

The main chat interface with Stitch UI design elements.

#### Features:
- **Custom App Bar**
  - Settings gear icon (gold) on left
  - "Jarvis" title centered
  - User avatar (circular) on right

- **Empty State**
  - Large gold orb in center with glow effect
  - Time-based personalized greeting ("Good morning/afternoon/evening, Tony")
  - "How can I help you today?" subtitle
  - Horizontal scrollable suggestion chips with prompts:
    - "Summarize my day"
    - "Draft an email"
    - "Tell me a joke"
    - "Plan a trip"
    - "Explain a concept"
    - "Write code"
  - Voice Mode button with gold gradient

- **Active Chat State**
  - Message list with AI and user messages
  - Enhanced typing indicator with gold orb
  - Smooth scrolling to bottom on new messages

- **Bottom Input Bar**
  - Attachment button (+) with glassmorphism
  - Text field with "Ask Jarvis..." placeholder
  - Gold send button (arrow up icon) with glow effect
  - Disabled states during loading

- **Bottom Navigation Bar**
  - Chat (filled chat icon, gold when active)
  - History (clock icon)
  - Profile (person icon)
  - Blur background with adaptive theming

#### Usage:
```dart
import 'package:jarvis/features/chat/screens/chat_screen_enhanced.dart';

// In your router or navigation
ChatScreenEnhanced()
```

### 2. Voice Mode Screen (`voice_mode_screen.dart`)

Full-screen voice interaction interface.

#### Features:
- **Full Screen Overlay**
  - Close button (X) at top right
  - Radial gradient background with gold tint

- **Large Pulsing Orb**
  - 200px gold orb in center
  - Animated pulse effect when listening
  - Multiple expanding rings for visual feedback
  - Tap to toggle listening state

- **Status Text**
  - "Listening..." when active (animated fade)
  - "Tap to speak" when inactive

- **Transcription Area**
  - Dark container with glass effect
  - Displays real-time speech-to-text
  - Placeholder: "The real-time speech-to-text will be displayed here."

- **Bottom Action Buttons**
  - Keyboard button (switch to text input)
  - Large mic button (gold ring, centered, 72px)
  - Hang up button (red phone icon)

#### Usage:
```dart
import 'package:jarvis/features/chat/screens/voice_mode_screen.dart';

// Navigate to voice mode
Navigator.of(context).push(
  CupertinoPageRoute(
    fullscreenDialog: true,
    builder: (context) => const VoiceModeScreen(),
  ),
);
```

## Widgets

### 1. Chat Input Bar (`chat_input_bar.dart`)

Enhanced input bar with attachment preview support.

#### Features:
- Attachment button with gold accent
- Multi-line text input (1-5 lines)
- Send button with gradient and glow
- Attachment preview chips (scrollable horizontal list)
- Remove button on each attachment
- Glassmorphism background with blur

#### Model:
```dart
class AttachmentPreview {
  final String name;
  final String? path;
  final AttachmentType type;
  final int? size;
}

enum AttachmentType {
  image,
  document,
  location,
}
```

#### Usage:
```dart
ChatInputBar(
  controller: _messageController,
  onSend: _sendMessage,
  onAttachment: _showAttachmentPicker,
  isLoading: chatState.isLoading,
  attachments: _attachments,
  onRemoveAttachment: (index) => setState(() {
    _attachments.removeAt(index);
  }),
)
```

### 2. Suggestion Chips (`suggestion_chip.dart`)

Reusable suggestion chips for quick prompts.

#### Features:
- Dark background with subtle gold border
- Icon support (optional)
- Tap animation with scale effect
- Adaptive theming
- Press state feedback

#### Usage:
```dart
// Single chip
SuggestionChip(
  label: 'Tell me a joke',
  icon: CupertinoIcons.smiley,
  onTap: () => _sendMessage('Tell me a joke'),
)

// Grid of suggestions
SuggestionChipGrid(
  onSuggestionTap: (prompt) {
    _messageController.text = prompt;
    _sendMessage();
  },
)
```

### 3. Enhanced Typing Indicator (`enhanced_typing_indicator.dart`)

Shows when Jarvis is composing a response.

#### Variants:

**Enhanced Version (with avatar):**
```dart
EnhancedTypingIndicator()
```
- Small Jarvis avatar (28px)
- "Jarvis" label in gold
- "Thinking" text with animated dots

**Compact Version (dots only):**
```dart
CompactTypingIndicator()
```
- Glass container
- Three animated gold dots
- Minimal design

### 4. Message Bubble (`message_bubble.dart`)

Displays individual chat messages.

#### Features:
- **AI Messages:**
  - Left-aligned
  - Gold "Jarvis" label
  - Markdown rendering support
  - Gold orb avatar (28px)
  - Streaming cursor when typing

- **User Messages:**
  - Left-aligned (iOS style)
  - "You" label in gray
  - Plain white text
  - No avatar

- **Animations:**
  - Fade in on latest message
  - Slide up on latest message
  - Thinking indicator when empty and streaming

#### Usage:
```dart
MessageBubble(
  message: chatMessage,
  isLatest: index == messages.length - 1,
)
```

### 5. Attachment Sheet (`attachment_sheet.dart`)

Bottom sheet for selecting attachment type.

#### Options:
- Photo (from gallery)
- Camera (take photo)
- Document (file picker)
- Location (coming soon)

#### Usage:
```dart
final type = await showModalBottomSheet<AttachmentType>(
  context: context,
  backgroundColor: Colors.transparent,
  builder: (context) => const AttachmentSheet(),
);
```

## State Management

### ChatController (`chat_controller.dart`)

Manages chat state using Riverpod.

#### State:
```dart
class ChatState {
  final List<ChatMessage> messages;
  final List<Conversation> conversations;
  final String? currentConversationId;
  final bool isLoading;
  final String? error;
  final String mode;
  final AiProvider currentProvider;
}
```

#### Key Methods:
- `sendMessage(String content)` - Send message and stream response
- `loadConversation(String id)` - Load conversation from DB
- `createConversation({String? title})` - Create new conversation
- `setProvider(AiProvider provider)` - Change AI model
- `clearChat()` - Clear current chat
- `startNewChat()` - Start fresh conversation

#### Usage:
```dart
// Watch state
final chatState = ref.watch(chatControllerProvider);

// Send message
ref.read(chatControllerProvider.notifier).sendMessage('Hello');

// Change AI model
ref.read(chatControllerProvider.notifier).setProvider(AiProvider.anthropic);
```

## Theme Integration

All screens and widgets use the adaptive theming system:

### Colors:
- `AdaptiveColors.primary` - Gold accent (#D4AF37)
- `AdaptiveColors.background(context)` - Black (dark) / Light gray (light)
- `AdaptiveColors.textPrimary(context)` - White (dark) / Black (light)
- `AdaptiveColors.textSecondary(context)` - Gray (adaptive)

### Gradients:
- `AppGradients.primary` - Gold gradient for buttons
- `AppGradients.glass` - Glassmorphism effect
- `AppGradients.backgroundAnimated` - Animated background

### Spacing:
- `AppSpacing.xs` - 4px
- `AppSpacing.sm` - 8px
- `AppSpacing.md` - 12px
- `AppSpacing.lg` - 16px
- `AppSpacing.xl` - 24px
- `AppSpacing.xxl` - 32px
- `AppSpacing.xxxl` - 48px

### Text Styles:
- `JarvisTextStyles.largeTitle(context)` - 34pt bold
- `JarvisTextStyles.headline(context)` - 17pt semibold
- `JarvisTextStyles.body(context)` - 17pt regular
- `JarvisTextStyles.footnote(context)` - 13pt regular

## Animations

### Flutter Animate
All animations use `flutter_animate` package:

```dart
widget
  .animate()
  .fadeIn(duration: 600.ms)
  .slideY(begin: 0.1)
```

### Common Patterns:
- **Fade in:** Empty state elements
- **Scale:** Button press states
- **Pulse:** Voice mode orb
- **Slide:** Message appearance
- **Ripple:** Expanding rings in voice mode

## Accessibility

- All buttons have haptic feedback
- Text contrast meets WCAG standards
- Focus states for keyboard navigation
- Screen reader labels on icons
- Adaptive text sizing support

## Performance Considerations

- Lazy loading of messages with ListView.builder
- Image caching for attachments
- Debounced scroll listeners
- Efficient state updates with Riverpod
- Animation controllers properly disposed

## Future Enhancements

1. **Real Voice Integration:**
   - Connect to speech-to-text API
   - Real-time transcription display
   - Voice activity detection

2. **Attachment Upload:**
   - Backend API integration
   - Progress indicators
   - File size validation

3. **Rich Message Types:**
   - Image grid display
   - File previews with icons
   - Location maps
   - Code syntax highlighting

4. **Advanced Features:**
   - Message reactions
   - Copy/share functionality
   - Message search
   - Conversation folders

## Testing

### Widget Tests:
```dart
testWidgets('Voice mode screen displays correctly', (tester) async {
  await tester.pumpWidget(
    CupertinoApp(home: VoiceModeScreen()),
  );
  expect(find.text('Tap to speak'), findsOneWidget);
  expect(find.byType(JarvisAvatar), findsOneWidget);
});
```

### Integration Tests:
- Send message flow
- Voice mode navigation
- Attachment selection
- Settings changes

## Dependencies

```yaml
dependencies:
  flutter_riverpod: ^2.4.0
  go_router: ^13.0.0
  flutter_animate: ^4.3.0
  gpt_markdown: ^0.0.1
  lottie: ^3.0.0
  dotlottie_loader: ^0.0.4
  image_picker: ^1.0.0
  file_picker: ^6.0.0
```

## Migration Guide

To migrate from `chat_screen.dart` to `chat_screen_enhanced.dart`:

1. Update router configuration:
```dart
// Before
GoRoute(path: '/chat', builder: (context, state) => ChatScreen())

// After
GoRoute(path: '/chat', builder: (context, state) => ChatScreenEnhanced())
```

2. Both screens use the same `ChatController`, so no state changes needed

3. Optional: Keep both screens and A/B test the designs

## Support

For issues or questions:
- Check existing GitHub issues
- Review theme documentation in `/lib/core/theme/`
- See widget examples in `/lib/core/widgets/`
