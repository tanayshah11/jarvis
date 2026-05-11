/// Intent Classifier - Rule-based intent detection for on-device processing
///
/// Uses keyword matching and pattern recognition to classify user intents
/// without requiring an LLM call. Fast, private, and runs entirely on-device.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/agent_state.dart';

/// Intent classification result
class IntentClassification {
  final AgentIntent intent;
  final double confidence;
  final ExtractedEntities entities;
  final Map<String, dynamic> metadata;

  const IntentClassification({
    required this.intent,
    required this.confidence,
    required this.entities,
    this.metadata = const {},
  });
}

/// Intent classifier provider
final intentClassifierProvider = Provider<IntentClassifier>((ref) {
  return IntentClassifier();
});

/// Rule-based intent classifier service
class IntentClassifier {
  // Calendar/Event patterns - high confidence triggers
  static final _calendarHighConfidence = [
    RegExp(
      r'\b(schedule|book)\s+(a\s+)?(meeting|appointment|event|lunch|dinner|call)\b',
      caseSensitive: false,
    ),
    RegExp(
      r'\b(set\s+up|create|add)\s+(a\s+)?(meeting|appointment|event)\b',
      caseSensitive: false,
    ),
    RegExp(
      r'\b(lunch|dinner|breakfast|brunch|coffee)\s+with\s+\w+',
      caseSensitive: false,
    ),
  ];

  // Calendar/Event patterns - supporting signals
  static final _calendarPatterns = [
    RegExp(
      r'\b(schedule|meeting|appointment|event|calendar)\b',
      caseSensitive: false,
    ),
    RegExp(
      r'\b(at|on|for)\s+\d{1,2}(:\d{2})?\s*(am|pm)?\b',
      caseSensitive: false,
    ),
    RegExp(
      r'\b(tomorrow|today|next\s+\w+|monday|tuesday|wednesday|thursday|friday|saturday|sunday)\b',
      caseSensitive: false,
    ),
    RegExp(
      r'\b(lunch|dinner|breakfast|brunch|coffee)\s+(with|at)\b',
      caseSensitive: false,
    ),
  ];

  // Send message patterns - high confidence triggers
  static final _messageHighConfidence = [
    RegExp(
      r'\b(send|text|message)\s+(a\s+)?(text|message|email)?\s*(to\s+)?\w+',
      caseSensitive: false,
    ),
    RegExp(r'\b(email|call)\s+(to\s+)?[A-Z][a-z]+', caseSensitive: false),
    RegExp(r'\blet\s+\w+\s+know\b', caseSensitive: false),
  ];

  // Send message patterns - supporting signals
  static final _messagePatterns = [
    RegExp(
      r'\b(text|message|send|call|email|notify|tell)\b',
      caseSensitive: false,
    ),
    RegExp(r'\b(sms|imessage|whatsapp)\b', caseSensitive: false),
    RegExp(r'\breach\s+out\s+to\b', caseSensitive: false),
  ];

  // Memory save patterns - high confidence triggers
  static final _saveMemoryHighConfidence = [
    RegExp(r'\b(remember|note)\s+that\b', caseSensitive: false),
    RegExp(r"\bdon'?t\s+forget\b", caseSensitive: false),
    RegExp(r'\bkeep\s+in\s+mind\b', caseSensitive: false),
  ];

  // Memory save patterns - supporting signals
  static final _saveMemoryPatterns = [
    RegExp(r'\b(remember|note|save|store)\b', caseSensitive: false),
    RegExp(r'\b(important|reminder):\b', caseSensitive: false),
    RegExp(r'\bfor\s+future\s+reference\b', caseSensitive: false),
  ];

  // Memory query patterns - high confidence triggers
  static final _queryMemoryHighConfidence = [
    RegExp(
      r'\bwhat\s+(do\s+)?(i|you)\s+(know|remember)\s+about\b',
      caseSensitive: false,
    ),
    RegExp(r'\b(tell|remind)\s+me\s+(about|what)\b', caseSensitive: false),
    RegExp(
      r'\bdo\s+(i|you)\s+have\s+(any\s+)?(info|information)\s+(about|on)\b',
      caseSensitive: false,
    ),
  ];

  // Memory query patterns - supporting signals
  static final _queryMemoryPatterns = [
    RegExp(
      r'\b(what|who|when|where)\s+(do\s+)?(i|you)\s+(know|remember)\b',
      caseSensitive: false,
    ),
    RegExp(
      r'\bwhat\s+(did|do)\s+(i|we)\s+(say|discuss|talk)\b',
      caseSensitive: false,
    ),
    RegExp(
      r'\bdo\s+(i|you)\s+(know|have)\s+(any|info|information)\b',
      caseSensitive: false,
    ),
  ];

  // Contact search patterns - high confidence triggers
  static final _contactHighConfidence = [
    RegExp(
      r"\b(find|get|search)\s+\w+'?s?\s*(phone|number|email|contact)\b",
      caseSensitive: false,
    ),
    RegExp(
      r"\b\w+'s\s+(phone|email|number)\s*(number|address)?\b",
      caseSensitive: false,
    ),
    RegExp(
      r"\b(email|phone)\s+(address|number)?\s*(for|of)\s+\w+",
      caseSensitive: false,
    ),
    RegExp(
      r'\bhow\s+(do\s+i|can\s+i)\s+(reach|contact)\s+\w+',
      caseSensitive: false,
    ),
    RegExp(
      r"\bwhat'?s?\s+\w+'?s?\s+(phone|number|email)\b",
      caseSensitive: false,
    ),
  ];

  // Contact search patterns - supporting signals
  static final _contactPatterns = [
    RegExp(
      r'\b(find|search|look\s+up|get)\s+(contact|phone|number|email)\b',
      caseSensitive: false,
    ),
    RegExp(
      r'\b(phone|number|email|contact)\s+(for|of)\b',
      caseSensitive: false,
    ),
  ];

  // Email search patterns - high confidence triggers
  static final _emailSearchHighConfidence = [
    RegExp(
      r'\b(search|find)\s+(for\s+)?(emails?|messages?)\s+(from|about)\b',
      caseSensitive: false,
    ),
    RegExp(r'\bemails?\s+from\s+\w+', caseSensitive: false),
  ];

  // Email search patterns - supporting signals
  static final _emailSearchPatterns = [
    RegExp(
      r'\b(search|find|look\s+for)\s+(email|mail|message)s?\b',
      caseSensitive: false,
    ),
    RegExp(r'\b(inbox|sent|draft)s?\b', caseSensitive: false),
  ];

  // Entity extraction patterns
  static final _personPattern = RegExp(r'\b([A-Z][a-z]+(?:\s+[A-Z][a-z]+)*)\b');

  // Names to exclude from person detection (AI names, common words, verbs)
  static const _excludedNames = {
    // AI assistants
    'Jarvis', 'Siri', 'Alexa', 'Cortana', 'Google', 'Assistant',
    // Greetings & responses
    'Hey', 'Hello', 'Hi', 'Thanks', 'Thank', 'Please', 'Sorry',
    'Yes', 'No', 'Ok', 'Okay', 'Sure', 'Maybe', 'Actually',
    // Days & months
    'Today', 'Tomorrow', 'Yesterday', 'Monday', 'Tuesday', 'Wednesday',
    'Thursday', 'Friday', 'Saturday', 'Sunday',
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
    // Question words
    'What', 'When', 'Where', 'Who', 'Why', 'How', 'Which',
    // Modal & auxiliary verbs
    'Can', 'Could', 'Would', 'Should', 'Will', 'Do', 'Does', 'Did',
    // Articles & determiners
    'The', 'This', 'That', 'These', 'Those', 'Some', 'Any', 'All',
    // Common action verbs (at start of sentences)
    'Send', 'Text', 'Call', 'Email', 'Message', 'Schedule', 'Book',
    'Set', 'Create', 'Add', 'Find', 'Get', 'Search', 'Look', 'Tell',
    'Remember', 'Note', 'Save', 'Remind', 'Show', 'Give', 'Make', 'Let',
    // Prepositions & conjunctions
    'About', 'With', 'From', 'For', 'And', 'But', 'Or',
    // Other common words
    'Lunch', 'Dinner', 'Meeting', 'Coffee', 'Breakfast', 'Brunch',
  };

  static final _timePattern = RegExp(
    r'\b(\d{1,2}(?::\d{2})?\s*(?:am|pm|AM|PM)?)\b',
  );

  static final _datePattern = RegExp(
    r'\b(today|tomorrow|yesterday|next\s+\w+|last\s+\w+|(?:monday|tuesday|wednesday|thursday|friday|saturday|sunday)|(?:jan(?:uary)?|feb(?:ruary)?|mar(?:ch)?|apr(?:il)?|may|jun(?:e)?|jul(?:y)?|aug(?:ust)?|sep(?:tember)?|oct(?:ober)?|nov(?:ember)?|dec(?:ember)?)\s+\d{1,2}(?:st|nd|rd|th)?(?:\s*,?\s*\d{4})?)\b',
    caseSensitive: false,
  );

  static final _phonePattern = RegExp(
    r'\b(\+?1?[-.\s]?\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4})\b',
  );

  static final _emailPattern = RegExp(
    r'\b([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})\b',
  );

  static final _placePattern = RegExp(
    r'\b(?:at|in|to|from)\s+(?:the\s+)?([A-Z][a-z]+(?:\s+[A-Z][a-z]+)*(?:\s+(?:Restaurant|Cafe|Coffee|Office|Building|Hotel|Airport|Station|Park|Mall|Center|Centre))?)\b',
  );

  /// Classify the intent of a user message
  IntentClassification classify(String message) {
    final entities = _extractEntities(message);

    // Score each intent type using two-tier system:
    // 1. High confidence patterns (strong indicators) - worth 0.5 each
    // 2. Supporting patterns (weak indicators) - worth less
    final scores = <AgentIntent, double>{};

    scores[AgentIntent.createEvent] = _scoreWithHighConfidence(
      message,
      _calendarHighConfidence,
      _calendarPatterns,
    );
    scores[AgentIntent.sendMessage] = _scoreWithHighConfidence(
      message,
      _messageHighConfidence,
      _messagePatterns,
    );
    scores[AgentIntent.saveMemory] = _scoreWithHighConfidence(
      message,
      _saveMemoryHighConfidence,
      _saveMemoryPatterns,
    );
    scores[AgentIntent.queryMemory] = _scoreWithHighConfidence(
      message,
      _queryMemoryHighConfidence,
      _queryMemoryPatterns,
    );
    scores[AgentIntent.searchContacts] = _scoreWithHighConfidence(
      message,
      _contactHighConfidence,
      _contactPatterns,
    );
    scores[AgentIntent.searchEmails] = _scoreWithHighConfidence(
      message,
      _emailSearchHighConfidence,
      _emailSearchPatterns,
    );

    // Boost calendar intent if time/date entities found with person
    if ((entities.dates.isNotEmpty || entities.times.isNotEmpty) &&
        entities.people.isNotEmpty) {
      scores[AgentIntent.createEvent] =
          (scores[AgentIntent.createEvent] ?? 0) + 0.25;
    }

    // Boost message intent if phone/email entities found
    if (entities.phoneNumbers.isNotEmpty || entities.emails.isNotEmpty) {
      scores[AgentIntent.sendMessage] =
          (scores[AgentIntent.sendMessage] ?? 0) + 0.2;
    }

    // Find the highest scoring intent
    var bestIntent = AgentIntent.chat;
    var bestScore = 0.0;

    for (final entry in scores.entries) {
      if (entry.value > bestScore) {
        bestScore = entry.value;
        bestIntent = entry.key;
      }
    }

    // If no strong signal, default to chat
    if (bestScore < 0.3) {
      bestIntent = AgentIntent.chat;
      bestScore = 1.0 - bestScore; // High confidence it's just chat
    }

    return IntentClassification(
      intent: bestIntent,
      confidence: bestScore.clamp(0.0, 1.0),
      entities: entities,
      metadata: {'scores': scores},
    );
  }

  /// Score using two-tier pattern system
  double _scoreWithHighConfidence(
    String message,
    List<RegExp> highConfidence,
    List<RegExp> supporting,
  ) {
    double score = 0;

    // High confidence patterns are worth 0.5 each (capped at 1.0)
    for (final pattern in highConfidence) {
      if (pattern.hasMatch(message)) {
        score += 0.5;
      }
    }

    // Supporting patterns add smaller increments
    for (final pattern in supporting) {
      if (pattern.hasMatch(message)) {
        score += 0.15;
      }
    }

    return score.clamp(0.0, 1.0);
  }

  /// Extract entities from a message
  ExtractedEntities _extractEntities(String message) {
    return ExtractedEntities(
      people: _extractPeople(message),
      places: _extractPlaces(message),
      dates: _extractMatches(message, _datePattern),
      times: _extractMatches(message, _timePattern),
      phoneNumbers: _extractMatches(message, _phonePattern),
      emails: _extractMatches(message, _emailPattern),
    );
  }

  /// Extract person names from message, filtering out excluded names
  List<String> _extractPeople(String message) {
    final results = <String>[];

    for (final match in _personPattern.allMatches(message)) {
      var name = match.group(1) ?? match.group(0)!;

      // If the name is a single word and excluded, skip it
      if (_excludedNames.contains(name)) continue;

      // If multi-word name starts with an excluded word, strip it
      // e.g., "Call Mom" -> "Mom", "Send Sarah" -> "Sarah"
      final words = name.split(' ');
      if (words.length > 1 && _excludedNames.contains(words.first)) {
        name = words.sublist(1).join(' ');
      }

      // Final check - skip if remaining name is excluded or empty
      if (name.isEmpty || _excludedNames.contains(name)) continue;

      results.add(name);
    }

    return results.toSet().toList();
  }

  /// Extract all matches for a pattern
  List<String> _extractMatches(String message, RegExp pattern) {
    return pattern
        .allMatches(message)
        .map((m) => (m.group(1) ?? m.group(0)!).trim())
        .toSet()
        .toList();
  }

  /// Extract place names (special handling for context)
  List<String> _extractPlaces(String message) {
    final matches = <String>[];
    for (final match in _placePattern.allMatches(message)) {
      final place = match.group(1);
      if (place != null && !_isCommonWord(place)) {
        matches.add(place);
      }
    }
    return matches.toSet().toList();
  }

  /// Check if a word is too common to be a place name
  bool _isCommonWord(String word) {
    const commonWords = {
      'The',
      'A',
      'An',
      'This',
      'That',
      'My',
      'Your',
      'His',
      'Her',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    };
    return commonWords.contains(word);
  }

  /// Check if the message is a simple greeting or acknowledgment
  bool isSimpleMessage(String message) {
    final trimmed = message.trim().toLowerCase();
    const simpleMessages = {
      'hi',
      'hello',
      'hey',
      'yo',
      'sup',
      'yes',
      'no',
      'yeah',
      'yep',
      'nope',
      'ok',
      'okay',
      'sure',
      'thanks',
      'thank you',
      'thx',
      'ty',
      'bye',
      'goodbye',
      'see you',
      'later',
      'good morning',
      'good afternoon',
      'good evening',
      'good night',
    };
    return simpleMessages.contains(trimmed) || trimmed.length < 5;
  }
}
