# GitHub Integration Service

This package provides comprehensive GitHub API integration for the Jarvis assistant, including repository management, issue tracking, pull requests, gists, and notifications.

## Features

- **User Profile**: Get authenticated user information
- **Repositories**: List, search, and view repository details
- **Issues**: Create, update, close, and search issues
- **Pull Requests**: List, create, and manage pull requests
- **Gists**: Create and manage code snippets
- **Notifications**: Access and manage GitHub notifications
- **Search**: Search repositories and issues
- **Rate Limiting**: Automatic rate limit tracking and handling
- **Error Handling**: Comprehensive error handling with specific exceptions

## Architecture

```
github/
├── github.dart           # Barrel file (export all)
├── github_models.dart    # Data models for GitHub entities
├── github_service.dart   # API service implementation
└── README.md            # This file
```

## Setup

### 1. OAuth Configuration

The GitHub integration requires OAuth authentication with the following scopes:

```dart
const githubScopes = [
  'repo',           // Full repository access
  'user',           // Read user profile
  'gist',           // Create and manage gists
  'notifications',  // Access notifications
];
```

### 2. Register Tools

To make GitHub functionality available to the AI, register the tools with the tool registry:

```dart
import 'package:jarvis/core/integrations/tools/github_tools.dart';
import 'package:jarvis/core/integrations/tool_registry.dart';
import 'package:jarvis/core/services/oauth/github/github_service.dart';

void initializeGitHub(ToolRegistry registry, GitHubService githubService) {
  registerGitHubTools(registry, githubService);
}
```

### 3. Connect Integration

Users must authenticate before using GitHub features:

```dart
final integrationManager = ref.read(integrationManagerProvider);
await integrationManager.connect('github');
```

## Usage Examples

### Get User Profile

```dart
final githubService = ref.read(githubServiceProvider);
final user = await githubService.getAuthenticatedUser();

print('Username: ${user.login}');
print('Name: ${user.name}');
print('Bio: ${user.bio}');
print('Public Repos: ${user.publicRepos}');
print('Followers: ${user.followers}');
```

### List Repositories

```dart
// Get recently updated repositories
final repos = await githubService.getMyRepos(
  sort: 'updated',
  perPage: 20,
);

for (final repo in repos) {
  print('${repo.fullName} - ${repo.description}');
  print('Stars: ${repo.stargazersCount}, Forks: ${repo.forksCount}');
  print('Language: ${repo.language}');
}
```

### Get Repository Details

```dart
final repo = await githubService.getRepo('flutter', 'flutter');

print('Repository: ${repo.fullName}');
print('Description: ${repo.description}');
print('Stars: ${repo.stargazersCount}');
print('Open Issues: ${repo.openIssuesCount}');
print('Default Branch: ${repo.defaultBranch}');
```

### Work with Issues

```dart
// List open issues
final issues = await githubService.getIssues(
  'flutter',
  'flutter',
  state: 'open',
  perPage: 10,
);

// Create a new issue
final newIssue = await githubService.createIssue(
  'myusername',
  'myrepo',
  title: 'Bug: App crashes on startup',
  body: 'Detailed description of the bug...',
  labels: ['bug', 'urgent'],
  assignees: ['developer1'],
);

print('Created issue #${newIssue.number}: ${newIssue.htmlUrl}');

// Close an issue
await githubService.closeIssue('myusername', 'myrepo', 42);
```

### Work with Pull Requests

```dart
// List open pull requests
final prs = await githubService.getPullRequests(
  'flutter',
  'flutter',
  state: 'open',
);

for (final pr in prs) {
  print('PR #${pr.number}: ${pr.title}');
  print('${pr.headRef} -> ${pr.baseRef}');
  print('Draft: ${pr.draft}');
  if (pr.additions != null && pr.deletions != null) {
    print('+${pr.additions} -${pr.deletions}');
  }
}

// Create a pull request
final pr = await githubService.createPullRequest(
  'myusername',
  'myrepo',
  title: 'Add new feature',
  head: 'feature-branch',
  base: 'main',
  body: 'This PR adds...',
  draft: false,
);

print('Created PR #${pr.number}: ${pr.htmlUrl}');
```

### Create a Gist

```dart
final gist = await githubService.createGist(
  files: {
    'example.dart': '''
void main() {
  print('Hello, World!');
}
''',
    'README.md': '# Example Gist\n\nThis is a demo.',
  },
  description: 'Example code snippet',
  public: false,
);

print('Created gist: ${gist.htmlUrl}');
```

### Check Notifications

```dart
final notifications = await githubService.getNotifications(
  all: false, // Only unread
  perPage: 20,
);

for (final notif in notifications) {
  print('${notif.subjectType}: ${notif.subjectTitle}');
  print('Reason: ${notif.reason}');
  print('Repository: ${notif.repository.fullName}');
  print('Unread: ${notif.unread}');
}
```

### Search Repositories

```dart
// Simple search
final repos = await githubService.searchRepos('flutter');

// Advanced search
final mlRepos = await githubService.searchRepos(
  'machine learning language:python stars:>1000',
  perPage: 10,
);

for (final repo in mlRepos) {
  print('${repo.fullName} (${repo.stargazersCount} stars)');
  print(repo.description);
}
```

### Search Issues

```dart
final issues = await githubService.searchIssues(
  'is:open label:bug repo:flutter/flutter',
  perPage: 10,
);

for (final issue in issues) {
  print('Issue #${issue.number}: ${issue.title}');
  print('Labels: ${issue.labels.map((l) => l.name).join(', ')}');
}
```

## Rate Limiting

GitHub API has rate limits (5000 requests/hour for authenticated users). The service automatically tracks rate limits:

```dart
final status = githubService.getRateLimitStatus();
print('Limit: ${status['limit']}');
print('Remaining: ${status['remaining']}');
print('Resets at: ${status['reset_at']}');
```

When rate limit is exceeded, `GitHubRateLimitException` is thrown:

```dart
try {
  final repos = await githubService.getMyRepos();
} on GitHubRateLimitException catch (e) {
  print('Rate limit exceeded!');
  print('Resets at: ${e.resetAt}');
  // Wait until reset or reduce request frequency
}
```

## Error Handling

The service provides specific exceptions for different error scenarios:

```dart
try {
  final user = await githubService.getAuthenticatedUser();
} on GitHubNotAuthenticatedException {
  // User needs to authenticate
  print('Please connect your GitHub account');
} on GitHubRateLimitException catch (e) {
  // Rate limit exceeded
  print('Too many requests. Try again in ${e.resetAt.difference(DateTime.now()).inMinutes} minutes');
} on GitHubApiException catch (e) {
  // Generic API error
  print('GitHub error [${e.statusCode}]: ${e.message}');
} catch (e) {
  // Other errors (network, etc.)
  print('Unexpected error: $e');
}
```

## Available Tools for AI

The following tools are registered for AI use:

### User
- `github.get_profile` - Get user profile

### Repositories
- `github.list_repos` - List user's repositories
- `github.get_repo` - Get repository details

### Issues
- `github.get_issues` - List issues in a repository
- `github.create_issue` - Create a new issue
- `github.close_issue` - Close an issue

### Pull Requests
- `github.get_pull_requests` - List pull requests
- `github.create_pull_request` - Create a new pull request

### Gists
- `github.create_gist` - Create a code snippet gist

### Notifications
- `github.get_notifications` - Get GitHub notifications

### Search
- `github.search_repos` - Search repositories

## Models

All data models are immutable and include:

- **GitHubUser** - User profile information
- **GitHubRepo** - Repository details
- **GitHubIssue** - Issue information
- **GitHubLabel** - Issue/PR labels
- **GitHubPullRequest** - Pull request details
- **GitHubGist** - Code snippet information
- **GitHubGistFile** - File in a gist
- **GitHubNotification** - Notification details

All models support:
- `fromJson()` - Parse from API response
- `toJson()` - Serialize to JSON

## Privacy & Security

- **Privacy Level**: `PrivacyLevel.withConsent`
- All API calls require user authentication
- Tokens are stored securely using `flutter_secure_storage`
- User data is only accessed with explicit permission
- No data is sent to third parties

## API Documentation

For complete GitHub API documentation, see:
- [GitHub REST API v3](https://docs.github.com/en/rest)
- [GitHub Authentication](https://docs.github.com/en/authentication)
- [GitHub Rate Limiting](https://docs.github.com/en/rest/overview/rate-limits-for-the-rest-api)

## Limitations

- Rate limits apply (5000 requests/hour for authenticated users)
- Some operations require specific repository permissions
- OAuth scopes determine what actions are available
- Large file operations not supported (use Git API for that)
- GraphQL API not currently supported (REST API only)
