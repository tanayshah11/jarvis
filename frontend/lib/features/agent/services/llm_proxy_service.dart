/// LLM Proxy Service - Thin client for backend LLM proxy
///
/// Sends anonymized messages to the backend for LLM inference.
/// The backend is stateless - it just proxies to the configured LLM provider.
library;

import 'dart:async';
import 'dart:convert' show utf8;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';

/// LLM proxy service provider
final llmProxyServiceProvider = Provider<LlmProxyService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return LlmProxyService(apiClient: apiClient);
});

/// LLM chat message
class LlmMessage {
  final String role;
  final String content;

  const LlmMessage({
    required this.role,
    required this.content,
  });

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
      };
}

/// LLM chat request
class LlmChatRequest {
  final List<LlmMessage> messages;
  final String? systemPrompt;
  final String provider;
  final bool stream;
  final double temperature;
  final int maxTokens;

  const LlmChatRequest({
    required this.messages,
    this.systemPrompt,
    this.provider = 'groq',
    this.stream = true,
    this.temperature = 0.7,
    this.maxTokens = 2048,
  });

  Map<String, dynamic> toJson() => {
        'messages': messages.map((m) => m.toJson()).toList(),
        if (systemPrompt != null) 'system_prompt': systemPrompt,
        'provider': provider,
        'stream': stream,
        'temperature': temperature,
        'max_tokens': maxTokens,
      };
}

/// LLM proxy service
class LlmProxyService {
  final ApiClient apiClient;

  LlmProxyService({required this.apiClient});

  /// Send a chat request and get a streaming response
  Stream<String> chatStream({
    required List<LlmMessage> messages,
    String? systemPrompt,
    String provider = 'groq',
    double temperature = 0.7,
    int maxTokens = 2048,
  }) async* {
    final request = LlmChatRequest(
      messages: messages,
      systemPrompt: systemPrompt,
      provider: provider,
      stream: true,
      temperature: temperature,
      maxTokens: maxTokens,
    );

    try {
      final response = await apiClient.postStream(
        '/llm/chat',
        data: request.toJson(),
      );

      final stream = response.data?.stream;
      if (stream == null) {
        throw LlmProxyException('No stream in response');
      }

      await for (final chunk in stream) {
        final chunkStr = utf8.decode(chunk);

        // Parse SSE format: data: <text>\n\n
        // Backend sends raw text chunks, not JSON
        for (final line in chunkStr.split('\n')) {
          if (line.startsWith('data: ')) {
            final content = line.substring(6);
            if (content.isEmpty || content == '[DONE]') continue;

            // Yield the raw text content
            yield content;
          }
        }
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw LlmProxyException('Unauthorized - please log in again');
      } else if (e.response?.statusCode == 429) {
        throw LlmProxyException('Rate limited - please try again later');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw LlmProxyException('Connection timeout - check your network');
      } else {
        throw LlmProxyException(
            'LLM request failed: ${e.message ?? "Unknown error"}');
      }
    }
  }

  /// Send a chat request and get a non-streaming response
  Future<String> chat({
    required List<LlmMessage> messages,
    String? systemPrompt,
    String provider = 'groq',
    double temperature = 0.7,
    int maxTokens = 2048,
  }) async {
    final request = LlmChatRequest(
      messages: messages,
      systemPrompt: systemPrompt,
      provider: provider,
      stream: false,
      temperature: temperature,
      maxTokens: maxTokens,
    );

    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        '/llm/chat',
        data: request.toJson(),
      );

      final data = response.data;
      if (data == null) {
        throw LlmProxyException('Empty response from LLM');
      }

      return data['content'] as String? ?? '';
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw LlmProxyException('Unauthorized - please log in again');
      } else if (e.response?.statusCode == 429) {
        throw LlmProxyException('Rate limited - please try again later');
      } else {
        throw LlmProxyException(
            'LLM request failed: ${e.message ?? "Unknown error"}');
      }
    }
  }

  /// Get available LLM providers
  Future<List<String>> getProviders() async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>('/llm/providers');
      final data = response.data;
      if (data == null) return ['groq'];

      final providers = data['providers'] as List<dynamic>?;
      return providers?.map((p) => p.toString()).toList() ?? ['groq'];
    } catch (_) {
      return ['groq']; // Default fallback
    }
  }
}

/// Exception for LLM proxy errors
class LlmProxyException implements Exception {
  final String message;

  const LlmProxyException(this.message);

  @override
  String toString() => 'LlmProxyException: $message';
}
