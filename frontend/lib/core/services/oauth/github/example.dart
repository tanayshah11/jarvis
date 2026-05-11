// Example usage of the GitHub integration service
//
// This file demonstrates how to use the GitHub service and register tools
// for AI functionality in the Jarvis assistant.

// ignore_for_file: avoid_print

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jarvis/core/integrations/integration_manager.dart';
import 'package:jarvis/core/integrations/tool_registry.dart';
import 'package:jarvis/core/integrations/tools/github_tools.dart';
import 'package:jarvis/core/services/oauth/github/github.dart';

/// Initialize GitHub integration
///
/// This should be called during app initialization to register GitHub tools
/// with the tool registry.
void initializeGitHubIntegration(WidgetRef ref) {
  final toolRegistry = ref.read(toolRegistryProvider);
  final githubService = ref.read(githubServiceProvider);

  // Register all GitHub tools for AI use
  registerGitHubTools(toolRegistry, githubService);
}

/// Example: Connect GitHub account
Future<void> connectGitHub(WidgetRef ref) async {
  final integrationManager = ref.read(integrationManagerProvider);

  try {
    final success = await integrationManager.connect('github');
    if (success) {
      print('GitHub connected successfully!');
    } else {
      print('Failed to connect GitHub');
    }
  } catch (e) {
    print('Error connecting GitHub: $e');
  }
}

/// Example: Get user profile
Future<void> getUserProfile(WidgetRef ref) async {
  final githubService = ref.read(githubServiceProvider);

  try {
    final user = await githubService.getAuthenticatedUser();

    print('=== GitHub Profile ===');
    print('Username: ${user.login}');
    print('Name: ${user.name}');
    print('Bio: ${user.bio}');
    print('Company: ${user.company}');
    print('Location: ${user.location}');
    print('Email: ${user.email}');
    print('Public Repos: ${user.publicRepos}');
    print('Followers: ${user.followers}');
    print('Following: ${user.following}');
  } on GitHubNotAuthenticatedException {
    print('Please connect your GitHub account first');
  } catch (e) {
    print('Error fetching profile: $e');
  }
}

/// Example: List recent repositories
Future<void> listRecentRepos(WidgetRef ref) async {
  final githubService = ref.read(githubServiceProvider);

  try {
    final repos = await githubService.getMyRepos(
      sort: 'updated',
      perPage: 10,
    );

    print('=== Recent Repositories ===');
    for (final repo in repos) {
      print('\n${repo.fullName}');
      if (repo.description != null) {
        print('  ${repo.description}');
      }
      print('  Language: ${repo.language ?? 'N/A'}');
      print('  Stars: ${repo.stargazersCount} | Forks: ${repo.forksCount}');
      print('  Open Issues: ${repo.openIssuesCount}');
      print('  Updated: ${repo.updatedAt}');
      print('  URL: ${repo.htmlUrl}');
    }
  } catch (e) {
    print('Error listing repos: $e');
  }
}

/// Example: Create an issue
Future<void> createBugReport(WidgetRef ref) async {
  final githubService = ref.read(githubServiceProvider);

  try {
    final issue = await githubService.createIssue(
      'myusername',
      'myrepo',
      title: 'Bug: App crashes on startup',
      body: '''
## Description
The app crashes immediately when launched on iOS 17.

## Steps to Reproduce
1. Launch the app
2. App crashes before showing main screen

## Expected Behavior
App should launch successfully

## Actual Behavior
App crashes with error message

## Environment
- iOS 17.0
- iPhone 14 Pro
- App version 1.0.0
      ''',
      labels: ['bug', 'ios'],
    );

    print('Created issue #${issue.number}');
    print('Title: ${issue.title}');
    print('URL: ${issue.htmlUrl}');
  } catch (e) {
    print('Error creating issue: $e');
  }
}

/// Example: List open pull requests
Future<void> listOpenPRs(WidgetRef ref, String owner, String repo) async {
  final githubService = ref.read(githubServiceProvider);

  try {
    final prs = await githubService.getPullRequests(
      owner,
      repo,
      state: 'open',
    );

    print('=== Open Pull Requests for $owner/$repo ===');
    for (final pr in prs) {
      print('\nPR #${pr.number}: ${pr.title}');
      print('  Author: ${pr.user.login}');
      print('  ${pr.headRef} -> ${pr.baseRef}');
      print('  Draft: ${pr.draft}');
      if (pr.additions != null && pr.deletions != null) {
        print('  Changes: +${pr.additions} -${pr.deletions}');
      }
      print('  Created: ${pr.createdAt}');
      print('  URL: ${pr.htmlUrl}');
    }
  } catch (e) {
    print('Error listing PRs: $e');
  }
}

/// Example: Create a gist
Future<void> createCodeSnippet(WidgetRef ref) async {
  final githubService = ref.read(githubServiceProvider);

  try {
    final gist = await githubService.createGist(
      files: {
        'hello.dart': '''
void main() {
  print('Hello, GitHub!');
}
''',
        'README.md': '''
# Example Code Snippet

This is a simple Dart example demonstrating a hello world program.
''',
      },
      description: 'Simple Dart hello world example',
      public: true,
    );

    print('Created gist: ${gist.htmlUrl}');
    print('Description: ${gist.description}');
    print('Files: ${gist.files.keys.join(', ')}');
  } catch (e) {
    print('Error creating gist: $e');
  }
}

/// Example: Check notifications
Future<void> checkNotifications(WidgetRef ref) async {
  final githubService = ref.read(githubServiceProvider);

  try {
    final notifications = await githubService.getNotifications(all: false);

    print('=== GitHub Notifications (${notifications.length}) ===');
    for (final notif in notifications) {
      print('\n${notif.subjectType}: ${notif.subjectTitle}');
      print('  Repository: ${notif.repository.fullName}');
      print('  Reason: ${notif.reason}');
      print('  Unread: ${notif.unread}');
      print('  Updated: ${notif.updatedAt}');
    }

    if (notifications.isEmpty) {
      print('No notifications!');
    }
  } catch (e) {
    print('Error checking notifications: $e');
  }
}

/// Example: Search repositories
Future<void> searchFlutterRepos(WidgetRef ref) async {
  final githubService = ref.read(githubServiceProvider);

  try {
    // Search for popular Flutter repositories
    final repos = await githubService.searchRepos(
      'flutter language:dart stars:>100',
      perPage: 10,
    );

    print('=== Popular Flutter Repositories ===');
    for (final repo in repos) {
      print('\n${repo.fullName}');
      print('  ${repo.description}');
      print('  Stars: ${repo.stargazersCount} | Forks: ${repo.forksCount}');
      print('  Language: ${repo.language}');
      print('  URL: ${repo.htmlUrl}');
    }
  } catch (e) {
    print('Error searching repos: $e');
  }
}

/// Example: Check rate limit status
void checkRateLimit(WidgetRef ref) {
  final githubService = ref.read(githubServiceProvider);
  final status = githubService.getRateLimitStatus();

  print('=== Rate Limit Status ===');
  print('Limit: ${status['limit'] ?? 'Unknown'}');
  print('Remaining: ${status['remaining'] ?? 'Unknown'}');
  if (status['reset_at'] != null) {
    final resetAt = DateTime.parse(status['reset_at'] as String);
    final timeUntilReset = resetAt.difference(DateTime.now());
    print('Resets in: ${timeUntilReset.inMinutes} minutes');
  }
}

/// Example: Error handling demonstration
Future<void> demonstrateErrorHandling(WidgetRef ref) async {
  final githubService = ref.read(githubServiceProvider);

  try {
    // This will fail if not authenticated
    await githubService.getAuthenticatedUser();
  } on GitHubNotAuthenticatedException {
    print('❌ Not authenticated - please connect GitHub account');
  } on GitHubRateLimitException catch (e) {
    print('❌ Rate limit exceeded');
    print('   Limit: ${e.limit}');
    print('   Remaining: ${e.remaining}');
    print('   Resets at: ${e.resetAt}');
  } on GitHubApiException catch (e) {
    print('❌ GitHub API error [${e.statusCode}]: ${e.message}');
  } catch (e) {
    print('❌ Unexpected error: $e');
  }
}

/// Example: Get repository with full details
Future<void> getRepoDetails(
  WidgetRef ref,
  String owner,
  String repo,
) async {
  final githubService = ref.read(githubServiceProvider);

  try {
    final repository = await githubService.getRepo(owner, repo);

    print('=== Repository Details ===');
    print('Name: ${repository.fullName}');
    print('Description: ${repository.description}');
    print('Private: ${repository.private}');
    print('Language: ${repository.language}');
    print('Default Branch: ${repository.defaultBranch}');
    print('\nStatistics:');
    print('  Stars: ${repository.stargazersCount}');
    print('  Forks: ${repository.forksCount}');
    print('  Open Issues: ${repository.openIssuesCount}');
    print('\nTimestamps:');
    print('  Created: ${repository.createdAt}');
    print('  Updated: ${repository.updatedAt}');
    if (repository.pushedAt != null) {
      print('  Last Push: ${repository.pushedAt}');
    }
    print('\nURL: ${repository.htmlUrl}');
  } catch (e) {
    print('Error getting repo details: $e');
  }
}

/// Example: List issues with filtering
Future<void> listBugIssues(
  WidgetRef ref,
  String owner,
  String repo,
) async {
  final githubService = ref.read(githubServiceProvider);

  try {
    final issues = await githubService.getIssues(
      owner,
      repo,
      state: 'open',
      perPage: 20,
    );

    // Filter for bugs (in practice, use GitHub's search API for this)
    final bugs = issues.where((issue) =>
        issue.labels.any((label) => label.name.toLowerCase() == 'bug'));

    print('=== Bug Issues in $owner/$repo ===');
    for (final issue in bugs) {
      print('\nIssue #${issue.number}: ${issue.title}');
      print('  Author: ${issue.user.login}');
      print('  State: ${issue.state}');
      print('  Labels: ${issue.labels.map((l) => l.name).join(', ')}');
      print('  Comments: ${issue.comments}');
      print('  Created: ${issue.createdAt}');
      print('  URL: ${issue.htmlUrl}');
    }

    print('\nTotal bugs found: ${bugs.length}');
  } catch (e) {
    print('Error listing issues: $e');
  }
}
