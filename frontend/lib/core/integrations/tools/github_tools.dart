import '../models/integration.dart';
import '../models/tool_definition.dart';
import '../tool_registry.dart';
import '../../services/oauth/github/github_service.dart';

/// Register all GitHub tools with the tool registry
///
/// This function registers tools for repository management, issues,
/// pull requests, gists, notifications, and search functionality.
void registerGitHubTools(ToolRegistry registry, GitHubService githubService) {
  // === User Profile ===

  registry.registerTool(
    const ToolDefinition(
      name: 'github.get_profile',
      description: 'Get the authenticated user\'s GitHub profile information',
      service: 'github',
      parameters: {},
      returnType: 'GitHubUser',
      requiresAuth: true,
      privacy: PrivacyLevel.withConsent,
      examples: [
        'What is my GitHub username?',
        'Show me my GitHub profile',
        'How many followers do I have on GitHub?',
      ],
    ),
    (_) async {
      final user = await githubService.getAuthenticatedUser();
      return {
        'login': user.login,
        'name': user.name,
        'bio': user.bio,
        'company': user.company,
        'location': user.location,
        'email': user.email,
        'public_repos': user.publicRepos,
        'followers': user.followers,
        'following': user.following,
        'avatar_url': user.avatarUrl,
      };
    },
  );

  // === Repositories ===

  registry.registerTool(
    const ToolDefinition(
      name: 'github.list_repos',
      description:
          'List repositories for the authenticated user. Returns repositories sorted by update time.',
      service: 'github',
      parameters: {
        'sort': ParamDef(
          type: 'string',
          description: 'How to sort repositories',
          enumValues: ['updated', 'created', 'pushed', 'full_name'],
          defaultValue: 'updated',
        ),
        'per_page': ParamDef(
          type: 'number',
          description: 'Number of repositories to return (max 100)',
          defaultValue: 30,
        ),
        'page': ParamDef(
          type: 'number',
          description: 'Page number for pagination',
          defaultValue: 1,
        ),
      },
      returnType: 'List<GitHubRepo>',
      requiresAuth: true,
      privacy: PrivacyLevel.withConsent,
      examples: [
        'Show me my GitHub repositories',
        'List my recently updated repos',
        'What repositories do I have?',
      ],
    ),
    (params) async {
      final sort = params['sort'] as String? ?? 'updated';
      final perPage = params['per_page'] as int? ?? 30;
      final page = params['page'] as int? ?? 1;

      final repos = await githubService.getMyRepos(
        sort: sort,
        perPage: perPage,
        page: page,
      );

      return repos
          .map((r) => {
                'name': r.name,
                'full_name': r.fullName,
                'description': r.description,
                'private': r.private,
                'language': r.language,
                'stars': r.stargazersCount,
                'forks': r.forksCount,
                'open_issues': r.openIssuesCount,
                'url': r.htmlUrl,
                'updated_at': r.updatedAt.toIso8601String(),
              })
          .toList();
    },
  );

  registry.registerTool(
    const ToolDefinition(
      name: 'github.get_repo',
      description: 'Get detailed information about a specific repository',
      service: 'github',
      parameters: {
        'owner': ParamDef(
          type: 'string',
          description: 'Repository owner (username or organization)',
          required: true,
        ),
        'repo': ParamDef(
          type: 'string',
          description: 'Repository name',
          required: true,
        ),
      },
      returnType: 'GitHubRepo',
      requiresAuth: true,
      privacy: PrivacyLevel.withConsent,
      examples: [
        'Show me details about flutter/flutter',
        'Get info on torvalds/linux repository',
      ],
    ),
    (params) async {
      final owner = params['owner'] as String;
      final repo = params['repo'] as String;

      final repository = await githubService.getRepo(owner, repo);

      return {
        'name': repository.name,
        'full_name': repository.fullName,
        'description': repository.description,
        'private': repository.private,
        'language': repository.language,
        'stars': repository.stargazersCount,
        'forks': repository.forksCount,
        'open_issues': repository.openIssuesCount,
        'default_branch': repository.defaultBranch,
        'url': repository.htmlUrl,
        'created_at': repository.createdAt.toIso8601String(),
        'updated_at': repository.updatedAt.toIso8601String(),
      };
    },
  );

  // === Issues ===

  registry.registerTool(
    const ToolDefinition(
      name: 'github.get_issues',
      description: 'Get issues for a repository',
      service: 'github',
      parameters: {
        'owner': ParamDef(
          type: 'string',
          description: 'Repository owner (username or organization)',
          required: true,
        ),
        'repo': ParamDef(
          type: 'string',
          description: 'Repository name',
          required: true,
        ),
        'state': ParamDef(
          type: 'string',
          description: 'Filter by issue state',
          enumValues: ['open', 'closed', 'all'],
          defaultValue: 'open',
        ),
        'per_page': ParamDef(
          type: 'number',
          description: 'Number of issues to return (max 100)',
          defaultValue: 30,
        ),
      },
      returnType: 'List<GitHubIssue>',
      requiresAuth: true,
      privacy: PrivacyLevel.withConsent,
      examples: [
        'Show me open issues in flutter/flutter',
        'List all closed issues in my repo',
      ],
    ),
    (params) async {
      final owner = params['owner'] as String;
      final repo = params['repo'] as String;
      final state = params['state'] as String? ?? 'open';
      final perPage = params['per_page'] as int? ?? 30;

      final issues = await githubService.getIssues(
        owner,
        repo,
        state: state,
        perPage: perPage,
      );

      return issues
          .map((i) => {
                'number': i.number,
                'title': i.title,
                'body': i.body,
                'state': i.state,
                'author': i.user.login,
                'labels': i.labels.map((l) => l.name).toList(),
                'assignees': i.assignees.map((a) => a.login).toList(),
                'comments': i.comments,
                'url': i.htmlUrl,
                'created_at': i.createdAt.toIso8601String(),
                'updated_at': i.updatedAt.toIso8601String(),
              })
          .toList();
    },
  );

  registry.registerTool(
    const ToolDefinition(
      name: 'github.create_issue',
      description: 'Create a new issue in a repository',
      service: 'github',
      parameters: {
        'owner': ParamDef(
          type: 'string',
          description: 'Repository owner (username or organization)',
          required: true,
        ),
        'repo': ParamDef(
          type: 'string',
          description: 'Repository name',
          required: true,
        ),
        'title': ParamDef(
          type: 'string',
          description: 'Issue title',
          required: true,
        ),
        'body': ParamDef(
          type: 'string',
          description: 'Issue description/body',
        ),
        'labels': ParamDef(
          type: 'array',
          description: 'Labels to add to the issue',
          itemType: 'string',
        ),
        'assignees': ParamDef(
          type: 'array',
          description: 'Usernames to assign to the issue',
          itemType: 'string',
        ),
      },
      returnType: 'GitHubIssue',
      requiresAuth: true,
      privacy: PrivacyLevel.withConsent,
      examples: [
        'Create an issue titled "Bug in login" in my repo',
        'File a bug report about the navbar',
      ],
    ),
    (params) async {
      final owner = params['owner'] as String;
      final repo = params['repo'] as String;
      final title = params['title'] as String;
      final body = params['body'] as String?;
      final labels = (params['labels'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList();
      final assignees = (params['assignees'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList();

      final issue = await githubService.createIssue(
        owner,
        repo,
        title: title,
        body: body,
        labels: labels,
        assignees: assignees,
      );

      return {
        'number': issue.number,
        'title': issue.title,
        'state': issue.state,
        'url': issue.htmlUrl,
        'created_at': issue.createdAt.toIso8601String(),
      };
    },
  );

  registry.registerTool(
    const ToolDefinition(
      name: 'github.close_issue',
      description: 'Close an issue in a repository',
      service: 'github',
      parameters: {
        'owner': ParamDef(
          type: 'string',
          description: 'Repository owner (username or organization)',
          required: true,
        ),
        'repo': ParamDef(
          type: 'string',
          description: 'Repository name',
          required: true,
        ),
        'issue_number': ParamDef(
          type: 'number',
          description: 'Issue number to close',
          required: true,
        ),
      },
      returnType: 'void',
      requiresAuth: true,
      privacy: PrivacyLevel.withConsent,
      examples: [
        'Close issue #42 in my repo',
        'Mark issue 15 as closed',
      ],
    ),
    (params) async {
      final owner = params['owner'] as String;
      final repo = params['repo'] as String;
      final issueNumber = params['issue_number'] as int;

      await githubService.closeIssue(owner, repo, issueNumber);

      return {'success': true};
    },
  );

  // === Pull Requests ===

  registry.registerTool(
    const ToolDefinition(
      name: 'github.get_pull_requests',
      description: 'Get pull requests for a repository',
      service: 'github',
      parameters: {
        'owner': ParamDef(
          type: 'string',
          description: 'Repository owner (username or organization)',
          required: true,
        ),
        'repo': ParamDef(
          type: 'string',
          description: 'Repository name',
          required: true,
        ),
        'state': ParamDef(
          type: 'string',
          description: 'Filter by PR state',
          enumValues: ['open', 'closed', 'all'],
          defaultValue: 'open',
        ),
        'per_page': ParamDef(
          type: 'number',
          description: 'Number of PRs to return (max 100)',
          defaultValue: 30,
        ),
      },
      returnType: 'List<GitHubPullRequest>',
      requiresAuth: true,
      privacy: PrivacyLevel.withConsent,
      examples: [
        'Show me open pull requests in flutter/flutter',
        'List all PRs in my repo',
      ],
    ),
    (params) async {
      final owner = params['owner'] as String;
      final repo = params['repo'] as String;
      final state = params['state'] as String? ?? 'open';
      final perPage = params['per_page'] as int? ?? 30;

      final prs = await githubService.getPullRequests(
        owner,
        repo,
        state: state,
        perPage: perPage,
      );

      return prs
          .map((pr) => {
                'number': pr.number,
                'title': pr.title,
                'body': pr.body,
                'state': pr.state,
                'author': pr.user.login,
                'head': pr.headRef,
                'base': pr.baseRef,
                'draft': pr.draft,
                'mergeable': pr.mergeable,
                'additions': pr.additions,
                'deletions': pr.deletions,
                'changed_files': pr.changedFiles,
                'url': pr.htmlUrl,
                'created_at': pr.createdAt.toIso8601String(),
                'updated_at': pr.updatedAt.toIso8601String(),
                if (pr.mergedAt != null)
                  'merged_at': pr.mergedAt!.toIso8601String(),
              })
          .toList();
    },
  );

  registry.registerTool(
    const ToolDefinition(
      name: 'github.create_pull_request',
      description: 'Create a new pull request in a repository',
      service: 'github',
      parameters: {
        'owner': ParamDef(
          type: 'string',
          description: 'Repository owner (username or organization)',
          required: true,
        ),
        'repo': ParamDef(
          type: 'string',
          description: 'Repository name',
          required: true,
        ),
        'title': ParamDef(
          type: 'string',
          description: 'Pull request title',
          required: true,
        ),
        'head': ParamDef(
          type: 'string',
          description: 'Source branch (e.g., "feature-branch")',
          required: true,
        ),
        'base': ParamDef(
          type: 'string',
          description: 'Target branch (e.g., "main" or "master")',
          required: true,
        ),
        'body': ParamDef(
          type: 'string',
          description: 'Pull request description/body',
        ),
        'draft': ParamDef(
          type: 'boolean',
          description: 'Create as a draft pull request',
          defaultValue: false,
        ),
      },
      returnType: 'GitHubPullRequest',
      requiresAuth: true,
      privacy: PrivacyLevel.withConsent,
      examples: [
        'Create a PR from feature-branch to main',
        'Open a pull request for my changes',
      ],
    ),
    (params) async {
      final owner = params['owner'] as String;
      final repo = params['repo'] as String;
      final title = params['title'] as String;
      final head = params['head'] as String;
      final base = params['base'] as String;
      final body = params['body'] as String?;
      final draft = params['draft'] as bool? ?? false;

      final pr = await githubService.createPullRequest(
        owner,
        repo,
        title: title,
        head: head,
        base: base,
        body: body,
        draft: draft,
      );

      return {
        'number': pr.number,
        'title': pr.title,
        'state': pr.state,
        'url': pr.htmlUrl,
        'created_at': pr.createdAt.toIso8601String(),
      };
    },
  );

  // === Gists ===

  registry.registerTool(
    const ToolDefinition(
      name: 'github.create_gist',
      description:
          'Create a gist from code snippets. Useful for sharing code or saving snippets.',
      service: 'github',
      parameters: {
        'files': ParamDef(
          type: 'object',
          description:
              'Map of filename to content (e.g., {"example.js": "console.log(\'hello\')"})',
          required: true,
        ),
        'description': ParamDef(
          type: 'string',
          description: 'Gist description',
        ),
        'public': ParamDef(
          type: 'boolean',
          description: 'Whether the gist should be public',
          defaultValue: false,
        ),
      },
      returnType: 'GitHubGist',
      requiresAuth: true,
      privacy: PrivacyLevel.withConsent,
      examples: [
        'Create a gist with my code snippet',
        'Save this code as a private gist',
      ],
    ),
    (params) async {
      final files = (params['files'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, value.toString()));
      final description = params['description'] as String?;
      final public = params['public'] as bool? ?? false;

      final gist = await githubService.createGist(
        files: files,
        description: description,
        public: public,
      );

      return {
        'id': gist.id,
        'description': gist.description,
        'public': gist.public,
        'url': gist.htmlUrl,
        'files': gist.files.keys.toList(),
        'created_at': gist.createdAt.toIso8601String(),
      };
    },
  );

  // === Notifications ===

  registry.registerTool(
    const ToolDefinition(
      name: 'github.get_notifications',
      description:
          'Get GitHub notifications for the authenticated user (mentions, issues, PRs, etc.)',
      service: 'github',
      parameters: {
        'all': ParamDef(
          type: 'boolean',
          description: 'Include read notifications',
          defaultValue: false,
        ),
        'per_page': ParamDef(
          type: 'number',
          description: 'Number of notifications to return (max 100)',
          defaultValue: 30,
        ),
      },
      returnType: 'List<GitHubNotification>',
      requiresAuth: true,
      privacy: PrivacyLevel.withConsent,
      examples: [
        'Show me my GitHub notifications',
        'What notifications do I have?',
        'Any new mentions on GitHub?',
      ],
    ),
    (params) async {
      final all = params['all'] as bool? ?? false;
      final perPage = params['per_page'] as int? ?? 30;

      final notifications = await githubService.getNotifications(
        all: all,
        perPage: perPage,
      );

      return notifications
          .map((n) => {
                'id': n.id,
                'reason': n.reason,
                'unread': n.unread,
                'subject_title': n.subjectTitle,
                'subject_type': n.subjectType,
                'repository': n.repository.fullName,
                'updated_at': n.updatedAt.toIso8601String(),
              })
          .toList();
    },
  );

  // === Search ===

  registry.registerTool(
    const ToolDefinition(
      name: 'github.search_repos',
      description:
          'Search for repositories on GitHub. Supports advanced search syntax.',
      service: 'github',
      parameters: {
        'query': ParamDef(
          type: 'string',
          description:
              'Search query (e.g., "flutter language:dart", "machine learning stars:>1000")',
          required: true,
        ),
        'per_page': ParamDef(
          type: 'number',
          description: 'Number of results to return (max 100)',
          defaultValue: 10,
        ),
      },
      returnType: 'List<GitHubRepo>',
      requiresAuth: true,
      privacy: PrivacyLevel.lowRisk,
      examples: [
        'Search for Flutter repositories',
        'Find popular machine learning projects',
        'Search for repos with "todo" in the name',
      ],
    ),
    (params) async {
      final query = params['query'] as String;
      final perPage = params['per_page'] as int? ?? 10;

      final repos = await githubService.searchRepos(query, perPage: perPage);

      return repos
          .map((r) => {
                'name': r.name,
                'full_name': r.fullName,
                'description': r.description,
                'language': r.language,
                'stars': r.stargazersCount,
                'forks': r.forksCount,
                'url': r.htmlUrl,
              })
          .toList();
    },
  );
}
