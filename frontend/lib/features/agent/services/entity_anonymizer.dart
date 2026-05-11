/// Entity Anonymizer - PII masking for privacy-first LLM calls
///
/// Replaces sensitive information with tokens (PERSON_1, PLACE_1, etc.)
/// before sending to external LLMs, then restores original values in responses.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/agent_state.dart';

/// Entity anonymizer provider
final entityAnonymizerProvider = Provider<EntityAnonymizer>((ref) {
  return EntityAnonymizer();
});

/// Entity anonymizer service
class EntityAnonymizer {
  // Patterns for detecting PII
  static final _personPattern = RegExp(
    r'\b([A-Z][a-z]+(?:\s+[A-Z][a-z]+){0,2})\b',
  );

  static final _phonePattern = RegExp(
    r'\b(\+?1?[-.\s]?\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4})\b',
  );

  static final _emailPattern = RegExp(
    r'\b([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})\b',
  );

  static final _addressPattern = RegExp(
    r'\b(\d+\s+[A-Z][a-z]+(?:\s+[A-Z][a-z]+)*\s+(?:St|Street|Ave|Avenue|Blvd|Boulevard|Dr|Drive|Rd|Road|Ln|Lane|Way|Ct|Court|Pl|Place)\.?(?:\s+(?:Apt|Suite|Unit|#)\s*\d+)?)\b',
    caseSensitive: false,
  );

  static final _ssnPattern = RegExp(
    r'\b(\d{3}-\d{2}-\d{4})\b',
  );

  static final _creditCardPattern = RegExp(
    r'\b(\d{4}[-\s]?\d{4}[-\s]?\d{4}[-\s]?\d{4})\b',
  );

  // Common words that look like names but aren't
  static const _excludedNames = {
    // Days/Months
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
    // Common words
    'The', 'This', 'That', 'Here', 'There', 'What', 'When', 'Where', 'Why', 'How',
    'Hello', 'Thanks', 'Please', 'Sorry', 'Okay', 'Sure', 'Yes', 'No',
    // Tech terms
    'Google', 'Apple', 'Microsoft', 'Amazon', 'Facebook', 'Meta', 'Twitter',
    'iPhone', 'Android', 'Windows', 'Mac', 'Linux',
    // Places that are fine to include
    'America', 'Europe', 'Asia', 'Africa', 'Australia',
    // Common titles
    'Mr', 'Mrs', 'Ms', 'Dr', 'Prof',
  };

  /// Anonymize PII in a message, returning the anonymized text and mapping
  AnonymizationResult anonymize(
    String text, {
    ExtractedEntities? knownEntities,
    bool anonymizeNames = true,
    bool anonymizePhones = true,
    bool anonymizeEmails = true,
    bool anonymizeAddresses = true,
    bool anonymizeSensitive = true,
  }) {
    var anonymizedText = text;
    final toToken = <String, String>{};
    final fromToken = <String, String>{};

    var personCount = 0;
    var phoneCount = 0;
    var emailCount = 0;
    var addressCount = 0;
    var placeCount = 0;

    // Helper to add mapping
    void addMapping(String original, String token) {
      if (!toToken.containsKey(original)) {
        toToken[original] = token;
        fromToken[token] = original;
      }
    }

    // Anonymize known entities first (more accurate)
    if (knownEntities != null) {
      for (final person in knownEntities.people) {
        if (_shouldAnonymizeName(person) && anonymizeNames) {
          final token = 'PERSON_${++personCount}';
          addMapping(person, token);
          anonymizedText = anonymizedText.replaceAll(person, token);
        }
      }

      for (final place in knownEntities.places) {
        final token = 'PLACE_${++placeCount}';
        addMapping(place, token);
        anonymizedText = anonymizedText.replaceAll(place, token);
      }

      for (final phone in knownEntities.phoneNumbers) {
        if (anonymizePhones) {
          final token = 'PHONE_${++phoneCount}';
          addMapping(phone, token);
          anonymizedText = anonymizedText.replaceAll(phone, token);
        }
      }

      for (final email in knownEntities.emails) {
        if (anonymizeEmails) {
          final token = 'EMAIL_${++emailCount}';
          addMapping(email, token);
          anonymizedText = anonymizedText.replaceAll(email, token);
        }
      }
    }

    // Pattern-based anonymization for anything missed
    if (anonymizeSensitive) {
      // SSN
      for (final match in _ssnPattern.allMatches(anonymizedText)) {
        final ssn = match.group(1)!;
        if (!toToken.containsKey(ssn)) {
          const token = 'SSN_REDACTED';
          addMapping(ssn, token);
        }
      }

      // Credit cards
      for (final match in _creditCardPattern.allMatches(anonymizedText)) {
        final cc = match.group(1)!;
        if (!toToken.containsKey(cc)) {
          const token = 'CARD_REDACTED';
          addMapping(cc, token);
        }
      }
    }

    if (anonymizePhones) {
      for (final match in _phonePattern.allMatches(anonymizedText)) {
        final phone = match.group(1)!;
        if (!toToken.containsKey(phone)) {
          final token = 'PHONE_${++phoneCount}';
          addMapping(phone, token);
        }
      }
    }

    if (anonymizeEmails) {
      for (final match in _emailPattern.allMatches(anonymizedText)) {
        final email = match.group(1)!;
        if (!toToken.containsKey(email)) {
          final token = 'EMAIL_${++emailCount}';
          addMapping(email, token);
        }
      }
    }

    if (anonymizeAddresses) {
      for (final match in _addressPattern.allMatches(anonymizedText)) {
        final address = match.group(1)!;
        if (!toToken.containsKey(address)) {
          final token = 'ADDRESS_${++addressCount}';
          addMapping(address, token);
        }
      }
    }

    if (anonymizeNames) {
      for (final match in _personPattern.allMatches(anonymizedText)) {
        final name = match.group(1)!;
        if (_shouldAnonymizeName(name) && !toToken.containsKey(name)) {
          final token = 'PERSON_${++personCount}';
          addMapping(name, token);
        }
      }
    }

    // Apply all replacements
    for (final entry in toToken.entries) {
      anonymizedText = anonymizedText.replaceAll(entry.key, entry.value);
    }

    return AnonymizationResult(
      originalText: text,
      anonymizedText: anonymizedText,
      map: AnonymizationMap(
        toToken: toToken,
        fromToken: fromToken,
      ),
    );
  }

  /// Restore original values in a response using the anonymization map
  String deanonymize(String text, AnonymizationMap map) {
    var restoredText = text;

    // Sort tokens by length (longest first) to avoid partial replacements
    final sortedTokens = map.fromToken.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));

    for (final token in sortedTokens) {
      final original = map.fromToken[token]!;
      restoredText = restoredText.replaceAll(token, original);
    }

    return restoredText;
  }

  /// Check if a potential name should be anonymized
  bool _shouldAnonymizeName(String name) {
    // Skip excluded words
    if (_excludedNames.contains(name)) {
      return false;
    }

    // Skip single words that are too short
    if (name.length < 3) {
      return false;
    }

    // Skip all-caps (likely acronyms)
    if (name == name.toUpperCase() && name.length <= 4) {
      return false;
    }

    return true;
  }

  /// Anonymize memory context (already formatted text)
  AnonymizationResult anonymizeContext(String context) {
    return anonymize(
      context,
      anonymizeNames: true,
      anonymizePhones: true,
      anonymizeEmails: true,
      anonymizeAddresses: true,
      anonymizeSensitive: true,
    );
  }

  /// Merge two anonymization maps (for message + context)
  AnonymizationMap mergeMaps(AnonymizationMap map1, AnonymizationMap map2) {
    return AnonymizationMap(
      toToken: {...map1.toToken, ...map2.toToken},
      fromToken: {...map1.fromToken, ...map2.fromToken},
    );
  }
}

/// Result of anonymization
class AnonymizationResult {
  final String originalText;
  final String anonymizedText;
  final AnonymizationMap map;

  const AnonymizationResult({
    required this.originalText,
    required this.anonymizedText,
    required this.map,
  });

  /// Whether any anonymization was performed
  bool get hasAnonymizations => map.toToken.isNotEmpty;

  /// Number of entities anonymized
  int get entityCount => map.toToken.length;
}
