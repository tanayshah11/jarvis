# Jarvis Frontend Architecture

> A privacy-first, on-device AI assistant with memory, integrations, and native device capabilities.

## High-Level Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              JARVIS APP                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │
│  │   Features   │  │     Core     │  │     Data     │  │   Platform   │    │
│  │              │  │              │  │              │  │   (Native)   │    │
│  │  • Chat      │  │  • Theme     │  │  • SQLite    │  │              │    │
│  │  • Agent     │  │  • Widgets   │  │  • ObjectBox │  │  • Calendar  │    │
│  │  • Memory    │  │  • Services  │  │  • TF Lite   │  │  • Contacts  │    │
│  │  • Settings  │  │  • OAuth     │  │  • Repos     │  │  • (future)  │    │
│  └──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘    │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Directory Structure

```
lib/
├── main.dart                 # App entry point
├── router.dart               # GoRouter navigation config
├── objectbox.g.dart          # Generated ObjectBox code
│
├── core/                     # Shared infrastructure
│   ├── config.dart           # Environment configuration
│   ├── theme/                # Design system & theming
│   ├── widgets/              # Reusable UI components
│   ├── services/             # Platform services (haptics, audio, OAuth)
│   ├── storage/              # Secure & local storage
│   ├── network/              # API client
│   ├── integrations/         # Third-party integrations framework
│   └── sync/                 # Background sync services
│
├── data/                     # Local-first data layer
│   ├── database/             # Drift (SQLite) database
│   ├── vector/               # ObjectBox vector store
│   ├── embeddings/           # TensorFlow Lite embeddings
│   ├── repositories/         # Data access layer
│   └── seed/                 # Demo/seed data
│
└── features/                 # Feature modules
    ├── agent/                # On-device AI agent
    ├── chat/                 # Conversation UI
    ├── memory/               # Memory graph visualization
    ├── auth/                 # Authentication
    ├── settings/             # App settings
    ├── integrations/         # Integration management UI
    ├── onboarding/           # First-run experience
    ├── history/              # Conversation history
    ├── profile/              # User profile
    └── network_sync/         # Deep network synchronization
```

---

## Core Modules (`/lib/core/`)

### Theme (`/core/theme/`)

The design system powering Jarvis's visual identity.

| File | Purpose |
|------|---------|
| `jarvis_theme.dart` | Main theme configuration |
| `jarvis_colors.dart` | Color palette (dark mode optimized) |
| `jarvis_typography.dart` | Font styles (SF Pro) |
| `jarvis_decorations.dart` | Box decorations, borders |
| `gradients.dart` | Gold/amber gradients (signature Jarvis look) |
| `shadows.dart` | Elevation shadows |
| `spacing.dart` | Consistent spacing scale |
| `animations.dart` | Animation curves & durations |
| `adaptive_colors.dart` | Light/dark mode color adaptation |
| `theme_provider.dart` | Riverpod provider for theme state |

**Key Design Elements:**
- Gold/amber accent color (`#FFD54F`)
- Dark background (`#0A0A0A`)
- Glassmorphism effects
- SF Pro typography

### Widgets (`/core/widgets/`)

Reusable UI components with Jarvis branding.

| Widget | Description |
|--------|-------------|
| `glass_container.dart` | Frosted glass effect container |
| `jarvis_button.dart` | Branded button variants |
| `jarvis_card.dart` | Card with glow effects |
| `jarvis_text_field.dart` | Styled text input |
| `jarvis_avatar.dart` | Avatar with status indicator |
| `jarvis_chip.dart` | Tag/label chips |
| `jarvis_sidebar.dart` | Navigation sidebar |
| `gold_switch.dart` | Gold-themed toggle switch |
| `gold_slider.dart` | Gold-themed slider |
| `particle_field.dart` | Animated particle background |
| `animated_gradient.dart` | Animated gradient backgrounds |
| `screen_header.dart` | Consistent screen headers |
| `state_widgets.dart` | Loading, error, empty states |
| `animations/jarvis_spinner.dart` | Loading spinner |
| `animations/skeleton_loader.dart` | Skeleton loading states |

### Services (`/core/services/`)

Platform and utility services.

#### Local Services (`/core/services/local/`)

Native device integrations via Flutter Method Channels.

| Service | Description | Native Bridge |
|---------|-------------|---------------|
| `calendar_service.dart` | iOS Calendar (EventKit) | `CalendarBridge.swift` |
| `contacts_service.dart` | iOS Contacts | `ContactsBridge.swift` |

**CalendarService Features:**
- `requestPermission()` / `checkPermission()`
- `getCalendars()` - List all device calendars
- `getEvents(start, end)` - Query events by date range
- `createEvent(title, start, end, ...)` - Create calendar events
- `updateEvent(eventId, ...)` - Modify events
- `deleteEvent(eventId)` - Remove events
- Natural language date parsing ("tomorrow at 2pm")

**ContactsService Features:**
- `requestPermission()` / `checkPermission()`
- `getContacts()` - List all contacts
- `searchContacts(query)` - Search by name/phone/email
- `getContact(id)` - Get single contact
- `addContact(...)` / `updateContact(...)` / `deleteContact(...)`

#### OAuth Services (`/core/services/oauth/`)

Third-party OAuth integrations.

| Provider | File | Capabilities |
|----------|------|--------------|
| Spotify | `spotify/spotify_service.dart` | Music control, playback, playlists |
| GitHub | `github/github_service.dart` | Repos, issues, PRs |

#### Other Services

| Service | Purpose |
|---------|---------|
| `audio_service.dart` | Sound effects playback (bootup sound) |
| `haptics.dart` | Haptic feedback (selection, success, error) |

### Storage (`/core/storage/`)

Data persistence layer.

| File | Purpose |
|------|---------|
| `secure_storage.dart` | `flutter_secure_storage` wrapper for sensitive data (tokens) |
| `local_storage.dart` | `shared_preferences` wrapper for app settings |

### Network (`/core/network/`)

API communication.

| File | Purpose |
|------|---------|
| `api_client.dart` | Dio-based HTTP client with auth interceptors |

**Features:**
- JWT token management
- Automatic token refresh
- Request/response logging
- Error handling

### Integrations Framework (`/core/integrations/`)

Extensible framework for third-party service integrations.

```
integrations/
├── integration_manager.dart   # Manages all integrations
├── tool_registry.dart         # Registry of available tools
├── models/
│   ├── integration.dart       # Integration model
│   ├── tool_definition.dart   # Tool schema
│   └── oauth_tokens.dart      # Token storage
├── oauth/
│   ├── oauth_service.dart     # OAuth flow handler
│   ├── oauth_config.dart      # Provider configs
│   └── oauth_state.dart       # Auth state management
└── tools/
    ├── calendar_tools.dart    # Calendar tool definitions
    ├── contacts_tools.dart    # Contacts tool definitions
    ├── spotify_tools.dart     # Spotify tool definitions
    └── github_tools.dart      # GitHub tool definitions
```

---

## Data Layer (`/lib/data/`)

Local-first data architecture using three complementary technologies.

### Database (`/data/database/`)

**Drift (SQLite)** for relational data.

```dart
// Tables defined in /database/tables/
users.dart              # User accounts
conversations.dart      # Chat conversations
messages.dart           # Chat messages
profiles.dart           # User profiles
memory_nodes.dart       # Memory graph nodes
memory_edges.dart       # Memory graph edges
connections.dart        # Contact connections
insights.dart           # Generated insights
temporal_patterns.dart  # Time-based patterns
entity_cooccurrences.dart # Entity relationships
```

**Key Tables:**

| Table | Purpose |
|-------|---------|
| `users` | Authentication & user data |
| `conversations` | Chat session metadata |
| `messages` | Individual messages |
| `memory_nodes` | Knowledge graph nodes (people, places, facts) |
| `memory_edges` | Relationships between nodes |

### Vector Store (`/data/vector/`)

**ObjectBox** for vector similarity search.

| File | Purpose |
|------|---------|
| `vector_store.dart` | Vector operations & similarity search |
| `models/memory_vector.dart` | Vector entity model |

**Capabilities:**
- Store 384-dimensional embeddings
- Cosine similarity search
- k-NN queries for semantic search

### Embeddings (`/data/embeddings/`)

**TensorFlow Lite** for on-device embedding generation.

| File | Purpose |
|------|---------|
| `local_embedding_service.dart` | Generate embeddings without network |

**Model:** MiniLM-L6 (384 dimensions)
- Runs entirely on-device
- No data sent to servers
- ~15ms per embedding on modern iPhones

### Repositories (`/data/repositories/`)

Clean API for data access.

| Repository | Purpose |
|------------|---------|
| `memory_repository.dart` | Memory graph CRUD & semantic search |
| `conversation_repository.dart` | Conversation & message management |
| `connection_repository.dart` | Contact relationship management |

**MemoryRepository Key Methods:**
```dart
// Node operations
upsertNode(nodeType, name, source, attributes, confidence)
getNode(id)
getNodeWithRelationships(id)
deleteNode(id)

// Search
searchNodesSemantically(query, limit, minScore)
findRelatedNodes(nodeId, relationshipTypes)

// Graph operations
createEdge(fromNodeId, toNodeId, relationshipType, weight)
```

---

## Features (`/lib/features/`)

### Agent (`/features/agent/`)

The core AI processing pipeline. **Privacy-first design** - all user data stays on-device.

```
agent/
├── agent_controller.dart          # Main orchestrator
├── models/
│   └── agent_state.dart           # State machine definitions
└── services/
    ├── intent_classifier.dart     # Rule-based intent detection
    ├── function_router.dart       # Route to appropriate handler
    ├── entity_anonymizer.dart     # PII anonymization
    ├── response_templates.dart    # Local response generation
    ├── llm_proxy_service.dart     # Backend LLM communication
    └── calendar_action_executor.dart # Calendar action execution
```

#### Processing Pipeline

```
User Message
     │
     ▼
┌─────────────────┐
│ Intent Classify │  ◄── On-device, rule-based
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Function Router │  ◄── Can handle locally?
└────────┬────────┘
         │
    ┌────┴────┐
    │         │
    ▼         ▼
 LOCAL      NEEDS LLM
    │         │
    │    ┌────┴────┐
    │    │Anonymize│  ◄── Remove PII before sending
    │    └────┬────┘
    │         │
    │    ┌────┴────┐
    │    │ LLM API │  ◄── Only anonymized data leaves device
    │    └────┬────┘
    │         │
    │    ┌────┴────┐
    │    │De-anon  │  ◄── Restore PII in response
    │    └────┬────┘
    │         │
    └────┬────┘
         │
         ▼
┌─────────────────┐
│Extract Memories │  ◄── On-device, rule-based
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Update Graph    │  ◄── Store in local database
└────────┬────────┘
         │
         ▼
    Response
```

#### Intent Types (AgentIntent)

| Intent | Trigger Examples | Handler |
|--------|------------------|---------|
| `createEvent` | "Schedule lunch with Sarah tomorrow" | CalendarActionExecutor |
| `sendMessage` | "Text John that I'm running late" | (planned) |
| `saveMemory` | "Remember that Sarah likes sushi" | MemoryRepository |
| `queryMemory` | "What does Sarah like?" | MemoryRepository + LLM |
| `searchContacts` | "Find John's phone number" | ContactsService |
| `searchEmails` | "Find emails from Amazon" | (planned) |
| `generalChat` | Everything else | LLM |

#### Entity Anonymizer

Protects privacy by replacing PII before sending to LLM:

```
Input:  "Schedule lunch with Sarah Chen at 415-555-1234"
Sent:   "Schedule lunch with PERSON_1 at PHONE_1"
Response: "I've scheduled lunch with PERSON_1..."
Output: "I've scheduled lunch with Sarah Chen..."
```

**Anonymized entities:**
- Names → `PERSON_1`, `PERSON_2`
- Phones → `PHONE_1`, `PHONE_2`
- Emails → `EMAIL_1`, `EMAIL_2`
- Addresses → `ADDRESS_1`

### Chat (`/features/chat/`)

The main conversation interface.

```
chat/
├── chat_screen.dart              # Main chat UI
├── chat_controller.dart          # State management
├── screens/
│   └── conversation_history_screen.dart
└── widgets/
    ├── message_bubble.dart       # Message display
    ├── chat_input_bar.dart       # Text input
    ├── jarvis_markdown.dart      # Markdown rendering
    ├── jarvis_code_block.dart    # Code syntax highlighting
    ├── enhanced_typing_indicator.dart # Animated typing dots
    ├── suggestion_chip.dart      # Quick action chips
    ├── chat_sidebar.dart         # Conversation list
    ├── conversation_menu.dart    # Context menu
    ├── tool_access_card.dart     # Tool execution display
    └── user_menu_sheet.dart      # User options
```

**ChatController Features:**
- Conversation CRUD
- Message streaming
- Local + remote persistence
- Agent integration
- History management

### Memory (`/features/memory/`)

Visualization and management of the knowledge graph.

```
memory/
├── models/
│   └── memory_node.dart          # Memory node model
├── screens/
│   ├── memory_hub_screen.dart    # Main memory view
│   ├── memory_detail_screen.dart # Node detail view
│   └── memory_search_screen.dart # Semantic search
├── controllers/
│   └── memory_controller.dart    # State management
├── services/
│   └── memory_service.dart       # Memory operations
└── widgets/
    ├── memory_node_card.dart     # Node display card
    ├── memory_action_tile.dart   # Action buttons
    └── stats_card.dart           # Statistics display
```

**Memory Node Types:**
- `person` - People you know
- `organization` - Companies, institutions
- `location` - Places
- `event` - Events, meetings
- `fact` - Facts about entities
- `preference` - Your preferences
- `relationship` - Connections between nodes

### Auth (`/features/auth/`)

Authentication flow.

```
auth/
├── auth_controller.dart          # Auth state management
├── providers/
│   └── password_reset_provider.dart
├── screens/
│   ├── splash_screen.dart        # Initial loading
│   ├── boot_transition_screen.dart # Jarvis boot animation
│   ├── new_login_screen.dart     # Login form
│   ├── sign_up_screen.dart       # Registration
│   ├── forgot_password_screen.dart
│   └── reset_password_screen.dart
└── services/
    └── google_auth_service.dart  # Google Sign-In
```

**Auth Flow:**
1. Splash → Check stored token
2. Boot Transition → Jarvis animation + sound
3. Login/Signup → JWT authentication
4. Main App → Authenticated routes

### Settings (`/features/settings/`)

App configuration.

```
settings/
├── settings_screen.dart          # Settings UI
├── providers/
│   └── settings_provider.dart    # Settings state
└── widgets/
    ├── settings_section.dart     # Section grouping
    └── settings_tile.dart        # Individual setting row
```

**Settings Categories:**
- **Privacy**: Anonymization toggle, memory extraction toggle
- **AI**: Provider selection (Groq/OpenAI), temperature, response length
- **Appearance**: Theme mode, haptics
- **Account**: Profile, logout

### Integrations (`/features/integrations/`)

UI for managing third-party connections.

```
integrations/
├── screens/
│   ├── integrations_hub_screen.dart # All integrations
│   └── oauth_flow_screen.dart       # OAuth flow UI
├── providers/
│   └── integrations_provider.dart
├── models/
│   ├── integration.dart
│   ├── mock_integrations.dart
│   └── oauth_flow_state.dart
└── widgets/
    ├── integration_card.dart
    ├── connection_status.dart
    ├── service_icon.dart
    ├── permission_dialog.dart
    └── connection_success_animation.dart
```

### Onboarding (`/features/onboarding/`)

First-run experience.

```
onboarding/
├── onboarding_screen.dart
├── onboarding_controller.dart
├── providers/
│   └── onboarding_provider.dart
└── widgets/
    ├── welcome_page.dart
    ├── memory_page.dart
    ├── integrations_page.dart
    ├── knowledge_graph_visual.dart
    └── page_indicator.dart
```

---

## State Management

**Riverpod** is used throughout for dependency injection and state management.

### Key Providers

```dart
// Auth
final authControllerProvider = NotifierProvider<AuthController, AuthState>(...);

// Chat
final chatControllerProvider = NotifierProvider<ChatController, ChatState>(...);

// Agent
final agentControllerProvider = NotifierProvider<AgentController, AgentState>(...);

// Data
final dataServiceProvider = Provider<DataService>(...);
final memoryRepositoryProvider = Provider<MemoryRepository>(...);

// Services
final calendarServiceProvider = Provider<CalendarService>(...);
final contactsServiceProvider = Provider<ContactsService>(...);

// Settings
final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(...);
final themeModeProvider = Provider<ThemeMode>(...);
```

---

## Native Bridges (iOS)

Located in `ios/Runner/`:

| Bridge | Channel | Purpose |
|--------|---------|---------|
| `CalendarBridge.swift` | `com.jarvis/calendar` | iOS EventKit access |
| `ContactsBridge.swift` | `com.jarvis/contacts` | iOS Contacts access |

Both bridges implement `FlutterPlugin` and register via `AppDelegate.swift`.

---

## Data Flow Examples

### Creating a Calendar Event

```
User: "Schedule lunch with Sarah tomorrow at noon"
         │
         ▼
    IntentClassifier
    → Intent: createEvent
    → Entities: {people: ["Sarah"], dates: ["tomorrow"], times: ["noon"]}
         │
         ▼
    FunctionRouter
    → Handled locally: true
    → ActionPayload: {attendees: ["Sarah"], date: "tomorrow", time: "12pm"}
         │
         ▼
    CalendarActionExecutor
    → Parse date: "tomorrow" → 2024-11-30
    → Parse time: "12pm" → 12:00
    → Create CalendarEvent
         │
         ▼
    CalendarService (Dart)
    → MethodChannel.invokeMethod('createEvent', params)
         │
         ▼
    CalendarBridge (Swift)
    → EKEventStore.save(event)
         │
         ▼
    iOS Calendar
    → Event appears in Calendar app!
```

### Semantic Memory Query

```
User: "What does Sarah like?"
         │
         ▼
    IntentClassifier
    → Intent: queryMemory
    → Entities: {people: ["Sarah"]}
         │
         ▼
    MemoryRepository.searchNodesSemantically("Sarah")
         │
         ▼
    LocalEmbeddingService.generateEmbedding("Sarah")
    → [0.23, -0.45, 0.12, ...] (384 dims)
         │
         ▼
    VectorStore.findSimilar(embedding, limit: 5)
    → Returns matching memory nodes
         │
         ▼
    MemoryRepository.getNodeWithRelationships(nodeId)
    → Returns node + edges + connected nodes
         │
         ▼
    AgentController._buildMemoryContext()
    → "Person: Sarah\n  - likes → sushi\n  - works at → Google"
         │
         ▼
    LLM (with context)
    → "Sarah likes sushi and works at Google!"
```

---

## Key Concepts

### Privacy-First Architecture

1. **On-Device Processing**: Intent classification, entity extraction, and memory storage all happen locally
2. **Anonymization**: PII is stripped before any data leaves the device
3. **Local Embeddings**: TensorFlow Lite generates vectors without network calls
4. **User Control**: Privacy settings let users disable features

### Local-First Data

1. **SQLite (Drift)**: Primary storage for structured data
2. **ObjectBox**: Vector similarity search
3. **TensorFlow Lite**: On-device ML inference
4. **Sync (planned)**: Optional cloud backup with E2E encryption

### Extensible Integrations

1. **Tool Registry**: Define tools with JSON Schema
2. **OAuth Framework**: Pluggable OAuth providers
3. **Native Bridges**: iOS/Android platform channels

---

## Running the App

```bash
# Get dependencies
flutter pub get

# Generate code (Drift, ObjectBox, Riverpod)
dart run build_runner build --delete-conflicting-outputs

# Run on iOS Simulator
flutter run -d <device_id>

# Run integration tests
flutter test integration_test/calendar_integration_test.dart -d <device_id>
```

---

## File Count Summary

| Directory | Files | Purpose |
|-----------|-------|---------|
| `core/` | 45 | Shared infrastructure |
| `data/` | 20 | Data layer |
| `features/` | 70+ | Feature modules |
| **Total** | **~135** | Dart source files |

---

## Tech Stack

| Category | Technology |
|----------|------------|
| Framework | Flutter 3.x |
| State | Riverpod |
| Navigation | GoRouter |
| Database | Drift (SQLite) |
| Vectors | ObjectBox |
| ML | TensorFlow Lite |
| HTTP | Dio |
| Auth | JWT + OAuth |
| Storage | flutter_secure_storage |
