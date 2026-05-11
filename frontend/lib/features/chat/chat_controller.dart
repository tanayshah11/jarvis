import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/network/api_client.dart';
import '../../core/storage/local_storage.dart';
import '../../data/data_service.dart';
import '../../data/database/database.dart';
import '../../data/repositories/memory_repository.dart';
import '../agent/agent_controller.dart';
import '../profile/profile_model.dart';

const String _logName = 'ChatController';

// Conversation model
class Conversation {
  final String id;
  final String? title;
  final String mode;
  final DateTime createdAt;
  final bool isArchived;

  Conversation({
    required this.id,
    this.title,
    required this.mode,
    required this.createdAt,
    this.isArchived = false,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      title: json['title'],
      mode: json['mode'] ?? 'chat',
      createdAt: DateTime.parse(json['created_at']),
      isArchived: json['is_archived'] ?? false,
    );
  }
}

// Message model
class ChatMessage {
  final String id;
  final String role; // 'user' or 'assistant'
  final String content;
  final DateTime timestamp;
  final bool isStreaming;

  ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    DateTime? timestamp,
    this.isStreaming = false,
  }) : timestamp = timestamp ?? DateTime.now();

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      role: json['role'],
      content: json['content'],
      timestamp: DateTime.parse(json['created_at']),
      isStreaming: false,
    );
  }

  ChatMessage copyWith({
    String? id,
    String? role,
    String? content,
    DateTime? timestamp,
    bool? isStreaming,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isStreaming: isStreaming ?? this.isStreaming,
    );
  }

  Map<String, dynamic> toApiJson() {
    return {'role': role, 'content': content};
  }
}

// Chat state
class ChatState {
  final List<ChatMessage> messages;
  final List<Conversation> conversations;
  final String? currentConversationId;
  final bool isLoading;
  final String? error;
  final String mode;
  final AiProvider currentProvider;
  final bool isAgentMode; // Whether to use the agentic AI with clarification
  final bool
  awaitingAgentResponse; // Whether agent is waiting for user clarification

  const ChatState({
    this.messages = const [],
    this.conversations = const [],
    this.currentConversationId,
    this.isLoading = false,
    this.error,
    this.mode = 'chat',
    this.currentProvider = AiProvider.groq,
    this.isAgentMode = true, // Default to agent mode
    this.awaitingAgentResponse = false,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    List<Conversation>? conversations,
    String? currentConversationId,
    bool? isLoading,
    String? error,
    String? mode,
    AiProvider? currentProvider,
    bool? isAgentMode,
    bool? awaitingAgentResponse,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      conversations: conversations ?? this.conversations,
      currentConversationId:
          currentConversationId ?? this.currentConversationId,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      mode: mode ?? this.mode,
      currentProvider: currentProvider ?? this.currentProvider,
      isAgentMode: isAgentMode ?? this.isAgentMode,
      awaitingAgentResponse:
          awaitingAgentResponse ?? this.awaitingAgentResponse,
    );
  }
}

final chatControllerProvider = NotifierProvider<ChatController, ChatState>(() {
  return ChatController();
});

class ChatController extends Notifier<ChatState> {
  StreamSubscription? _streamSubscription;

  // Use getters to access providers - avoids late initialization issues on rebuild
  ApiClient get apiClient => ref.read(apiClientProvider);
  DataService get dataService => ref.read(dataServiceProvider);
  LocalStorage get localStorage => ref.read(localStorageProvider);
  MemoryRepository get memoryRepository => ref.read(memoryRepositoryProvider);

  @override
  ChatState build() {
    ref.onDispose(() {
      _streamSubscription?.cancel();
    });

    _loadCurrentProvider();
    loadConversations();

    return const ChatState();
  }

  Future<void> _loadCurrentProvider() async {
    try {
      // Get current user ID from localStorage (or use a default)
      final userId =
          await localStorage.getSetting('user_id') as String? ?? 'default_user';

      // Load from local Drift DB
      final profile = await dataService.database.getProfileByUserId(userId);
      if (profile != null) {
        final provider = AiProvider.fromString(profile.preferredAiProvider);
        state = state.copyWith(currentProvider: provider);
      }
    } catch (e) {
      // Profile might not exist yet, use default
    }
  }

  Future<void> loadConversations() async {
    try {
      // Load from local conversationRepository
      final dbConversations = await dataService.conversationRepository
          .getAllConversations();

      // Convert to Conversation model
      final conversations = dbConversations.map((dbConv) {
        return Conversation(
          id: dbConv.id,
          title: dbConv.title,
          mode: 'chat', // Default mode since it's not in the DB schema
          createdAt: dbConv.createdAt,
          isArchived: dbConv.isArchived,
        );
      }).toList();

      state = state.copyWith(conversations: conversations);
    } catch (e) {
      // Silently fail or use a proper logger in production
    }
  }

  Future<void> loadConversation(String id) async {
    try {
      state = state.copyWith(isLoading: true, currentConversationId: id);

      // Get conversation details from local DB
      final dbConversation = await dataService.conversationRepository
          .getConversation(id);
      if (dbConversation != null) {
        state = state.copyWith(mode: 'chat'); // Default mode
      }

      // Get messages from local DB
      final dbMessages = await dataService.conversationRepository.getMessages(
        id,
      );
      final messages = dbMessages.map((dbMsg) {
        return ChatMessage(
          id: dbMsg.id,
          role: dbMsg.role,
          content: dbMsg.content,
          timestamp: dbMsg.createdAt,
          isStreaming: false,
        );
      }).toList();

      state = state.copyWith(messages: messages, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load conversation',
      );
    }
  }

  Future<void> createConversation({String? title}) async {
    try {
      // Create conversation in local DB with title
      final conversationId = await dataService.conversationRepository
          .createConversation(title: title);

      final now = DateTime.now();
      final conversation = Conversation(
        id: conversationId,
        title: title,
        mode: state.mode,
        createdAt: now,
        isArchived: false,
      );

      state = state.copyWith(
        conversations: [conversation, ...state.conversations],
        currentConversationId: conversationId,
        messages: [],
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to create conversation');
    }
  }

  /// Generate a short title from the first message
  String _generateTitleFromMessage(String content) {
    // Remove extra whitespace and truncate
    final cleaned = content.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (cleaned.length <= 40) return cleaned;
    // Find a good break point (space, punctuation)
    final truncated = cleaned.substring(0, 40);
    final lastSpace = truncated.lastIndexOf(' ');
    if (lastSpace > 20) {
      return '${truncated.substring(0, lastSpace)}...';
    }
    return '$truncated...';
  }

  void setMode(String mode) {
    state = state.copyWith(mode: mode);
  }

  void toggleAgentMode() {
    state = state.copyWith(isAgentMode: !state.isAgentMode);
  }

  void setAgentMode(bool enabled) {
    state = state.copyWith(isAgentMode: enabled);
  }

  Future<void> setProvider(AiProvider provider) async {
    try {
      // Get current user ID
      final userId =
          await localStorage.getSetting('user_id') as String? ?? 'default_user';

      // Load profile from local DB
      final profile = await dataService.database.getProfileByUserId(userId);

      if (profile != null) {
        // Update existing profile
        final updatedProfile = profile.copyWith(
          preferredAiProvider: provider.value,
          updatedAt: DateTime.now(),
        );
        await dataService.database.updateProfile(updatedProfile);
      } else {
        // Create new profile if doesn't exist
        await dataService.database.insertProfile(
          ProfilesCompanion.insert(
            id: const Uuid().v4(),
            userId: userId,
            preferredAiProvider: Value(provider.value),
          ),
        );
      }

      state = state.copyWith(currentProvider: provider);
    } catch (e) {
      state = state.copyWith(error: 'Failed to update AI provider');
    }
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    // Cancel any existing stream
    await _streamSubscription?.cancel();

    // Ensure we have a conversation - create with title from first message
    if (state.currentConversationId == null) {
      final title = _generateTitleFromMessage(content);
      await createConversation(title: title);
      if (state.error != null) return;
    }

    final conversationId = state.currentConversationId!;

    // Add user message to UI immediately
    final userMessageId = const Uuid().v4();
    final userMessage = ChatMessage(
      id: userMessageId,
      role: 'user',
      content: content,
    );

    // Save user message to local DB
    await dataService.conversationRepository.addMessage(
      conversationId: conversationId,
      role: 'user',
      content: content,
    );

    // Add placeholder assistant message for streaming
    final assistantMessageId = const Uuid().v4();
    final assistantMessage = ChatMessage(
      id: assistantMessageId,
      role: 'assistant',
      content: '',
      isStreaming: true,
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage, assistantMessage],
      isLoading: true,
      error: null,
    );

    try {
      // Build memory context from local knowledge graph
      String memoryContext = '';
      try {
        // Build memory context from knowledge graph
        memoryContext = await memoryRepository.buildMemoryContext(
          query: content,
          maxNodes: 8,
          minScore: 0.0,
        );
      } catch (e, stackTrace) {
        developer.log(
          'Failed to build memory context: $e',
          name: _logName,
          level: 900,
          error: e,
          stackTrace: stackTrace,
        );
      }

      // Build message history for the LLM (only user/assistant messages)
      final conversationHistory = state.messages
          .where((msg) => msg.id != assistantMessageId) // Exclude placeholder
          .map((msg) => msg.toApiJson())
          .toList();

      // Use on-device agent if agent mode is enabled
      // Agent handles memory extraction internally (privacy-first)
      if (state.isAgentMode) {
        await _sendAgentMessage(
          conversationId: conversationId,
          messages: conversationHistory,
          memoryContext: memoryContext,
          assistantMessageId: assistantMessageId,
        );
      } else {
        await _sendStreamingMessage(
          conversationId: conversationId,
          messages: conversationHistory,
          memoryContext: memoryContext,
          assistantMessageId: assistantMessageId,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to send message: $e',
      );
    }
  }

  /// Send message using the on-device agent (privacy-first)
  ///
  /// All processing happens locally:
  /// - Intent classification
  /// - Memory context building
  /// - Entity anonymization (if enabled)
  /// - Memory extraction
  ///
  /// Only anonymized queries are sent to the backend LLM proxy.
  Future<void> _sendAgentMessage({
    required String conversationId,
    required List<Map<String, dynamic>> messages,
    required String memoryContext,
    required String assistantMessageId,
  }) async {
    try {
      // Get the user's message (last message in history)
      final userMessage = messages.isNotEmpty
          ? messages.last['content'] as String? ?? ''
          : '';

      if (userMessage.isEmpty) {
        throw Exception('Empty user message');
      }

      // Get the on-device agent controller
      final agentController = ref.read(agentControllerProvider.notifier);

      // Process through on-device agent pipeline
      String finalResponse = '';

      await for (final result in agentController.processMessage(userMessage)) {
        if (result.error != null) {
          throw Exception(result.error);
        }

        // Update UI with streaming response
        _updateAssistantMessage(
          assistantMessageId,
          result.response,
          !result.isComplete,
        );

        if (result.isComplete) {
          finalResponse = result.response;

          // Log extracted memories
          if (result.extractedMemories.isNotEmpty) {
            developer.log(
              'On-device memory extraction: ${result.extractedMemories.length} memories',
              name: _logName,
            );
          }
        }
      }

      // Save assistant message to DB
      await dataService.conversationRepository.addMessage(
        conversationId: conversationId,
        role: 'assistant',
        content: finalResponse,
      );

      state = state.copyWith(
        isLoading: false,
        awaitingAgentResponse: false,
      );

      // Refresh conversations list
      loadConversations();
    } catch (e) {
      rethrow;
    }
  }

  /// Send message using the streaming LLM endpoint
  Future<void> _sendStreamingMessage({
    required String conversationId,
    required List<Map<String, dynamic>> messages,
    required String memoryContext,
    required String assistantMessageId,
  }) async {
    // Use /llm/chat endpoint for streaming response
    final response = await apiClient.postStream(
      '/llm/chat',
      data: {
        'messages': messages,
        'memory_context': memoryContext.isNotEmpty ? memoryContext : null,
        'provider': state.currentProvider.value,
        'stream': true,
      },
    );

    if (response.data == null) {
      throw Exception('No response data');
    }

    final stream = response.data!.stream;
    final StringBuffer buffer = StringBuffer();

    _streamSubscription = stream
        .cast<List<int>>()
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(
          (line) {
            if (line.startsWith('data: ')) {
              final data = line.substring(6);

              if (data == '[DONE]') {
                // Stream complete - save assistant message to DB
                final finalContent = buffer.toString();
                dataService.conversationRepository.addMessage(
                  conversationId: conversationId,
                  role: 'assistant',
                  content: finalContent,
                );

                _updateAssistantMessage(
                  assistantMessageId,
                  finalContent,
                  false,
                );
                state = state.copyWith(isLoading: false);

                // Refresh list to get updated title if it was first message
                loadConversations();
              } else if (data.startsWith('[ERROR]')) {
                // Error occurred
                state = state.copyWith(
                  isLoading: false,
                  error: data.substring(8),
                );
              } else {
                // Append chunk to buffer and update UI
                buffer.write(data);
                _updateAssistantMessage(
                  assistantMessageId,
                  buffer.toString(),
                  true,
                );
              }
            }
          },
          onError: (error) {
            state = state.copyWith(
              isLoading: false,
              error: 'Stream error: $error',
            );
          },
          onDone: () {
            if (state.isLoading) {
              final finalContent = buffer.toString();

              // Save to DB if not already saved
              dataService.conversationRepository.addMessage(
                conversationId: conversationId,
                role: 'assistant',
                content: finalContent,
              );

              _updateAssistantMessage(assistantMessageId, finalContent, false);
              state = state.copyWith(isLoading: false);
            }
          },
        );
  }

  void _updateAssistantMessage(
    String messageId,
    String content,
    bool isStreaming,
  ) {
    final updatedMessages = state.messages.map((msg) {
      if (msg.id == messageId) {
        return msg.copyWith(content: content, isStreaming: isStreaming);
      }
      return msg;
    }).toList();

    state = state.copyWith(messages: updatedMessages);
  }

  Future<void> startNewChat() async {
    _streamSubscription?.cancel();
    // Just clear state - conversation will be created when first message is sent
    state = state.copyWith(
      messages: [],
      currentConversationId: null,
      isLoading: false,
      error: null,
    );
  }

  Future<bool> renameConversation(String id, String newTitle) async {
    try {
      // Update in local DB
      await dataService.conversationRepository.updateConversationTitle(
        id,
        newTitle,
      );

      // Update local state
      final updatedConversations = state.conversations.map((conv) {
        if (conv.id == id) {
          return Conversation(
            id: conv.id,
            title: newTitle,
            mode: conv.mode,
            createdAt: conv.createdAt,
            isArchived: conv.isArchived,
          );
        }
        return conv;
      }).toList();
      state = state.copyWith(conversations: updatedConversations);
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to rename conversation');
      return false;
    }
  }

  Future<bool> deleteConversation(String id) async {
    try {
      // Delete from local DB
      await dataService.conversationRepository.deleteConversation(id);

      // Remove from local state
      final updatedConversations = state.conversations
          .where((conv) => conv.id != id)
          .toList();

      // If deleted conversation was current, clear it
      final newCurrentId = state.currentConversationId == id
          ? null
          : state.currentConversationId;

      state = state.copyWith(
        conversations: updatedConversations,
        currentConversationId: newCurrentId,
        messages: newCurrentId == null ? [] : state.messages,
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete conversation');
      return false;
    }
  }

  Future<bool> archiveConversation(String id, bool archive) async {
    try {
      // Update in local DB
      await dataService.conversationRepository.archiveConversation(id);

      // Update local state
      final updatedConversations = state.conversations.map((conv) {
        if (conv.id == id) {
          return Conversation(
            id: conv.id,
            title: conv.title,
            mode: conv.mode,
            createdAt: conv.createdAt,
            isArchived: archive,
          );
        }
        return conv;
      }).toList();
      state = state.copyWith(conversations: updatedConversations);
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to archive conversation');
      return false;
    }
  }

  void clearChat() {
    _streamSubscription?.cancel();
    // Just reset current conversation view, but keep the conversation ID if we want to continue?
    // Actually "Clear Chat" usually means start fresh
    state = state.copyWith(
      messages: [],
      currentConversationId: null,
      isLoading: false,
      error: null,
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
