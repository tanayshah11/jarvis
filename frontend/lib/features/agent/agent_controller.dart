/// Agent Controller - Main orchestrator for on-device agent processing
///
/// Flow: idle → classifyingIntent → buildingContext → anonymizing →
///       awaitingLlm → deanonymizing → extractingMemory → updatingGraph → idle
///
/// Privacy-First: All user data stays on-device. Only anonymized queries
/// are sent to the backend LLM proxy.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/data_service.dart';
import '../../data/repositories/memory_repository.dart';
import '../profile/profile_model.dart';
import '../settings/providers/settings_provider.dart';
import 'models/agent_state.dart';
import 'services/calendar_action_executor.dart';
import 'services/entity_anonymizer.dart';
import 'services/function_router.dart';
import 'services/intent_classifier.dart' show IntentClassification;
import 'services/llm_proxy_service.dart';

const String _logName = 'AgentController';

/// Agent controller provider
final agentControllerProvider = NotifierProvider<AgentController, AgentState>(
  () => AgentController(),
);

/// Agent controller
class AgentController extends Notifier<AgentState> {
  late EntityAnonymizer _anonymizer;
  late LlmProxyService _llmProxy;
  late MemoryRepository _memoryRepository;
  late FunctionRouter _router;
  late CalendarActionExecutor _calendarExecutor;

  @override
  AgentState build() {
    _anonymizer = ref.watch(entityAnonymizerProvider);
    _llmProxy = ref.watch(llmProxyServiceProvider);
    _memoryRepository = ref.watch(memoryRepositoryProvider);
    _router = ref.watch(functionRouterProvider);
    _calendarExecutor = ref.watch(calendarActionExecutorProvider);
    return const AgentState.idle();
  }

  /// Process a user message through the on-device agent pipeline
  ///
  /// Returns a stream of partial responses for streaming UI updates.
  /// The final result will be emitted when processing is complete.
  Stream<AgentResult> processMessage(String userMessage) async* {
    if (userMessage.trim().isEmpty) {
      yield const AgentResult(
        response: '',
        isComplete: true,
        error: 'Empty message',
      );
      return;
    }

    try {
      // Get settings
      final settings = ref.read(settingsProvider);
      final enableAnonymization = settings.privacy.enableAnonymization;
      final enableMemoryExtraction = settings.privacy.enableMemoryExtraction;
      final provider = settings.ai.aiProvider.value;
      final temperature = settings.ai.creativity;
      final maxTokens = settings.ai.responseLength.tokenLimit;

      // 0. Try local routing first (no LLM needed for simple queries)
      state = AgentState.classifyingIntent(userMessage: userMessage);
      final routerResult = _router.route(userMessage);

      if (routerResult.handled && routerResult.response != null) {
        developer.log(
          'Handled locally: ${routerResult.intent} -> "${routerResult.response}"',
          name: _logName,
        );

        // Execute calendar actions if this is a createEvent intent
        if (routerResult.intent == AgentIntent.createEvent &&
            routerResult.actionPayload != null) {
          final payload = routerResult.actionPayload!;
          final calendarResult = await _calendarExecutor.executeCreateEvent(
            attendees: List<String>.from(payload['attendees'] ?? []),
            dateString: payload['date'] as String?,
            timeString: payload['time'] as String?,
            location: payload['location'] as String?,
          );

          state = const AgentState.idle();
          yield AgentResult(
            response: calendarResult.message,
            isComplete: true,
            intent: routerResult.intent,
            toolResults: calendarResult.success
                ? {'event': calendarResult.event?.toMap(), 'success': true}
                : {'error': calendarResult.error, 'success': false},
          );
          return;
        }

        state = const AgentState.idle();
        yield AgentResult(
          response: routerResult.response!,
          isComplete: true,
          intent: routerResult.intent,
          toolResults: routerResult.actionPayload,
        );
        return;
      }

      // 1. Use classification from router
      final classification = IntentClassification(
        intent: routerResult.intent,
        confidence: 1.0,
        entities: routerResult.entities,
      );

      developer.log(
        'Intent: ${classification.intent}, confidence: ${classification.confidence}',
        name: _logName,
      );

      // 2. Build memory context
      state = AgentState.buildingContext(
        userMessage: userMessage,
        intent: classification.intent,
        entities: classification.entities,
      );

      final memoryContext = await _buildMemoryContext(
        userMessage,
        classification.entities,
      );

      developer.log(
        'Memory context: ${memoryContext.tokenCount} tokens, ${memoryContext.nodeIds.length} nodes',
        name: _logName,
      );

      // 3. Anonymize if enabled
      String processedMessage = userMessage;
      String processedContext = memoryContext.contextText;
      AnonymizationMap anonymizationMap = const AnonymizationMap();

      if (enableAnonymization) {
        state = AgentState.anonymizing(
          userMessage: userMessage,
          intent: classification.intent,
          memoryContext: memoryContext,
        );

        final messageResult = _anonymizer.anonymize(
          userMessage,
          knownEntities: classification.entities,
        );
        final contextResult = _anonymizer.anonymizeContext(processedContext);

        processedMessage = messageResult.anonymizedText;
        processedContext = contextResult.anonymizedText;
        anonymizationMap = _anonymizer.mergeMaps(
          messageResult.map,
          contextResult.map,
        );

        developer.log(
          'Anonymized ${anonymizationMap.toToken.length} entities',
          name: _logName,
        );
      }

      // 4. Build system prompt with memory context
      final systemPrompt = _buildSystemPrompt(
        processedContext,
        classification.intent,
      );

      // 5. Call LLM
      state = AgentState.awaitingLlm(
        anonymizedMessage: processedMessage,
        anonymizedContext: processedContext,
        anonymizationMap: anonymizationMap,
      );

      final messages = [LlmMessage(role: 'user', content: processedMessage)];

      final responseBuffer = StringBuffer();

      await for (final chunk in _llmProxy.chatStream(
        messages: messages,
        systemPrompt: systemPrompt,
        provider: provider,
        temperature: temperature,
        maxTokens: maxTokens,
      )) {
        responseBuffer.write(chunk);

        state = AgentState.streaming(
          partialResponse: responseBuffer.toString(),
          anonymizationMap: anonymizationMap,
        );

        yield AgentResult(
          response: enableAnonymization
              ? _anonymizer.deanonymize(
                  responseBuffer.toString(),
                  anonymizationMap,
                )
              : responseBuffer.toString(),
          isComplete: false,
          intent: classification.intent,
        );
      }

      // 6. De-anonymize final response
      String finalResponse = responseBuffer.toString();
      if (enableAnonymization && !anonymizationMap.isEmpty) {
        state = AgentState.deanonymizing(
          llmResponse: finalResponse,
          anonymizationMap: anonymizationMap,
        );
        finalResponse = _anonymizer.deanonymize(
          finalResponse,
          anonymizationMap,
        );
      }

      // 7. Extract memories (on-device) if enabled
      List<MemoryExtraction> extractions = [];
      if (enableMemoryExtraction) {
        state = AgentState.extractingMemory(
          userMessage: userMessage,
          assistantResponse: finalResponse,
        );

        extractions = await _extractMemories(userMessage, finalResponse);

        if (extractions.isNotEmpty) {
          state = AgentState.updatingGraph(extractions: extractions);
          await _updateMemoryGraph(extractions);
        }
      }

      // 8. Return to idle
      state = const AgentState.idle();

      yield AgentResult(
        response: finalResponse,
        isComplete: true,
        intent: classification.intent,
        extractedMemories: extractions,
      );
    } catch (e, stackTrace) {
      developer.log(
        'Agent error: $e',
        name: _logName,
        error: e,
        stackTrace: stackTrace,
      );

      final previousState = state;
      state = AgentState.error(
        message: e.toString(),
        previousState: previousState,
      );

      yield AgentResult(response: '', isComplete: true, error: e.toString());
    }
  }

  /// Build memory context from on-device graph
  ///
  /// Strategy for reliable memory lookup:
  /// 1. DIRECT LOOKUP: For each person name in entities, directly search for matching nodes
  /// 2. GET RELATIONSHIPS: For each person found, get all their connected memories
  /// 3. SEMANTIC SEARCH: Add any additional relevant context from query
  Future<MemoryContext> _buildMemoryContext(
    String query,
    ExtractedEntities entities,
  ) async {
    try {
      final contextParts = <String>[];
      final foundNodeIds = <String>{};

      // 1. DIRECT LOOKUP for mentioned people (most reliable)
      for (final personName in entities.people) {
        developer.log(
          'Direct lookup for person: "$personName"',
          name: _logName,
        );

        // Search for this specific person
        final personResults = await _memoryRepository.searchNodesSemantically(
          query: personName,
          limit: 3,
          minScore: 0.1, // Low threshold for direct name lookup
        );

        for (final result in personResults) {
          if (foundNodeIds.contains(result.node.id)) continue;

          // Check if this node is actually about this person
          final nameLower = result.node.name.toLowerCase();
          final searchLower = personName.toLowerCase();
          final isMatch =
              nameLower.contains(searchLower) ||
              searchLower.contains(nameLower) ||
              nameLower.split(' ').first == searchLower;

          if (!isMatch) continue;

          foundNodeIds.add(result.node.id);

          developer.log(
            'Found person node: "${result.node.name}" (${result.node.nodeType})',
            name: _logName,
          );

          // Get full node with relationships
          final nodeWithRels = await _memoryRepository.getNodeWithRelationships(
            result.node.id,
          );

          if (nodeWithRels != null) {
            final nodeContext = _formatNodeContext(nodeWithRels);
            if (nodeContext.isNotEmpty) {
              contextParts.add(nodeContext);
            }
          }
        }
      }

      // 2. SEMANTIC SEARCH for additional context
      final expandedQuery = [
        query,
        ...entities.people,
        ...entities.places,
      ].join(' ');

      final semanticResults = await _memoryRepository.searchNodesSemantically(
        query: expandedQuery,
        limit: 5,
        minScore: 0.3,
      );

      for (final result in semanticResults) {
        if (foundNodeIds.contains(result.node.id)) continue;
        foundNodeIds.add(result.node.id);

        final nodeWithRels = await _memoryRepository.getNodeWithRelationships(
          result.node.id,
        );

        if (nodeWithRels != null) {
          final nodeContext = _formatNodeContext(nodeWithRels);
          if (nodeContext.isNotEmpty) {
            contextParts.add(nodeContext);
          }
        }
      }

      final contextText = contextParts.join('\n\n');
      final tokenCount = (contextText.length / 4).ceil();

      developer.log(
        'Memory context built: ${foundNodeIds.length} nodes, $tokenCount tokens',
        name: _logName,
      );

      return MemoryContext(
        contextText: contextText,
        nodeIds: foundNodeIds.toList(),
        tokenCount: tokenCount,
      );
    } catch (e, stackTrace) {
      developer.log(
        'Failed to build memory context: $e',
        name: _logName,
        level: 800,
        error: e,
        stackTrace: stackTrace,
      );
      return const MemoryContext();
    }
  }

  /// Format a node with its relationships into context text
  String _formatNodeContext(NodeWithRelationships nodeWithRels) {
    final lines = <String>[];
    final node = nodeWithRels.node;

    lines.add('${node.nodeType}: ${node.name}');

    // Add attributes (stored as JSON string in database)
    if (node.attributes != null && node.attributes!.isNotEmpty) {
      try {
        final attrs = jsonDecode(node.attributes!) as Map<String, dynamic>;
        attrs.forEach((key, value) {
          if (value != null && value.toString().isNotEmpty) {
            lines.add('  - $key: $value');
          }
        });
      } catch (_) {
        // If JSON parsing fails, just skip attributes
      }
    }

    // Add relationships (limited to most relevant)
    for (final edge in nodeWithRels.outgoingEdges.take(5)) {
      final targetNode = nodeWithRels.connectedNodes
          .where((n) => n.id == edge.toNodeId)
          .firstOrNull;
      if (targetNode != null) {
        lines.add('  - ${edge.relationshipType} → ${targetNode.name}');
      }
    }

    return lines.join('\n');
  }

  /// Build system prompt with memory context
  String _buildSystemPrompt(String memoryContext, AgentIntent intent) {
    final buffer = StringBuffer();

    buffer.writeln(
      'You are Jarvis, a friendly and warm personal AI assistant.',
    );
    buffer.writeln(
      'You help the user by remembering details about their life, friends, and preferences.',
    );
    buffer.writeln();

    if (memoryContext.isNotEmpty) {
      buffer.writeln(
        'Here is what you remember about the user and their life:',
      );
      buffer.writeln('---');
      buffer.writeln(memoryContext);
      buffer.writeln('---');
      buffer.writeln();
    }

    buffer.writeln('Guidelines:');
    buffer.writeln('- Be warm, friendly, and conversational');
    buffer.writeln(
      '- These are the USER\'S friends, family, and relationships - not yours',
    );
    buffer.writeln(
      '- IMPORTANT: When referring to people, ALWAYS use their exact placeholder name (PERSON_1, PERSON_2, etc.) in your response. Never say "your friend" or "they" - always use the placeholder like "PERSON_1 would love..." or "Since PERSON_1 enjoys..."',
    );
    buffer.writeln(
      '- Never say "context" or "based on the information provided" - speak naturally',
    );
    buffer.writeln(
      "- If you don't remember something, say \"I don't remember\" not \"I don't have information\"",
    );
    buffer.writeln('- Keep responses concise but personable');

    // Intent-specific guidance
    switch (intent) {
      case AgentIntent.createEvent:
        buffer.writeln(
          '- Help them set up this event. Confirm the details warmly.',
        );
        break;
      case AgentIntent.sendMessage:
        buffer.writeln('- Help them send this message. Confirm who and what.');
        break;
      case AgentIntent.saveMemory:
        buffer.writeln(
          "- They want you to remember something. Acknowledge it naturally, like \"Got it, I'll remember that!\"",
        );
        break;
      case AgentIntent.queryMemory:
        buffer.writeln(
          '- They\'re asking about something. Share what you remember naturally.',
        );
        break;
      default:
        break;
    }

    return buffer.toString();
  }

  /// Extract memories from conversation (on-device rule-based)
  Future<List<MemoryExtraction>> _extractMemories(
    String userMessage,
    String assistantResponse,
  ) async {
    final extractions = <MemoryExtraction>[];

    // Extract facts about people
    final personPattern = RegExp(
      r'(\w+)\s+(?:is|works at|lives in|likes|loves|hates)\s+(.+?)(?:\.|$)',
      caseSensitive: false,
    );

    for (final match in personPattern.allMatches(userMessage)) {
      final person = match.group(1);
      final fact = match.group(0);
      if (person != null && fact != null) {
        extractions.add(
          MemoryExtraction(
            content: fact.trim(),
            type: MemoryType.fact,
            confidence: 0.7,
            entities: [person],
            sourceMessage: userMessage,
          ),
        );
      }
    }

    // Extract preferences
    final preferencePatterns = [
      RegExp(
        r'I (?:like|love|prefer|enjoy)\s+(.+?)(?:\.|$)',
        caseSensitive: false,
      ),
      RegExp(
        r"I (?:don't like|hate|dislike)\s+(.+?)(?:\.|$)",
        caseSensitive: false,
      ),
    ];

    for (final pattern in preferencePatterns) {
      for (final match in pattern.allMatches(userMessage)) {
        final pref = match.group(0);
        if (pref != null) {
          extractions.add(
            MemoryExtraction(
              content: pref.trim(),
              type: MemoryType.preference,
              confidence: 0.8,
              entities: [],
              sourceMessage: userMessage,
            ),
          );
        }
      }
    }

    // Extract relationships
    final relationshipPattern = RegExp(
      r'(\w+)\s+is\s+my\s+(friend|colleague|boss|manager|wife|husband|partner|sister|brother|mom|dad|mother|father)',
      caseSensitive: false,
    );

    for (final match in relationshipPattern.allMatches(userMessage)) {
      final person = match.group(1);
      final relationship = match.group(2);
      if (person != null && relationship != null) {
        extractions.add(
          MemoryExtraction(
            content: '$person is my $relationship',
            type: MemoryType.relationship,
            confidence: 0.9,
            entities: [person],
            sourceMessage: userMessage,
          ),
        );
      }
    }

    return extractions;
  }

  /// Update memory graph with extracted memories
  Future<void> _updateMemoryGraph(List<MemoryExtraction> extractions) async {
    for (final extraction in extractions) {
      try {
        // Create node for the memory
        final nodeType = switch (extraction.type) {
          MemoryType.fact => 'fact',
          MemoryType.preference => 'preference',
          MemoryType.relationship => 'relationship',
          MemoryType.event => 'event',
          MemoryType.contact => 'contact',
          MemoryType.location => 'location',
        };

        await _memoryRepository.upsertNode(
          nodeType: nodeType,
          name: extraction.content,
          source: 'conversation',
          attributes: {
            'confidence': extraction.confidence,
            'entities': extraction.entities,
            'extracted_at': DateTime.now().toIso8601String(),
          },
          confidence: extraction.confidence,
        );

        // Create edges to entity nodes
        for (final entity in extraction.entities) {
          await _memoryRepository.upsertNode(
            nodeType: 'person',
            name: entity,
            source: 'extraction',
            confidence: extraction.confidence,
          );

          developer.log('Created/updated entity node: $entity', name: _logName);
        }

        developer.log('Stored memory: ${extraction.content}', name: _logName);
      } catch (e) {
        developer.log('Failed to store memory: $e', name: _logName, level: 800);
      }
    }
  }

  /// Reset agent state
  void reset() {
    state = const AgentState.idle();
  }
}

/// Extension for ResponseLength to get token limits
extension ResponseLengthTokens on ResponseLength {
  int get tokenLimit => switch (this) {
    ResponseLength.short => 512,
    ResponseLength.medium => 1024,
    ResponseLength.long => 2048,
  };
}
