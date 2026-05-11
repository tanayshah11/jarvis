# Memory Feature - Phase 1 Implementation

This directory contains the Memory Search UI implementation for the Jarvis Flutter app.

## Overview

The Memory feature allows users to search, view, and manage their knowledge graph nodes that Jarvis has learned about them. This includes information about people, places, preferences, organizations, events, and concepts.

## Structure

```
memory/
├── models/
│   └── memory_node.dart          # Data model for memory nodes with NodeType enum
├── services/
│   └── memory_service.dart       # API service for memory endpoints
├── controllers/
│   └── memory_controller.dart    # Riverpod state management controller
├── screens/
│   ├── memory_search_screen.dart # Main search interface with filters
│   └── memory_detail_screen.dart # Detail view with edit capabilities
├── widgets/
│   └── memory_node_card.dart     # Card component for displaying memory nodes
└── README.md                      # This file
```

## Features Implemented

### 1. Memory Node Model (`models/memory_node.dart`)
- **MemoryNode class**: Represents a knowledge graph node
  - Properties: id, type, label, attributes, confidence, referenceCount, similarity
  - JSON serialization/deserialization
  - copyWith method for immutable updates

- **NodeType enum**: Type-safe node type filtering
  - Types: all, person, place, preference, organization, event, concept
  - Display names and value conversions

### 2. Memory Service (`services/memory_service.dart`)
- API integration using the existing ApiClient pattern
- Methods:
  - `searchMemories(query)` - Semantic search via `GET /memory/search`
  - `fetchNodes({type, limit})` - List nodes with filters via `GET /memory/nodes`
  - `getNode(nodeId)` - Get single node via `GET /memory/nodes/{id}`
  - `updateNode(nodeId, {label, attributes, confidence})` - Update via `PATCH /memory/nodes/{id}`
  - `deleteNode(nodeId)` - Delete via `DELETE /memory/nodes/{id}`

### 3. Memory Controller (`controllers/memory_controller.dart`)
- Riverpod StateNotifier for state management
- State includes:
  - List of memory nodes
  - Current search query
  - Selected node type filter
  - Loading and error states
- Methods:
  - Search and fetch operations
  - Node CRUD operations
  - Pull-to-refresh support
  - Error handling

### 4. Memory Search Screen (`screens/memory_search_screen.dart`)
- Main UI with:
  - Search bar at the top with clear button
  - Horizontal scrolling filter chips for node types
  - List of memory node cards
  - Pull-to-refresh functionality
  - Empty states for no results
  - Error handling with retry
  - Loading indicators

### 5. Memory Detail Screen (`screens/memory_detail_screen.dart`)
- Detail view with:
  - Node type header with icon and color coding
  - Label display/edit
  - Confidence display/edit with visual indicator
  - Attributes list display/edit
  - Statistics (reference count, similarity)
  - Edit mode toggle
  - Save functionality with loading state
  - Error handling

### 6. Memory Node Card (`widgets/memory_node_card.dart`)
- Card component featuring:
  - Color-coded node type icons
  - Label and type display
  - Confidence indicator badge
  - Attributes preview (first 3)
  - Similarity score (when available)
  - Tap to view details
  - Swipe-to-delete with confirmation dialog

## Node Type Color Coding

Each node type has a unique color for easy visual identification:

- **Person**: Cyan (`#00D9FF`)
- **Place**: Green (`#00C48C`)
- **Preference**: Red (`#FF4757`)
- **Organization**: Orange (`#FFB800`)
- **Event**: Purple (`#6C5CE7`)
- **Concept**: Light Purple (`#8B7CFF`)

## Navigation

The memory feature is integrated into the app router:

- `/memory` - Memory Hub (existing)
- `/memory/search` - Memory Search Screen
- `/memory/detail/:nodeId` - Memory Detail Screen

## Usage Example

### Navigate to Memory Search
```dart
import 'package:go_router/go_router.dart';

// Using go_router
context.go('/memory/search');

// Or with pushNamed
context.pushNamed('/memory/search');
```

### Navigate to Memory Detail
```dart
// From memory search screen (already implemented)
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => MemoryDetailScreen(nodeId: nodeId),
  ),
);

// Or using go_router
context.go('/memory/detail/$nodeId');
```

### Access Memory Controller
```dart
// In a ConsumerWidget
final memoryState = ref.watch(memoryControllerProvider);
final memoryController = ref.read(memoryControllerProvider.notifier);

// Search for memories
await memoryController.searchMemories('pizza');

// Filter by type
memoryController.setNodeTypeFilter(NodeType.person);

// Update a node
await memoryController.updateNode(
  nodeId,
  label: 'Updated Label',
  attributes: {'key': 'value'},
  confidence: 0.9,
);

// Delete a node
await memoryController.deleteNode(nodeId);
```

## Design System

The implementation follows the existing Jarvis design system:

- **Colors**: Uses `AppColors` from `core/theme/colors.dart`
- **Spacing**: Uses `AppSpacing` and `AppRadius` from `core/theme/spacing.dart`
- **Components**: Leverages existing widgets:
  - `JarvisCard` - Card container
  - `JarvisInput` - Text input fields
  - `JarvisButton` - Action buttons
  - `JarvisChip` - Filter chips
  - `GlassContainer` - Glass morphism effects

## API Integration

The feature expects the following backend endpoints to be available:

1. **GET /memory/search?query={query}**
   - Returns: `{ "results": [MemoryNode...] }`

2. **GET /memory/nodes?node_type={type}&limit={limit}**
   - Returns: `{ "nodes": [MemoryNode...] }`

3. **GET /memory/nodes/{nodeId}**
   - Returns: `MemoryNode`

4. **PATCH /memory/nodes/{nodeId}**
   - Body: `{ "label": "...", "attributes": {...}, "confidence": 0.8 }`
   - Returns: `MemoryNode`

5. **DELETE /memory/nodes/{nodeId}**
   - Returns: Success status

## Error Handling

- Network errors are caught and displayed to users
- Failed operations show error messages via SnackBar
- Retry functionality for failed loads
- Form validation for edit operations
- Loading states prevent duplicate operations

## State Management

Uses Riverpod with StateNotifier pattern:
- Immutable state updates via copyWith
- Provider-based dependency injection
- Separation of concerns (UI, business logic, data)

## Future Enhancements

Potential Phase 2 features:
- Node creation from UI
- Advanced search filters
- Relationship visualization
- Batch operations
- Export functionality
- Node merging
- History/version tracking

## Testing Recommendations

1. **Unit Tests**
   - Test MemoryNode serialization
   - Test service methods with mock API client
   - Test controller state transitions

2. **Widget Tests**
   - Test card interactions
   - Test search functionality
   - Test edit mode toggle

3. **Integration Tests**
   - Test full search flow
   - Test edit and save flow
   - Test delete with undo

## Dependencies

- `flutter_riverpod` - State management
- `go_router` - Navigation (already in project)
- `dio` - HTTP client (via ApiClient)

No additional dependencies were added beyond what's already in the project.

## Notes

- All files follow the existing code patterns from the chat feature
- Responsive design adapts to different screen sizes
- Accessibility considerations included (semantic labels, contrast)
- Material Design 3 components used throughout
- Optimistic UI updates for better UX
