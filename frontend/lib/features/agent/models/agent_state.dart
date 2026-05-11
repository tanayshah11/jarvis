/// Agent State Machine for Privacy-First On-Device Processing
///
/// Flow: idle → classifyingIntent → buildingContext → anonymizing →
///       awaitingLlm → deanonymizing → extractingMemory → updatingGraph → idle
library;

/// Detected intent from user message
enum AgentIntent {
  /// General conversation - use LLM
  chat,

  /// Create calendar event
  createEvent,

  /// Send message (SMS, email, etc.)
  sendMessage,

  /// Save information to memory
  saveMemory,

  /// Query existing memories
  queryMemory,

  /// Search contacts
  searchContacts,

  /// Search emails
  searchEmails,

  /// Unknown - fallback to chat
  unknown,
}

/// Extracted entities from user message
class ExtractedEntities {
  final List<String> people;
  final List<String> places;
  final List<String> organizations;
  final List<String> dates;
  final List<String> times;
  final List<String> phoneNumbers;
  final List<String> emails;

  const ExtractedEntities({
    this.people = const [],
    this.places = const [],
    this.organizations = const [],
    this.dates = const [],
    this.times = const [],
    this.phoneNumbers = const [],
    this.emails = const [],
  });

  bool get isEmpty =>
      people.isEmpty &&
      places.isEmpty &&
      organizations.isEmpty &&
      dates.isEmpty &&
      times.isEmpty &&
      phoneNumbers.isEmpty &&
      emails.isEmpty;
}

/// Mapping of original values to anonymized tokens
class AnonymizationMap {
  /// Original -> Token (e.g., "Sarah" -> "PERSON_1")
  final Map<String, String> toToken;

  /// Token -> Original (e.g., "PERSON_1" -> "Sarah")
  final Map<String, String> fromToken;

  const AnonymizationMap({
    this.toToken = const {},
    this.fromToken = const {},
  });

  bool get isEmpty => toToken.isEmpty;
}

/// Memory context built from on-device graph
class MemoryContext {
  /// Relevant memories as formatted text
  final String contextText;

  /// IDs of memory nodes used
  final List<String> nodeIds;

  /// Number of tokens in context
  final int tokenCount;

  const MemoryContext({
    this.contextText = '',
    this.nodeIds = const [],
    this.tokenCount = 0,
  });

  bool get isEmpty => contextText.isEmpty;
}

/// Agent processing state types
enum AgentStateType {
  idle,
  classifyingIntent,
  executingTools,
  buildingContext,
  anonymizing,
  awaitingLlm,
  deanonymizing,
  extractingMemory,
  updatingGraph,
  streaming,
  error,
}

/// Agent processing state
class AgentState {
  final AgentStateType type;
  final String? userMessage;
  final AgentIntent? intent;
  final ExtractedEntities? entities;
  final MemoryContext? memoryContext;
  final AnonymizationMap? anonymizationMap;
  final String? partialResponse;
  final String? errorMessage;
  final AgentState? previousState;

  const AgentState._({
    required this.type,
    this.userMessage,
    this.intent,
    this.entities,
    this.memoryContext,
    this.anonymizationMap,
    this.partialResponse,
    this.errorMessage,
    this.previousState,
  });

  /// Waiting for user input
  const AgentState.idle() : this._(type: AgentStateType.idle);

  /// Classifying user intent
  AgentState.classifyingIntent({required String userMessage})
      : this._(type: AgentStateType.classifyingIntent, userMessage: userMessage);

  /// Executing local tools (calendar, contacts, etc.)
  AgentState.executingTools({
    required String userMessage,
    required AgentIntent intent,
    required ExtractedEntities entities,
  }) : this._(
          type: AgentStateType.executingTools,
          userMessage: userMessage,
          intent: intent,
          entities: entities,
        );

  /// Building memory context from on-device graph
  AgentState.buildingContext({
    required String userMessage,
    required AgentIntent intent,
    required ExtractedEntities entities,
  }) : this._(
          type: AgentStateType.buildingContext,
          userMessage: userMessage,
          intent: intent,
          entities: entities,
        );

  /// Anonymizing PII before LLM call
  AgentState.anonymizing({
    required String userMessage,
    required AgentIntent intent,
    required MemoryContext memoryContext,
  }) : this._(
          type: AgentStateType.anonymizing,
          userMessage: userMessage,
          intent: intent,
          memoryContext: memoryContext,
        );

  /// Waiting for LLM response
  AgentState.awaitingLlm({
    required String anonymizedMessage,
    required String anonymizedContext,
    required AnonymizationMap anonymizationMap,
  }) : this._(
          type: AgentStateType.awaitingLlm,
          userMessage: anonymizedMessage,
          partialResponse: anonymizedContext,
          anonymizationMap: anonymizationMap,
        );

  /// De-anonymizing LLM response
  AgentState.deanonymizing({
    required String llmResponse,
    required AnonymizationMap anonymizationMap,
  }) : this._(
          type: AgentStateType.deanonymizing,
          partialResponse: llmResponse,
          anonymizationMap: anonymizationMap,
        );

  /// Extracting memories from response (on-device)
  AgentState.extractingMemory({
    required String userMessage,
    required String assistantResponse,
  }) : this._(
          type: AgentStateType.extractingMemory,
          userMessage: userMessage,
          partialResponse: assistantResponse,
        );

  /// Updating memory graph with new nodes/edges
  AgentState.updatingGraph({
    required List<MemoryExtraction> extractions,
  }) : this._(type: AgentStateType.updatingGraph);

  /// Streaming response to UI
  AgentState.streaming({
    required String partialResponse,
    required AnonymizationMap anonymizationMap,
  }) : this._(
          type: AgentStateType.streaming,
          partialResponse: partialResponse,
          anonymizationMap: anonymizationMap,
        );

  /// Error occurred during processing
  AgentState.error({
    required String message,
    required AgentState previousState,
  }) : this._(
          type: AgentStateType.error,
          errorMessage: message,
          previousState: previousState,
        );

  bool get isIdle => type == AgentStateType.idle;
  bool get isError => type == AgentStateType.error;
  bool get isStreaming => type == AgentStateType.streaming;
}

/// Extracted memory from conversation
class MemoryExtraction {
  /// The fact or information to remember
  final String content;

  /// Type of memory (fact, preference, relationship, event)
  final MemoryType type;

  /// Confidence score (0.0 - 1.0)
  final double confidence;

  /// Related entities
  final List<String> entities;

  /// Source message
  final String? sourceMessage;

  const MemoryExtraction({
    required this.content,
    required this.type,
    required this.confidence,
    this.entities = const [],
    this.sourceMessage,
  });
}

/// Types of memories that can be extracted
enum MemoryType {
  /// A factual statement about something
  fact,

  /// User preference or opinion
  preference,

  /// Relationship between people/entities
  relationship,

  /// Past or future event
  event,

  /// Contact information
  contact,

  /// Location information
  location,
}

/// Result of agent processing
class AgentResult {
  /// The response to show the user
  final String response;

  /// Whether streaming is complete
  final bool isComplete;

  /// Intent that was detected
  final AgentIntent? intent;

  /// Tool results if any tools were executed
  final Map<String, dynamic>? toolResults;

  /// Memories that were extracted
  final List<MemoryExtraction> extractedMemories;

  /// Error message if processing failed
  final String? error;

  const AgentResult({
    required this.response,
    this.isComplete = true,
    this.intent,
    this.toolResults,
    this.extractedMemories = const [],
    this.error,
  });
}
