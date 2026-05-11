enum AiProvider {
  groq('groq', 'Groq', 'Groq (Free)'),
  gemini('gemini', 'Gemini', 'Google (Free)'),
  anthropic('anthropic', 'Claude', 'Anthropic'),
  openai('openai', 'GPT', 'OpenAI');

  final String value;
  final String displayName;
  final String company;

  const AiProvider(this.value, this.displayName, this.company);

  static AiProvider fromString(String? value) {
    // Handle legacy 'llama' value -> map to groq
    if (value == 'llama') return AiProvider.groq;
    return AiProvider.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AiProvider.groq,
    );
  }
}

enum ResponseLength {
  short('short', 'Short'),
  medium('medium', 'Medium'),
  long('long', 'Long');

  final String value;
  final String displayName;

  const ResponseLength(this.value, this.displayName);

  static ResponseLength fromString(String? value) {
    return ResponseLength.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ResponseLength.medium,
    );
  }
}

class ProfileModel {
  final String? id;
  final String? userId;
  final String? city;
  final String? budgetLevel;
  final List<String> vibes;
  final AiProvider preferredAiProvider;
  final double creativity; // 0.0 = Low, 0.5 = Med, 1.0 = High
  final ResponseLength responseLength;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProfileModel({
    this.id,
    this.userId,
    this.city,
    this.budgetLevel,
    this.vibes = const [],
    this.preferredAiProvider = AiProvider.groq,
    this.creativity = 0.5,
    this.responseLength = ResponseLength.medium,
    this.createdAt,
    this.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final profileJson = json['profile_json'] as Map<String, dynamic>? ?? {};

    return ProfileModel(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      city: profileJson['city'] as String?,
      budgetLevel: profileJson['budget_level'] as String?,
      vibes: (profileJson['vibes'] as List<dynamic>?)?.cast<String>() ?? [],
      preferredAiProvider: AiProvider.fromString(
        json['preferred_ai_provider'] as String?,
      ),
      creativity: (json['creativity'] as num?)?.toDouble() ?? 0.5,
      responseLength: ResponseLength.fromString(
        json['response_length'] as String?,
      ),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profile_json': {
        'city': city,
        'budget_level': budgetLevel,
        'vibes': vibes,
      },
    };
  }

  ProfileModel copyWith({
    String? id,
    String? userId,
    String? city,
    String? budgetLevel,
    List<String>? vibes,
    AiProvider? preferredAiProvider,
    double? creativity,
    ResponseLength? responseLength,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      city: city ?? this.city,
      budgetLevel: budgetLevel ?? this.budgetLevel,
      vibes: vibes ?? this.vibes,
      preferredAiProvider: preferredAiProvider ?? this.preferredAiProvider,
      creativity: creativity ?? this.creativity,
      responseLength: responseLength ?? this.responseLength,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
