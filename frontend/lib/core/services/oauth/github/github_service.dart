import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../integrations/integration_manager.dart';
import 'github_models.dart';

/// Exception thrown when GitHub service is not authenticated
class GitHubNotAuthenticatedException implements Exception {
  @override
  String toString() => 'GitHub is not authenticated. Please connect first.';
}

/// Exception thrown when GitHub API request fails
class GitHubApiException implements Exception {
  final int? statusCode;
  final String message;
  final dynamic originalError;

  GitHubApiException(this.message, {this.statusCode, this.originalError});

  @override
  String toString() {
    if (statusCode != null) {
      return 'GitHub API error [$statusCode]: $message';
    }
    return 'GitHub API error: $message';
  }
}

/// Exception thrown when GitHub rate limit is exceeded
class GitHubRateLimitException implements Exception {
  final int limit;
  final int remaining;
  final DateTime resetAt;

  GitHubRateLimitException({
    required this.limit,
    required this.remaining,
    required this.resetAt,
  });

  @override
  String toString() {
    final waitTime = resetAt.difference(DateTime.now());
    return 'GitHub rate limit exceeded. Resets in ${waitTime.inMinutes} minutes.';
  }
}

/// Service for interacting with GitHub API
///
/// Provides methods for managing repositories, issues, pull requests,
/// gists, and notifications. Handles authentication, rate limiting,
/// and error responses from GitHub's REST API v3.
class GitHubService {
  static const _baseUrl = 'https://api.github.com';
  final Dio _dio;
  final IntegrationManager _integrationManager;

  // Rate limit tracking
  int? _rateLimit;
  int? _rateLimitRemaining;
  DateTime? _rateLimitResetAt;

  GitHubService({required IntegrationManager integrationManager})
      : _integrationManager = integrationManager,
        _dio = Dio(BaseOptions(
          baseUrl: _baseUrl,
          headers: {'Accept': 'application/vnd.github.v3+json'},
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 30),
        )) {
    // Add interceptor for rate limit tracking and error handling
    _dio.interceptors.add(
      InterceptorsWrapper(
        onResponse: (response, handler) {
          _updateRateLimitInfo(response.headers);
          handler.next(response);
        },
        onError: (error, handler) {
          _handleError(error, handler);
        },
      ),
    );
  }

  /// Get authorization headers with access token
  Future<Map<String, String>> _getHeaders() async {
    final tokens = await _integrationManager.getTokens('github');
    if (tokens == null) throw GitHubNotAuthenticatedException();
    return {
      'Authorization': 'Bearer ${tokens.accessToken}',
      'Accept': 'application/vnd.github.v3+json',
    };
  }

  /// Update rate limit information from response headers
  void _updateRateLimitInfo(Headers headers) {
    final limit = headers.value('x-ratelimit-limit');
    final remaining = headers.value('x-ratelimit-remaining');
    final reset = headers.value('x-ratelimit-reset');

    if (limit != null) _rateLimit = int.tryParse(limit);
    if (remaining != null) _rateLimitRemaining = int.tryParse(remaining);
    if (reset != null) {
      _rateLimitResetAt = DateTime.fromMillisecondsSinceEpoch(
        int.parse(reset) * 1000,
      );
    }
  }

  /// Handle API errors
  void _handleError(DioException error, ErrorInterceptorHandler handler) {
    if (error.response?.statusCode == 401) {
      handler.reject(
        DioException(
          requestOptions: error.requestOptions,
          error: GitHubNotAuthenticatedException(),
        ),
      );
      return;
    }

    if (error.response?.statusCode == 403) {
      // Check if it's a rate limit error
      final remaining = error.response?.headers.value('x-ratelimit-remaining');
      if (remaining == '0') {
        final resetAt = _rateLimitResetAt ?? DateTime.now();
        handler.reject(
          DioException(
            requestOptions: error.requestOptions,
            error: GitHubRateLimitException(
              limit: _rateLimit ?? 0,
              remaining: 0,
              resetAt: resetAt,
            ),
          ),
        );
        return;
      }
    }

    // Generic API error
    final message = error.response?.data?['message'] as String? ??
        error.message ??
        'Unknown error';

    handler.reject(
      DioException(
        requestOptions: error.requestOptions,
        error: GitHubApiException(
          message,
          statusCode: error.response?.statusCode,
          originalError: error,
        ),
      ),
    );
  }

  /// Get current rate limit status
  Map<String, dynamic> getRateLimitStatus() {
    return {
      'limit': _rateLimit,
      'remaining': _rateLimitRemaining,
      'reset_at': _rateLimitResetAt?.toIso8601String(),
    };
  }

  // === User ===

  /// Get the authenticated user's profile
  Future<GitHubUser> getAuthenticatedUser() async {
    final response = await _dio.get(
      '/user',
      options: Options(headers: await _getHeaders()),
    );
    return GitHubUser.fromJson(response.data as Map<String, dynamic>);
  }

  // === Repositories ===

  /// Get repositories for the authenticated user
  Future<List<GitHubRepo>> getMyRepos({
    String sort = 'updated',
    int perPage = 30,
    int page = 1,
  }) async {
    final response = await _dio.get(
      '/user/repos',
      queryParameters: {'sort': sort, 'per_page': perPage, 'page': page},
      options: Options(headers: await _getHeaders()),
    );
    return (response.data as List)
        .map((r) => GitHubRepo.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  /// Get a specific repository
  Future<GitHubRepo> getRepo(String owner, String repo) async {
    final response = await _dio.get(
      '/repos/$owner/$repo',
      options: Options(headers: await _getHeaders()),
    );
    return GitHubRepo.fromJson(response.data as Map<String, dynamic>);
  }

  // === Issues ===

  /// Get issues for a repository
  Future<List<GitHubIssue>> getIssues(
    String owner,
    String repo, {
    String state = 'open',
    int perPage = 30,
    int page = 1,
  }) async {
    final response = await _dio.get(
      '/repos/$owner/$repo/issues',
      queryParameters: {'state': state, 'per_page': perPage, 'page': page},
      options: Options(headers: await _getHeaders()),
    );
    return (response.data as List)
        .map((i) => GitHubIssue.fromJson(i as Map<String, dynamic>))
        .toList();
  }

  /// Get a specific issue
  Future<GitHubIssue> getIssue(String owner, String repo, int number) async {
    final response = await _dio.get(
      '/repos/$owner/$repo/issues/$number',
      options: Options(headers: await _getHeaders()),
    );
    return GitHubIssue.fromJson(response.data as Map<String, dynamic>);
  }

  /// Create a new issue
  Future<GitHubIssue> createIssue(
    String owner,
    String repo, {
    required String title,
    String? body,
    List<String>? labels,
    List<String>? assignees,
  }) async {
    final response = await _dio.post(
      '/repos/$owner/$repo/issues',
      data: {
        'title': title,
        if (body != null) 'body': body,
        if (labels != null && labels.isNotEmpty) 'labels': labels,
        if (assignees != null && assignees.isNotEmpty) 'assignees': assignees,
      },
      options: Options(headers: await _getHeaders()),
    );
    return GitHubIssue.fromJson(response.data as Map<String, dynamic>);
  }

  /// Update an existing issue
  Future<GitHubIssue> updateIssue(
    String owner,
    String repo,
    int number, {
    String? title,
    String? body,
    String? state,
    List<String>? labels,
    List<String>? assignees,
  }) async {
    final response = await _dio.patch(
      '/repos/$owner/$repo/issues/$number',
      data: {
        if (title != null) 'title': title,
        if (body != null) 'body': body,
        if (state != null) 'state': state,
        if (labels != null) 'labels': labels,
        if (assignees != null) 'assignees': assignees,
      },
      options: Options(headers: await _getHeaders()),
    );
    return GitHubIssue.fromJson(response.data as Map<String, dynamic>);
  }

  /// Close an issue
  Future<void> closeIssue(String owner, String repo, int issueNumber) async {
    await _dio.patch(
      '/repos/$owner/$repo/issues/$issueNumber',
      data: {'state': 'closed'},
      options: Options(headers: await _getHeaders()),
    );
  }

  // === Pull Requests ===

  /// Get pull requests for a repository
  Future<List<GitHubPullRequest>> getPullRequests(
    String owner,
    String repo, {
    String state = 'open',
    int perPage = 30,
    int page = 1,
  }) async {
    final response = await _dio.get(
      '/repos/$owner/$repo/pulls',
      queryParameters: {'state': state, 'per_page': perPage, 'page': page},
      options: Options(headers: await _getHeaders()),
    );
    return (response.data as List)
        .map((p) => GitHubPullRequest.fromJson(p as Map<String, dynamic>))
        .toList();
  }

  /// Get a specific pull request
  Future<GitHubPullRequest> getPullRequest(
    String owner,
    String repo,
    int number,
  ) async {
    final response = await _dio.get(
      '/repos/$owner/$repo/pulls/$number',
      options: Options(headers: await _getHeaders()),
    );
    return GitHubPullRequest.fromJson(response.data as Map<String, dynamic>);
  }

  /// Create a new pull request
  Future<GitHubPullRequest> createPullRequest(
    String owner,
    String repo, {
    required String title,
    required String head,
    required String base,
    String? body,
    bool draft = false,
  }) async {
    final response = await _dio.post(
      '/repos/$owner/$repo/pulls',
      data: {
        'title': title,
        'head': head,
        'base': base,
        if (body != null) 'body': body,
        'draft': draft,
      },
      options: Options(headers: await _getHeaders()),
    );
    return GitHubPullRequest.fromJson(response.data as Map<String, dynamic>);
  }

  /// Merge a pull request
  Future<void> mergePullRequest(
    String owner,
    String repo,
    int number, {
    String? commitTitle,
    String? commitMessage,
    String mergeMethod = 'merge',
  }) async {
    await _dio.put(
      '/repos/$owner/$repo/pulls/$number/merge',
      data: {
        if (commitTitle != null) 'commit_title': commitTitle,
        if (commitMessage != null) 'commit_message': commitMessage,
        'merge_method': mergeMethod,
      },
      options: Options(headers: await _getHeaders()),
    );
  }

  // === Gists ===

  /// Create a new gist
  Future<GitHubGist> createGist({
    required Map<String, String> files, // filename -> content
    String? description,
    bool public = false,
  }) async {
    final response = await _dio.post(
      '/gists',
      data: {
        'files':
            files.map((name, content) => MapEntry(name, {'content': content})),
        if (description != null) 'description': description,
        'public': public,
      },
      options: Options(headers: await _getHeaders()),
    );
    return GitHubGist.fromJson(response.data as Map<String, dynamic>);
  }

  /// Get gists for the authenticated user
  Future<List<GitHubGist>> getMyGists({int perPage = 30, int page = 1}) async {
    final response = await _dio.get(
      '/gists',
      queryParameters: {'per_page': perPage, 'page': page},
      options: Options(headers: await _getHeaders()),
    );
    return (response.data as List)
        .map((g) => GitHubGist.fromJson(g as Map<String, dynamic>))
        .toList();
  }

  /// Get a specific gist
  Future<GitHubGist> getGist(String gistId) async {
    final response = await _dio.get(
      '/gists/$gistId',
      options: Options(headers: await _getHeaders()),
    );
    return GitHubGist.fromJson(response.data as Map<String, dynamic>);
  }

  /// Delete a gist
  Future<void> deleteGist(String gistId) async {
    await _dio.delete(
      '/gists/$gistId',
      options: Options(headers: await _getHeaders()),
    );
  }

  // === Notifications ===

  /// Get notifications for the authenticated user
  Future<List<GitHubNotification>> getNotifications({
    bool all = false,
    int perPage = 30,
    int page = 1,
  }) async {
    final response = await _dio.get(
      '/notifications',
      queryParameters: {'all': all, 'per_page': perPage, 'page': page},
      options: Options(headers: await _getHeaders()),
    );
    return (response.data as List)
        .map((n) => GitHubNotification.fromJson(n as Map<String, dynamic>))
        .toList();
  }

  /// Mark a notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    await _dio.patch(
      '/notifications/threads/$notificationId',
      options: Options(headers: await _getHeaders()),
    );
  }

  /// Mark all notifications as read
  Future<void> markAllNotificationsAsRead() async {
    await _dio.put(
      '/notifications',
      options: Options(headers: await _getHeaders()),
    );
  }

  // === Search ===

  /// Search for repositories
  Future<List<GitHubRepo>> searchRepos(
    String query, {
    int perPage = 10,
    int page = 1,
  }) async {
    final response = await _dio.get(
      '/search/repositories',
      queryParameters: {'q': query, 'per_page': perPage, 'page': page},
      options: Options(headers: await _getHeaders()),
    );
    final items = (response.data as Map<String, dynamic>)['items'] as List;
    return items
        .map((r) => GitHubRepo.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  /// Search for issues
  Future<List<GitHubIssue>> searchIssues(
    String query, {
    int perPage = 10,
    int page = 1,
  }) async {
    final response = await _dio.get(
      '/search/issues',
      queryParameters: {'q': query, 'per_page': perPage, 'page': page},
      options: Options(headers: await _getHeaders()),
    );
    final items = (response.data as Map<String, dynamic>)['items'] as List;
    return items
        .map((i) => GitHubIssue.fromJson(i as Map<String, dynamic>))
        .toList();
  }
}

/// Riverpod provider for GitHub service
final githubServiceProvider = Provider<GitHubService>((ref) {
  final integrationManager = ref.watch(integrationManagerProvider);
  return GitHubService(integrationManager: integrationManager);
});
