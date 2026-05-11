# Memory Feature Architecture

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                        UI LAYER                              │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────────────┐      ┌────────────────────────┐  │
│  │ MemorySearchScreen   │      │ MemoryDetailScreen     │  │
│  │                      │      │                        │  │
│  │ - Search Bar         │      │ - Edit Mode            │  │
│  │ - Filter Chips       │      │ - Form Inputs          │  │
│  │ - Node Cards List    │◄────►│ - Save/Cancel          │  │
│  │ - Pull to Refresh    │      │ - Statistics Display   │  │
│  └──────────┬───────────┘      └───────────┬────────────┘  │
│             │                               │                │
│             │  ┌──────────────────────┐    │                │
│             └─►│ MemoryNodeCard       │◄───┘                │
│                │                      │                      │
│                │ - Type Icon          │                      │
│                │ - Label & Type       │                      │
│                │ - Confidence Badge   │                      │
│                │ - Attributes Preview │                      │
│                │ - Swipe to Delete    │                      │
│                └──────────────────────┘                      │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      │ Uses Riverpod Watch/Read
                      │
┌─────────────────────▼───────────────────────────────────────┐
│                   STATE MANAGEMENT LAYER                      │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌────────────────────────────────────────────────────────┐ │
│  │ MemoryController (StateNotifier)                       │ │
│  │                                                         │ │
│  │ State:                     Actions:                    │ │
│  │ - nodes: List<MemoryNode>  - searchMemories()        │ │
│  │ - searchQuery: String      - fetchNodes()             │ │
│  │ - selectedNodeType         - getNode()                │ │
│  │ - isLoading: bool          - updateNode()             │ │
│  │ - error: String?           - deleteNode()             │ │
│  │ - isSearching: bool        - refresh()                │ │
│  │                            - setNodeTypeFilter()      │ │
│  └──────────────────┬──────────────────────────────────────┘ │
│                     │                                         │
└─────────────────────┼─────────────────────────────────────────┘
                      │
                      │ Calls Service Methods
                      │
┌─────────────────────▼───────────────────────────────────────┐
│                    SERVICE LAYER                              │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌────────────────────────────────────────────────────────┐ │
│  │ MemoryService                                          │ │
│  │                                                         │ │
│  │ Methods:                                               │ │
│  │ - searchMemories(query)                               │ │
│  │ - fetchNodes({nodeType, limit})                       │ │
│  │ - getNode(nodeId)                                     │ │
│  │ - updateNode(nodeId, {label, attributes, confidence}) │ │
│  │ - deleteNode(nodeId)                                  │ │
│  │                                                         │ │
│  └──────────────────┬──────────────────────────────────────┘ │
│                     │                                         │
└─────────────────────┼─────────────────────────────────────────┘
                      │
                      │ Uses ApiClient
                      │
┌─────────────────────▼───────────────────────────────────────┐
│                   NETWORK LAYER                               │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌────────────────────────────────────────────────────────┐ │
│  │ ApiClient (Dio)                                        │ │
│  │                                                         │ │
│  │ - GET /memory/search?query=...                        │ │
│  │ - GET /memory/nodes?node_type=...&limit=...          │ │
│  │ - GET /memory/nodes/{node_id}                         │ │
│  │ - PATCH /memory/nodes/{node_id}                       │ │
│  │ - DELETE /memory/nodes/{node_id}                      │ │
│  │                                                         │ │
│  │ Features:                                              │ │
│  │ - Auto JWT token injection                            │ │
│  │ - Error handling                                       │ │
│  │ - Request/response interceptors                       │ │
│  └──────────────────┬──────────────────────────────────────┘ │
│                     │                                         │
└─────────────────────┼─────────────────────────────────────────┘
                      │
                      │ HTTP Requests
                      │
┌─────────────────────▼───────────────────────────────────────┐
│                    BACKEND API                                │
│                  (Phase 1 Complete)                           │
└─────────────────────────────────────────────────────────────┘


┌─────────────────────────────────────────────────────────────┐
│                      DATA MODELS                              │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌────────────────────────────────────────────────────────┐ │
│  │ MemoryNode                                             │ │
│  │                                                         │ │
│  │ Properties:                                            │ │
│  │ - id: String                                           │ │
│  │ - type: String                                         │ │
│  │ - label: String                                        │ │
│  │ - attributes: Map<String, dynamic>                    │ │
│  │ - confidence: double                                   │ │
│  │ - referenceCount: int                                  │ │
│  │ - similarity: double? (optional)                       │ │
│  │                                                         │ │
│  │ Methods:                                               │ │
│  │ - fromJson()                                           │ │
│  │ - toJson()                                             │ │
│  │ - copyWith()                                           │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                               │
│  ┌────────────────────────────────────────────────────────┐ │
│  │ NodeType (Enum)                                        │ │
│  │                                                         │ │
│  │ Values:                                                │ │
│  │ - all                                                  │ │
│  │ - person                                               │ │
│  │ - place                                                │ │
│  │ - preference                                           │ │
│  │ - organization                                         │ │
│  │ - event                                                │ │
│  │ - concept                                              │ │
│  │                                                         │ │
│  │ Methods:                                               │ │
│  │ - displayName                                          │ │
│  │ - value                                                │ │
│  │ - fromString()                                         │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

## Data Flow

### Search Flow
```
User Input (Search Bar)
    ↓
MemorySearchScreen onSubmitted
    ↓
MemoryController.searchMemories(query)
    ↓
MemoryService.searchMemories(query)
    ↓
ApiClient.get('/memory/search', queryParameters: {query})
    ↓
Backend API Processing
    ↓
Response: {results: [MemoryNode...]}
    ↓
MemoryService parses response
    ↓
MemoryController updates state.nodes
    ↓
UI rebuilds with new nodes
    ↓
MemoryNodeCard widgets displayed
```

### Filter Flow
```
User Taps Filter Chip
    ↓
MemorySearchScreen onSelected
    ↓
MemoryController.setNodeTypeFilter(nodeType)
    ↓
State updated with new selectedNodeType
    ↓
MemoryController.fetchNodes() called automatically
    ↓
MemoryService.fetchNodes(nodeType: type)
    ↓
ApiClient.get('/memory/nodes', queryParameters: {node_type, limit})
    ↓
Backend returns filtered nodes
    ↓
State.nodes updated
    ↓
UI rebuilds with filtered results
```

### Update Flow
```
User Taps Edit Icon
    ↓
MemoryDetailScreen sets isEditing = true
    ↓
User Modifies Fields
    ↓
User Taps Save Changes
    ↓
MemoryDetailScreen._saveChanges()
    ↓
MemoryController.updateNode(id, {label, attributes, confidence})
    ↓
MemoryService.updateNode(...)
    ↓
ApiClient.patch('/memory/nodes/{id}', data: {...})
    ↓
Backend updates node
    ↓
Response: Updated MemoryNode
    ↓
MemoryController updates local state
    ↓
UI shows success message
    ↓
Screen reloads with updated data
```

### Delete Flow
```
User Swipes Card Left
    ↓
Dismissible widget triggered
    ↓
Confirmation Dialog shown
    ↓
User Confirms
    ↓
MemoryNodeCard onDelete callback
    ↓
MemoryController.deleteNode(nodeId)
    ↓
MemoryService.deleteNode(nodeId)
    ↓
ApiClient.delete('/memory/nodes/{id}')
    ↓
Backend deletes node
    ↓
MemoryController removes from state.nodes
    ↓
UI shows SnackBar confirmation
    ↓
Card animates out of view
```

## State Management Flow

### State Structure
```dart
MemoryState {
  nodes: List<MemoryNode>      // Current list of nodes
  searchQuery: String           // Current search query
  selectedNodeType: NodeType    // Current filter
  isLoading: bool              // General loading state
  error: String?               // Error message if any
  isSearching: bool            // Specific to search operations
}
```

### State Updates (Immutable)
```dart
// Every state change creates a new state object
state = state.copyWith(
  nodes: updatedNodes,
  isLoading: false,
);

// Riverpod watches for changes and rebuilds UI
ref.watch(memoryControllerProvider)
```

## Navigation Flow

```
App Router (/memory/search)
    ↓
MemorySearchScreen
    │
    ├─ Tap on MemoryNodeCard
    │    ↓
    │  Navigator.push(MemoryDetailScreen)
    │    ↓
    │  MemoryDetailScreen(nodeId: node.id)
    │    │
    │    ├─ Tap Edit → Edit Mode
    │    ├─ Tap Save → Update & Refresh
    │    └─ Tap Back → Return to Search
    │
    ├─ Swipe Card
    │    ↓
    │  Confirmation Dialog
    │    ↓
    │  Delete & Show SnackBar
    │
    └─ Pull to Refresh → Reload Data
```

## Dependency Injection (Riverpod)

```
Provider Hierarchy:

secureStorageProvider (global)
    ↓
apiClientProvider
    ↓
memoryServiceProvider
    ↓
memoryControllerProvider
    ↓
UI Components (ConsumerWidget/ConsumerStatefulWidget)
```

## Component Hierarchy

```
MemorySearchScreen
├── AppBar
├── Column
    ├── JarvisInput (Search Bar)
    │   └── IconButton (Clear)
    ├── SizedBox (Filter Chips Container)
    │   └── ListView (Horizontal)
    │       └── JarvisChip (x7, one per NodeType)
    └── Expanded
        └── RefreshIndicator
            └── ListView.builder
                └── MemoryNodeCard (x N nodes)
                    └── JarvisCard
                        ├── Dismissible (Swipe to Delete)
                        └── Column
                            ├── Row (Header: Icon, Label, Confidence)
                            ├── Divider
                            ├── Wrap (Attribute Chips x3)
                            └── Row (Similarity Score)
```

```
MemoryDetailScreen
├── AppBar
│   └── Actions
│       ├── Edit IconButton
│       └── Close IconButton
└── SingleChildScrollView
    └── Column
        ├── GlassContainer (Header Card)
        │   └── Row (Icon, Type, ID)
        ├── Text ("Label")
        ├── JarvisInput/GlassContainer (Label)
        ├── Text ("Confidence")
        ├── JarvisInput/GlassContainer (Confidence + Progress Bar)
        ├── Text ("Attributes")
        ├── For each attribute:
        │   └── JarvisInput/GlassContainer
        ├── Text ("Statistics")
        ├── GlassContainer
        │   ├── Row (Reference Count)
        │   └── Row (Similarity)
        └── JarvisButton (Save Changes)
```

## Error Handling Strategy

```
Try-Catch at Service Layer
    ↓
Throw custom exceptions with messages
    ↓
Controller catches and sets state.error
    ↓
UI shows error state:
    - Error icon
    - Error message
    - Retry button
    ↓
User taps retry
    ↓
Controller clears error and retries operation
```

## Performance Optimizations

1. **Immutable State**: Only rebuilds widgets that depend on changed state
2. **Provider Scoping**: Services are singletons, controllers are scoped
3. **ListView.builder**: Lazy loading of cards
4. **Dismissible**: Hardware-accelerated swipe animations
5. **RefreshIndicator**: Native pull-to-refresh with proper async handling
6. **copyWith Pattern**: Efficient state updates without full object recreation

## Type Safety

- Full null safety compliance
- Typed providers (no dynamic)
- Enum for node types (no string comparison errors)
- Required parameters where appropriate
- Optional parameters with defaults

## Separation of Concerns

| Layer | Responsibility | Dependencies |
|-------|---------------|--------------|
| UI | Display & user input | Controller (read-only) |
| Controller | Business logic & state | Service |
| Service | API communication | ApiClient |
| ApiClient | HTTP requests | Dio, SecureStorage |
| Models | Data structures | None |

## Testing Strategy

```
Unit Tests
├── MemoryNode serialization/deserialization
├── NodeType enum conversions
├── MemoryService methods (mocked ApiClient)
└── MemoryController state transitions

Widget Tests
├── MemoryNodeCard interactions
├── MemorySearchScreen search flow
├── MemoryDetailScreen edit mode
└── Filter chip selection

Integration Tests
├── Full search flow
├── Edit and save flow
└── Delete with confirmation flow
```

This architecture ensures:
- ✓ Separation of concerns
- ✓ Testability
- ✓ Maintainability
- ✓ Scalability
- ✓ Type safety
- ✓ Performance
- ✓ Error handling
- ✓ User experience
