/// GitHub integration service
///
/// This library provides access to GitHub API functionality including:
/// - User profile information
/// - Repository management
/// - Issue tracking
/// - Pull request management
/// - Gist creation and management
/// - Notifications
/// - Search functionality
///
/// OAuth Scopes Required:
/// - repo: Full repository access (read/write)
/// - user: Read user profile data
/// - gist: Create and manage gists
/// - notifications: Access notifications
///
/// Rate Limiting:
/// GitHub API has rate limits (typically 5000 requests/hour for authenticated users).
/// The service automatically tracks rate limit headers and throws
/// GitHubRateLimitException when limits are exceeded.
///
/// Example usage:
/// ```dart
/// final githubService = ref.read(githubServiceProvider);
///
/// // Get user profile
/// final user = await githubService.getAuthenticatedUser();
///
/// // List repositories
/// final repos = await githubService.getMyRepos(sort: 'updated');
///
/// // Create an issue
/// final issue = await githubService.createIssue(
///   'owner',
///   'repo',
///   title: 'Bug report',
///   body: 'Description of the bug',
/// );
/// ```
library;

export 'github_models.dart';
export 'github_service.dart';
