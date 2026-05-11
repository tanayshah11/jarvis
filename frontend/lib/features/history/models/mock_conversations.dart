import 'conversation.dart';

/// Mock conversation data for development and testing.
final List<Conversation> mockConversations = [
  // TODAY
  Conversation(
    id: '1',
    title: 'Quantum Computing Basics',
    timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    lastMessage: 'Can you explain quantum entanglement?',
    messageCount: 15,
    modelId: 'claude-sonnet-4',
  ),
  Conversation(
    id: '2',
    title: 'Flutter State Management',
    timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    lastMessage: 'How does Riverpod compare to Provider?',
    messageCount: 8,
    modelId: 'gpt-4o',
  ),
  Conversation(
    id: '3',
    title: 'Machine Learning Models',
    timestamp: DateTime.now().subtract(const Duration(hours: 8)),
    lastMessage: 'What are transformer architectures?',
    messageCount: 22,
    modelId: 'claude-opus-4',
  ),

  // YESTERDAY
  Conversation(
    id: '4',
    title: 'Python Best Practices',
    timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
    lastMessage: 'Type hints and mypy usage',
    messageCount: 12,
    modelId: 'gpt-4o',
  ),
  Conversation(
    id: '5',
    title: 'Database Design Patterns',
    timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 8)),
    lastMessage: 'Normalization vs denormalization',
    messageCount: 18,
    modelId: 'claude-sonnet-4',
  ),
  Conversation(
    id: '6',
    title: 'Microservices Architecture',
    timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 12)),
    lastMessage: 'Service mesh and API gateway',
    messageCount: 25,
    modelId: 'gpt-4o-mini',
  ),

  // PREVIOUS 7 DAYS
  Conversation(
    id: '7',
    title: 'Docker & Kubernetes',
    timestamp: DateTime.now().subtract(const Duration(days: 3)),
    lastMessage: 'Container orchestration strategies',
    messageCount: 30,
    modelId: 'claude-sonnet-4',
  ),
  Conversation(
    id: '8',
    title: 'GraphQL vs REST',
    timestamp: DateTime.now().subtract(const Duration(days: 4)),
    lastMessage: 'When to use each approach',
    messageCount: 14,
    modelId: 'gpt-4o',
  ),
  Conversation(
    id: '9',
    title: 'Cryptography Fundamentals',
    timestamp: DateTime.now().subtract(const Duration(days: 5)),
    lastMessage: 'Public key infrastructure',
    messageCount: 20,
    modelId: 'claude-opus-4',
  ),
  Conversation(
    id: '10',
    title: 'UI/UX Design Principles',
    timestamp: DateTime.now().subtract(const Duration(days: 6)),
    lastMessage: 'Color theory and typography',
    messageCount: 16,
    modelId: 'gpt-4o',
  ),
  Conversation(
    id: '11',
    title: 'Performance Optimization',
    timestamp: DateTime.now().subtract(const Duration(days: 7)),
    lastMessage: 'Code profiling and bottlenecks',
    messageCount: 28,
    modelId: 'groq-llama-3',
  ),

  // OLDER
  Conversation(
    id: '12',
    title: 'Blockchain Technology',
    timestamp: DateTime.now().subtract(const Duration(days: 10)),
    lastMessage: 'Consensus mechanisms explained',
    messageCount: 35,
    modelId: 'claude-sonnet-4',
  ),
  Conversation(
    id: '13',
    title: 'CI/CD Pipelines',
    timestamp: DateTime.now().subtract(const Duration(days: 14)),
    lastMessage: 'GitHub Actions workflow',
    messageCount: 19,
    modelId: 'gpt-4o',
  ),
  Conversation(
    id: '14',
    title: 'Data Structures & Algorithms',
    timestamp: DateTime.now().subtract(const Duration(days: 20)),
    lastMessage: 'Binary tree traversal methods',
    messageCount: 42,
    modelId: 'claude-opus-4',
  ),
  Conversation(
    id: '15',
    title: 'Cloud Computing Basics',
    timestamp: DateTime.now().subtract(const Duration(days: 25)),
    lastMessage: 'AWS vs Azure vs GCP',
    messageCount: 23,
    modelId: 'gpt-4o',
  ),
];
