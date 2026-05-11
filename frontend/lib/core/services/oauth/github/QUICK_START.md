# GitHub Integration - Quick Start Guide

## Setup (One-Time)

### 1. Register GitHub Tools
Add this to your app initialization (typically in `main.dart` or an initialization service):

```dart
import 'package:jarvis/core/integrations/tools/github_tools.dart';
import 'package:jarvis/core/integrations/tool_registry.dart';
import 'package:jarvis/core/services/oauth/github/github_service.dart';

void initializeApp(WidgetRef ref) {
  final toolRegistry = ref.read(toolRegistryProvider);
  final githubService = ref.read(githubServiceProvider);

  // Register GitHub tools for AI use
  registerGitHubTools(toolRegistry, githubService);
}
```

### 2. Configure OAuth (TODO - Not Yet Implemented)
When implementing OAuth, you'll need:
- GitHub OAuth App credentials
- Scopes: `repo user gist notifications`
- Redirect URI configuration

## Usage

### Connect GitHub Account

```dart
final integrationManager = ref.read(integrationManagerProvider);
await integrationManager.connect('github');
```

### Access GitHub Service

```dart
final githubService = ref.read(githubServiceProvider);
```

## Common Operations

### Get User Profile
```dart
final user = await githubService.getAuthenticatedUser();
// user.login, user.name, user.publicRepos, etc.
```

### List Repositories
```dart
final repos = await githubService.getMyRepos(sort: 'updated');
// repos[0].fullName, repos[0].stargazersCount, etc.
```

### Create Issue
```dart
final issue = await githubService.createIssue(
  'owner',
  'repo',
  title: 'Bug report',
  body: 'Description...',
  labels: ['bug'],
);
```

### Search Repositories
```dart
final results = await githubService.searchRepos('flutter language:dart');
```

## AI Tools Available

Once registered, the AI can use these tools:

1. `github.get_profile` - User profile
2. `github.list_repos` - List repositories
3. `github.get_repo` - Repository details
4. `github.get_issues` - List issues
5. `github.create_issue` - Create issue
6. `github.close_issue` - Close issue
7. `github.get_pull_requests` - List PRs
8. `github.create_pull_request` - Create PR
9. `github.create_gist` - Create gist
10. `github.get_notifications` - Check notifications
11. `github.search_repos` - Search repositories

## Error Handling

```dart
try {
  final user = await githubService.getAuthenticatedUser();
} on GitHubNotAuthenticatedException {
  // User needs to connect GitHub
} on GitHubRateLimitException catch (e) {
  // Rate limit exceeded, wait until e.resetAt
} on GitHubApiException catch (e) {
  // API error: e.statusCode, e.message
}
```

## Rate Limits

Check current status:
```dart
final status = githubService.getRateLimitStatus();
// status['remaining'], status['reset_at']
```

Limits:
- Authenticated: 5000 requests/hour
- Unauthenticated: 60 requests/hour

## Key Files

- **Service:** `/lib/core/services/oauth/github/github_service.dart`
- **Models:** `/lib/core/services/oauth/github/github_models.dart`
- **Tools:** `/lib/core/integrations/tools/github_tools.dart`
- **Examples:** `/lib/core/services/oauth/github/example.dart`
- **Full Docs:** `/lib/core/services/oauth/github/README.md`

## Next Steps

1. ✅ Service implementation complete
2. ⏳ Implement OAuth flow in IntegrationManager
3. ⏳ Add UI for GitHub connection
4. ⏳ Test with real GitHub account
5. ⏳ Add analytics tracking

## Support

- Full documentation: See `README.md`
- Examples: See `example.dart`
- Implementation details: See `IMPLEMENTATION.md`
- GitHub API docs: https://docs.github.com/en/rest
