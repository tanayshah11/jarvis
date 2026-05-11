/// Function Router - Routes intents to local handlers without LLM
///
/// Decides whether a query can be handled locally or needs cloud LLM.
/// Handles 80%+ of common queries on-device for speed and privacy.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/agent_state.dart';
import 'intent_classifier.dart';
import 'response_templates.dart';

/// Result of routing attempt
class RouterResult {
  final bool handled;
  final String? response;
  final AgentIntent intent;
  final ExtractedEntities entities;
  final Map<String, dynamic>? actionPayload;

  const RouterResult({
    required this.handled,
    this.response,
    required this.intent,
    required this.entities,
    this.actionPayload,
  });

  /// Query was handled locally - no LLM needed
  factory RouterResult.handled({
    required String response,
    required AgentIntent intent,
    required ExtractedEntities entities,
    Map<String, dynamic>? actionPayload,
  }) => RouterResult(
    handled: true,
    response: response,
    intent: intent,
    entities: entities,
    actionPayload: actionPayload,
  );

  /// Query needs LLM - pass through
  factory RouterResult.passthrough({
    required AgentIntent intent,
    required ExtractedEntities entities,
  }) => RouterResult(
    handled: false,
    intent: intent,
    entities: entities,
  );
}

/// Function router provider
final functionRouterProvider = Provider<FunctionRouter>((ref) {
  return FunctionRouter(ref.watch(intentClassifierProvider));
});

/// Routes intents to local handlers
class FunctionRouter {
  final IntentClassifier _classifier;

  FunctionRouter(this._classifier);

  /// Try to route query locally. Returns null response if LLM needed.
  RouterResult route(String message, {String memoryContext = ''}) {
    final classification = _classifier.classify(message);
    final e = classification.entities;

    // Skip simple greetings - let LLM handle naturally
    if (_classifier.isSimpleMessage(message)) {
      return RouterResult.passthrough(
        intent: AgentIntent.chat,
        entities: e,
      );
    }

    // Try local handling based on intent
    final response = switch (classification.intent) {
      AgentIntent.createEvent => ResponseTemplates.createEvent(
          people: e.people, dates: e.dates, times: e.times, places: e.places),
      AgentIntent.sendMessage => ResponseTemplates.sendMessage(
          people: e.people, phoneNumbers: e.phoneNumbers, emails: e.emails),
      AgentIntent.saveMemory => ResponseTemplates.saveMemory(),
      AgentIntent.queryMemory => ResponseTemplates.queryMemory(
          memoryContext: memoryContext, people: e.people),
      AgentIntent.searchContacts => ResponseTemplates.searchContacts(people: e.people),
      _ => '',
    };

    // Empty response means needs LLM
    if (response.isEmpty) {
      return RouterResult.passthrough(
        intent: classification.intent,
        entities: e,
      );
    }

    return RouterResult.handled(
      response: response,
      intent: classification.intent,
      entities: e,
      actionPayload: _buildActionPayload(classification.intent, e),
    );
  }

  /// Build action payload for intent execution
  Map<String, dynamic>? _buildActionPayload(AgentIntent intent, ExtractedEntities e) {
    return switch (intent) {
      AgentIntent.createEvent => {
        'type': 'create_event',
        'attendees': e.people,
        'date': e.dates.firstOrNull,
        'time': e.times.firstOrNull,
        'location': e.places.firstOrNull,
      },
      AgentIntent.sendMessage => {
        'type': 'send_message',
        'recipient': e.people.firstOrNull,
        'phone': e.phoneNumbers.firstOrNull,
        'email': e.emails.firstOrNull,
      },
      _ => null,
    };
  }
}
