import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

// Table imports
import 'tables/users.dart';
import 'tables/profiles.dart';
import 'tables/conversations.dart';
import 'tables/messages.dart';
import 'tables/memory_nodes.dart';
import 'tables/memory_edges.dart';
import 'tables/connections.dart';
import 'tables/insights.dart';
import 'tables/entity_cooccurrences.dart';
import 'tables/temporal_patterns.dart';

// Export tables for external use
export 'tables/users.dart';
export 'tables/profiles.dart';
export 'tables/conversations.dart';
export 'tables/messages.dart';
export 'tables/memory_nodes.dart';
export 'tables/memory_edges.dart';
export 'tables/connections.dart';
export 'tables/insights.dart';
export 'tables/entity_cooccurrences.dart';
export 'tables/temporal_patterns.dart';

part 'database.g.dart';

@DriftDatabase(tables: [
  Users,
  Profiles,
  Conversations,
  Messages,
  MemoryNodes,
  MemoryEdges,
  Connections,
  Insights,
  EntityCooccurrences,
  TemporalPatterns,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Migration from v1 to v2: Add deep network sync tables
        if (from < 2) {
          await m.createTable(entityCooccurrences);
          await m.createTable(temporalPatterns);
        }
      },
    );
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'jarvis_local');
  }

  // ============================================
  // User Operations
  // ============================================

  Future<User?> getUser(String id) {
    return (select(users)..where((u) => u.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertUser(UsersCompanion user) {
    return into(users).insert(user);
  }

  Future<bool> updateUser(User user) {
    return update(users).replace(user);
  }

  // ============================================
  // Profile Operations
  // ============================================

  Future<Profile?> getProfileByUserId(String userId) {
    return (select(profiles)..where((p) => p.userId.equals(userId)))
        .getSingleOrNull();
  }

  Future<int> insertProfile(ProfilesCompanion profile) {
    return into(profiles).insert(profile);
  }

  Future<bool> updateProfile(Profile profile) {
    return update(profiles).replace(profile);
  }

  // ============================================
  // Conversation Operations
  // ============================================

  Future<List<Conversation>> getAllConversations() {
    return (select(conversations)
          ..orderBy([
            (c) => OrderingTerm(expression: c.updatedAt, mode: OrderingMode.desc)
          ]))
        .get();
  }

  Future<Conversation?> getConversation(String id) {
    return (select(conversations)..where((c) => c.id.equals(id)))
        .getSingleOrNull();
  }

  Future<int> insertConversation(ConversationsCompanion conversation) {
    return into(conversations).insert(conversation);
  }

  Future<bool> updateConversation(Conversation conversation) {
    return update(conversations).replace(conversation);
  }

  Future<int> deleteConversation(String id) {
    return (delete(conversations)..where((c) => c.id.equals(id))).go();
  }

  // ============================================
  // Message Operations
  // ============================================

  Future<List<Message>> getMessagesByConversation(String conversationId) {
    return (select(messages)
          ..where((m) => m.conversationId.equals(conversationId))
          ..orderBy([
            (m) => OrderingTerm(expression: m.createdAt, mode: OrderingMode.asc)
          ]))
        .get();
  }

  Stream<List<Message>> watchMessagesByConversation(String conversationId) {
    return (select(messages)
          ..where((m) => m.conversationId.equals(conversationId))
          ..orderBy([
            (m) => OrderingTerm(expression: m.createdAt, mode: OrderingMode.asc)
          ]))
        .watch();
  }

  Future<int> insertMessage(MessagesCompanion message) {
    return into(messages).insert(message);
  }

  Future<int> deleteMessagesByConversation(String conversationId) {
    return (delete(messages)
          ..where((m) => m.conversationId.equals(conversationId)))
        .go();
  }

  // ============================================
  // Memory Node Operations
  // ============================================

  Future<List<MemoryNode>> getAllMemoryNodes() {
    return select(memoryNodes).get();
  }

  Future<List<MemoryNode>> searchMemoryNodes(String query) {
    return (select(memoryNodes)
          ..where((n) => n.name.like('%$query%') | n.nodeType.like('%$query%')))
        .get();
  }

  Future<MemoryNode?> getMemoryNode(String id) {
    return (select(memoryNodes)..where((n) => n.id.equals(id)))
        .getSingleOrNull();
  }

  Future<MemoryNode?> findMemoryNodeBySourceId(String source, String sourceId) {
    return (select(memoryNodes)
          ..where(
              (n) => n.source.equals(source) & n.sourceId.equals(sourceId)))
        .getSingleOrNull();
  }

  Future<int> insertMemoryNode(MemoryNodesCompanion node) {
    return into(memoryNodes).insert(node);
  }

  Future<bool> updateMemoryNode(MemoryNode node) {
    return update(memoryNodes).replace(node);
  }

  Future<int> upsertMemoryNode(MemoryNodesCompanion node) {
    return into(memoryNodes).insertOnConflictUpdate(node);
  }

  Future<int> deleteMemoryNode(String id) {
    return (delete(memoryNodes)..where((n) => n.id.equals(id))).go();
  }

  // ============================================
  // Memory Edge Operations
  // ============================================

  Future<List<MemoryEdge>> getAllMemoryEdges() {
    return select(memoryEdges).get();
  }

  Future<List<MemoryEdge>> getEdgesFromNode(String nodeId) {
    return (select(memoryEdges)..where((e) => e.fromNodeId.equals(nodeId)))
        .get();
  }

  Future<List<MemoryEdge>> getEdgesToNode(String nodeId) {
    return (select(memoryEdges)..where((e) => e.toNodeId.equals(nodeId))).get();
  }

  Future<MemoryEdge?> findEdge(String fromId, String toId, String relType) {
    return (select(memoryEdges)
          ..where((e) =>
              e.fromNodeId.equals(fromId) &
              e.toNodeId.equals(toId) &
              e.relationshipType.equals(relType)))
        .getSingleOrNull();
  }

  Future<int> insertMemoryEdge(MemoryEdgesCompanion edge) {
    return into(memoryEdges).insert(edge);
  }

  Future<bool> updateMemoryEdge(MemoryEdge edge) {
    return update(memoryEdges).replace(edge);
  }

  Future<int> upsertMemoryEdge(MemoryEdgesCompanion edge) {
    return into(memoryEdges).insertOnConflictUpdate(edge);
  }

  Future<int> deleteMemoryEdge(String id) {
    return (delete(memoryEdges)..where((e) => e.id.equals(id))).go();
  }

  /// Delete all edges connected to a node (both from and to)
  Future<int> deleteEdgesForNode(String nodeId) async {
    final fromCount = await (delete(memoryEdges)
          ..where((e) => e.fromNodeId.equals(nodeId)))
        .go();
    final toCount = await (delete(memoryEdges)
          ..where((e) => e.toNodeId.equals(nodeId)))
        .go();
    return fromCount + toCount;
  }

  // ============================================
  // Graph Traversal (SQLite Recursive CTEs)
  // ============================================

  /// Find all nodes connected to a given node within N hops
  /// Returns raw query results that can be mapped to MemoryNode
  Future<List<MemoryNode>> findConnectedNodes(String nodeId, int maxDepth) async {
    // Use a simpler approach: get edges and then fetch nodes
    final connectedIds = <String>{};
    var currentIds = <String>{nodeId};

    for (int depth = 0; depth < maxDepth; depth++) {
      final edges = await (select(memoryEdges)
            ..where((e) => e.fromNodeId.isIn(currentIds)))
          .get();

      final newIds = edges.map((e) => e.toNodeId).toSet();
      if (newIds.isEmpty) break;

      connectedIds.addAll(newIds);
      currentIds = newIds.difference(connectedIds);
    }

    if (connectedIds.isEmpty) return [];

    return (select(memoryNodes)
          ..where((n) => n.id.isIn(connectedIds) & n.id.isNotValue(nodeId)))
        .get();
  }

  /// Find path between two nodes (simplified BFS approach)
  Future<List<String>> findPath(String fromNodeId, String toNodeId, int maxDepth) async {
    if (fromNodeId == toNodeId) return [fromNodeId];

    final visited = <String>{fromNodeId};
    final parents = <String, String>{};
    var frontier = <String>{fromNodeId};

    for (int depth = 0; depth < maxDepth && frontier.isNotEmpty; depth++) {
      final edges = await (select(memoryEdges)
            ..where((e) => e.fromNodeId.isIn(frontier)))
          .get();

      final newFrontier = <String>{};
      for (final edge in edges) {
        if (!visited.contains(edge.toNodeId)) {
          visited.add(edge.toNodeId);
          parents[edge.toNodeId] = edge.fromNodeId;
          newFrontier.add(edge.toNodeId);

          if (edge.toNodeId == toNodeId) {
            // Reconstruct path
            final path = <String>[toNodeId];
            var current = toNodeId;
            while (parents.containsKey(current)) {
              current = parents[current]!;
              path.insert(0, current);
            }
            return path;
          }
        }
      }
      frontier = newFrontier;
    }

    return []; // No path found
  }

  // ============================================
  // Connection (OAuth) Operations
  // ============================================

  Future<List<Connection>> getAllConnections() {
    return select(connections).get();
  }

  Future<Connection?> getConnection(String provider) {
    return (select(connections)..where((c) => c.provider.equals(provider)))
        .getSingleOrNull();
  }

  Future<int> insertConnection(ConnectionsCompanion connection) {
    return into(connections).insert(connection);
  }

  Future<bool> updateConnection(Connection connection) {
    return update(connections).replace(connection);
  }

  Future<int> deleteConnection(String provider) {
    return (delete(connections)..where((c) => c.provider.equals(provider))).go();
  }

  // ============================================
  // Insight Operations
  // ============================================

  Future<List<Insight>> getAllInsights() {
    return (select(insights)
          ..orderBy([
            (i) => OrderingTerm(expression: i.generatedAt, mode: OrderingMode.desc)
          ]))
        .get();
  }

  Future<Insight?> getLatestInsight(String insightType) {
    return (select(insights)
          ..where((i) => i.insightType.equals(insightType))
          ..orderBy([
            (i) => OrderingTerm(expression: i.generatedAt, mode: OrderingMode.desc)
          ])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<int> insertInsight(InsightsCompanion insight) {
    return into(insights).insert(insight);
  }

  // ============================================
  // Stats
  // ============================================

  Future<Map<String, int>> getMemoryStats() async {
    final nodeQuery = selectOnly(memoryNodes)..addColumns([memoryNodes.id.count()]);
    final edgeQuery = selectOnly(memoryEdges)..addColumns([memoryEdges.id.count()]);
    final convQuery = selectOnly(conversations)..addColumns([conversations.id.count()]);
    final msgQuery = selectOnly(messages)..addColumns([messages.id.count()]);

    final nodeResult = await nodeQuery.getSingle();
    final edgeResult = await edgeQuery.getSingle();
    final convResult = await convQuery.getSingle();
    final msgResult = await msgQuery.getSingle();

    return {
      'nodes': nodeResult.read(memoryNodes.id.count()) ?? 0,
      'edges': edgeResult.read(memoryEdges.id.count()) ?? 0,
      'conversations': convResult.read(conversations.id.count()) ?? 0,
      'messages': msgResult.read(messages.id.count()) ?? 0,
    };
  }

  // ============================================
  // Entity Co-occurrence Operations
  // ============================================

  /// Get or create a co-occurrence record for two entities
  /// Entities are sorted alphabetically to ensure consistent ordering
  Future<EntityCooccurrence?> getCooccurrence(String entityA, String entityB) {
    final a = entityA.compareTo(entityB) < 0 ? entityA : entityB;
    final b = entityA.compareTo(entityB) < 0 ? entityB : entityA;
    return (select(entityCooccurrences)
          ..where((c) => c.entityA.equals(a) & c.entityB.equals(b)))
        .getSingleOrNull();
  }

  /// Track a co-occurrence between two entities
  Future<void> trackCooccurrence(
    String entityA,
    String entityB, {
    bool isNewMessage = true,
    bool isNewSession = false,
  }) async {
    final a = entityA.compareTo(entityB) < 0 ? entityA : entityB;
    final b = entityA.compareTo(entityB) < 0 ? entityB : entityA;
    final now = DateTime.now();

    final existing = await getCooccurrence(a, b);
    if (existing != null) {
      await (update(entityCooccurrences)
            ..where((c) => c.entityA.equals(a) & c.entityB.equals(b)))
          .write(EntityCooccurrencesCompanion(
        cooccurrenceCount: Value(existing.cooccurrenceCount + 1),
        messageCount:
            Value(existing.messageCount + (isNewMessage ? 1 : 0)),
        sessionCount:
            Value(existing.sessionCount + (isNewSession ? 1 : 0)),
        lastSeen: Value(now),
      ));
    } else {
      await into(entityCooccurrences).insert(EntityCooccurrencesCompanion(
        entityA: Value(a),
        entityB: Value(b),
        cooccurrenceCount: const Value(1),
        messageCount: Value(isNewMessage ? 1 : 0),
        sessionCount: Value(isNewSession ? 1 : 0),
        firstSeen: Value(now),
        lastSeen: Value(now),
      ));
    }
  }

  /// Get high co-occurrence pairs (above threshold)
  Future<List<EntityCooccurrence>> getHighCooccurrences({
    int minCount = 3,
    int limit = 50,
  }) {
    return (select(entityCooccurrences)
          ..where((c) => c.cooccurrenceCount.isBiggerOrEqualValue(minCount))
          ..orderBy([
            (c) =>
                OrderingTerm(expression: c.cooccurrenceCount, mode: OrderingMode.desc)
          ])
          ..limit(limit))
        .get();
  }

  /// Get all co-occurrences for an entity
  Future<List<EntityCooccurrence>> getCooccurrencesForEntity(String entityId) {
    return (select(entityCooccurrences)
          ..where(
              (c) => c.entityA.equals(entityId) | c.entityB.equals(entityId)))
        .get();
  }

  // ============================================
  // Temporal Pattern Operations
  // ============================================

  /// Insert a new temporal pattern
  Future<int> insertTemporalPattern(TemporalPatternsCompanion pattern) {
    return into(temporalPatterns).insert(pattern);
  }

  /// Update or insert a temporal pattern
  Future<int> upsertTemporalPattern(TemporalPatternsCompanion pattern) {
    return into(temporalPatterns).insertOnConflictUpdate(pattern);
  }

  /// Get all patterns for an entity
  Future<List<TemporalPattern>> getPatternsForEntity(String entityId) {
    return (select(temporalPatterns)..where((p) => p.entityId.equals(entityId)))
        .get();
  }

  /// Get patterns by type
  Future<List<TemporalPattern>> getPatternsByType(String patternType) {
    return (select(temporalPatterns)
          ..where((p) => p.patternType.equals(patternType)))
        .get();
  }

  /// Get high-confidence patterns
  Future<List<TemporalPattern>> getHighConfidencePatterns({
    double minConfidence = 0.7,
    int limit = 50,
  }) {
    return (select(temporalPatterns)
          ..where((p) => p.confidence.isBiggerOrEqualValue(minConfidence))
          ..orderBy(
              [(p) => OrderingTerm(expression: p.confidence, mode: OrderingMode.desc)])
          ..limit(limit))
        .get();
  }

  /// Update pattern observation
  Future<void> updatePatternObservation(String patternId) async {
    final existing = await (select(temporalPatterns)
          ..where((p) => p.id.equals(patternId)))
        .getSingleOrNull();

    if (existing != null) {
      await (update(temporalPatterns)..where((p) => p.id.equals(patternId)))
          .write(TemporalPatternsCompanion(
        occurrenceCount: Value(existing.occurrenceCount + 1),
        lastObserved: Value(DateTime.now()),
      ));
    }
  }

  /// Delete old/low-confidence patterns
  Future<int> cleanupStalePatterns({
    required Duration maxAge,
    double minConfidence = 0.3,
  }) {
    final cutoff = DateTime.now().subtract(maxAge);
    return (delete(temporalPatterns)
          ..where((p) =>
              p.lastObserved.isSmallerThanValue(cutoff) &
              p.confidence.isSmallerThanValue(minConfidence)))
        .go();
  }
}
