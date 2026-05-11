/// GitHub data models for API responses
///
/// This file contains immutable data models for various GitHub entities
/// including users, repositories, issues, pull requests, gists, and notifications.
library;

/// GitHub user information
class GitHubUser {
  final int id;
  final String login; // username
  final String? name;
  final String avatarUrl;
  final String? bio;
  final String? company;
  final String? location;
  final String? email;
  final int publicRepos;
  final int followers;
  final int following;

  const GitHubUser({
    required this.id,
    required this.login,
    this.name,
    required this.avatarUrl,
    this.bio,
    this.company,
    this.location,
    this.email,
    required this.publicRepos,
    required this.followers,
    required this.following,
  });

  factory GitHubUser.fromJson(Map<String, dynamic> json) {
    return GitHubUser(
      id: json['id'] as int,
      login: json['login'] as String,
      name: json['name'] as String?,
      avatarUrl: json['avatar_url'] as String,
      bio: json['bio'] as String?,
      company: json['company'] as String?,
      location: json['location'] as String?,
      email: json['email'] as String?,
      publicRepos: json['public_repos'] as int? ?? 0,
      followers: json['followers'] as int? ?? 0,
      following: json['following'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'login': login,
      if (name != null) 'name': name,
      'avatar_url': avatarUrl,
      if (bio != null) 'bio': bio,
      if (company != null) 'company': company,
      if (location != null) 'location': location,
      if (email != null) 'email': email,
      'public_repos': publicRepos,
      'followers': followers,
      'following': following,
    };
  }
}

/// GitHub repository information
class GitHubRepo {
  final int id;
  final String name;
  final String fullName; // owner/name
  final String? description;
  final bool private;
  final String htmlUrl;
  final String? language;
  final int stargazersCount;
  final int forksCount;
  final int openIssuesCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? pushedAt;
  final String defaultBranch;

  const GitHubRepo({
    required this.id,
    required this.name,
    required this.fullName,
    this.description,
    required this.private,
    required this.htmlUrl,
    this.language,
    required this.stargazersCount,
    required this.forksCount,
    required this.openIssuesCount,
    required this.createdAt,
    required this.updatedAt,
    this.pushedAt,
    required this.defaultBranch,
  });

  factory GitHubRepo.fromJson(Map<String, dynamic> json) {
    return GitHubRepo(
      id: json['id'] as int,
      name: json['name'] as String,
      fullName: json['full_name'] as String,
      description: json['description'] as String?,
      private: json['private'] as bool? ?? false,
      htmlUrl: json['html_url'] as String,
      language: json['language'] as String?,
      stargazersCount: json['stargazers_count'] as int? ?? 0,
      forksCount: json['forks_count'] as int? ?? 0,
      openIssuesCount: json['open_issues_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      pushedAt: json['pushed_at'] != null
          ? DateTime.parse(json['pushed_at'] as String)
          : null,
      defaultBranch: json['default_branch'] as String? ?? 'main',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'full_name': fullName,
      if (description != null) 'description': description,
      'private': private,
      'html_url': htmlUrl,
      if (language != null) 'language': language,
      'stargazers_count': stargazersCount,
      'forks_count': forksCount,
      'open_issues_count': openIssuesCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (pushedAt != null) 'pushed_at': pushedAt!.toIso8601String(),
      'default_branch': defaultBranch,
    };
  }
}

/// GitHub label for issues and pull requests
class GitHubLabel {
  final int id;
  final String name;
  final String color;
  final String? description;

  const GitHubLabel({
    required this.id,
    required this.name,
    required this.color,
    this.description,
  });

  factory GitHubLabel.fromJson(Map<String, dynamic> json) {
    return GitHubLabel(
      id: json['id'] as int,
      name: json['name'] as String,
      color: json['color'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      if (description != null) 'description': description,
    };
  }
}

/// GitHub issue information
class GitHubIssue {
  final int id;
  final int number;
  final String title;
  final String? body;
  final String state; // open, closed
  final GitHubUser user;
  final List<GitHubLabel> labels;
  final GitHubUser? assignee;
  final List<GitHubUser> assignees;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? closedAt;
  final int comments;
  final String htmlUrl;

  const GitHubIssue({
    required this.id,
    required this.number,
    required this.title,
    this.body,
    required this.state,
    required this.user,
    required this.labels,
    this.assignee,
    required this.assignees,
    required this.createdAt,
    required this.updatedAt,
    this.closedAt,
    required this.comments,
    required this.htmlUrl,
  });

  factory GitHubIssue.fromJson(Map<String, dynamic> json) {
    return GitHubIssue(
      id: json['id'] as int,
      number: json['number'] as int,
      title: json['title'] as String,
      body: json['body'] as String?,
      state: json['state'] as String,
      user: GitHubUser.fromJson(json['user'] as Map<String, dynamic>),
      labels: (json['labels'] as List<dynamic>?)
              ?.map((l) => GitHubLabel.fromJson(l as Map<String, dynamic>))
              .toList() ??
          [],
      assignee: json['assignee'] != null
          ? GitHubUser.fromJson(json['assignee'] as Map<String, dynamic>)
          : null,
      assignees: (json['assignees'] as List<dynamic>?)
              ?.map((a) => GitHubUser.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      closedAt: json['closed_at'] != null
          ? DateTime.parse(json['closed_at'] as String)
          : null,
      comments: json['comments'] as int? ?? 0,
      htmlUrl: json['html_url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'title': title,
      if (body != null) 'body': body,
      'state': state,
      'user': user.toJson(),
      'labels': labels.map((l) => l.toJson()).toList(),
      if (assignee != null) 'assignee': assignee!.toJson(),
      'assignees': assignees.map((a) => a.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (closedAt != null) 'closed_at': closedAt!.toIso8601String(),
      'comments': comments,
      'html_url': htmlUrl,
    };
  }
}

/// GitHub pull request information
class GitHubPullRequest {
  final int id;
  final int number;
  final String title;
  final String? body;
  final String state; // open, closed, merged
  final GitHubUser user;
  final String headRef; // source branch
  final String baseRef; // target branch
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? mergedAt;
  final DateTime? closedAt;
  final bool draft;
  final bool? mergeable;
  final int? additions;
  final int? deletions;
  final int? changedFiles;
  final String htmlUrl;

  const GitHubPullRequest({
    required this.id,
    required this.number,
    required this.title,
    this.body,
    required this.state,
    required this.user,
    required this.headRef,
    required this.baseRef,
    required this.createdAt,
    required this.updatedAt,
    this.mergedAt,
    this.closedAt,
    required this.draft,
    this.mergeable,
    this.additions,
    this.deletions,
    this.changedFiles,
    required this.htmlUrl,
  });

  factory GitHubPullRequest.fromJson(Map<String, dynamic> json) {
    return GitHubPullRequest(
      id: json['id'] as int,
      number: json['number'] as int,
      title: json['title'] as String,
      body: json['body'] as String?,
      state: json['state'] as String,
      user: GitHubUser.fromJson(json['user'] as Map<String, dynamic>),
      headRef: (json['head'] as Map<String, dynamic>)['ref'] as String,
      baseRef: (json['base'] as Map<String, dynamic>)['ref'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      mergedAt: json['merged_at'] != null
          ? DateTime.parse(json['merged_at'] as String)
          : null,
      closedAt: json['closed_at'] != null
          ? DateTime.parse(json['closed_at'] as String)
          : null,
      draft: json['draft'] as bool? ?? false,
      mergeable: json['mergeable'] as bool?,
      additions: json['additions'] as int?,
      deletions: json['deletions'] as int?,
      changedFiles: json['changed_files'] as int?,
      htmlUrl: json['html_url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'title': title,
      if (body != null) 'body': body,
      'state': state,
      'user': user.toJson(),
      'head': {'ref': headRef},
      'base': {'ref': baseRef},
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (mergedAt != null) 'merged_at': mergedAt!.toIso8601String(),
      if (closedAt != null) 'closed_at': closedAt!.toIso8601String(),
      'draft': draft,
      if (mergeable != null) 'mergeable': mergeable,
      if (additions != null) 'additions': additions,
      if (deletions != null) 'deletions': deletions,
      if (changedFiles != null) 'changed_files': changedFiles,
      'html_url': htmlUrl,
    };
  }
}

/// GitHub gist file information
class GitHubGistFile {
  final String filename;
  final String? language;
  final String? content;
  final int size;

  const GitHubGistFile({
    required this.filename,
    this.language,
    this.content,
    required this.size,
  });

  factory GitHubGistFile.fromJson(Map<String, dynamic> json) {
    return GitHubGistFile(
      filename: json['filename'] as String,
      language: json['language'] as String?,
      content: json['content'] as String?,
      size: json['size'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'filename': filename,
      if (language != null) 'language': language,
      if (content != null) 'content': content,
      'size': size,
    };
  }
}

/// GitHub gist information
class GitHubGist {
  final String id;
  final String? description;
  final bool public;
  final Map<String, GitHubGistFile> files;
  final String htmlUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const GitHubGist({
    required this.id,
    this.description,
    required this.public,
    required this.files,
    required this.htmlUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GitHubGist.fromJson(Map<String, dynamic> json) {
    final filesJson = json['files'] as Map<String, dynamic>;
    final files = filesJson.map(
      (key, value) => MapEntry(
        key,
        GitHubGistFile.fromJson(value as Map<String, dynamic>),
      ),
    );

    return GitHubGist(
      id: json['id'] as String,
      description: json['description'] as String?,
      public: json['public'] as bool,
      files: files,
      htmlUrl: json['html_url'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (description != null) 'description': description,
      'public': public,
      'files': files.map((key, value) => MapEntry(key, value.toJson())),
      'html_url': htmlUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// GitHub notification information
class GitHubNotification {
  final String id;
  final String reason;
  final bool unread;
  final String? subjectTitle;
  final String? subjectType; // Issue, PullRequest, etc.
  final String? subjectUrl;
  final GitHubRepo repository;
  final DateTime updatedAt;

  const GitHubNotification({
    required this.id,
    required this.reason,
    required this.unread,
    this.subjectTitle,
    this.subjectType,
    this.subjectUrl,
    required this.repository,
    required this.updatedAt,
  });

  factory GitHubNotification.fromJson(Map<String, dynamic> json) {
    final subject = json['subject'] as Map<String, dynamic>;

    return GitHubNotification(
      id: json['id'] as String,
      reason: json['reason'] as String,
      unread: json['unread'] as bool,
      subjectTitle: subject['title'] as String?,
      subjectType: subject['type'] as String?,
      subjectUrl: subject['url'] as String?,
      repository:
          GitHubRepo.fromJson(json['repository'] as Map<String, dynamic>),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reason': reason,
      'unread': unread,
      'subject': {
        if (subjectTitle != null) 'title': subjectTitle,
        if (subjectType != null) 'type': subjectType,
        if (subjectUrl != null) 'url': subjectUrl,
      },
      'repository': repository.toJson(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
