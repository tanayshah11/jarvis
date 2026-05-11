import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/conversation.dart';
import '../models/mock_conversations.dart';

/// State class for conversation history.
class HistoryState {
  /// List of all conversations.
  final List<Conversation> conversations;

  /// Current search query.
  final String searchQuery;

  /// Whether data is currently loading.
  final bool isLoading;

  /// Error message if any.
  final String? error;

  const HistoryState({
    required this.conversations,
    this.searchQuery = '',
    this.isLoading = false,
    this.error,
  });

  HistoryState copyWith({
    List<Conversation>? conversations,
    String? searchQuery,
    bool? isLoading,
    String? error,
  }) {
    return HistoryState(
      conversations: conversations ?? this.conversations,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Get filtered conversations based on search query.
  List<Conversation> get filteredConversations {
    if (searchQuery.isEmpty) {
      return conversations;
    }

    final query = searchQuery.toLowerCase();
    return conversations.where((conversation) {
      return conversation.title.toLowerCase().contains(query) ||
          (conversation.lastMessage?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  /// Get conversations from today.
  List<Conversation> get todayConversations {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return filteredConversations.where((conversation) {
      final conversationDate = DateTime(
        conversation.timestamp.year,
        conversation.timestamp.month,
        conversation.timestamp.day,
      );
      return conversationDate.isAtSameMomentAs(today);
    }).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Get conversations from yesterday.
  List<Conversation> get yesterdayConversations {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day).subtract(
      const Duration(days: 1),
    );

    return filteredConversations.where((conversation) {
      final conversationDate = DateTime(
        conversation.timestamp.year,
        conversation.timestamp.month,
        conversation.timestamp.day,
      );
      return conversationDate.isAtSameMomentAs(yesterday);
    }).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Get conversations from the previous 7 days (excluding today and yesterday).
  List<Conversation> get previous7DaysConversations {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sevenDaysAgo = today.subtract(const Duration(days: 7));

    return filteredConversations.where((conversation) {
      final conversationDate = DateTime(
        conversation.timestamp.year,
        conversation.timestamp.month,
        conversation.timestamp.day,
      );
      return conversationDate.isBefore(today.subtract(const Duration(days: 1))) &&
          conversationDate.isAfter(sevenDaysAgo);
    }).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Get conversations older than 7 days.
  List<Conversation> get olderConversations {
    final now = DateTime.now();
    final sevenDaysAgo = DateTime(now.year, now.month, now.day).subtract(
      const Duration(days: 7),
    );

    return filteredConversations.where((conversation) {
      final conversationDate = DateTime(
        conversation.timestamp.year,
        conversation.timestamp.month,
        conversation.timestamp.day,
      );
      return conversationDate.isBefore(sevenDaysAgo);
    }).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }
}

/// Notifier for managing conversation history state.
class HistoryNotifier extends Notifier<HistoryState> {
  @override
  HistoryState build() {
    return HistoryState(conversations: mockConversations);
  }

  /// Update the search query.
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Clear the search query.
  void clearSearch() {
    state = state.copyWith(searchQuery: '');
  }

  /// Delete a conversation.
  Future<void> deleteConversation(String conversationId) async {
    final updatedConversations = state.conversations
        .where((c) => c.id != conversationId)
        .toList();

    state = state.copyWith(conversations: updatedConversations);
  }

  /// Refresh conversations (e.g., from API).
  Future<void> refreshConversations() async {
    state = state.copyWith(isLoading: true);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // In a real app, this would fetch from an API
      state = state.copyWith(
        conversations: mockConversations,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

/// Provider for conversation history controller.
final historyControllerProvider =
    NotifierProvider<HistoryNotifier, HistoryState>(() {
  return HistoryNotifier();
});
