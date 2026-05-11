/// Response Templates - Pre-built responses for common intents
///
/// These templates allow the on-device NLU to respond without LLM calls
/// for predictable, structured queries.
library;

import '../models/agent_state.dart';

/// Template-based response generator
class ResponseTemplates {
  /// Generate response for createEvent intent
  static String createEvent({
    required List<String> people,
    required List<String> dates,
    required List<String> times,
    required List<String> places,
  }) {
    final who = people.isNotEmpty ? people.join(' and ') : null;
    final when = [
      if (dates.isNotEmpty) dates.first,
      if (times.isNotEmpty) 'at ${times.first}',
    ].join(' ');
    final where = places.isNotEmpty ? ' at ${places.first}' : '';

    if (who != null && when.isNotEmpty) {
      return "I'll set up a meeting with $who $when$where. Should I add it to your calendar?";
    } else if (when.isNotEmpty) {
      return "I'll create an event $when$where. What should I call it?";
    }
    return "I can help you create an event. When would you like to schedule it?";
  }

  /// Generate response for sendMessage intent
  static String sendMessage({
    required List<String> people,
    required List<String> phoneNumbers,
    required List<String> emails,
  }) {
    final who = people.isNotEmpty ? people.first : null;
    final hasContact = phoneNumbers.isNotEmpty || emails.isNotEmpty;

    if (who != null) {
      return hasContact
          ? "I'll send a message to $who. What would you like to say?"
          : "I'll help you message $who. What would you like to say?";
    }
    return "Who would you like to send a message to?";
  }

  /// Generate response for queryMemory intent with context
  static String queryMemory({
    required String memoryContext,
    required List<String> people,
  }) {
    if (memoryContext.isEmpty) {
      final who = people.isNotEmpty ? 'about ${people.first}' : '';
      return "I don't have any memories saved $who yet.";
    }
    // Has context - needs LLM to synthesize
    return '';
  }

  /// Generate response for saveMemory intent
  static String saveMemory() => "Got it, I'll remember that!";

  /// Generate response for searchContacts intent
  static String searchContacts({required List<String> people}) {
    if (people.isEmpty) return "Who are you looking for?";
    return ''; // Needs actual contact lookup
  }

  /// Check if intent can be handled locally without LLM
  static bool canHandleLocally(AgentIntent intent, {String memoryContext = ''}) {
    return switch (intent) {
      AgentIntent.createEvent => true,
      AgentIntent.sendMessage => true,
      AgentIntent.saveMemory => true,
      AgentIntent.queryMemory => memoryContext.isEmpty, // Only if no context to synthesize
      AgentIntent.searchContacts => false, // Needs contact lookup
      AgentIntent.searchEmails => false, // Needs email search
      AgentIntent.chat => false, // Needs LLM
      AgentIntent.unknown => false, // Needs LLM fallback
    };
  }
}
