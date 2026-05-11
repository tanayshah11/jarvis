# Memory Search UI - Quick Start Guide

## 🚀 Getting Started

The Memory Search UI is **ready to use** - no additional setup required!

## 📱 How to Access

### Option 1: Direct Navigation (Recommended)
```dart
import 'package:go_router/go_router.dart';

// Navigate to search screen
context.go('/memory/search');

// Navigate to specific node detail
context.go('/memory/detail/node-id-here');
```

### Option 2: Add to Your Navigation Menu
```dart
ListTile(
  leading: const Icon(Icons.psychology),
  title: const Text('Memory Search'),
  onTap: () => context.go('/memory/search'),
)
```

### Option 3: Add to Bottom Navigation
Already integrated via existing memory hub at `/memory`

## 🎯 Key Features at a Glance

### Search Screen (`/memory/search`)
```
┌─────────────────────────────────┐
│ ← Memory Search              ⋮  │  ← App Bar
├─────────────────────────────────┤
│ 🔍 Search memories...        ✕  │  ← Search Bar
├─────────────────────────────────┤
│ ⚪ All  👤 Person  📍 Place  ❤️ │  ← Filter Chips
│   Preference  🏢 Organization    │     (Horizontal Scroll)
├─────────────────────────────────┤
│ ┌─────────────────────────────┐ │
│ │ 👤 John Doe        ✓ 85%   │ │  ← Memory Card
│ │ PERSON                       │ │
│ │ ─────────────────────────── │ │
│ │ email: john@example.com     │ │  ← Attributes
│ │ age: 30                      │ │
│ └─────────────────────────────┘ │
│                                  │
│ ┌─────────────────────────────┐ │
│ │ 📍 San Francisco   ✓ 92%   │ │  ← Another Card
│ │ PLACE                        │ │
│ │ ─────────────────────────── │ │
│ │ country: USA                 │ │
│ └─────────────────────────────┘ │
│                                  │
│ Pull to refresh...               │  ← Pull-to-refresh
└─────────────────────────────────┘
```

### Detail Screen (`/memory/detail/:nodeId`)
```
┌─────────────────────────────────┐
│ ← Memory Details          ✏️    │  ← Edit Button
├─────────────────────────────────┤
│ ┌─────────────────────────────┐ │
│ │ 👤  PERSON                  │ │  ← Type Header
│ │     ID: node-123            │ │
│ └─────────────────────────────┘ │
│                                  │
│ Label                            │
│ ┌─────────────────────────────┐ │
│ │ John Doe                    │ │  ← Label Display
│ └─────────────────────────────┘ │
│                                  │
│ Confidence                       │
│ ┌─────────────────────────────┐ │
│ │ 85% ████████████░░░░░░░░░░ │ │  ← Progress Bar
│ └─────────────────────────────┘ │
│                                  │
│ Attributes                       │
│ ┌─────────────────────────────┐ │
│ │ email                       │ │
│ │ john@example.com            │ │  ← Each Attribute
│ └─────────────────────────────┘ │
│ ┌─────────────────────────────┐ │
│ │ age                         │ │
│ │ 30                          │ │
│ └─────────────────────────────┘ │
│                                  │
│ Statistics                       │
│ ┌─────────────────────────────┐ │
│ │ 🔗 Reference Count      5   │ │  ← Stats
│ │ ⇄ Similarity        87.5%  │ │
│ └─────────────────────────────┘ │
└─────────────────────────────────┘
```

## 🎨 Visual Guide

### Node Type Colors
```
👤 Person         → Cyan      #00D9FF
📍 Place          → Green     #00C48C
❤️  Preference     → Red       #FF4757
🏢 Organization   → Orange    #FFB800
📅 Event          → Purple    #6C5CE7
💡 Concept        → Lt Purple #8B7CFF
```

### Confidence Colors
```
✓ High (70-100%)   → Green  #00C48C
⚠ Medium (40-69%)  → Orange #FFB800
✗ Low (0-39%)      → Red    #FF4757
```

## 💻 Code Examples

### 1. Using the Controller in Your Widget

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_app/features/memory/controllers/memory_controller.dart';
import 'package:your_app/features/memory/models/memory_node.dart';

class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the state
    final memoryState = ref.watch(memoryControllerProvider);
    final controller = ref.read(memoryControllerProvider.notifier);

    // Access data
    final nodes = memoryState.nodes;
    final isLoading = memoryState.isLoading;
    final error = memoryState.error;

    // Perform actions
    controller.searchMemories('pizza');
    controller.setNodeTypeFilter(NodeType.person);

    return YourUIHere();
  }
}
```

### 2. Search Functionality

```dart
// Simple search
await controller.searchMemories('John');

// With filter
controller.setNodeTypeFilter(NodeType.person);
await controller.fetchNodes();

// Clear search
controller.setSearchQuery('');
await controller.fetchNodes();
```

### 3. CRUD Operations

```dart
// Get a node
final node = await controller.getNode('node-id-123');

// Update a node
final success = await controller.updateNode(
  'node-id-123',
  label: 'New Label',
  attributes: {'key': 'value'},
  confidence: 0.9,
);

// Delete a node
final success = await controller.deleteNode('node-id-123');

// Refresh list
await controller.refresh();
```

### 4. Navigate Programmatically

```dart
// Go to search
context.go('/memory/search');

// Go to specific node
final nodeId = 'node-id-123';
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => MemoryDetailScreen(nodeId: nodeId),
  ),
);
```

## 🎬 User Interactions

### Search
1. User types in search bar
2. Press Enter or wait for auto-search
3. Results appear instantly
4. Tap ✕ to clear search

### Filter
1. Tap a filter chip (e.g., "Person")
2. List filters to show only that type
3. Tap "All" to clear filter

### View Details
1. Tap any memory card
2. Detail screen opens
3. View all information

### Edit
1. In detail screen, tap ✏️ (edit icon)
2. Modify any field
3. Tap "Save Changes"
4. Success message appears

### Delete
1. Swipe card left ← ← ←
2. Red delete icon appears
3. Confirm in dialog
4. Card disappears with animation

### Refresh
1. Pull down list from top ↓
2. Loading indicator appears
3. List refreshes with latest data

## 🐛 Error Handling

### No Results
```
🔍
No memories found matching "xyz"
Try a different search term
```

### Network Error
```
⚠️
Failed to load memories
[Retry Button]
```

### Empty State
```
🧠
No memories yet
Start chatting with Jarvis to build your memory graph
```

## 📊 State Management

### State Properties
```dart
memoryState.nodes              // List<MemoryNode>
memoryState.searchQuery        // String
memoryState.selectedNodeType   // NodeType enum
memoryState.isLoading          // bool
memoryState.error              // String?
memoryState.isSearching        // bool
```

### Read vs Watch
```dart
// Watch: Rebuilds on changes
final state = ref.watch(memoryControllerProvider);

// Read: No rebuilds, for actions
final controller = ref.read(memoryControllerProvider.notifier);
```

## 🧪 Testing the Feature

### Manual Test Checklist
- [ ] Navigate to `/memory/search`
- [ ] Search for a term
- [ ] Filter by node type
- [ ] Tap a card to view details
- [ ] Edit a node and save
- [ ] Swipe to delete a card
- [ ] Pull to refresh
- [ ] Check empty states
- [ ] Verify error handling

### Sample Test Data
```dart
// If testing with mock data
final mockNode = MemoryNode(
  id: 'test-1',
  type: 'person',
  label: 'Test User',
  attributes: {'email': 'test@example.com'},
  confidence: 0.85,
  referenceCount: 5,
  similarity: 0.92,
);
```

## 🔧 Troubleshooting

### Issue: Can't navigate to memory search
**Solution**: Make sure router is imported in your main.dart
```dart
import 'package:your_app/router.dart';

// In MaterialApp.router
routerConfig: ref.watch(routerProvider),
```

### Issue: State not updating
**Solution**: Use ConsumerWidget or ConsumerStatefulWidget
```dart
class MyWidget extends ConsumerWidget {  // ✓ Correct
class MyWidget extends StatelessWidget { // ✗ Wrong
```

### Issue: API errors
**Solution**: Check backend is running and endpoints are available
```bash
# Test endpoints
curl http://localhost:8000/memory/nodes
curl http://localhost:8000/memory/search?query=test
```

## 📚 Related Documentation

- **README.md** - Comprehensive feature documentation
- **ARCHITECTURE.md** - Technical architecture details
- **IMPLEMENTATION_SUMMARY.md** - Implementation overview

## 🎓 Learning Resources

### Key Concepts
1. **Riverpod**: State management
2. **Go Router**: Navigation
3. **Material Design 3**: UI components
4. **Clean Architecture**: Code organization

### Similar Patterns
Look at the chat feature for similar implementation patterns:
- `/features/chat/chat_controller.dart`
- `/features/chat/chat_screen.dart`

## ✨ Pro Tips

1. **Performance**: Use ListView.builder for long lists
2. **UX**: Always show loading states
3. **Errors**: Provide retry options
4. **Navigation**: Use go_router for type-safe routing
5. **State**: Keep state immutable with copyWith
6. **Testing**: Write tests for controllers first

## 🎯 Next Steps

1. Integrate into your main navigation
2. Test with real backend data
3. Add analytics tracking
4. Customize colors/themes
5. Add more features from Phase 2 roadmap

## 💡 Quick Commands

```dart
// Search
controller.searchMemories('query');

// Filter
controller.setNodeTypeFilter(NodeType.person);

// Refresh
controller.refresh();

// Navigate
context.go('/memory/search');
```

---

**That's it! You're ready to use the Memory Search UI. Happy coding! 🎉**
