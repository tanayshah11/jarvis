// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, email, name, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<User> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  /// UUID from server
  final String id;

  /// User's email address
  final String email;

  /// Display name
  final String? name;

  /// When the user was created
  final DateTime createdAt;

  /// When the user was last updated
  final DateTime updatedAt;
  const User({
    required this.id,
    required this.email,
    this.name,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['email'] = Variable<String>(email);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      email: Value(email),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory User.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<String>(json['id']),
      email: serializer.fromJson<String>(json['email']),
      name: serializer.fromJson<String?>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'email': serializer.toJson<String>(email),
      'name': serializer.toJson<String?>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  User copyWith({
    String? id,
    String? email,
    Value<String?> name = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => User(
    id: id ?? this.id,
    email: email ?? this.email,
    name: name.present ? name.value : this.name,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      email: data.email.present ? data.email.value : this.email,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, email, name, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.email == this.email &&
          other.name == this.name &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<String> id;
  final Value<String> email;
  final Value<String?> name;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.email = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    required String email,
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       email = Value(email);
  static Insertable<User> custom({
    Expression<String>? id,
    Expression<String>? email,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (email != null) 'email': email,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith({
    Value<String>? id,
    Value<String>? email,
    Value<String?>? name,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProfilesTable extends Profiles with TableInfo<$ProfilesTable, Profile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _preferredAiProviderMeta =
      const VerificationMeta('preferredAiProvider');
  @override
  late final GeneratedColumn<String> preferredAiProvider =
      GeneratedColumn<String>(
        'preferred_ai_provider',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('groq'),
      );
  static const VerificationMeta _preferredModelMeta = const VerificationMeta(
    'preferredModel',
  );
  @override
  late final GeneratedColumn<String> preferredModel = GeneratedColumn<String>(
    'preferred_model',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timezoneMeta = const VerificationMeta(
    'timezone',
  );
  @override
  late final GeneratedColumn<String> timezone = GeneratedColumn<String>(
    'timezone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('UTC'),
  );
  static const VerificationMeta _personalityTraitsMeta = const VerificationMeta(
    'personalityTraits',
  );
  @override
  late final GeneratedColumn<String> personalityTraits =
      GeneratedColumn<String>(
        'personality_traits',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _preferencesMeta = const VerificationMeta(
    'preferences',
  );
  @override
  late final GeneratedColumn<String> preferences = GeneratedColumn<String>(
    'preferences',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    displayName,
    preferredAiProvider,
    preferredModel,
    timezone,
    personalityTraits,
    preferences,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Profile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    }
    if (data.containsKey('preferred_ai_provider')) {
      context.handle(
        _preferredAiProviderMeta,
        preferredAiProvider.isAcceptableOrUnknown(
          data['preferred_ai_provider']!,
          _preferredAiProviderMeta,
        ),
      );
    }
    if (data.containsKey('preferred_model')) {
      context.handle(
        _preferredModelMeta,
        preferredModel.isAcceptableOrUnknown(
          data['preferred_model']!,
          _preferredModelMeta,
        ),
      );
    }
    if (data.containsKey('timezone')) {
      context.handle(
        _timezoneMeta,
        timezone.isAcceptableOrUnknown(data['timezone']!, _timezoneMeta),
      );
    }
    if (data.containsKey('personality_traits')) {
      context.handle(
        _personalityTraitsMeta,
        personalityTraits.isAcceptableOrUnknown(
          data['personality_traits']!,
          _personalityTraitsMeta,
        ),
      );
    }
    if (data.containsKey('preferences')) {
      context.handle(
        _preferencesMeta,
        preferences.isAcceptableOrUnknown(
          data['preferences']!,
          _preferencesMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Profile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Profile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      ),
      preferredAiProvider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preferred_ai_provider'],
      )!,
      preferredModel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preferred_model'],
      ),
      timezone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timezone'],
      )!,
      personalityTraits: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}personality_traits'],
      ),
      preferences: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preferences'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }
}

class Profile extends DataClass implements Insertable<Profile> {
  /// UUID
  final String id;

  /// Foreign key to users table
  final String userId;

  /// User's display name
  final String? displayName;

  /// AI provider preference (groq, anthropic, openai)
  final String preferredAiProvider;

  /// AI model preference
  final String? preferredModel;

  /// User's timezone
  final String timezone;

  /// Personality traits as JSON
  final String? personalityTraits;

  /// User preferences as JSON
  final String? preferences;

  /// When the profile was created
  final DateTime createdAt;

  /// When the profile was last updated
  final DateTime updatedAt;
  const Profile({
    required this.id,
    required this.userId,
    this.displayName,
    required this.preferredAiProvider,
    this.preferredModel,
    required this.timezone,
    this.personalityTraits,
    this.preferences,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || displayName != null) {
      map['display_name'] = Variable<String>(displayName);
    }
    map['preferred_ai_provider'] = Variable<String>(preferredAiProvider);
    if (!nullToAbsent || preferredModel != null) {
      map['preferred_model'] = Variable<String>(preferredModel);
    }
    map['timezone'] = Variable<String>(timezone);
    if (!nullToAbsent || personalityTraits != null) {
      map['personality_traits'] = Variable<String>(personalityTraits);
    }
    if (!nullToAbsent || preferences != null) {
      map['preferences'] = Variable<String>(preferences);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      id: Value(id),
      userId: Value(userId),
      displayName: displayName == null && nullToAbsent
          ? const Value.absent()
          : Value(displayName),
      preferredAiProvider: Value(preferredAiProvider),
      preferredModel: preferredModel == null && nullToAbsent
          ? const Value.absent()
          : Value(preferredModel),
      timezone: Value(timezone),
      personalityTraits: personalityTraits == null && nullToAbsent
          ? const Value.absent()
          : Value(personalityTraits),
      preferences: preferences == null && nullToAbsent
          ? const Value.absent()
          : Value(preferences),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Profile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Profile(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      displayName: serializer.fromJson<String?>(json['displayName']),
      preferredAiProvider: serializer.fromJson<String>(
        json['preferredAiProvider'],
      ),
      preferredModel: serializer.fromJson<String?>(json['preferredModel']),
      timezone: serializer.fromJson<String>(json['timezone']),
      personalityTraits: serializer.fromJson<String?>(
        json['personalityTraits'],
      ),
      preferences: serializer.fromJson<String?>(json['preferences']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'displayName': serializer.toJson<String?>(displayName),
      'preferredAiProvider': serializer.toJson<String>(preferredAiProvider),
      'preferredModel': serializer.toJson<String?>(preferredModel),
      'timezone': serializer.toJson<String>(timezone),
      'personalityTraits': serializer.toJson<String?>(personalityTraits),
      'preferences': serializer.toJson<String?>(preferences),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Profile copyWith({
    String? id,
    String? userId,
    Value<String?> displayName = const Value.absent(),
    String? preferredAiProvider,
    Value<String?> preferredModel = const Value.absent(),
    String? timezone,
    Value<String?> personalityTraits = const Value.absent(),
    Value<String?> preferences = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Profile(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    displayName: displayName.present ? displayName.value : this.displayName,
    preferredAiProvider: preferredAiProvider ?? this.preferredAiProvider,
    preferredModel: preferredModel.present
        ? preferredModel.value
        : this.preferredModel,
    timezone: timezone ?? this.timezone,
    personalityTraits: personalityTraits.present
        ? personalityTraits.value
        : this.personalityTraits,
    preferences: preferences.present ? preferences.value : this.preferences,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Profile copyWithCompanion(ProfilesCompanion data) {
    return Profile(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      preferredAiProvider: data.preferredAiProvider.present
          ? data.preferredAiProvider.value
          : this.preferredAiProvider,
      preferredModel: data.preferredModel.present
          ? data.preferredModel.value
          : this.preferredModel,
      timezone: data.timezone.present ? data.timezone.value : this.timezone,
      personalityTraits: data.personalityTraits.present
          ? data.personalityTraits.value
          : this.personalityTraits,
      preferences: data.preferences.present
          ? data.preferences.value
          : this.preferences,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Profile(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('displayName: $displayName, ')
          ..write('preferredAiProvider: $preferredAiProvider, ')
          ..write('preferredModel: $preferredModel, ')
          ..write('timezone: $timezone, ')
          ..write('personalityTraits: $personalityTraits, ')
          ..write('preferences: $preferences, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    displayName,
    preferredAiProvider,
    preferredModel,
    timezone,
    personalityTraits,
    preferences,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Profile &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.displayName == this.displayName &&
          other.preferredAiProvider == this.preferredAiProvider &&
          other.preferredModel == this.preferredModel &&
          other.timezone == this.timezone &&
          other.personalityTraits == this.personalityTraits &&
          other.preferences == this.preferences &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ProfilesCompanion extends UpdateCompanion<Profile> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String?> displayName;
  final Value<String> preferredAiProvider;
  final Value<String?> preferredModel;
  final Value<String> timezone;
  final Value<String?> personalityTraits;
  final Value<String?> preferences;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ProfilesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.preferredAiProvider = const Value.absent(),
    this.preferredModel = const Value.absent(),
    this.timezone = const Value.absent(),
    this.personalityTraits = const Value.absent(),
    this.preferences = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfilesCompanion.insert({
    required String id,
    required String userId,
    this.displayName = const Value.absent(),
    this.preferredAiProvider = const Value.absent(),
    this.preferredModel = const Value.absent(),
    this.timezone = const Value.absent(),
    this.personalityTraits = const Value.absent(),
    this.preferences = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId);
  static Insertable<Profile> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? displayName,
    Expression<String>? preferredAiProvider,
    Expression<String>? preferredModel,
    Expression<String>? timezone,
    Expression<String>? personalityTraits,
    Expression<String>? preferences,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (displayName != null) 'display_name': displayName,
      if (preferredAiProvider != null)
        'preferred_ai_provider': preferredAiProvider,
      if (preferredModel != null) 'preferred_model': preferredModel,
      if (timezone != null) 'timezone': timezone,
      if (personalityTraits != null) 'personality_traits': personalityTraits,
      if (preferences != null) 'preferences': preferences,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfilesCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String?>? displayName,
    Value<String>? preferredAiProvider,
    Value<String?>? preferredModel,
    Value<String>? timezone,
    Value<String?>? personalityTraits,
    Value<String?>? preferences,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ProfilesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      preferredAiProvider: preferredAiProvider ?? this.preferredAiProvider,
      preferredModel: preferredModel ?? this.preferredModel,
      timezone: timezone ?? this.timezone,
      personalityTraits: personalityTraits ?? this.personalityTraits,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (preferredAiProvider.present) {
      map['preferred_ai_provider'] = Variable<String>(
        preferredAiProvider.value,
      );
    }
    if (preferredModel.present) {
      map['preferred_model'] = Variable<String>(preferredModel.value);
    }
    if (timezone.present) {
      map['timezone'] = Variable<String>(timezone.value);
    }
    if (personalityTraits.present) {
      map['personality_traits'] = Variable<String>(personalityTraits.value);
    }
    if (preferences.present) {
      map['preferences'] = Variable<String>(preferences.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('displayName: $displayName, ')
          ..write('preferredAiProvider: $preferredAiProvider, ')
          ..write('preferredModel: $preferredModel, ')
          ..write('timezone: $timezone, ')
          ..write('personalityTraits: $personalityTraits, ')
          ..write('preferences: $preferences, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ConversationsTable extends Conversations
    with TableInfo<$ConversationsTable, Conversation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConversationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _metadataMeta = const VerificationMeta(
    'metadata',
  );
  @override
  late final GeneratedColumn<String> metadata = GeneratedColumn<String>(
    'metadata',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isPinnedMeta = const VerificationMeta(
    'isPinned',
  );
  @override
  late final GeneratedColumn<bool> isPinned = GeneratedColumn<bool>(
    'is_pinned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_pinned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    summary,
    createdAt,
    updatedAt,
    metadata,
    isArchived,
    isPinned,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conversations';
  @override
  VerificationContext validateIntegrity(
    Insertable<Conversation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('metadata')) {
      context.handle(
        _metadataMeta,
        metadata.isAcceptableOrUnknown(data['metadata']!, _metadataMeta),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('is_pinned')) {
      context.handle(
        _isPinnedMeta,
        isPinned.isAcceptableOrUnknown(data['is_pinned']!, _isPinnedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Conversation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Conversation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      metadata: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata'],
      ),
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      isPinned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_pinned'],
      )!,
    );
  }

  @override
  $ConversationsTable createAlias(String alias) {
    return $ConversationsTable(attachedDatabase, alias);
  }
}

class Conversation extends DataClass implements Insertable<Conversation> {
  /// UUID
  final String id;

  /// Conversation title (auto-generated or user-set)
  final String? title;

  /// Summary of the conversation
  final String? summary;

  /// When the conversation was created
  final DateTime createdAt;

  /// When the conversation was last updated
  final DateTime updatedAt;

  /// Metadata as JSON (e.g., tags, context)
  final String? metadata;

  /// Whether the conversation is archived
  final bool isArchived;

  /// Whether the conversation is pinned
  final bool isPinned;
  const Conversation({
    required this.id,
    this.title,
    this.summary,
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
    required this.isArchived,
    required this.isPinned,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || summary != null) {
      map['summary'] = Variable<String>(summary);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || metadata != null) {
      map['metadata'] = Variable<String>(metadata);
    }
    map['is_archived'] = Variable<bool>(isArchived);
    map['is_pinned'] = Variable<bool>(isPinned);
    return map;
  }

  ConversationsCompanion toCompanion(bool nullToAbsent) {
    return ConversationsCompanion(
      id: Value(id),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      summary: summary == null && nullToAbsent
          ? const Value.absent()
          : Value(summary),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      metadata: metadata == null && nullToAbsent
          ? const Value.absent()
          : Value(metadata),
      isArchived: Value(isArchived),
      isPinned: Value(isPinned),
    );
  }

  factory Conversation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Conversation(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String?>(json['title']),
      summary: serializer.fromJson<String?>(json['summary']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      metadata: serializer.fromJson<String?>(json['metadata']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      isPinned: serializer.fromJson<bool>(json['isPinned']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String?>(title),
      'summary': serializer.toJson<String?>(summary),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'metadata': serializer.toJson<String?>(metadata),
      'isArchived': serializer.toJson<bool>(isArchived),
      'isPinned': serializer.toJson<bool>(isPinned),
    };
  }

  Conversation copyWith({
    String? id,
    Value<String?> title = const Value.absent(),
    Value<String?> summary = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<String?> metadata = const Value.absent(),
    bool? isArchived,
    bool? isPinned,
  }) => Conversation(
    id: id ?? this.id,
    title: title.present ? title.value : this.title,
    summary: summary.present ? summary.value : this.summary,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    metadata: metadata.present ? metadata.value : this.metadata,
    isArchived: isArchived ?? this.isArchived,
    isPinned: isPinned ?? this.isPinned,
  );
  Conversation copyWithCompanion(ConversationsCompanion data) {
    return Conversation(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      summary: data.summary.present ? data.summary.value : this.summary,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      isPinned: data.isPinned.present ? data.isPinned.value : this.isPinned,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Conversation(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('summary: $summary, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('metadata: $metadata, ')
          ..write('isArchived: $isArchived, ')
          ..write('isPinned: $isPinned')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    summary,
    createdAt,
    updatedAt,
    metadata,
    isArchived,
    isPinned,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Conversation &&
          other.id == this.id &&
          other.title == this.title &&
          other.summary == this.summary &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.metadata == this.metadata &&
          other.isArchived == this.isArchived &&
          other.isPinned == this.isPinned);
}

class ConversationsCompanion extends UpdateCompanion<Conversation> {
  final Value<String> id;
  final Value<String?> title;
  final Value<String?> summary;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String?> metadata;
  final Value<bool> isArchived;
  final Value<bool> isPinned;
  final Value<int> rowid;
  const ConversationsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.summary = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.metadata = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConversationsCompanion.insert({
    required String id,
    this.title = const Value.absent(),
    this.summary = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.metadata = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<Conversation> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? summary,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? metadata,
    Expression<bool>? isArchived,
    Expression<bool>? isPinned,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (summary != null) 'summary': summary,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (metadata != null) 'metadata': metadata,
      if (isArchived != null) 'is_archived': isArchived,
      if (isPinned != null) 'is_pinned': isPinned,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConversationsCompanion copyWith({
    Value<String>? id,
    Value<String?>? title,
    Value<String?>? summary,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String?>? metadata,
    Value<bool>? isArchived,
    Value<bool>? isPinned,
    Value<int>? rowid,
  }) {
    return ConversationsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
      isArchived: isArchived ?? this.isArchived,
      isPinned: isPinned ?? this.isPinned,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (metadata.present) {
      map['metadata'] = Variable<String>(metadata.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (isPinned.present) {
      map['is_pinned'] = Variable<bool>(isPinned.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConversationsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('summary: $summary, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('metadata: $metadata, ')
          ..write('isArchived: $isArchived, ')
          ..write('isPinned: $isPinned, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MessagesTable extends Messages with TableInfo<$MessagesTable, Message> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _conversationIdMeta = const VerificationMeta(
    'conversationId',
  );
  @override
  late final GeneratedColumn<String> conversationId = GeneratedColumn<String>(
    'conversation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES conversations (id)',
    ),
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _metadataMeta = const VerificationMeta(
    'metadata',
  );
  @override
  late final GeneratedColumn<String> metadata = GeneratedColumn<String>(
    'metadata',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _memoriesExtractedMeta = const VerificationMeta(
    'memoriesExtracted',
  );
  @override
  late final GeneratedColumn<bool> memoriesExtracted = GeneratedColumn<bool>(
    'memories_extracted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("memories_extracted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _vectorIdMeta = const VerificationMeta(
    'vectorId',
  );
  @override
  late final GeneratedColumn<int> vectorId = GeneratedColumn<int>(
    'vector_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    conversationId,
    role,
    content,
    createdAt,
    metadata,
    memoriesExtracted,
    vectorId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<Message> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
        _conversationIdMeta,
        conversationId.isAcceptableOrUnknown(
          data['conversation_id']!,
          _conversationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conversationIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('metadata')) {
      context.handle(
        _metadataMeta,
        metadata.isAcceptableOrUnknown(data['metadata']!, _metadataMeta),
      );
    }
    if (data.containsKey('memories_extracted')) {
      context.handle(
        _memoriesExtractedMeta,
        memoriesExtracted.isAcceptableOrUnknown(
          data['memories_extracted']!,
          _memoriesExtractedMeta,
        ),
      );
    }
    if (data.containsKey('vector_id')) {
      context.handle(
        _vectorIdMeta,
        vectorId.isAcceptableOrUnknown(data['vector_id']!, _vectorIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Message map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Message(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      conversationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conversation_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      metadata: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata'],
      ),
      memoriesExtracted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}memories_extracted'],
      )!,
      vectorId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vector_id'],
      ),
    );
  }

  @override
  $MessagesTable createAlias(String alias) {
    return $MessagesTable(attachedDatabase, alias);
  }
}

class Message extends DataClass implements Insertable<Message> {
  /// UUID
  final String id;

  /// Foreign key to conversations table
  final String conversationId;

  /// Role: 'user', 'assistant', or 'system'
  final String role;

  /// Message content
  final String content;

  /// When the message was created
  final DateTime createdAt;

  /// Message metadata as JSON (tokens used, model, etc.)
  final String? metadata;

  /// Whether memories were extracted from this message
  final bool memoriesExtracted;

  /// Vector embedding ID (reference to ObjectBox)
  final int? vectorId;
  const Message({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.createdAt,
    this.metadata,
    required this.memoriesExtracted,
    this.vectorId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['conversation_id'] = Variable<String>(conversationId);
    map['role'] = Variable<String>(role);
    map['content'] = Variable<String>(content);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || metadata != null) {
      map['metadata'] = Variable<String>(metadata);
    }
    map['memories_extracted'] = Variable<bool>(memoriesExtracted);
    if (!nullToAbsent || vectorId != null) {
      map['vector_id'] = Variable<int>(vectorId);
    }
    return map;
  }

  MessagesCompanion toCompanion(bool nullToAbsent) {
    return MessagesCompanion(
      id: Value(id),
      conversationId: Value(conversationId),
      role: Value(role),
      content: Value(content),
      createdAt: Value(createdAt),
      metadata: metadata == null && nullToAbsent
          ? const Value.absent()
          : Value(metadata),
      memoriesExtracted: Value(memoriesExtracted),
      vectorId: vectorId == null && nullToAbsent
          ? const Value.absent()
          : Value(vectorId),
    );
  }

  factory Message.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Message(
      id: serializer.fromJson<String>(json['id']),
      conversationId: serializer.fromJson<String>(json['conversationId']),
      role: serializer.fromJson<String>(json['role']),
      content: serializer.fromJson<String>(json['content']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      metadata: serializer.fromJson<String?>(json['metadata']),
      memoriesExtracted: serializer.fromJson<bool>(json['memoriesExtracted']),
      vectorId: serializer.fromJson<int?>(json['vectorId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'conversationId': serializer.toJson<String>(conversationId),
      'role': serializer.toJson<String>(role),
      'content': serializer.toJson<String>(content),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'metadata': serializer.toJson<String?>(metadata),
      'memoriesExtracted': serializer.toJson<bool>(memoriesExtracted),
      'vectorId': serializer.toJson<int?>(vectorId),
    };
  }

  Message copyWith({
    String? id,
    String? conversationId,
    String? role,
    String? content,
    DateTime? createdAt,
    Value<String?> metadata = const Value.absent(),
    bool? memoriesExtracted,
    Value<int?> vectorId = const Value.absent(),
  }) => Message(
    id: id ?? this.id,
    conversationId: conversationId ?? this.conversationId,
    role: role ?? this.role,
    content: content ?? this.content,
    createdAt: createdAt ?? this.createdAt,
    metadata: metadata.present ? metadata.value : this.metadata,
    memoriesExtracted: memoriesExtracted ?? this.memoriesExtracted,
    vectorId: vectorId.present ? vectorId.value : this.vectorId,
  );
  Message copyWithCompanion(MessagesCompanion data) {
    return Message(
      id: data.id.present ? data.id.value : this.id,
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      role: data.role.present ? data.role.value : this.role,
      content: data.content.present ? data.content.value : this.content,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
      memoriesExtracted: data.memoriesExtracted.present
          ? data.memoriesExtracted.value
          : this.memoriesExtracted,
      vectorId: data.vectorId.present ? data.vectorId.value : this.vectorId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Message(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt, ')
          ..write('metadata: $metadata, ')
          ..write('memoriesExtracted: $memoriesExtracted, ')
          ..write('vectorId: $vectorId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    conversationId,
    role,
    content,
    createdAt,
    metadata,
    memoriesExtracted,
    vectorId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Message &&
          other.id == this.id &&
          other.conversationId == this.conversationId &&
          other.role == this.role &&
          other.content == this.content &&
          other.createdAt == this.createdAt &&
          other.metadata == this.metadata &&
          other.memoriesExtracted == this.memoriesExtracted &&
          other.vectorId == this.vectorId);
}

class MessagesCompanion extends UpdateCompanion<Message> {
  final Value<String> id;
  final Value<String> conversationId;
  final Value<String> role;
  final Value<String> content;
  final Value<DateTime> createdAt;
  final Value<String?> metadata;
  final Value<bool> memoriesExtracted;
  final Value<int?> vectorId;
  final Value<int> rowid;
  const MessagesCompanion({
    this.id = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.role = const Value.absent(),
    this.content = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.metadata = const Value.absent(),
    this.memoriesExtracted = const Value.absent(),
    this.vectorId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessagesCompanion.insert({
    required String id,
    required String conversationId,
    required String role,
    required String content,
    this.createdAt = const Value.absent(),
    this.metadata = const Value.absent(),
    this.memoriesExtracted = const Value.absent(),
    this.vectorId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       conversationId = Value(conversationId),
       role = Value(role),
       content = Value(content);
  static Insertable<Message> custom({
    Expression<String>? id,
    Expression<String>? conversationId,
    Expression<String>? role,
    Expression<String>? content,
    Expression<DateTime>? createdAt,
    Expression<String>? metadata,
    Expression<bool>? memoriesExtracted,
    Expression<int>? vectorId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (conversationId != null) 'conversation_id': conversationId,
      if (role != null) 'role': role,
      if (content != null) 'content': content,
      if (createdAt != null) 'created_at': createdAt,
      if (metadata != null) 'metadata': metadata,
      if (memoriesExtracted != null) 'memories_extracted': memoriesExtracted,
      if (vectorId != null) 'vector_id': vectorId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MessagesCompanion copyWith({
    Value<String>? id,
    Value<String>? conversationId,
    Value<String>? role,
    Value<String>? content,
    Value<DateTime>? createdAt,
    Value<String?>? metadata,
    Value<bool>? memoriesExtracted,
    Value<int?>? vectorId,
    Value<int>? rowid,
  }) {
    return MessagesCompanion(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      role: role ?? this.role,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
      memoriesExtracted: memoriesExtracted ?? this.memoriesExtracted,
      vectorId: vectorId ?? this.vectorId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<String>(conversationId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (metadata.present) {
      map['metadata'] = Variable<String>(metadata.value);
    }
    if (memoriesExtracted.present) {
      map['memories_extracted'] = Variable<bool>(memoriesExtracted.value);
    }
    if (vectorId.present) {
      map['vector_id'] = Variable<int>(vectorId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesCompanion(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt, ')
          ..write('metadata: $metadata, ')
          ..write('memoriesExtracted: $memoriesExtracted, ')
          ..write('vectorId: $vectorId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MemoryNodesTable extends MemoryNodes
    with TableInfo<$MemoryNodesTable, MemoryNode> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MemoryNodesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nodeTypeMeta = const VerificationMeta(
    'nodeType',
  );
  @override
  late final GeneratedColumn<String> nodeType = GeneratedColumn<String>(
    'node_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _attributesMeta = const VerificationMeta(
    'attributes',
  );
  @override
  late final GeneratedColumn<String> attributes = GeneratedColumn<String>(
    'attributes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.8),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _lastReferencedMeta = const VerificationMeta(
    'lastReferenced',
  );
  @override
  late final GeneratedColumn<DateTime> lastReferenced =
      GeneratedColumn<DateTime>(
        'last_referenced',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _vectorIdMeta = const VerificationMeta(
    'vectorId',
  );
  @override
  late final GeneratedColumn<int> vectorId = GeneratedColumn<int>(
    'vector_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nodeType,
    name,
    source,
    sourceId,
    attributes,
    confidence,
    createdAt,
    updatedAt,
    lastReferenced,
    vectorId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'memory_nodes';
  @override
  VerificationContext validateIntegrity(
    Insertable<MemoryNode> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('node_type')) {
      context.handle(
        _nodeTypeMeta,
        nodeType.isAcceptableOrUnknown(data['node_type']!, _nodeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_nodeTypeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    }
    if (data.containsKey('attributes')) {
      context.handle(
        _attributesMeta,
        attributes.isAcceptableOrUnknown(data['attributes']!, _attributesMeta),
      );
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('last_referenced')) {
      context.handle(
        _lastReferencedMeta,
        lastReferenced.isAcceptableOrUnknown(
          data['last_referenced']!,
          _lastReferencedMeta,
        ),
      );
    }
    if (data.containsKey('vector_id')) {
      context.handle(
        _vectorIdMeta,
        vectorId.isAcceptableOrUnknown(data['vector_id']!, _vectorIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {source, sourceId},
  ];
  @override
  MemoryNode map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MemoryNode(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      nodeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}node_type'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      ),
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      ),
      attributes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attributes'],
      ),
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      lastReferenced: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_referenced'],
      ),
      vectorId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vector_id'],
      ),
    );
  }

  @override
  $MemoryNodesTable createAlias(String alias) {
    return $MemoryNodesTable(attachedDatabase, alias);
  }
}

class MemoryNode extends DataClass implements Insertable<MemoryNode> {
  /// UUID
  final String id;

  /// Node type: person, event, organization, location, topic, etc.
  final String nodeType;

  /// Display name
  final String name;

  /// Source of this node: google_calendar, gmail, contacts, conversation
  final String? source;

  /// ID from the source system
  final String? sourceId;

  /// Additional attributes as JSON
  /// e.g., {"email": "...", "birthday": "...", "job_title": "..."}
  final String? attributes;

  /// Confidence score (0.0 - 1.0)
  /// 0.9 = explicitly mentioned, 0.7 = implied, 0.5 = inferred
  final double confidence;

  /// When the node was created
  final DateTime createdAt;

  /// When the node was last updated
  final DateTime updatedAt;

  /// When the node was last referenced in conversation
  final DateTime? lastReferenced;

  /// Vector embedding ID (reference to ObjectBox)
  final int? vectorId;
  const MemoryNode({
    required this.id,
    required this.nodeType,
    required this.name,
    this.source,
    this.sourceId,
    this.attributes,
    required this.confidence,
    required this.createdAt,
    required this.updatedAt,
    this.lastReferenced,
    this.vectorId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['node_type'] = Variable<String>(nodeType);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || source != null) {
      map['source'] = Variable<String>(source);
    }
    if (!nullToAbsent || sourceId != null) {
      map['source_id'] = Variable<String>(sourceId);
    }
    if (!nullToAbsent || attributes != null) {
      map['attributes'] = Variable<String>(attributes);
    }
    map['confidence'] = Variable<double>(confidence);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || lastReferenced != null) {
      map['last_referenced'] = Variable<DateTime>(lastReferenced);
    }
    if (!nullToAbsent || vectorId != null) {
      map['vector_id'] = Variable<int>(vectorId);
    }
    return map;
  }

  MemoryNodesCompanion toCompanion(bool nullToAbsent) {
    return MemoryNodesCompanion(
      id: Value(id),
      nodeType: Value(nodeType),
      name: Value(name),
      source: source == null && nullToAbsent
          ? const Value.absent()
          : Value(source),
      sourceId: sourceId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceId),
      attributes: attributes == null && nullToAbsent
          ? const Value.absent()
          : Value(attributes),
      confidence: Value(confidence),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      lastReferenced: lastReferenced == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReferenced),
      vectorId: vectorId == null && nullToAbsent
          ? const Value.absent()
          : Value(vectorId),
    );
  }

  factory MemoryNode.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MemoryNode(
      id: serializer.fromJson<String>(json['id']),
      nodeType: serializer.fromJson<String>(json['nodeType']),
      name: serializer.fromJson<String>(json['name']),
      source: serializer.fromJson<String?>(json['source']),
      sourceId: serializer.fromJson<String?>(json['sourceId']),
      attributes: serializer.fromJson<String?>(json['attributes']),
      confidence: serializer.fromJson<double>(json['confidence']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      lastReferenced: serializer.fromJson<DateTime?>(json['lastReferenced']),
      vectorId: serializer.fromJson<int?>(json['vectorId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nodeType': serializer.toJson<String>(nodeType),
      'name': serializer.toJson<String>(name),
      'source': serializer.toJson<String?>(source),
      'sourceId': serializer.toJson<String?>(sourceId),
      'attributes': serializer.toJson<String?>(attributes),
      'confidence': serializer.toJson<double>(confidence),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'lastReferenced': serializer.toJson<DateTime?>(lastReferenced),
      'vectorId': serializer.toJson<int?>(vectorId),
    };
  }

  MemoryNode copyWith({
    String? id,
    String? nodeType,
    String? name,
    Value<String?> source = const Value.absent(),
    Value<String?> sourceId = const Value.absent(),
    Value<String?> attributes = const Value.absent(),
    double? confidence,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> lastReferenced = const Value.absent(),
    Value<int?> vectorId = const Value.absent(),
  }) => MemoryNode(
    id: id ?? this.id,
    nodeType: nodeType ?? this.nodeType,
    name: name ?? this.name,
    source: source.present ? source.value : this.source,
    sourceId: sourceId.present ? sourceId.value : this.sourceId,
    attributes: attributes.present ? attributes.value : this.attributes,
    confidence: confidence ?? this.confidence,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    lastReferenced: lastReferenced.present
        ? lastReferenced.value
        : this.lastReferenced,
    vectorId: vectorId.present ? vectorId.value : this.vectorId,
  );
  MemoryNode copyWithCompanion(MemoryNodesCompanion data) {
    return MemoryNode(
      id: data.id.present ? data.id.value : this.id,
      nodeType: data.nodeType.present ? data.nodeType.value : this.nodeType,
      name: data.name.present ? data.name.value : this.name,
      source: data.source.present ? data.source.value : this.source,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      attributes: data.attributes.present
          ? data.attributes.value
          : this.attributes,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastReferenced: data.lastReferenced.present
          ? data.lastReferenced.value
          : this.lastReferenced,
      vectorId: data.vectorId.present ? data.vectorId.value : this.vectorId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MemoryNode(')
          ..write('id: $id, ')
          ..write('nodeType: $nodeType, ')
          ..write('name: $name, ')
          ..write('source: $source, ')
          ..write('sourceId: $sourceId, ')
          ..write('attributes: $attributes, ')
          ..write('confidence: $confidence, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastReferenced: $lastReferenced, ')
          ..write('vectorId: $vectorId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nodeType,
    name,
    source,
    sourceId,
    attributes,
    confidence,
    createdAt,
    updatedAt,
    lastReferenced,
    vectorId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MemoryNode &&
          other.id == this.id &&
          other.nodeType == this.nodeType &&
          other.name == this.name &&
          other.source == this.source &&
          other.sourceId == this.sourceId &&
          other.attributes == this.attributes &&
          other.confidence == this.confidence &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.lastReferenced == this.lastReferenced &&
          other.vectorId == this.vectorId);
}

class MemoryNodesCompanion extends UpdateCompanion<MemoryNode> {
  final Value<String> id;
  final Value<String> nodeType;
  final Value<String> name;
  final Value<String?> source;
  final Value<String?> sourceId;
  final Value<String?> attributes;
  final Value<double> confidence;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> lastReferenced;
  final Value<int?> vectorId;
  final Value<int> rowid;
  const MemoryNodesCompanion({
    this.id = const Value.absent(),
    this.nodeType = const Value.absent(),
    this.name = const Value.absent(),
    this.source = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.attributes = const Value.absent(),
    this.confidence = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastReferenced = const Value.absent(),
    this.vectorId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MemoryNodesCompanion.insert({
    required String id,
    required String nodeType,
    required String name,
    this.source = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.attributes = const Value.absent(),
    this.confidence = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastReferenced = const Value.absent(),
    this.vectorId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nodeType = Value(nodeType),
       name = Value(name);
  static Insertable<MemoryNode> custom({
    Expression<String>? id,
    Expression<String>? nodeType,
    Expression<String>? name,
    Expression<String>? source,
    Expression<String>? sourceId,
    Expression<String>? attributes,
    Expression<double>? confidence,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? lastReferenced,
    Expression<int>? vectorId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nodeType != null) 'node_type': nodeType,
      if (name != null) 'name': name,
      if (source != null) 'source': source,
      if (sourceId != null) 'source_id': sourceId,
      if (attributes != null) 'attributes': attributes,
      if (confidence != null) 'confidence': confidence,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastReferenced != null) 'last_referenced': lastReferenced,
      if (vectorId != null) 'vector_id': vectorId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MemoryNodesCompanion copyWith({
    Value<String>? id,
    Value<String>? nodeType,
    Value<String>? name,
    Value<String?>? source,
    Value<String?>? sourceId,
    Value<String?>? attributes,
    Value<double>? confidence,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? lastReferenced,
    Value<int?>? vectorId,
    Value<int>? rowid,
  }) {
    return MemoryNodesCompanion(
      id: id ?? this.id,
      nodeType: nodeType ?? this.nodeType,
      name: name ?? this.name,
      source: source ?? this.source,
      sourceId: sourceId ?? this.sourceId,
      attributes: attributes ?? this.attributes,
      confidence: confidence ?? this.confidence,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastReferenced: lastReferenced ?? this.lastReferenced,
      vectorId: vectorId ?? this.vectorId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nodeType.present) {
      map['node_type'] = Variable<String>(nodeType.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (attributes.present) {
      map['attributes'] = Variable<String>(attributes.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (lastReferenced.present) {
      map['last_referenced'] = Variable<DateTime>(lastReferenced.value);
    }
    if (vectorId.present) {
      map['vector_id'] = Variable<int>(vectorId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MemoryNodesCompanion(')
          ..write('id: $id, ')
          ..write('nodeType: $nodeType, ')
          ..write('name: $name, ')
          ..write('source: $source, ')
          ..write('sourceId: $sourceId, ')
          ..write('attributes: $attributes, ')
          ..write('confidence: $confidence, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastReferenced: $lastReferenced, ')
          ..write('vectorId: $vectorId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MemoryEdgesTable extends MemoryEdges
    with TableInfo<$MemoryEdgesTable, MemoryEdge> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MemoryEdgesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fromNodeIdMeta = const VerificationMeta(
    'fromNodeId',
  );
  @override
  late final GeneratedColumn<String> fromNodeId = GeneratedColumn<String>(
    'from_node_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES memory_nodes (id)',
    ),
  );
  static const VerificationMeta _toNodeIdMeta = const VerificationMeta(
    'toNodeId',
  );
  @override
  late final GeneratedColumn<String> toNodeId = GeneratedColumn<String>(
    'to_node_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES memory_nodes (id)',
    ),
  );
  static const VerificationMeta _relationshipTypeMeta = const VerificationMeta(
    'relationshipType',
  );
  @override
  late final GeneratedColumn<String> relationshipType = GeneratedColumn<String>(
    'relationship_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attributesMeta = const VerificationMeta(
    'attributes',
  );
  @override
  late final GeneratedColumn<String> attributes = GeneratedColumn<String>(
    'attributes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.7),
  );
  static const VerificationMeta _referenceCountMeta = const VerificationMeta(
    'referenceCount',
  );
  @override
  late final GeneratedColumn<int> referenceCount = GeneratedColumn<int>(
    'reference_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _lastReferencedMeta = const VerificationMeta(
    'lastReferenced',
  );
  @override
  late final GeneratedColumn<DateTime> lastReferenced =
      GeneratedColumn<DateTime>(
        'last_referenced',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    fromNodeId,
    toNodeId,
    relationshipType,
    attributes,
    confidence,
    referenceCount,
    createdAt,
    updatedAt,
    lastReferenced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'memory_edges';
  @override
  VerificationContext validateIntegrity(
    Insertable<MemoryEdge> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('from_node_id')) {
      context.handle(
        _fromNodeIdMeta,
        fromNodeId.isAcceptableOrUnknown(
          data['from_node_id']!,
          _fromNodeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fromNodeIdMeta);
    }
    if (data.containsKey('to_node_id')) {
      context.handle(
        _toNodeIdMeta,
        toNodeId.isAcceptableOrUnknown(data['to_node_id']!, _toNodeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_toNodeIdMeta);
    }
    if (data.containsKey('relationship_type')) {
      context.handle(
        _relationshipTypeMeta,
        relationshipType.isAcceptableOrUnknown(
          data['relationship_type']!,
          _relationshipTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_relationshipTypeMeta);
    }
    if (data.containsKey('attributes')) {
      context.handle(
        _attributesMeta,
        attributes.isAcceptableOrUnknown(data['attributes']!, _attributesMeta),
      );
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    }
    if (data.containsKey('reference_count')) {
      context.handle(
        _referenceCountMeta,
        referenceCount.isAcceptableOrUnknown(
          data['reference_count']!,
          _referenceCountMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('last_referenced')) {
      context.handle(
        _lastReferencedMeta,
        lastReferenced.isAcceptableOrUnknown(
          data['last_referenced']!,
          _lastReferencedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {fromNodeId, toNodeId, relationshipType},
  ];
  @override
  MemoryEdge map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MemoryEdge(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      fromNodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_node_id'],
      )!,
      toNodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_node_id'],
      )!,
      relationshipType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relationship_type'],
      )!,
      attributes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attributes'],
      ),
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      )!,
      referenceCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reference_count'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      lastReferenced: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_referenced'],
      ),
    );
  }

  @override
  $MemoryEdgesTable createAlias(String alias) {
    return $MemoryEdgesTable(attachedDatabase, alias);
  }
}

class MemoryEdge extends DataClass implements Insertable<MemoryEdge> {
  /// UUID
  final String id;

  /// Source node ID
  final String fromNodeId;

  /// Target node ID
  final String toNodeId;

  /// Relationship type: knows, works_at, attended, lives_in, etc.
  final String relationshipType;

  /// Additional attributes as JSON
  /// e.g., {"since": "2020", "role": "colleague"}
  final String? attributes;

  /// Confidence score (0.0 - 1.0)
  final double confidence;

  /// How many times this relationship has been referenced
  final int referenceCount;

  /// When the edge was created
  final DateTime createdAt;

  /// When the edge was last updated
  final DateTime updatedAt;

  /// When the edge was last referenced in conversation
  final DateTime? lastReferenced;
  const MemoryEdge({
    required this.id,
    required this.fromNodeId,
    required this.toNodeId,
    required this.relationshipType,
    this.attributes,
    required this.confidence,
    required this.referenceCount,
    required this.createdAt,
    required this.updatedAt,
    this.lastReferenced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['from_node_id'] = Variable<String>(fromNodeId);
    map['to_node_id'] = Variable<String>(toNodeId);
    map['relationship_type'] = Variable<String>(relationshipType);
    if (!nullToAbsent || attributes != null) {
      map['attributes'] = Variable<String>(attributes);
    }
    map['confidence'] = Variable<double>(confidence);
    map['reference_count'] = Variable<int>(referenceCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || lastReferenced != null) {
      map['last_referenced'] = Variable<DateTime>(lastReferenced);
    }
    return map;
  }

  MemoryEdgesCompanion toCompanion(bool nullToAbsent) {
    return MemoryEdgesCompanion(
      id: Value(id),
      fromNodeId: Value(fromNodeId),
      toNodeId: Value(toNodeId),
      relationshipType: Value(relationshipType),
      attributes: attributes == null && nullToAbsent
          ? const Value.absent()
          : Value(attributes),
      confidence: Value(confidence),
      referenceCount: Value(referenceCount),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      lastReferenced: lastReferenced == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReferenced),
    );
  }

  factory MemoryEdge.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MemoryEdge(
      id: serializer.fromJson<String>(json['id']),
      fromNodeId: serializer.fromJson<String>(json['fromNodeId']),
      toNodeId: serializer.fromJson<String>(json['toNodeId']),
      relationshipType: serializer.fromJson<String>(json['relationshipType']),
      attributes: serializer.fromJson<String?>(json['attributes']),
      confidence: serializer.fromJson<double>(json['confidence']),
      referenceCount: serializer.fromJson<int>(json['referenceCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      lastReferenced: serializer.fromJson<DateTime?>(json['lastReferenced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fromNodeId': serializer.toJson<String>(fromNodeId),
      'toNodeId': serializer.toJson<String>(toNodeId),
      'relationshipType': serializer.toJson<String>(relationshipType),
      'attributes': serializer.toJson<String?>(attributes),
      'confidence': serializer.toJson<double>(confidence),
      'referenceCount': serializer.toJson<int>(referenceCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'lastReferenced': serializer.toJson<DateTime?>(lastReferenced),
    };
  }

  MemoryEdge copyWith({
    String? id,
    String? fromNodeId,
    String? toNodeId,
    String? relationshipType,
    Value<String?> attributes = const Value.absent(),
    double? confidence,
    int? referenceCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> lastReferenced = const Value.absent(),
  }) => MemoryEdge(
    id: id ?? this.id,
    fromNodeId: fromNodeId ?? this.fromNodeId,
    toNodeId: toNodeId ?? this.toNodeId,
    relationshipType: relationshipType ?? this.relationshipType,
    attributes: attributes.present ? attributes.value : this.attributes,
    confidence: confidence ?? this.confidence,
    referenceCount: referenceCount ?? this.referenceCount,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    lastReferenced: lastReferenced.present
        ? lastReferenced.value
        : this.lastReferenced,
  );
  MemoryEdge copyWithCompanion(MemoryEdgesCompanion data) {
    return MemoryEdge(
      id: data.id.present ? data.id.value : this.id,
      fromNodeId: data.fromNodeId.present
          ? data.fromNodeId.value
          : this.fromNodeId,
      toNodeId: data.toNodeId.present ? data.toNodeId.value : this.toNodeId,
      relationshipType: data.relationshipType.present
          ? data.relationshipType.value
          : this.relationshipType,
      attributes: data.attributes.present
          ? data.attributes.value
          : this.attributes,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      referenceCount: data.referenceCount.present
          ? data.referenceCount.value
          : this.referenceCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastReferenced: data.lastReferenced.present
          ? data.lastReferenced.value
          : this.lastReferenced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MemoryEdge(')
          ..write('id: $id, ')
          ..write('fromNodeId: $fromNodeId, ')
          ..write('toNodeId: $toNodeId, ')
          ..write('relationshipType: $relationshipType, ')
          ..write('attributes: $attributes, ')
          ..write('confidence: $confidence, ')
          ..write('referenceCount: $referenceCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastReferenced: $lastReferenced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    fromNodeId,
    toNodeId,
    relationshipType,
    attributes,
    confidence,
    referenceCount,
    createdAt,
    updatedAt,
    lastReferenced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MemoryEdge &&
          other.id == this.id &&
          other.fromNodeId == this.fromNodeId &&
          other.toNodeId == this.toNodeId &&
          other.relationshipType == this.relationshipType &&
          other.attributes == this.attributes &&
          other.confidence == this.confidence &&
          other.referenceCount == this.referenceCount &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.lastReferenced == this.lastReferenced);
}

class MemoryEdgesCompanion extends UpdateCompanion<MemoryEdge> {
  final Value<String> id;
  final Value<String> fromNodeId;
  final Value<String> toNodeId;
  final Value<String> relationshipType;
  final Value<String?> attributes;
  final Value<double> confidence;
  final Value<int> referenceCount;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> lastReferenced;
  final Value<int> rowid;
  const MemoryEdgesCompanion({
    this.id = const Value.absent(),
    this.fromNodeId = const Value.absent(),
    this.toNodeId = const Value.absent(),
    this.relationshipType = const Value.absent(),
    this.attributes = const Value.absent(),
    this.confidence = const Value.absent(),
    this.referenceCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastReferenced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MemoryEdgesCompanion.insert({
    required String id,
    required String fromNodeId,
    required String toNodeId,
    required String relationshipType,
    this.attributes = const Value.absent(),
    this.confidence = const Value.absent(),
    this.referenceCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastReferenced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       fromNodeId = Value(fromNodeId),
       toNodeId = Value(toNodeId),
       relationshipType = Value(relationshipType);
  static Insertable<MemoryEdge> custom({
    Expression<String>? id,
    Expression<String>? fromNodeId,
    Expression<String>? toNodeId,
    Expression<String>? relationshipType,
    Expression<String>? attributes,
    Expression<double>? confidence,
    Expression<int>? referenceCount,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? lastReferenced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fromNodeId != null) 'from_node_id': fromNodeId,
      if (toNodeId != null) 'to_node_id': toNodeId,
      if (relationshipType != null) 'relationship_type': relationshipType,
      if (attributes != null) 'attributes': attributes,
      if (confidence != null) 'confidence': confidence,
      if (referenceCount != null) 'reference_count': referenceCount,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastReferenced != null) 'last_referenced': lastReferenced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MemoryEdgesCompanion copyWith({
    Value<String>? id,
    Value<String>? fromNodeId,
    Value<String>? toNodeId,
    Value<String>? relationshipType,
    Value<String?>? attributes,
    Value<double>? confidence,
    Value<int>? referenceCount,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? lastReferenced,
    Value<int>? rowid,
  }) {
    return MemoryEdgesCompanion(
      id: id ?? this.id,
      fromNodeId: fromNodeId ?? this.fromNodeId,
      toNodeId: toNodeId ?? this.toNodeId,
      relationshipType: relationshipType ?? this.relationshipType,
      attributes: attributes ?? this.attributes,
      confidence: confidence ?? this.confidence,
      referenceCount: referenceCount ?? this.referenceCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastReferenced: lastReferenced ?? this.lastReferenced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (fromNodeId.present) {
      map['from_node_id'] = Variable<String>(fromNodeId.value);
    }
    if (toNodeId.present) {
      map['to_node_id'] = Variable<String>(toNodeId.value);
    }
    if (relationshipType.present) {
      map['relationship_type'] = Variable<String>(relationshipType.value);
    }
    if (attributes.present) {
      map['attributes'] = Variable<String>(attributes.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (referenceCount.present) {
      map['reference_count'] = Variable<int>(referenceCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (lastReferenced.present) {
      map['last_referenced'] = Variable<DateTime>(lastReferenced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MemoryEdgesCompanion(')
          ..write('id: $id, ')
          ..write('fromNodeId: $fromNodeId, ')
          ..write('toNodeId: $toNodeId, ')
          ..write('relationshipType: $relationshipType, ')
          ..write('attributes: $attributes, ')
          ..write('confidence: $confidence, ')
          ..write('referenceCount: $referenceCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastReferenced: $lastReferenced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ConnectionsTable extends Connections
    with TableInfo<$ConnectionsTable, Connection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConnectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _providerMeta = const VerificationMeta(
    'provider',
  );
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
    'provider',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _encryptedAccessTokenMeta =
      const VerificationMeta('encryptedAccessToken');
  @override
  late final GeneratedColumn<String> encryptedAccessToken =
      GeneratedColumn<String>(
        'encrypted_access_token',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _encryptedRefreshTokenMeta =
      const VerificationMeta('encryptedRefreshToken');
  @override
  late final GeneratedColumn<String> encryptedRefreshToken =
      GeneratedColumn<String>(
        'encrypted_refresh_token',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
    'expires_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _metadataMeta = const VerificationMeta(
    'metadata',
  );
  @override
  late final GeneratedColumn<String> metadata = GeneratedColumn<String>(
    'metadata',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSyncEntitiesMeta = const VerificationMeta(
    'lastSyncEntities',
  );
  @override
  late final GeneratedColumn<int> lastSyncEntities = GeneratedColumn<int>(
    'last_sync_entities',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSyncRelationshipsMeta =
      const VerificationMeta('lastSyncRelationships');
  @override
  late final GeneratedColumn<int> lastSyncRelationships = GeneratedColumn<int>(
    'last_sync_relationships',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    provider,
    encryptedAccessToken,
    encryptedRefreshToken,
    expiresAt,
    metadata,
    createdAt,
    updatedAt,
    lastSyncedAt,
    lastSyncEntities,
    lastSyncRelationships,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'connections';
  @override
  VerificationContext validateIntegrity(
    Insertable<Connection> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('provider')) {
      context.handle(
        _providerMeta,
        provider.isAcceptableOrUnknown(data['provider']!, _providerMeta),
      );
    } else if (isInserting) {
      context.missing(_providerMeta);
    }
    if (data.containsKey('encrypted_access_token')) {
      context.handle(
        _encryptedAccessTokenMeta,
        encryptedAccessToken.isAcceptableOrUnknown(
          data['encrypted_access_token']!,
          _encryptedAccessTokenMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_encryptedAccessTokenMeta);
    }
    if (data.containsKey('encrypted_refresh_token')) {
      context.handle(
        _encryptedRefreshTokenMeta,
        encryptedRefreshToken.isAcceptableOrUnknown(
          data['encrypted_refresh_token']!,
          _encryptedRefreshTokenMeta,
        ),
      );
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    }
    if (data.containsKey('metadata')) {
      context.handle(
        _metadataMeta,
        metadata.isAcceptableOrUnknown(data['metadata']!, _metadataMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_sync_entities')) {
      context.handle(
        _lastSyncEntitiesMeta,
        lastSyncEntities.isAcceptableOrUnknown(
          data['last_sync_entities']!,
          _lastSyncEntitiesMeta,
        ),
      );
    }
    if (data.containsKey('last_sync_relationships')) {
      context.handle(
        _lastSyncRelationshipsMeta,
        lastSyncRelationships.isAcceptableOrUnknown(
          data['last_sync_relationships']!,
          _lastSyncRelationshipsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {provider};
  @override
  Connection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Connection(
      provider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider'],
      )!,
      encryptedAccessToken: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}encrypted_access_token'],
      )!,
      encryptedRefreshToken: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}encrypted_refresh_token'],
      ),
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at'],
      ),
      metadata: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
      lastSyncEntities: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_sync_entities'],
      ),
      lastSyncRelationships: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_sync_relationships'],
      ),
    );
  }

  @override
  $ConnectionsTable createAlias(String alias) {
    return $ConnectionsTable(attachedDatabase, alias);
  }
}

class Connection extends DataClass implements Insertable<Connection> {
  /// Provider name: google, amazon, spotify
  final String provider;

  /// Encrypted access token
  final String encryptedAccessToken;

  /// Encrypted refresh token
  final String? encryptedRefreshToken;

  /// When the access token expires
  final DateTime? expiresAt;

  /// Connection metadata as JSON
  /// e.g., {"scopes": [...], "email": "..."}
  final String? metadata;

  /// When the connection was established
  final DateTime createdAt;

  /// When the connection was last updated
  final DateTime updatedAt;

  /// When data was last synced from this provider
  final DateTime? lastSyncedAt;

  /// Number of entities synced in last sync
  final int? lastSyncEntities;

  /// Number of relationships synced in last sync
  final int? lastSyncRelationships;
  const Connection({
    required this.provider,
    required this.encryptedAccessToken,
    this.encryptedRefreshToken,
    this.expiresAt,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.lastSyncedAt,
    this.lastSyncEntities,
    this.lastSyncRelationships,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['provider'] = Variable<String>(provider);
    map['encrypted_access_token'] = Variable<String>(encryptedAccessToken);
    if (!nullToAbsent || encryptedRefreshToken != null) {
      map['encrypted_refresh_token'] = Variable<String>(encryptedRefreshToken);
    }
    if (!nullToAbsent || expiresAt != null) {
      map['expires_at'] = Variable<DateTime>(expiresAt);
    }
    if (!nullToAbsent || metadata != null) {
      map['metadata'] = Variable<String>(metadata);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    if (!nullToAbsent || lastSyncEntities != null) {
      map['last_sync_entities'] = Variable<int>(lastSyncEntities);
    }
    if (!nullToAbsent || lastSyncRelationships != null) {
      map['last_sync_relationships'] = Variable<int>(lastSyncRelationships);
    }
    return map;
  }

  ConnectionsCompanion toCompanion(bool nullToAbsent) {
    return ConnectionsCompanion(
      provider: Value(provider),
      encryptedAccessToken: Value(encryptedAccessToken),
      encryptedRefreshToken: encryptedRefreshToken == null && nullToAbsent
          ? const Value.absent()
          : Value(encryptedRefreshToken),
      expiresAt: expiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(expiresAt),
      metadata: metadata == null && nullToAbsent
          ? const Value.absent()
          : Value(metadata),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      lastSyncEntities: lastSyncEntities == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncEntities),
      lastSyncRelationships: lastSyncRelationships == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncRelationships),
    );
  }

  factory Connection.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Connection(
      provider: serializer.fromJson<String>(json['provider']),
      encryptedAccessToken: serializer.fromJson<String>(
        json['encryptedAccessToken'],
      ),
      encryptedRefreshToken: serializer.fromJson<String?>(
        json['encryptedRefreshToken'],
      ),
      expiresAt: serializer.fromJson<DateTime?>(json['expiresAt']),
      metadata: serializer.fromJson<String?>(json['metadata']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      lastSyncEntities: serializer.fromJson<int?>(json['lastSyncEntities']),
      lastSyncRelationships: serializer.fromJson<int?>(
        json['lastSyncRelationships'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'provider': serializer.toJson<String>(provider),
      'encryptedAccessToken': serializer.toJson<String>(encryptedAccessToken),
      'encryptedRefreshToken': serializer.toJson<String?>(
        encryptedRefreshToken,
      ),
      'expiresAt': serializer.toJson<DateTime?>(expiresAt),
      'metadata': serializer.toJson<String?>(metadata),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'lastSyncEntities': serializer.toJson<int?>(lastSyncEntities),
      'lastSyncRelationships': serializer.toJson<int?>(lastSyncRelationships),
    };
  }

  Connection copyWith({
    String? provider,
    String? encryptedAccessToken,
    Value<String?> encryptedRefreshToken = const Value.absent(),
    Value<DateTime?> expiresAt = const Value.absent(),
    Value<String?> metadata = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
    Value<int?> lastSyncEntities = const Value.absent(),
    Value<int?> lastSyncRelationships = const Value.absent(),
  }) => Connection(
    provider: provider ?? this.provider,
    encryptedAccessToken: encryptedAccessToken ?? this.encryptedAccessToken,
    encryptedRefreshToken: encryptedRefreshToken.present
        ? encryptedRefreshToken.value
        : this.encryptedRefreshToken,
    expiresAt: expiresAt.present ? expiresAt.value : this.expiresAt,
    metadata: metadata.present ? metadata.value : this.metadata,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
    lastSyncEntities: lastSyncEntities.present
        ? lastSyncEntities.value
        : this.lastSyncEntities,
    lastSyncRelationships: lastSyncRelationships.present
        ? lastSyncRelationships.value
        : this.lastSyncRelationships,
  );
  Connection copyWithCompanion(ConnectionsCompanion data) {
    return Connection(
      provider: data.provider.present ? data.provider.value : this.provider,
      encryptedAccessToken: data.encryptedAccessToken.present
          ? data.encryptedAccessToken.value
          : this.encryptedAccessToken,
      encryptedRefreshToken: data.encryptedRefreshToken.present
          ? data.encryptedRefreshToken.value
          : this.encryptedRefreshToken,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      lastSyncEntities: data.lastSyncEntities.present
          ? data.lastSyncEntities.value
          : this.lastSyncEntities,
      lastSyncRelationships: data.lastSyncRelationships.present
          ? data.lastSyncRelationships.value
          : this.lastSyncRelationships,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Connection(')
          ..write('provider: $provider, ')
          ..write('encryptedAccessToken: $encryptedAccessToken, ')
          ..write('encryptedRefreshToken: $encryptedRefreshToken, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('metadata: $metadata, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('lastSyncEntities: $lastSyncEntities, ')
          ..write('lastSyncRelationships: $lastSyncRelationships')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    provider,
    encryptedAccessToken,
    encryptedRefreshToken,
    expiresAt,
    metadata,
    createdAt,
    updatedAt,
    lastSyncedAt,
    lastSyncEntities,
    lastSyncRelationships,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Connection &&
          other.provider == this.provider &&
          other.encryptedAccessToken == this.encryptedAccessToken &&
          other.encryptedRefreshToken == this.encryptedRefreshToken &&
          other.expiresAt == this.expiresAt &&
          other.metadata == this.metadata &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.lastSyncEntities == this.lastSyncEntities &&
          other.lastSyncRelationships == this.lastSyncRelationships);
}

class ConnectionsCompanion extends UpdateCompanion<Connection> {
  final Value<String> provider;
  final Value<String> encryptedAccessToken;
  final Value<String?> encryptedRefreshToken;
  final Value<DateTime?> expiresAt;
  final Value<String?> metadata;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> lastSyncedAt;
  final Value<int?> lastSyncEntities;
  final Value<int?> lastSyncRelationships;
  final Value<int> rowid;
  const ConnectionsCompanion({
    this.provider = const Value.absent(),
    this.encryptedAccessToken = const Value.absent(),
    this.encryptedRefreshToken = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.metadata = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.lastSyncEntities = const Value.absent(),
    this.lastSyncRelationships = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConnectionsCompanion.insert({
    required String provider,
    required String encryptedAccessToken,
    this.encryptedRefreshToken = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.metadata = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.lastSyncEntities = const Value.absent(),
    this.lastSyncRelationships = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : provider = Value(provider),
       encryptedAccessToken = Value(encryptedAccessToken);
  static Insertable<Connection> custom({
    Expression<String>? provider,
    Expression<String>? encryptedAccessToken,
    Expression<String>? encryptedRefreshToken,
    Expression<DateTime>? expiresAt,
    Expression<String>? metadata,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? lastSyncEntities,
    Expression<int>? lastSyncRelationships,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (provider != null) 'provider': provider,
      if (encryptedAccessToken != null)
        'encrypted_access_token': encryptedAccessToken,
      if (encryptedRefreshToken != null)
        'encrypted_refresh_token': encryptedRefreshToken,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (metadata != null) 'metadata': metadata,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (lastSyncEntities != null) 'last_sync_entities': lastSyncEntities,
      if (lastSyncRelationships != null)
        'last_sync_relationships': lastSyncRelationships,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConnectionsCompanion copyWith({
    Value<String>? provider,
    Value<String>? encryptedAccessToken,
    Value<String?>? encryptedRefreshToken,
    Value<DateTime?>? expiresAt,
    Value<String?>? metadata,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? lastSyncedAt,
    Value<int?>? lastSyncEntities,
    Value<int?>? lastSyncRelationships,
    Value<int>? rowid,
  }) {
    return ConnectionsCompanion(
      provider: provider ?? this.provider,
      encryptedAccessToken: encryptedAccessToken ?? this.encryptedAccessToken,
      encryptedRefreshToken:
          encryptedRefreshToken ?? this.encryptedRefreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      lastSyncEntities: lastSyncEntities ?? this.lastSyncEntities,
      lastSyncRelationships:
          lastSyncRelationships ?? this.lastSyncRelationships,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (encryptedAccessToken.present) {
      map['encrypted_access_token'] = Variable<String>(
        encryptedAccessToken.value,
      );
    }
    if (encryptedRefreshToken.present) {
      map['encrypted_refresh_token'] = Variable<String>(
        encryptedRefreshToken.value,
      );
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (metadata.present) {
      map['metadata'] = Variable<String>(metadata.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (lastSyncEntities.present) {
      map['last_sync_entities'] = Variable<int>(lastSyncEntities.value);
    }
    if (lastSyncRelationships.present) {
      map['last_sync_relationships'] = Variable<int>(
        lastSyncRelationships.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConnectionsCompanion(')
          ..write('provider: $provider, ')
          ..write('encryptedAccessToken: $encryptedAccessToken, ')
          ..write('encryptedRefreshToken: $encryptedRefreshToken, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('metadata: $metadata, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('lastSyncEntities: $lastSyncEntities, ')
          ..write('lastSyncRelationships: $lastSyncRelationships, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InsightsTable extends Insights with TableInfo<$InsightsTable, Insight> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InsightsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _insightTypeMeta = const VerificationMeta(
    'insightType',
  );
  @override
  late final GeneratedColumn<String> insightType = GeneratedColumn<String>(
    'insight_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _generatedAtMeta = const VerificationMeta(
    'generatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> generatedAt = GeneratedColumn<DateTime>(
    'generated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
    'expires_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isViewedMeta = const VerificationMeta(
    'isViewed',
  );
  @override
  late final GeneratedColumn<bool> isViewed = GeneratedColumn<bool>(
    'is_viewed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_viewed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDismissedMeta = const VerificationMeta(
    'isDismissed',
  );
  @override
  late final GeneratedColumn<bool> isDismissed = GeneratedColumn<bool>(
    'is_dismissed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dismissed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    insightType,
    title,
    data,
    generatedAt,
    expiresAt,
    isViewed,
    isDismissed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'insights';
  @override
  VerificationContext validateIntegrity(
    Insertable<Insight> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('insight_type')) {
      context.handle(
        _insightTypeMeta,
        insightType.isAcceptableOrUnknown(
          data['insight_type']!,
          _insightTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_insightTypeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('generated_at')) {
      context.handle(
        _generatedAtMeta,
        generatedAt.isAcceptableOrUnknown(
          data['generated_at']!,
          _generatedAtMeta,
        ),
      );
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    }
    if (data.containsKey('is_viewed')) {
      context.handle(
        _isViewedMeta,
        isViewed.isAcceptableOrUnknown(data['is_viewed']!, _isViewedMeta),
      );
    }
    if (data.containsKey('is_dismissed')) {
      context.handle(
        _isDismissedMeta,
        isDismissed.isAcceptableOrUnknown(
          data['is_dismissed']!,
          _isDismissedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Insight map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Insight(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      insightType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}insight_type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data'],
      )!,
      generatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}generated_at'],
      )!,
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at'],
      ),
      isViewed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_viewed'],
      )!,
      isDismissed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dismissed'],
      )!,
    );
  }

  @override
  $InsightsTable createAlias(String alias) {
    return $InsightsTable(attachedDatabase, alias);
  }
}

class Insight extends DataClass implements Insertable<Insight> {
  /// UUID
  final String id;

  /// Type of insight: personality, reconnection, pattern, community
  final String insightType;

  /// Human-readable title
  final String title;

  /// Insight data as JSON (structure varies by type)
  final String data;

  /// When the insight was generated
  final DateTime generatedAt;

  /// When the insight expires (should be regenerated)
  final DateTime? expiresAt;

  /// Whether the insight has been viewed by the user
  final bool isViewed;

  /// Whether the user dismissed this insight
  final bool isDismissed;
  const Insight({
    required this.id,
    required this.insightType,
    required this.title,
    required this.data,
    required this.generatedAt,
    this.expiresAt,
    required this.isViewed,
    required this.isDismissed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['insight_type'] = Variable<String>(insightType);
    map['title'] = Variable<String>(title);
    map['data'] = Variable<String>(data);
    map['generated_at'] = Variable<DateTime>(generatedAt);
    if (!nullToAbsent || expiresAt != null) {
      map['expires_at'] = Variable<DateTime>(expiresAt);
    }
    map['is_viewed'] = Variable<bool>(isViewed);
    map['is_dismissed'] = Variable<bool>(isDismissed);
    return map;
  }

  InsightsCompanion toCompanion(bool nullToAbsent) {
    return InsightsCompanion(
      id: Value(id),
      insightType: Value(insightType),
      title: Value(title),
      data: Value(data),
      generatedAt: Value(generatedAt),
      expiresAt: expiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(expiresAt),
      isViewed: Value(isViewed),
      isDismissed: Value(isDismissed),
    );
  }

  factory Insight.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Insight(
      id: serializer.fromJson<String>(json['id']),
      insightType: serializer.fromJson<String>(json['insightType']),
      title: serializer.fromJson<String>(json['title']),
      data: serializer.fromJson<String>(json['data']),
      generatedAt: serializer.fromJson<DateTime>(json['generatedAt']),
      expiresAt: serializer.fromJson<DateTime?>(json['expiresAt']),
      isViewed: serializer.fromJson<bool>(json['isViewed']),
      isDismissed: serializer.fromJson<bool>(json['isDismissed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'insightType': serializer.toJson<String>(insightType),
      'title': serializer.toJson<String>(title),
      'data': serializer.toJson<String>(data),
      'generatedAt': serializer.toJson<DateTime>(generatedAt),
      'expiresAt': serializer.toJson<DateTime?>(expiresAt),
      'isViewed': serializer.toJson<bool>(isViewed),
      'isDismissed': serializer.toJson<bool>(isDismissed),
    };
  }

  Insight copyWith({
    String? id,
    String? insightType,
    String? title,
    String? data,
    DateTime? generatedAt,
    Value<DateTime?> expiresAt = const Value.absent(),
    bool? isViewed,
    bool? isDismissed,
  }) => Insight(
    id: id ?? this.id,
    insightType: insightType ?? this.insightType,
    title: title ?? this.title,
    data: data ?? this.data,
    generatedAt: generatedAt ?? this.generatedAt,
    expiresAt: expiresAt.present ? expiresAt.value : this.expiresAt,
    isViewed: isViewed ?? this.isViewed,
    isDismissed: isDismissed ?? this.isDismissed,
  );
  Insight copyWithCompanion(InsightsCompanion data) {
    return Insight(
      id: data.id.present ? data.id.value : this.id,
      insightType: data.insightType.present
          ? data.insightType.value
          : this.insightType,
      title: data.title.present ? data.title.value : this.title,
      data: data.data.present ? data.data.value : this.data,
      generatedAt: data.generatedAt.present
          ? data.generatedAt.value
          : this.generatedAt,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
      isViewed: data.isViewed.present ? data.isViewed.value : this.isViewed,
      isDismissed: data.isDismissed.present
          ? data.isDismissed.value
          : this.isDismissed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Insight(')
          ..write('id: $id, ')
          ..write('insightType: $insightType, ')
          ..write('title: $title, ')
          ..write('data: $data, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('isViewed: $isViewed, ')
          ..write('isDismissed: $isDismissed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    insightType,
    title,
    data,
    generatedAt,
    expiresAt,
    isViewed,
    isDismissed,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Insight &&
          other.id == this.id &&
          other.insightType == this.insightType &&
          other.title == this.title &&
          other.data == this.data &&
          other.generatedAt == this.generatedAt &&
          other.expiresAt == this.expiresAt &&
          other.isViewed == this.isViewed &&
          other.isDismissed == this.isDismissed);
}

class InsightsCompanion extends UpdateCompanion<Insight> {
  final Value<String> id;
  final Value<String> insightType;
  final Value<String> title;
  final Value<String> data;
  final Value<DateTime> generatedAt;
  final Value<DateTime?> expiresAt;
  final Value<bool> isViewed;
  final Value<bool> isDismissed;
  final Value<int> rowid;
  const InsightsCompanion({
    this.id = const Value.absent(),
    this.insightType = const Value.absent(),
    this.title = const Value.absent(),
    this.data = const Value.absent(),
    this.generatedAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.isViewed = const Value.absent(),
    this.isDismissed = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InsightsCompanion.insert({
    required String id,
    required String insightType,
    required String title,
    required String data,
    this.generatedAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.isViewed = const Value.absent(),
    this.isDismissed = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       insightType = Value(insightType),
       title = Value(title),
       data = Value(data);
  static Insertable<Insight> custom({
    Expression<String>? id,
    Expression<String>? insightType,
    Expression<String>? title,
    Expression<String>? data,
    Expression<DateTime>? generatedAt,
    Expression<DateTime>? expiresAt,
    Expression<bool>? isViewed,
    Expression<bool>? isDismissed,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (insightType != null) 'insight_type': insightType,
      if (title != null) 'title': title,
      if (data != null) 'data': data,
      if (generatedAt != null) 'generated_at': generatedAt,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (isViewed != null) 'is_viewed': isViewed,
      if (isDismissed != null) 'is_dismissed': isDismissed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InsightsCompanion copyWith({
    Value<String>? id,
    Value<String>? insightType,
    Value<String>? title,
    Value<String>? data,
    Value<DateTime>? generatedAt,
    Value<DateTime?>? expiresAt,
    Value<bool>? isViewed,
    Value<bool>? isDismissed,
    Value<int>? rowid,
  }) {
    return InsightsCompanion(
      id: id ?? this.id,
      insightType: insightType ?? this.insightType,
      title: title ?? this.title,
      data: data ?? this.data,
      generatedAt: generatedAt ?? this.generatedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isViewed: isViewed ?? this.isViewed,
      isDismissed: isDismissed ?? this.isDismissed,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (insightType.present) {
      map['insight_type'] = Variable<String>(insightType.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (generatedAt.present) {
      map['generated_at'] = Variable<DateTime>(generatedAt.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (isViewed.present) {
      map['is_viewed'] = Variable<bool>(isViewed.value);
    }
    if (isDismissed.present) {
      map['is_dismissed'] = Variable<bool>(isDismissed.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InsightsCompanion(')
          ..write('id: $id, ')
          ..write('insightType: $insightType, ')
          ..write('title: $title, ')
          ..write('data: $data, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('isViewed: $isViewed, ')
          ..write('isDismissed: $isDismissed, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EntityCooccurrencesTable extends EntityCooccurrences
    with TableInfo<$EntityCooccurrencesTable, EntityCooccurrence> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntityCooccurrencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entityAMeta = const VerificationMeta(
    'entityA',
  );
  @override
  late final GeneratedColumn<String> entityA = GeneratedColumn<String>(
    'entity_a',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityBMeta = const VerificationMeta(
    'entityB',
  );
  @override
  late final GeneratedColumn<String> entityB = GeneratedColumn<String>(
    'entity_b',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cooccurrenceCountMeta = const VerificationMeta(
    'cooccurrenceCount',
  );
  @override
  late final GeneratedColumn<int> cooccurrenceCount = GeneratedColumn<int>(
    'cooccurrence_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _messageCountMeta = const VerificationMeta(
    'messageCount',
  );
  @override
  late final GeneratedColumn<int> messageCount = GeneratedColumn<int>(
    'message_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sessionCountMeta = const VerificationMeta(
    'sessionCount',
  );
  @override
  late final GeneratedColumn<int> sessionCount = GeneratedColumn<int>(
    'session_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _temporalProximityMeta = const VerificationMeta(
    'temporalProximity',
  );
  @override
  late final GeneratedColumn<double> temporalProximity =
      GeneratedColumn<double>(
        'temporal_proximity',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0.0),
      );
  static const VerificationMeta _firstSeenMeta = const VerificationMeta(
    'firstSeen',
  );
  @override
  late final GeneratedColumn<DateTime> firstSeen = GeneratedColumn<DateTime>(
    'first_seen',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _lastSeenMeta = const VerificationMeta(
    'lastSeen',
  );
  @override
  late final GeneratedColumn<DateTime> lastSeen = GeneratedColumn<DateTime>(
    'last_seen',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    entityA,
    entityB,
    cooccurrenceCount,
    messageCount,
    sessionCount,
    temporalProximity,
    firstSeen,
    lastSeen,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entity_cooccurrences';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntityCooccurrence> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entity_a')) {
      context.handle(
        _entityAMeta,
        entityA.isAcceptableOrUnknown(data['entity_a']!, _entityAMeta),
      );
    } else if (isInserting) {
      context.missing(_entityAMeta);
    }
    if (data.containsKey('entity_b')) {
      context.handle(
        _entityBMeta,
        entityB.isAcceptableOrUnknown(data['entity_b']!, _entityBMeta),
      );
    } else if (isInserting) {
      context.missing(_entityBMeta);
    }
    if (data.containsKey('cooccurrence_count')) {
      context.handle(
        _cooccurrenceCountMeta,
        cooccurrenceCount.isAcceptableOrUnknown(
          data['cooccurrence_count']!,
          _cooccurrenceCountMeta,
        ),
      );
    }
    if (data.containsKey('message_count')) {
      context.handle(
        _messageCountMeta,
        messageCount.isAcceptableOrUnknown(
          data['message_count']!,
          _messageCountMeta,
        ),
      );
    }
    if (data.containsKey('session_count')) {
      context.handle(
        _sessionCountMeta,
        sessionCount.isAcceptableOrUnknown(
          data['session_count']!,
          _sessionCountMeta,
        ),
      );
    }
    if (data.containsKey('temporal_proximity')) {
      context.handle(
        _temporalProximityMeta,
        temporalProximity.isAcceptableOrUnknown(
          data['temporal_proximity']!,
          _temporalProximityMeta,
        ),
      );
    }
    if (data.containsKey('first_seen')) {
      context.handle(
        _firstSeenMeta,
        firstSeen.isAcceptableOrUnknown(data['first_seen']!, _firstSeenMeta),
      );
    }
    if (data.containsKey('last_seen')) {
      context.handle(
        _lastSeenMeta,
        lastSeen.isAcceptableOrUnknown(data['last_seen']!, _lastSeenMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entityA, entityB};
  @override
  EntityCooccurrence map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntityCooccurrence(
      entityA: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_a'],
      )!,
      entityB: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_b'],
      )!,
      cooccurrenceCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cooccurrence_count'],
      )!,
      messageCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}message_count'],
      )!,
      sessionCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_count'],
      )!,
      temporalProximity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}temporal_proximity'],
      )!,
      firstSeen: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}first_seen'],
      )!,
      lastSeen: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_seen'],
      )!,
    );
  }

  @override
  $EntityCooccurrencesTable createAlias(String alias) {
    return $EntityCooccurrencesTable(attachedDatabase, alias);
  }
}

class EntityCooccurrence extends DataClass
    implements Insertable<EntityCooccurrence> {
  /// First entity ID (sorted alphabetically to ensure consistent pairs)
  final String entityA;

  /// Second entity ID (sorted alphabetically to ensure consistent pairs)
  final String entityB;

  /// Number of times these entities co-occurred in the same message
  final int cooccurrenceCount;

  /// Number of distinct messages where they co-occurred
  final int messageCount;

  /// Number of distinct sessions/conversations where they co-occurred
  final int sessionCount;

  /// Average temporal proximity (seconds between mentions in same session)
  /// Lower values indicate closer temporal relationship
  final double temporalProximity;

  /// When this pair was first observed together
  final DateTime firstSeen;

  /// When this pair was last observed together
  final DateTime lastSeen;
  const EntityCooccurrence({
    required this.entityA,
    required this.entityB,
    required this.cooccurrenceCount,
    required this.messageCount,
    required this.sessionCount,
    required this.temporalProximity,
    required this.firstSeen,
    required this.lastSeen,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entity_a'] = Variable<String>(entityA);
    map['entity_b'] = Variable<String>(entityB);
    map['cooccurrence_count'] = Variable<int>(cooccurrenceCount);
    map['message_count'] = Variable<int>(messageCount);
    map['session_count'] = Variable<int>(sessionCount);
    map['temporal_proximity'] = Variable<double>(temporalProximity);
    map['first_seen'] = Variable<DateTime>(firstSeen);
    map['last_seen'] = Variable<DateTime>(lastSeen);
    return map;
  }

  EntityCooccurrencesCompanion toCompanion(bool nullToAbsent) {
    return EntityCooccurrencesCompanion(
      entityA: Value(entityA),
      entityB: Value(entityB),
      cooccurrenceCount: Value(cooccurrenceCount),
      messageCount: Value(messageCount),
      sessionCount: Value(sessionCount),
      temporalProximity: Value(temporalProximity),
      firstSeen: Value(firstSeen),
      lastSeen: Value(lastSeen),
    );
  }

  factory EntityCooccurrence.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntityCooccurrence(
      entityA: serializer.fromJson<String>(json['entityA']),
      entityB: serializer.fromJson<String>(json['entityB']),
      cooccurrenceCount: serializer.fromJson<int>(json['cooccurrenceCount']),
      messageCount: serializer.fromJson<int>(json['messageCount']),
      sessionCount: serializer.fromJson<int>(json['sessionCount']),
      temporalProximity: serializer.fromJson<double>(json['temporalProximity']),
      firstSeen: serializer.fromJson<DateTime>(json['firstSeen']),
      lastSeen: serializer.fromJson<DateTime>(json['lastSeen']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entityA': serializer.toJson<String>(entityA),
      'entityB': serializer.toJson<String>(entityB),
      'cooccurrenceCount': serializer.toJson<int>(cooccurrenceCount),
      'messageCount': serializer.toJson<int>(messageCount),
      'sessionCount': serializer.toJson<int>(sessionCount),
      'temporalProximity': serializer.toJson<double>(temporalProximity),
      'firstSeen': serializer.toJson<DateTime>(firstSeen),
      'lastSeen': serializer.toJson<DateTime>(lastSeen),
    };
  }

  EntityCooccurrence copyWith({
    String? entityA,
    String? entityB,
    int? cooccurrenceCount,
    int? messageCount,
    int? sessionCount,
    double? temporalProximity,
    DateTime? firstSeen,
    DateTime? lastSeen,
  }) => EntityCooccurrence(
    entityA: entityA ?? this.entityA,
    entityB: entityB ?? this.entityB,
    cooccurrenceCount: cooccurrenceCount ?? this.cooccurrenceCount,
    messageCount: messageCount ?? this.messageCount,
    sessionCount: sessionCount ?? this.sessionCount,
    temporalProximity: temporalProximity ?? this.temporalProximity,
    firstSeen: firstSeen ?? this.firstSeen,
    lastSeen: lastSeen ?? this.lastSeen,
  );
  EntityCooccurrence copyWithCompanion(EntityCooccurrencesCompanion data) {
    return EntityCooccurrence(
      entityA: data.entityA.present ? data.entityA.value : this.entityA,
      entityB: data.entityB.present ? data.entityB.value : this.entityB,
      cooccurrenceCount: data.cooccurrenceCount.present
          ? data.cooccurrenceCount.value
          : this.cooccurrenceCount,
      messageCount: data.messageCount.present
          ? data.messageCount.value
          : this.messageCount,
      sessionCount: data.sessionCount.present
          ? data.sessionCount.value
          : this.sessionCount,
      temporalProximity: data.temporalProximity.present
          ? data.temporalProximity.value
          : this.temporalProximity,
      firstSeen: data.firstSeen.present ? data.firstSeen.value : this.firstSeen,
      lastSeen: data.lastSeen.present ? data.lastSeen.value : this.lastSeen,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntityCooccurrence(')
          ..write('entityA: $entityA, ')
          ..write('entityB: $entityB, ')
          ..write('cooccurrenceCount: $cooccurrenceCount, ')
          ..write('messageCount: $messageCount, ')
          ..write('sessionCount: $sessionCount, ')
          ..write('temporalProximity: $temporalProximity, ')
          ..write('firstSeen: $firstSeen, ')
          ..write('lastSeen: $lastSeen')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    entityA,
    entityB,
    cooccurrenceCount,
    messageCount,
    sessionCount,
    temporalProximity,
    firstSeen,
    lastSeen,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntityCooccurrence &&
          other.entityA == this.entityA &&
          other.entityB == this.entityB &&
          other.cooccurrenceCount == this.cooccurrenceCount &&
          other.messageCount == this.messageCount &&
          other.sessionCount == this.sessionCount &&
          other.temporalProximity == this.temporalProximity &&
          other.firstSeen == this.firstSeen &&
          other.lastSeen == this.lastSeen);
}

class EntityCooccurrencesCompanion extends UpdateCompanion<EntityCooccurrence> {
  final Value<String> entityA;
  final Value<String> entityB;
  final Value<int> cooccurrenceCount;
  final Value<int> messageCount;
  final Value<int> sessionCount;
  final Value<double> temporalProximity;
  final Value<DateTime> firstSeen;
  final Value<DateTime> lastSeen;
  final Value<int> rowid;
  const EntityCooccurrencesCompanion({
    this.entityA = const Value.absent(),
    this.entityB = const Value.absent(),
    this.cooccurrenceCount = const Value.absent(),
    this.messageCount = const Value.absent(),
    this.sessionCount = const Value.absent(),
    this.temporalProximity = const Value.absent(),
    this.firstSeen = const Value.absent(),
    this.lastSeen = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EntityCooccurrencesCompanion.insert({
    required String entityA,
    required String entityB,
    this.cooccurrenceCount = const Value.absent(),
    this.messageCount = const Value.absent(),
    this.sessionCount = const Value.absent(),
    this.temporalProximity = const Value.absent(),
    this.firstSeen = const Value.absent(),
    this.lastSeen = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : entityA = Value(entityA),
       entityB = Value(entityB);
  static Insertable<EntityCooccurrence> custom({
    Expression<String>? entityA,
    Expression<String>? entityB,
    Expression<int>? cooccurrenceCount,
    Expression<int>? messageCount,
    Expression<int>? sessionCount,
    Expression<double>? temporalProximity,
    Expression<DateTime>? firstSeen,
    Expression<DateTime>? lastSeen,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entityA != null) 'entity_a': entityA,
      if (entityB != null) 'entity_b': entityB,
      if (cooccurrenceCount != null) 'cooccurrence_count': cooccurrenceCount,
      if (messageCount != null) 'message_count': messageCount,
      if (sessionCount != null) 'session_count': sessionCount,
      if (temporalProximity != null) 'temporal_proximity': temporalProximity,
      if (firstSeen != null) 'first_seen': firstSeen,
      if (lastSeen != null) 'last_seen': lastSeen,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EntityCooccurrencesCompanion copyWith({
    Value<String>? entityA,
    Value<String>? entityB,
    Value<int>? cooccurrenceCount,
    Value<int>? messageCount,
    Value<int>? sessionCount,
    Value<double>? temporalProximity,
    Value<DateTime>? firstSeen,
    Value<DateTime>? lastSeen,
    Value<int>? rowid,
  }) {
    return EntityCooccurrencesCompanion(
      entityA: entityA ?? this.entityA,
      entityB: entityB ?? this.entityB,
      cooccurrenceCount: cooccurrenceCount ?? this.cooccurrenceCount,
      messageCount: messageCount ?? this.messageCount,
      sessionCount: sessionCount ?? this.sessionCount,
      temporalProximity: temporalProximity ?? this.temporalProximity,
      firstSeen: firstSeen ?? this.firstSeen,
      lastSeen: lastSeen ?? this.lastSeen,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entityA.present) {
      map['entity_a'] = Variable<String>(entityA.value);
    }
    if (entityB.present) {
      map['entity_b'] = Variable<String>(entityB.value);
    }
    if (cooccurrenceCount.present) {
      map['cooccurrence_count'] = Variable<int>(cooccurrenceCount.value);
    }
    if (messageCount.present) {
      map['message_count'] = Variable<int>(messageCount.value);
    }
    if (sessionCount.present) {
      map['session_count'] = Variable<int>(sessionCount.value);
    }
    if (temporalProximity.present) {
      map['temporal_proximity'] = Variable<double>(temporalProximity.value);
    }
    if (firstSeen.present) {
      map['first_seen'] = Variable<DateTime>(firstSeen.value);
    }
    if (lastSeen.present) {
      map['last_seen'] = Variable<DateTime>(lastSeen.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntityCooccurrencesCompanion(')
          ..write('entityA: $entityA, ')
          ..write('entityB: $entityB, ')
          ..write('cooccurrenceCount: $cooccurrenceCount, ')
          ..write('messageCount: $messageCount, ')
          ..write('sessionCount: $sessionCount, ')
          ..write('temporalProximity: $temporalProximity, ')
          ..write('firstSeen: $firstSeen, ')
          ..write('lastSeen: $lastSeen, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TemporalPatternsTable extends TemporalPatterns
    with TableInfo<$TemporalPatternsTable, TemporalPattern> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TemporalPatternsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _patternTypeMeta = const VerificationMeta(
    'patternType',
  );
  @override
  late final GeneratedColumn<String> patternType = GeneratedColumn<String>(
    'pattern_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _patternDataMeta = const VerificationMeta(
    'patternData',
  );
  @override
  late final GeneratedColumn<String> patternData = GeneratedColumn<String>(
    'pattern_data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.5),
  );
  static const VerificationMeta _occurrenceCountMeta = const VerificationMeta(
    'occurrenceCount',
  );
  @override
  late final GeneratedColumn<int> occurrenceCount = GeneratedColumn<int>(
    'occurrence_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _discoveredAtMeta = const VerificationMeta(
    'discoveredAt',
  );
  @override
  late final GeneratedColumn<DateTime> discoveredAt = GeneratedColumn<DateTime>(
    'discovered_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _lastObservedMeta = const VerificationMeta(
    'lastObserved',
  );
  @override
  late final GeneratedColumn<DateTime> lastObserved = GeneratedColumn<DateTime>(
    'last_observed',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityId,
    patternType,
    patternData,
    confidence,
    occurrenceCount,
    discoveredAt,
    lastObserved,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'temporal_patterns';
  @override
  VerificationContext validateIntegrity(
    Insertable<TemporalPattern> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('pattern_type')) {
      context.handle(
        _patternTypeMeta,
        patternType.isAcceptableOrUnknown(
          data['pattern_type']!,
          _patternTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_patternTypeMeta);
    }
    if (data.containsKey('pattern_data')) {
      context.handle(
        _patternDataMeta,
        patternData.isAcceptableOrUnknown(
          data['pattern_data']!,
          _patternDataMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_patternDataMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    }
    if (data.containsKey('occurrence_count')) {
      context.handle(
        _occurrenceCountMeta,
        occurrenceCount.isAcceptableOrUnknown(
          data['occurrence_count']!,
          _occurrenceCountMeta,
        ),
      );
    }
    if (data.containsKey('discovered_at')) {
      context.handle(
        _discoveredAtMeta,
        discoveredAt.isAcceptableOrUnknown(
          data['discovered_at']!,
          _discoveredAtMeta,
        ),
      );
    }
    if (data.containsKey('last_observed')) {
      context.handle(
        _lastObservedMeta,
        lastObserved.isAcceptableOrUnknown(
          data['last_observed']!,
          _lastObservedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TemporalPattern map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TemporalPattern(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      patternType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pattern_type'],
      )!,
      patternData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pattern_data'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      )!,
      occurrenceCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}occurrence_count'],
      )!,
      discoveredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}discovered_at'],
      )!,
      lastObserved: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_observed'],
      )!,
    );
  }

  @override
  $TemporalPatternsTable createAlias(String alias) {
    return $TemporalPatternsTable(attachedDatabase, alias);
  }
}

class TemporalPattern extends DataClass implements Insertable<TemporalPattern> {
  /// Unique pattern ID (UUID)
  final String id;

  /// The entity this pattern is about
  final String entityId;

  /// Type of pattern: 'weekly', 'daily', 'monthly', 'sequence'
  /// - weekly: entity mentioned on specific day(s) of week
  /// - daily: entity mentioned at specific time(s) of day
  /// - monthly: entity mentioned on specific day(s) of month
  /// - sequence: entity often follows/precedes another entity
  final String patternType;

  /// JSON-encoded pattern data
  /// For weekly: {"dayOfWeek": 0, "dayName": "Monday", "avgTime": "18:30"}
  /// For daily: {"hourOfDay": 18, "timeRange": "evening"}
  /// For sequence: {"followsEntity": "uuid", "precedesEntity": "uuid"}
  final String patternData;

  /// Statistical confidence in the pattern (0.0 - 1.0)
  /// Based on chi-squared test or other statistical measure
  final double confidence;

  /// Number of times this pattern was observed
  final int occurrenceCount;

  /// When the pattern was first discovered
  final DateTime discoveredAt;

  /// When the pattern was last observed
  final DateTime lastObserved;
  const TemporalPattern({
    required this.id,
    required this.entityId,
    required this.patternType,
    required this.patternData,
    required this.confidence,
    required this.occurrenceCount,
    required this.discoveredAt,
    required this.lastObserved,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity_id'] = Variable<String>(entityId);
    map['pattern_type'] = Variable<String>(patternType);
    map['pattern_data'] = Variable<String>(patternData);
    map['confidence'] = Variable<double>(confidence);
    map['occurrence_count'] = Variable<int>(occurrenceCount);
    map['discovered_at'] = Variable<DateTime>(discoveredAt);
    map['last_observed'] = Variable<DateTime>(lastObserved);
    return map;
  }

  TemporalPatternsCompanion toCompanion(bool nullToAbsent) {
    return TemporalPatternsCompanion(
      id: Value(id),
      entityId: Value(entityId),
      patternType: Value(patternType),
      patternData: Value(patternData),
      confidence: Value(confidence),
      occurrenceCount: Value(occurrenceCount),
      discoveredAt: Value(discoveredAt),
      lastObserved: Value(lastObserved),
    );
  }

  factory TemporalPattern.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TemporalPattern(
      id: serializer.fromJson<String>(json['id']),
      entityId: serializer.fromJson<String>(json['entityId']),
      patternType: serializer.fromJson<String>(json['patternType']),
      patternData: serializer.fromJson<String>(json['patternData']),
      confidence: serializer.fromJson<double>(json['confidence']),
      occurrenceCount: serializer.fromJson<int>(json['occurrenceCount']),
      discoveredAt: serializer.fromJson<DateTime>(json['discoveredAt']),
      lastObserved: serializer.fromJson<DateTime>(json['lastObserved']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityId': serializer.toJson<String>(entityId),
      'patternType': serializer.toJson<String>(patternType),
      'patternData': serializer.toJson<String>(patternData),
      'confidence': serializer.toJson<double>(confidence),
      'occurrenceCount': serializer.toJson<int>(occurrenceCount),
      'discoveredAt': serializer.toJson<DateTime>(discoveredAt),
      'lastObserved': serializer.toJson<DateTime>(lastObserved),
    };
  }

  TemporalPattern copyWith({
    String? id,
    String? entityId,
    String? patternType,
    String? patternData,
    double? confidence,
    int? occurrenceCount,
    DateTime? discoveredAt,
    DateTime? lastObserved,
  }) => TemporalPattern(
    id: id ?? this.id,
    entityId: entityId ?? this.entityId,
    patternType: patternType ?? this.patternType,
    patternData: patternData ?? this.patternData,
    confidence: confidence ?? this.confidence,
    occurrenceCount: occurrenceCount ?? this.occurrenceCount,
    discoveredAt: discoveredAt ?? this.discoveredAt,
    lastObserved: lastObserved ?? this.lastObserved,
  );
  TemporalPattern copyWithCompanion(TemporalPatternsCompanion data) {
    return TemporalPattern(
      id: data.id.present ? data.id.value : this.id,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      patternType: data.patternType.present
          ? data.patternType.value
          : this.patternType,
      patternData: data.patternData.present
          ? data.patternData.value
          : this.patternData,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      occurrenceCount: data.occurrenceCount.present
          ? data.occurrenceCount.value
          : this.occurrenceCount,
      discoveredAt: data.discoveredAt.present
          ? data.discoveredAt.value
          : this.discoveredAt,
      lastObserved: data.lastObserved.present
          ? data.lastObserved.value
          : this.lastObserved,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TemporalPattern(')
          ..write('id: $id, ')
          ..write('entityId: $entityId, ')
          ..write('patternType: $patternType, ')
          ..write('patternData: $patternData, ')
          ..write('confidence: $confidence, ')
          ..write('occurrenceCount: $occurrenceCount, ')
          ..write('discoveredAt: $discoveredAt, ')
          ..write('lastObserved: $lastObserved')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entityId,
    patternType,
    patternData,
    confidence,
    occurrenceCount,
    discoveredAt,
    lastObserved,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TemporalPattern &&
          other.id == this.id &&
          other.entityId == this.entityId &&
          other.patternType == this.patternType &&
          other.patternData == this.patternData &&
          other.confidence == this.confidence &&
          other.occurrenceCount == this.occurrenceCount &&
          other.discoveredAt == this.discoveredAt &&
          other.lastObserved == this.lastObserved);
}

class TemporalPatternsCompanion extends UpdateCompanion<TemporalPattern> {
  final Value<String> id;
  final Value<String> entityId;
  final Value<String> patternType;
  final Value<String> patternData;
  final Value<double> confidence;
  final Value<int> occurrenceCount;
  final Value<DateTime> discoveredAt;
  final Value<DateTime> lastObserved;
  final Value<int> rowid;
  const TemporalPatternsCompanion({
    this.id = const Value.absent(),
    this.entityId = const Value.absent(),
    this.patternType = const Value.absent(),
    this.patternData = const Value.absent(),
    this.confidence = const Value.absent(),
    this.occurrenceCount = const Value.absent(),
    this.discoveredAt = const Value.absent(),
    this.lastObserved = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TemporalPatternsCompanion.insert({
    required String id,
    required String entityId,
    required String patternType,
    required String patternData,
    this.confidence = const Value.absent(),
    this.occurrenceCount = const Value.absent(),
    this.discoveredAt = const Value.absent(),
    this.lastObserved = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       entityId = Value(entityId),
       patternType = Value(patternType),
       patternData = Value(patternData);
  static Insertable<TemporalPattern> custom({
    Expression<String>? id,
    Expression<String>? entityId,
    Expression<String>? patternType,
    Expression<String>? patternData,
    Expression<double>? confidence,
    Expression<int>? occurrenceCount,
    Expression<DateTime>? discoveredAt,
    Expression<DateTime>? lastObserved,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityId != null) 'entity_id': entityId,
      if (patternType != null) 'pattern_type': patternType,
      if (patternData != null) 'pattern_data': patternData,
      if (confidence != null) 'confidence': confidence,
      if (occurrenceCount != null) 'occurrence_count': occurrenceCount,
      if (discoveredAt != null) 'discovered_at': discoveredAt,
      if (lastObserved != null) 'last_observed': lastObserved,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TemporalPatternsCompanion copyWith({
    Value<String>? id,
    Value<String>? entityId,
    Value<String>? patternType,
    Value<String>? patternData,
    Value<double>? confidence,
    Value<int>? occurrenceCount,
    Value<DateTime>? discoveredAt,
    Value<DateTime>? lastObserved,
    Value<int>? rowid,
  }) {
    return TemporalPatternsCompanion(
      id: id ?? this.id,
      entityId: entityId ?? this.entityId,
      patternType: patternType ?? this.patternType,
      patternData: patternData ?? this.patternData,
      confidence: confidence ?? this.confidence,
      occurrenceCount: occurrenceCount ?? this.occurrenceCount,
      discoveredAt: discoveredAt ?? this.discoveredAt,
      lastObserved: lastObserved ?? this.lastObserved,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (patternType.present) {
      map['pattern_type'] = Variable<String>(patternType.value);
    }
    if (patternData.present) {
      map['pattern_data'] = Variable<String>(patternData.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (occurrenceCount.present) {
      map['occurrence_count'] = Variable<int>(occurrenceCount.value);
    }
    if (discoveredAt.present) {
      map['discovered_at'] = Variable<DateTime>(discoveredAt.value);
    }
    if (lastObserved.present) {
      map['last_observed'] = Variable<DateTime>(lastObserved.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TemporalPatternsCompanion(')
          ..write('id: $id, ')
          ..write('entityId: $entityId, ')
          ..write('patternType: $patternType, ')
          ..write('patternData: $patternData, ')
          ..write('confidence: $confidence, ')
          ..write('occurrenceCount: $occurrenceCount, ')
          ..write('discoveredAt: $discoveredAt, ')
          ..write('lastObserved: $lastObserved, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $ConversationsTable conversations = $ConversationsTable(this);
  late final $MessagesTable messages = $MessagesTable(this);
  late final $MemoryNodesTable memoryNodes = $MemoryNodesTable(this);
  late final $MemoryEdgesTable memoryEdges = $MemoryEdgesTable(this);
  late final $ConnectionsTable connections = $ConnectionsTable(this);
  late final $InsightsTable insights = $InsightsTable(this);
  late final $EntityCooccurrencesTable entityCooccurrences =
      $EntityCooccurrencesTable(this);
  late final $TemporalPatternsTable temporalPatterns = $TemporalPatternsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    users,
    profiles,
    conversations,
    messages,
    memoryNodes,
    memoryEdges,
    connections,
    insights,
    entityCooccurrences,
    temporalPatterns,
  ];
}

typedef $$UsersTableCreateCompanionBuilder =
    UsersCompanion Function({
      required String id,
      required String email,
      Value<String?> name,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$UsersTableUpdateCompanionBuilder =
    UsersCompanion Function({
      Value<String> id,
      Value<String> email,
      Value<String?> name,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$UsersTableReferences
    extends BaseReferences<_$AppDatabase, $UsersTable, User> {
  $$UsersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ProfilesTable, List<Profile>> _profilesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.profiles,
    aliasName: $_aliasNameGenerator(db.users.id, db.profiles.userId),
  );

  $$ProfilesTableProcessedTableManager get profilesRefs {
    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_profilesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> profilesRefs(
    Expression<bool> Function($$ProfilesTableFilterComposer f) f,
  ) {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> profilesRefs<T extends Object>(
    Expression<T> Function($$ProfilesTableAnnotationComposer a) f,
  ) {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTable,
          User,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (User, $$UsersTableReferences),
          User,
          PrefetchHooks Function({bool profilesRefs})
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                email: email,
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String email,
                Value<String?> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion.insert(
                id: id,
                email: email,
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$UsersTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({profilesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (profilesRefs) db.profiles],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (profilesRefs)
                    await $_getPrefetchedData<User, $UsersTable, Profile>(
                      currentTable: table,
                      referencedTable: $$UsersTableReferences
                          ._profilesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$UsersTableReferences(db, table, p0).profilesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.userId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTable,
      User,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (User, $$UsersTableReferences),
      User,
      PrefetchHooks Function({bool profilesRefs})
    >;
typedef $$ProfilesTableCreateCompanionBuilder =
    ProfilesCompanion Function({
      required String id,
      required String userId,
      Value<String?> displayName,
      Value<String> preferredAiProvider,
      Value<String?> preferredModel,
      Value<String> timezone,
      Value<String?> personalityTraits,
      Value<String?> preferences,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$ProfilesTableUpdateCompanionBuilder =
    ProfilesCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String?> displayName,
      Value<String> preferredAiProvider,
      Value<String?> preferredModel,
      Value<String> timezone,
      Value<String?> personalityTraits,
      Value<String?> preferences,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$ProfilesTableReferences
    extends BaseReferences<_$AppDatabase, $ProfilesTable, Profile> {
  $$ProfilesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _userIdTable(_$AppDatabase db) => db.users.createAlias(
    $_aliasNameGenerator(db.profiles.userId, db.users.id),
  );

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get preferredAiProvider => $composableBuilder(
    column: $table.preferredAiProvider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get preferredModel => $composableBuilder(
    column: $table.preferredModel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get personalityTraits => $composableBuilder(
    column: $table.personalityTraits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get preferences => $composableBuilder(
    column: $table.preferences,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get preferredAiProvider => $composableBuilder(
    column: $table.preferredAiProvider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get preferredModel => $composableBuilder(
    column: $table.preferredModel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get personalityTraits => $composableBuilder(
    column: $table.personalityTraits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get preferences => $composableBuilder(
    column: $table.preferences,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get preferredAiProvider => $composableBuilder(
    column: $table.preferredAiProvider,
    builder: (column) => column,
  );

  GeneratedColumn<String> get preferredModel => $composableBuilder(
    column: $table.preferredModel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get timezone =>
      $composableBuilder(column: $table.timezone, builder: (column) => column);

  GeneratedColumn<String> get personalityTraits => $composableBuilder(
    column: $table.personalityTraits,
    builder: (column) => column,
  );

  GeneratedColumn<String> get preferences => $composableBuilder(
    column: $table.preferences,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfilesTable,
          Profile,
          $$ProfilesTableFilterComposer,
          $$ProfilesTableOrderingComposer,
          $$ProfilesTableAnnotationComposer,
          $$ProfilesTableCreateCompanionBuilder,
          $$ProfilesTableUpdateCompanionBuilder,
          (Profile, $$ProfilesTableReferences),
          Profile,
          PrefetchHooks Function({bool userId})
        > {
  $$ProfilesTableTableManager(_$AppDatabase db, $ProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<String> preferredAiProvider = const Value.absent(),
                Value<String?> preferredModel = const Value.absent(),
                Value<String> timezone = const Value.absent(),
                Value<String?> personalityTraits = const Value.absent(),
                Value<String?> preferences = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfilesCompanion(
                id: id,
                userId: userId,
                displayName: displayName,
                preferredAiProvider: preferredAiProvider,
                preferredModel: preferredModel,
                timezone: timezone,
                personalityTraits: personalityTraits,
                preferences: preferences,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                Value<String?> displayName = const Value.absent(),
                Value<String> preferredAiProvider = const Value.absent(),
                Value<String?> preferredModel = const Value.absent(),
                Value<String> timezone = const Value.absent(),
                Value<String?> personalityTraits = const Value.absent(),
                Value<String?> preferences = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfilesCompanion.insert(
                id: id,
                userId: userId,
                displayName: displayName,
                preferredAiProvider: preferredAiProvider,
                preferredModel: preferredModel,
                timezone: timezone,
                personalityTraits: personalityTraits,
                preferences: preferences,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProfilesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (userId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userId,
                                referencedTable: $$ProfilesTableReferences
                                    ._userIdTable(db),
                                referencedColumn: $$ProfilesTableReferences
                                    ._userIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfilesTable,
      Profile,
      $$ProfilesTableFilterComposer,
      $$ProfilesTableOrderingComposer,
      $$ProfilesTableAnnotationComposer,
      $$ProfilesTableCreateCompanionBuilder,
      $$ProfilesTableUpdateCompanionBuilder,
      (Profile, $$ProfilesTableReferences),
      Profile,
      PrefetchHooks Function({bool userId})
    >;
typedef $$ConversationsTableCreateCompanionBuilder =
    ConversationsCompanion Function({
      required String id,
      Value<String?> title,
      Value<String?> summary,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String?> metadata,
      Value<bool> isArchived,
      Value<bool> isPinned,
      Value<int> rowid,
    });
typedef $$ConversationsTableUpdateCompanionBuilder =
    ConversationsCompanion Function({
      Value<String> id,
      Value<String?> title,
      Value<String?> summary,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String?> metadata,
      Value<bool> isArchived,
      Value<bool> isPinned,
      Value<int> rowid,
    });

final class $$ConversationsTableReferences
    extends BaseReferences<_$AppDatabase, $ConversationsTable, Conversation> {
  $$ConversationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$MessagesTable, List<Message>> _messagesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.messages,
    aliasName: $_aliasNameGenerator(
      db.conversations.id,
      db.messages.conversationId,
    ),
  );

  $$MessagesTableProcessedTableManager get messagesRefs {
    final manager = $$MessagesTableTableManager(
      $_db,
      $_db.messages,
    ).filter((f) => f.conversationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_messagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ConversationsTableFilterComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> messagesRefs(
    Expression<bool> Function($$MessagesTableFilterComposer f) f,
  ) {
    final $$MessagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.messages,
      getReferencedColumn: (t) => t.conversationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessagesTableFilterComposer(
            $db: $db,
            $table: $db.messages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ConversationsTableOrderingComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ConversationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPinned =>
      $composableBuilder(column: $table.isPinned, builder: (column) => column);

  Expression<T> messagesRefs<T extends Object>(
    Expression<T> Function($$MessagesTableAnnotationComposer a) f,
  ) {
    final $$MessagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.messages,
      getReferencedColumn: (t) => t.conversationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessagesTableAnnotationComposer(
            $db: $db,
            $table: $db.messages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ConversationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConversationsTable,
          Conversation,
          $$ConversationsTableFilterComposer,
          $$ConversationsTableOrderingComposer,
          $$ConversationsTableAnnotationComposer,
          $$ConversationsTableCreateCompanionBuilder,
          $$ConversationsTableUpdateCompanionBuilder,
          (Conversation, $$ConversationsTableReferences),
          Conversation,
          PrefetchHooks Function({bool messagesRefs})
        > {
  $$ConversationsTableTableManager(_$AppDatabase db, $ConversationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConversationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConversationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConversationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> summary = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> metadata = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<bool> isPinned = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConversationsCompanion(
                id: id,
                title: title,
                summary: summary,
                createdAt: createdAt,
                updatedAt: updatedAt,
                metadata: metadata,
                isArchived: isArchived,
                isPinned: isPinned,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> title = const Value.absent(),
                Value<String?> summary = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> metadata = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<bool> isPinned = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConversationsCompanion.insert(
                id: id,
                title: title,
                summary: summary,
                createdAt: createdAt,
                updatedAt: updatedAt,
                metadata: metadata,
                isArchived: isArchived,
                isPinned: isPinned,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ConversationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({messagesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (messagesRefs) db.messages],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (messagesRefs)
                    await $_getPrefetchedData<
                      Conversation,
                      $ConversationsTable,
                      Message
                    >(
                      currentTable: table,
                      referencedTable: $$ConversationsTableReferences
                          ._messagesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ConversationsTableReferences(
                            db,
                            table,
                            p0,
                          ).messagesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.conversationId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ConversationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConversationsTable,
      Conversation,
      $$ConversationsTableFilterComposer,
      $$ConversationsTableOrderingComposer,
      $$ConversationsTableAnnotationComposer,
      $$ConversationsTableCreateCompanionBuilder,
      $$ConversationsTableUpdateCompanionBuilder,
      (Conversation, $$ConversationsTableReferences),
      Conversation,
      PrefetchHooks Function({bool messagesRefs})
    >;
typedef $$MessagesTableCreateCompanionBuilder =
    MessagesCompanion Function({
      required String id,
      required String conversationId,
      required String role,
      required String content,
      Value<DateTime> createdAt,
      Value<String?> metadata,
      Value<bool> memoriesExtracted,
      Value<int?> vectorId,
      Value<int> rowid,
    });
typedef $$MessagesTableUpdateCompanionBuilder =
    MessagesCompanion Function({
      Value<String> id,
      Value<String> conversationId,
      Value<String> role,
      Value<String> content,
      Value<DateTime> createdAt,
      Value<String?> metadata,
      Value<bool> memoriesExtracted,
      Value<int?> vectorId,
      Value<int> rowid,
    });

final class $$MessagesTableReferences
    extends BaseReferences<_$AppDatabase, $MessagesTable, Message> {
  $$MessagesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ConversationsTable _conversationIdTable(_$AppDatabase db) =>
      db.conversations.createAlias(
        $_aliasNameGenerator(db.messages.conversationId, db.conversations.id),
      );

  $$ConversationsTableProcessedTableManager get conversationId {
    final $_column = $_itemColumn<String>('conversation_id')!;

    final manager = $$ConversationsTableTableManager(
      $_db,
      $_db.conversations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_conversationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MessagesTableFilterComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get memoriesExtracted => $composableBuilder(
    column: $table.memoriesExtracted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get vectorId => $composableBuilder(
    column: $table.vectorId,
    builder: (column) => ColumnFilters(column),
  );

  $$ConversationsTableFilterComposer get conversationId {
    final $$ConversationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.conversationId,
      referencedTable: $db.conversations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConversationsTableFilterComposer(
            $db: $db,
            $table: $db.conversations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get memoriesExtracted => $composableBuilder(
    column: $table.memoriesExtracted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get vectorId => $composableBuilder(
    column: $table.vectorId,
    builder: (column) => ColumnOrderings(column),
  );

  $$ConversationsTableOrderingComposer get conversationId {
    final $$ConversationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.conversationId,
      referencedTable: $db.conversations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConversationsTableOrderingComposer(
            $db: $db,
            $table: $db.conversations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);

  GeneratedColumn<bool> get memoriesExtracted => $composableBuilder(
    column: $table.memoriesExtracted,
    builder: (column) => column,
  );

  GeneratedColumn<int> get vectorId =>
      $composableBuilder(column: $table.vectorId, builder: (column) => column);

  $$ConversationsTableAnnotationComposer get conversationId {
    final $$ConversationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.conversationId,
      referencedTable: $db.conversations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConversationsTableAnnotationComposer(
            $db: $db,
            $table: $db.conversations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MessagesTable,
          Message,
          $$MessagesTableFilterComposer,
          $$MessagesTableOrderingComposer,
          $$MessagesTableAnnotationComposer,
          $$MessagesTableCreateCompanionBuilder,
          $$MessagesTableUpdateCompanionBuilder,
          (Message, $$MessagesTableReferences),
          Message,
          PrefetchHooks Function({bool conversationId})
        > {
  $$MessagesTableTableManager(_$AppDatabase db, $MessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> conversationId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> metadata = const Value.absent(),
                Value<bool> memoriesExtracted = const Value.absent(),
                Value<int?> vectorId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessagesCompanion(
                id: id,
                conversationId: conversationId,
                role: role,
                content: content,
                createdAt: createdAt,
                metadata: metadata,
                memoriesExtracted: memoriesExtracted,
                vectorId: vectorId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String conversationId,
                required String role,
                required String content,
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> metadata = const Value.absent(),
                Value<bool> memoriesExtracted = const Value.absent(),
                Value<int?> vectorId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessagesCompanion.insert(
                id: id,
                conversationId: conversationId,
                role: role,
                content: content,
                createdAt: createdAt,
                metadata: metadata,
                memoriesExtracted: memoriesExtracted,
                vectorId: vectorId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MessagesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({conversationId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (conversationId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.conversationId,
                                referencedTable: $$MessagesTableReferences
                                    ._conversationIdTable(db),
                                referencedColumn: $$MessagesTableReferences
                                    ._conversationIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MessagesTable,
      Message,
      $$MessagesTableFilterComposer,
      $$MessagesTableOrderingComposer,
      $$MessagesTableAnnotationComposer,
      $$MessagesTableCreateCompanionBuilder,
      $$MessagesTableUpdateCompanionBuilder,
      (Message, $$MessagesTableReferences),
      Message,
      PrefetchHooks Function({bool conversationId})
    >;
typedef $$MemoryNodesTableCreateCompanionBuilder =
    MemoryNodesCompanion Function({
      required String id,
      required String nodeType,
      required String name,
      Value<String?> source,
      Value<String?> sourceId,
      Value<String?> attributes,
      Value<double> confidence,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> lastReferenced,
      Value<int?> vectorId,
      Value<int> rowid,
    });
typedef $$MemoryNodesTableUpdateCompanionBuilder =
    MemoryNodesCompanion Function({
      Value<String> id,
      Value<String> nodeType,
      Value<String> name,
      Value<String?> source,
      Value<String?> sourceId,
      Value<String?> attributes,
      Value<double> confidence,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> lastReferenced,
      Value<int?> vectorId,
      Value<int> rowid,
    });

final class $$MemoryNodesTableReferences
    extends BaseReferences<_$AppDatabase, $MemoryNodesTable, MemoryNode> {
  $$MemoryNodesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MemoryEdgesTable, List<MemoryEdge>>
  _outgoingEdgesTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.memoryEdges,
    aliasName: $_aliasNameGenerator(
      db.memoryNodes.id,
      db.memoryEdges.fromNodeId,
    ),
  );

  $$MemoryEdgesTableProcessedTableManager get outgoingEdges {
    final manager = $$MemoryEdgesTableTableManager(
      $_db,
      $_db.memoryEdges,
    ).filter((f) => f.fromNodeId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_outgoingEdgesTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MemoryEdgesTable, List<MemoryEdge>>
  _incomingEdgesTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.memoryEdges,
    aliasName: $_aliasNameGenerator(db.memoryNodes.id, db.memoryEdges.toNodeId),
  );

  $$MemoryEdgesTableProcessedTableManager get incomingEdges {
    final manager = $$MemoryEdgesTableTableManager(
      $_db,
      $_db.memoryEdges,
    ).filter((f) => f.toNodeId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_incomingEdgesTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MemoryNodesTableFilterComposer
    extends Composer<_$AppDatabase, $MemoryNodesTable> {
  $$MemoryNodesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nodeType => $composableBuilder(
    column: $table.nodeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attributes => $composableBuilder(
    column: $table.attributes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastReferenced => $composableBuilder(
    column: $table.lastReferenced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get vectorId => $composableBuilder(
    column: $table.vectorId,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> outgoingEdges(
    Expression<bool> Function($$MemoryEdgesTableFilterComposer f) f,
  ) {
    final $$MemoryEdgesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.memoryEdges,
      getReferencedColumn: (t) => t.fromNodeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryEdgesTableFilterComposer(
            $db: $db,
            $table: $db.memoryEdges,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> incomingEdges(
    Expression<bool> Function($$MemoryEdgesTableFilterComposer f) f,
  ) {
    final $$MemoryEdgesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.memoryEdges,
      getReferencedColumn: (t) => t.toNodeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryEdgesTableFilterComposer(
            $db: $db,
            $table: $db.memoryEdges,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MemoryNodesTableOrderingComposer
    extends Composer<_$AppDatabase, $MemoryNodesTable> {
  $$MemoryNodesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nodeType => $composableBuilder(
    column: $table.nodeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attributes => $composableBuilder(
    column: $table.attributes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastReferenced => $composableBuilder(
    column: $table.lastReferenced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get vectorId => $composableBuilder(
    column: $table.vectorId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MemoryNodesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MemoryNodesTable> {
  $$MemoryNodesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nodeType =>
      $composableBuilder(column: $table.nodeType, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get attributes => $composableBuilder(
    column: $table.attributes,
    builder: (column) => column,
  );

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastReferenced => $composableBuilder(
    column: $table.lastReferenced,
    builder: (column) => column,
  );

  GeneratedColumn<int> get vectorId =>
      $composableBuilder(column: $table.vectorId, builder: (column) => column);

  Expression<T> outgoingEdges<T extends Object>(
    Expression<T> Function($$MemoryEdgesTableAnnotationComposer a) f,
  ) {
    final $$MemoryEdgesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.memoryEdges,
      getReferencedColumn: (t) => t.fromNodeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryEdgesTableAnnotationComposer(
            $db: $db,
            $table: $db.memoryEdges,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> incomingEdges<T extends Object>(
    Expression<T> Function($$MemoryEdgesTableAnnotationComposer a) f,
  ) {
    final $$MemoryEdgesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.memoryEdges,
      getReferencedColumn: (t) => t.toNodeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryEdgesTableAnnotationComposer(
            $db: $db,
            $table: $db.memoryEdges,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MemoryNodesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MemoryNodesTable,
          MemoryNode,
          $$MemoryNodesTableFilterComposer,
          $$MemoryNodesTableOrderingComposer,
          $$MemoryNodesTableAnnotationComposer,
          $$MemoryNodesTableCreateCompanionBuilder,
          $$MemoryNodesTableUpdateCompanionBuilder,
          (MemoryNode, $$MemoryNodesTableReferences),
          MemoryNode,
          PrefetchHooks Function({bool outgoingEdges, bool incomingEdges})
        > {
  $$MemoryNodesTableTableManager(_$AppDatabase db, $MemoryNodesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MemoryNodesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MemoryNodesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MemoryNodesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> nodeType = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> source = const Value.absent(),
                Value<String?> sourceId = const Value.absent(),
                Value<String?> attributes = const Value.absent(),
                Value<double> confidence = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> lastReferenced = const Value.absent(),
                Value<int?> vectorId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MemoryNodesCompanion(
                id: id,
                nodeType: nodeType,
                name: name,
                source: source,
                sourceId: sourceId,
                attributes: attributes,
                confidence: confidence,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastReferenced: lastReferenced,
                vectorId: vectorId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String nodeType,
                required String name,
                Value<String?> source = const Value.absent(),
                Value<String?> sourceId = const Value.absent(),
                Value<String?> attributes = const Value.absent(),
                Value<double> confidence = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> lastReferenced = const Value.absent(),
                Value<int?> vectorId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MemoryNodesCompanion.insert(
                id: id,
                nodeType: nodeType,
                name: name,
                source: source,
                sourceId: sourceId,
                attributes: attributes,
                confidence: confidence,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastReferenced: lastReferenced,
                vectorId: vectorId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MemoryNodesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({outgoingEdges = false, incomingEdges = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (outgoingEdges) db.memoryEdges,
                    if (incomingEdges) db.memoryEdges,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (outgoingEdges)
                        await $_getPrefetchedData<
                          MemoryNode,
                          $MemoryNodesTable,
                          MemoryEdge
                        >(
                          currentTable: table,
                          referencedTable: $$MemoryNodesTableReferences
                              ._outgoingEdgesTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MemoryNodesTableReferences(
                                db,
                                table,
                                p0,
                              ).outgoingEdges,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.fromNodeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (incomingEdges)
                        await $_getPrefetchedData<
                          MemoryNode,
                          $MemoryNodesTable,
                          MemoryEdge
                        >(
                          currentTable: table,
                          referencedTable: $$MemoryNodesTableReferences
                              ._incomingEdgesTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MemoryNodesTableReferences(
                                db,
                                table,
                                p0,
                              ).incomingEdges,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.toNodeId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$MemoryNodesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MemoryNodesTable,
      MemoryNode,
      $$MemoryNodesTableFilterComposer,
      $$MemoryNodesTableOrderingComposer,
      $$MemoryNodesTableAnnotationComposer,
      $$MemoryNodesTableCreateCompanionBuilder,
      $$MemoryNodesTableUpdateCompanionBuilder,
      (MemoryNode, $$MemoryNodesTableReferences),
      MemoryNode,
      PrefetchHooks Function({bool outgoingEdges, bool incomingEdges})
    >;
typedef $$MemoryEdgesTableCreateCompanionBuilder =
    MemoryEdgesCompanion Function({
      required String id,
      required String fromNodeId,
      required String toNodeId,
      required String relationshipType,
      Value<String?> attributes,
      Value<double> confidence,
      Value<int> referenceCount,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> lastReferenced,
      Value<int> rowid,
    });
typedef $$MemoryEdgesTableUpdateCompanionBuilder =
    MemoryEdgesCompanion Function({
      Value<String> id,
      Value<String> fromNodeId,
      Value<String> toNodeId,
      Value<String> relationshipType,
      Value<String?> attributes,
      Value<double> confidence,
      Value<int> referenceCount,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> lastReferenced,
      Value<int> rowid,
    });

final class $$MemoryEdgesTableReferences
    extends BaseReferences<_$AppDatabase, $MemoryEdgesTable, MemoryEdge> {
  $$MemoryEdgesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MemoryNodesTable _fromNodeIdTable(_$AppDatabase db) =>
      db.memoryNodes.createAlias(
        $_aliasNameGenerator(db.memoryEdges.fromNodeId, db.memoryNodes.id),
      );

  $$MemoryNodesTableProcessedTableManager get fromNodeId {
    final $_column = $_itemColumn<String>('from_node_id')!;

    final manager = $$MemoryNodesTableTableManager(
      $_db,
      $_db.memoryNodes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_fromNodeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MemoryNodesTable _toNodeIdTable(_$AppDatabase db) =>
      db.memoryNodes.createAlias(
        $_aliasNameGenerator(db.memoryEdges.toNodeId, db.memoryNodes.id),
      );

  $$MemoryNodesTableProcessedTableManager get toNodeId {
    final $_column = $_itemColumn<String>('to_node_id')!;

    final manager = $$MemoryNodesTableTableManager(
      $_db,
      $_db.memoryNodes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_toNodeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MemoryEdgesTableFilterComposer
    extends Composer<_$AppDatabase, $MemoryEdgesTable> {
  $$MemoryEdgesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relationshipType => $composableBuilder(
    column: $table.relationshipType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attributes => $composableBuilder(
    column: $table.attributes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get referenceCount => $composableBuilder(
    column: $table.referenceCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastReferenced => $composableBuilder(
    column: $table.lastReferenced,
    builder: (column) => ColumnFilters(column),
  );

  $$MemoryNodesTableFilterComposer get fromNodeId {
    final $$MemoryNodesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fromNodeId,
      referencedTable: $db.memoryNodes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryNodesTableFilterComposer(
            $db: $db,
            $table: $db.memoryNodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MemoryNodesTableFilterComposer get toNodeId {
    final $$MemoryNodesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.toNodeId,
      referencedTable: $db.memoryNodes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryNodesTableFilterComposer(
            $db: $db,
            $table: $db.memoryNodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MemoryEdgesTableOrderingComposer
    extends Composer<_$AppDatabase, $MemoryEdgesTable> {
  $$MemoryEdgesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relationshipType => $composableBuilder(
    column: $table.relationshipType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attributes => $composableBuilder(
    column: $table.attributes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get referenceCount => $composableBuilder(
    column: $table.referenceCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastReferenced => $composableBuilder(
    column: $table.lastReferenced,
    builder: (column) => ColumnOrderings(column),
  );

  $$MemoryNodesTableOrderingComposer get fromNodeId {
    final $$MemoryNodesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fromNodeId,
      referencedTable: $db.memoryNodes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryNodesTableOrderingComposer(
            $db: $db,
            $table: $db.memoryNodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MemoryNodesTableOrderingComposer get toNodeId {
    final $$MemoryNodesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.toNodeId,
      referencedTable: $db.memoryNodes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryNodesTableOrderingComposer(
            $db: $db,
            $table: $db.memoryNodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MemoryEdgesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MemoryEdgesTable> {
  $$MemoryEdgesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get relationshipType => $composableBuilder(
    column: $table.relationshipType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get attributes => $composableBuilder(
    column: $table.attributes,
    builder: (column) => column,
  );

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<int> get referenceCount => $composableBuilder(
    column: $table.referenceCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastReferenced => $composableBuilder(
    column: $table.lastReferenced,
    builder: (column) => column,
  );

  $$MemoryNodesTableAnnotationComposer get fromNodeId {
    final $$MemoryNodesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fromNodeId,
      referencedTable: $db.memoryNodes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryNodesTableAnnotationComposer(
            $db: $db,
            $table: $db.memoryNodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MemoryNodesTableAnnotationComposer get toNodeId {
    final $$MemoryNodesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.toNodeId,
      referencedTable: $db.memoryNodes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryNodesTableAnnotationComposer(
            $db: $db,
            $table: $db.memoryNodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MemoryEdgesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MemoryEdgesTable,
          MemoryEdge,
          $$MemoryEdgesTableFilterComposer,
          $$MemoryEdgesTableOrderingComposer,
          $$MemoryEdgesTableAnnotationComposer,
          $$MemoryEdgesTableCreateCompanionBuilder,
          $$MemoryEdgesTableUpdateCompanionBuilder,
          (MemoryEdge, $$MemoryEdgesTableReferences),
          MemoryEdge,
          PrefetchHooks Function({bool fromNodeId, bool toNodeId})
        > {
  $$MemoryEdgesTableTableManager(_$AppDatabase db, $MemoryEdgesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MemoryEdgesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MemoryEdgesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MemoryEdgesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> fromNodeId = const Value.absent(),
                Value<String> toNodeId = const Value.absent(),
                Value<String> relationshipType = const Value.absent(),
                Value<String?> attributes = const Value.absent(),
                Value<double> confidence = const Value.absent(),
                Value<int> referenceCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> lastReferenced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MemoryEdgesCompanion(
                id: id,
                fromNodeId: fromNodeId,
                toNodeId: toNodeId,
                relationshipType: relationshipType,
                attributes: attributes,
                confidence: confidence,
                referenceCount: referenceCount,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastReferenced: lastReferenced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String fromNodeId,
                required String toNodeId,
                required String relationshipType,
                Value<String?> attributes = const Value.absent(),
                Value<double> confidence = const Value.absent(),
                Value<int> referenceCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> lastReferenced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MemoryEdgesCompanion.insert(
                id: id,
                fromNodeId: fromNodeId,
                toNodeId: toNodeId,
                relationshipType: relationshipType,
                attributes: attributes,
                confidence: confidence,
                referenceCount: referenceCount,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastReferenced: lastReferenced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MemoryEdgesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({fromNodeId = false, toNodeId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (fromNodeId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.fromNodeId,
                                referencedTable: $$MemoryEdgesTableReferences
                                    ._fromNodeIdTable(db),
                                referencedColumn: $$MemoryEdgesTableReferences
                                    ._fromNodeIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (toNodeId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.toNodeId,
                                referencedTable: $$MemoryEdgesTableReferences
                                    ._toNodeIdTable(db),
                                referencedColumn: $$MemoryEdgesTableReferences
                                    ._toNodeIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MemoryEdgesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MemoryEdgesTable,
      MemoryEdge,
      $$MemoryEdgesTableFilterComposer,
      $$MemoryEdgesTableOrderingComposer,
      $$MemoryEdgesTableAnnotationComposer,
      $$MemoryEdgesTableCreateCompanionBuilder,
      $$MemoryEdgesTableUpdateCompanionBuilder,
      (MemoryEdge, $$MemoryEdgesTableReferences),
      MemoryEdge,
      PrefetchHooks Function({bool fromNodeId, bool toNodeId})
    >;
typedef $$ConnectionsTableCreateCompanionBuilder =
    ConnectionsCompanion Function({
      required String provider,
      required String encryptedAccessToken,
      Value<String?> encryptedRefreshToken,
      Value<DateTime?> expiresAt,
      Value<String?> metadata,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> lastSyncedAt,
      Value<int?> lastSyncEntities,
      Value<int?> lastSyncRelationships,
      Value<int> rowid,
    });
typedef $$ConnectionsTableUpdateCompanionBuilder =
    ConnectionsCompanion Function({
      Value<String> provider,
      Value<String> encryptedAccessToken,
      Value<String?> encryptedRefreshToken,
      Value<DateTime?> expiresAt,
      Value<String?> metadata,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> lastSyncedAt,
      Value<int?> lastSyncEntities,
      Value<int?> lastSyncRelationships,
      Value<int> rowid,
    });

class $$ConnectionsTableFilterComposer
    extends Composer<_$AppDatabase, $ConnectionsTable> {
  $$ConnectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get encryptedAccessToken => $composableBuilder(
    column: $table.encryptedAccessToken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get encryptedRefreshToken => $composableBuilder(
    column: $table.encryptedRefreshToken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSyncEntities => $composableBuilder(
    column: $table.lastSyncEntities,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSyncRelationships => $composableBuilder(
    column: $table.lastSyncRelationships,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ConnectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ConnectionsTable> {
  $$ConnectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get encryptedAccessToken => $composableBuilder(
    column: $table.encryptedAccessToken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get encryptedRefreshToken => $composableBuilder(
    column: $table.encryptedRefreshToken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSyncEntities => $composableBuilder(
    column: $table.lastSyncEntities,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSyncRelationships => $composableBuilder(
    column: $table.lastSyncRelationships,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ConnectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConnectionsTable> {
  $$ConnectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<String> get encryptedAccessToken => $composableBuilder(
    column: $table.encryptedAccessToken,
    builder: (column) => column,
  );

  GeneratedColumn<String> get encryptedRefreshToken => $composableBuilder(
    column: $table.encryptedRefreshToken,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  GeneratedColumn<String> get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastSyncEntities => $composableBuilder(
    column: $table.lastSyncEntities,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastSyncRelationships => $composableBuilder(
    column: $table.lastSyncRelationships,
    builder: (column) => column,
  );
}

class $$ConnectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConnectionsTable,
          Connection,
          $$ConnectionsTableFilterComposer,
          $$ConnectionsTableOrderingComposer,
          $$ConnectionsTableAnnotationComposer,
          $$ConnectionsTableCreateCompanionBuilder,
          $$ConnectionsTableUpdateCompanionBuilder,
          (
            Connection,
            BaseReferences<_$AppDatabase, $ConnectionsTable, Connection>,
          ),
          Connection,
          PrefetchHooks Function()
        > {
  $$ConnectionsTableTableManager(_$AppDatabase db, $ConnectionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConnectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConnectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConnectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> provider = const Value.absent(),
                Value<String> encryptedAccessToken = const Value.absent(),
                Value<String?> encryptedRefreshToken = const Value.absent(),
                Value<DateTime?> expiresAt = const Value.absent(),
                Value<String?> metadata = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<int?> lastSyncEntities = const Value.absent(),
                Value<int?> lastSyncRelationships = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConnectionsCompanion(
                provider: provider,
                encryptedAccessToken: encryptedAccessToken,
                encryptedRefreshToken: encryptedRefreshToken,
                expiresAt: expiresAt,
                metadata: metadata,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastSyncedAt: lastSyncedAt,
                lastSyncEntities: lastSyncEntities,
                lastSyncRelationships: lastSyncRelationships,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String provider,
                required String encryptedAccessToken,
                Value<String?> encryptedRefreshToken = const Value.absent(),
                Value<DateTime?> expiresAt = const Value.absent(),
                Value<String?> metadata = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<int?> lastSyncEntities = const Value.absent(),
                Value<int?> lastSyncRelationships = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConnectionsCompanion.insert(
                provider: provider,
                encryptedAccessToken: encryptedAccessToken,
                encryptedRefreshToken: encryptedRefreshToken,
                expiresAt: expiresAt,
                metadata: metadata,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastSyncedAt: lastSyncedAt,
                lastSyncEntities: lastSyncEntities,
                lastSyncRelationships: lastSyncRelationships,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ConnectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConnectionsTable,
      Connection,
      $$ConnectionsTableFilterComposer,
      $$ConnectionsTableOrderingComposer,
      $$ConnectionsTableAnnotationComposer,
      $$ConnectionsTableCreateCompanionBuilder,
      $$ConnectionsTableUpdateCompanionBuilder,
      (
        Connection,
        BaseReferences<_$AppDatabase, $ConnectionsTable, Connection>,
      ),
      Connection,
      PrefetchHooks Function()
    >;
typedef $$InsightsTableCreateCompanionBuilder =
    InsightsCompanion Function({
      required String id,
      required String insightType,
      required String title,
      required String data,
      Value<DateTime> generatedAt,
      Value<DateTime?> expiresAt,
      Value<bool> isViewed,
      Value<bool> isDismissed,
      Value<int> rowid,
    });
typedef $$InsightsTableUpdateCompanionBuilder =
    InsightsCompanion Function({
      Value<String> id,
      Value<String> insightType,
      Value<String> title,
      Value<String> data,
      Value<DateTime> generatedAt,
      Value<DateTime?> expiresAt,
      Value<bool> isViewed,
      Value<bool> isDismissed,
      Value<int> rowid,
    });

class $$InsightsTableFilterComposer
    extends Composer<_$AppDatabase, $InsightsTable> {
  $$InsightsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get insightType => $composableBuilder(
    column: $table.insightType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isViewed => $composableBuilder(
    column: $table.isViewed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDismissed => $composableBuilder(
    column: $table.isDismissed,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InsightsTableOrderingComposer
    extends Composer<_$AppDatabase, $InsightsTable> {
  $$InsightsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get insightType => $composableBuilder(
    column: $table.insightType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isViewed => $composableBuilder(
    column: $table.isViewed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDismissed => $composableBuilder(
    column: $table.isDismissed,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InsightsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InsightsTable> {
  $$InsightsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get insightType => $composableBuilder(
    column: $table.insightType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  GeneratedColumn<bool> get isViewed =>
      $composableBuilder(column: $table.isViewed, builder: (column) => column);

  GeneratedColumn<bool> get isDismissed => $composableBuilder(
    column: $table.isDismissed,
    builder: (column) => column,
  );
}

class $$InsightsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InsightsTable,
          Insight,
          $$InsightsTableFilterComposer,
          $$InsightsTableOrderingComposer,
          $$InsightsTableAnnotationComposer,
          $$InsightsTableCreateCompanionBuilder,
          $$InsightsTableUpdateCompanionBuilder,
          (Insight, BaseReferences<_$AppDatabase, $InsightsTable, Insight>),
          Insight,
          PrefetchHooks Function()
        > {
  $$InsightsTableTableManager(_$AppDatabase db, $InsightsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InsightsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InsightsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InsightsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> insightType = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> data = const Value.absent(),
                Value<DateTime> generatedAt = const Value.absent(),
                Value<DateTime?> expiresAt = const Value.absent(),
                Value<bool> isViewed = const Value.absent(),
                Value<bool> isDismissed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InsightsCompanion(
                id: id,
                insightType: insightType,
                title: title,
                data: data,
                generatedAt: generatedAt,
                expiresAt: expiresAt,
                isViewed: isViewed,
                isDismissed: isDismissed,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String insightType,
                required String title,
                required String data,
                Value<DateTime> generatedAt = const Value.absent(),
                Value<DateTime?> expiresAt = const Value.absent(),
                Value<bool> isViewed = const Value.absent(),
                Value<bool> isDismissed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InsightsCompanion.insert(
                id: id,
                insightType: insightType,
                title: title,
                data: data,
                generatedAt: generatedAt,
                expiresAt: expiresAt,
                isViewed: isViewed,
                isDismissed: isDismissed,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InsightsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InsightsTable,
      Insight,
      $$InsightsTableFilterComposer,
      $$InsightsTableOrderingComposer,
      $$InsightsTableAnnotationComposer,
      $$InsightsTableCreateCompanionBuilder,
      $$InsightsTableUpdateCompanionBuilder,
      (Insight, BaseReferences<_$AppDatabase, $InsightsTable, Insight>),
      Insight,
      PrefetchHooks Function()
    >;
typedef $$EntityCooccurrencesTableCreateCompanionBuilder =
    EntityCooccurrencesCompanion Function({
      required String entityA,
      required String entityB,
      Value<int> cooccurrenceCount,
      Value<int> messageCount,
      Value<int> sessionCount,
      Value<double> temporalProximity,
      Value<DateTime> firstSeen,
      Value<DateTime> lastSeen,
      Value<int> rowid,
    });
typedef $$EntityCooccurrencesTableUpdateCompanionBuilder =
    EntityCooccurrencesCompanion Function({
      Value<String> entityA,
      Value<String> entityB,
      Value<int> cooccurrenceCount,
      Value<int> messageCount,
      Value<int> sessionCount,
      Value<double> temporalProximity,
      Value<DateTime> firstSeen,
      Value<DateTime> lastSeen,
      Value<int> rowid,
    });

class $$EntityCooccurrencesTableFilterComposer
    extends Composer<_$AppDatabase, $EntityCooccurrencesTable> {
  $$EntityCooccurrencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entityA => $composableBuilder(
    column: $table.entityA,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityB => $composableBuilder(
    column: $table.entityB,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cooccurrenceCount => $composableBuilder(
    column: $table.cooccurrenceCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get messageCount => $composableBuilder(
    column: $table.messageCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sessionCount => $composableBuilder(
    column: $table.sessionCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get temporalProximity => $composableBuilder(
    column: $table.temporalProximity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get firstSeen => $composableBuilder(
    column: $table.firstSeen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSeen => $composableBuilder(
    column: $table.lastSeen,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EntityCooccurrencesTableOrderingComposer
    extends Composer<_$AppDatabase, $EntityCooccurrencesTable> {
  $$EntityCooccurrencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entityA => $composableBuilder(
    column: $table.entityA,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityB => $composableBuilder(
    column: $table.entityB,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cooccurrenceCount => $composableBuilder(
    column: $table.cooccurrenceCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get messageCount => $composableBuilder(
    column: $table.messageCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sessionCount => $composableBuilder(
    column: $table.sessionCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get temporalProximity => $composableBuilder(
    column: $table.temporalProximity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get firstSeen => $composableBuilder(
    column: $table.firstSeen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSeen => $composableBuilder(
    column: $table.lastSeen,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EntityCooccurrencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EntityCooccurrencesTable> {
  $$EntityCooccurrencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entityA =>
      $composableBuilder(column: $table.entityA, builder: (column) => column);

  GeneratedColumn<String> get entityB =>
      $composableBuilder(column: $table.entityB, builder: (column) => column);

  GeneratedColumn<int> get cooccurrenceCount => $composableBuilder(
    column: $table.cooccurrenceCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get messageCount => $composableBuilder(
    column: $table.messageCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sessionCount => $composableBuilder(
    column: $table.sessionCount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get temporalProximity => $composableBuilder(
    column: $table.temporalProximity,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get firstSeen =>
      $composableBuilder(column: $table.firstSeen, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSeen =>
      $composableBuilder(column: $table.lastSeen, builder: (column) => column);
}

class $$EntityCooccurrencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EntityCooccurrencesTable,
          EntityCooccurrence,
          $$EntityCooccurrencesTableFilterComposer,
          $$EntityCooccurrencesTableOrderingComposer,
          $$EntityCooccurrencesTableAnnotationComposer,
          $$EntityCooccurrencesTableCreateCompanionBuilder,
          $$EntityCooccurrencesTableUpdateCompanionBuilder,
          (
            EntityCooccurrence,
            BaseReferences<
              _$AppDatabase,
              $EntityCooccurrencesTable,
              EntityCooccurrence
            >,
          ),
          EntityCooccurrence,
          PrefetchHooks Function()
        > {
  $$EntityCooccurrencesTableTableManager(
    _$AppDatabase db,
    $EntityCooccurrencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntityCooccurrencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntityCooccurrencesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$EntityCooccurrencesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> entityA = const Value.absent(),
                Value<String> entityB = const Value.absent(),
                Value<int> cooccurrenceCount = const Value.absent(),
                Value<int> messageCount = const Value.absent(),
                Value<int> sessionCount = const Value.absent(),
                Value<double> temporalProximity = const Value.absent(),
                Value<DateTime> firstSeen = const Value.absent(),
                Value<DateTime> lastSeen = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntityCooccurrencesCompanion(
                entityA: entityA,
                entityB: entityB,
                cooccurrenceCount: cooccurrenceCount,
                messageCount: messageCount,
                sessionCount: sessionCount,
                temporalProximity: temporalProximity,
                firstSeen: firstSeen,
                lastSeen: lastSeen,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String entityA,
                required String entityB,
                Value<int> cooccurrenceCount = const Value.absent(),
                Value<int> messageCount = const Value.absent(),
                Value<int> sessionCount = const Value.absent(),
                Value<double> temporalProximity = const Value.absent(),
                Value<DateTime> firstSeen = const Value.absent(),
                Value<DateTime> lastSeen = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntityCooccurrencesCompanion.insert(
                entityA: entityA,
                entityB: entityB,
                cooccurrenceCount: cooccurrenceCount,
                messageCount: messageCount,
                sessionCount: sessionCount,
                temporalProximity: temporalProximity,
                firstSeen: firstSeen,
                lastSeen: lastSeen,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EntityCooccurrencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EntityCooccurrencesTable,
      EntityCooccurrence,
      $$EntityCooccurrencesTableFilterComposer,
      $$EntityCooccurrencesTableOrderingComposer,
      $$EntityCooccurrencesTableAnnotationComposer,
      $$EntityCooccurrencesTableCreateCompanionBuilder,
      $$EntityCooccurrencesTableUpdateCompanionBuilder,
      (
        EntityCooccurrence,
        BaseReferences<
          _$AppDatabase,
          $EntityCooccurrencesTable,
          EntityCooccurrence
        >,
      ),
      EntityCooccurrence,
      PrefetchHooks Function()
    >;
typedef $$TemporalPatternsTableCreateCompanionBuilder =
    TemporalPatternsCompanion Function({
      required String id,
      required String entityId,
      required String patternType,
      required String patternData,
      Value<double> confidence,
      Value<int> occurrenceCount,
      Value<DateTime> discoveredAt,
      Value<DateTime> lastObserved,
      Value<int> rowid,
    });
typedef $$TemporalPatternsTableUpdateCompanionBuilder =
    TemporalPatternsCompanion Function({
      Value<String> id,
      Value<String> entityId,
      Value<String> patternType,
      Value<String> patternData,
      Value<double> confidence,
      Value<int> occurrenceCount,
      Value<DateTime> discoveredAt,
      Value<DateTime> lastObserved,
      Value<int> rowid,
    });

class $$TemporalPatternsTableFilterComposer
    extends Composer<_$AppDatabase, $TemporalPatternsTable> {
  $$TemporalPatternsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get patternType => $composableBuilder(
    column: $table.patternType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get patternData => $composableBuilder(
    column: $table.patternData,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get occurrenceCount => $composableBuilder(
    column: $table.occurrenceCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get discoveredAt => $composableBuilder(
    column: $table.discoveredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastObserved => $composableBuilder(
    column: $table.lastObserved,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TemporalPatternsTableOrderingComposer
    extends Composer<_$AppDatabase, $TemporalPatternsTable> {
  $$TemporalPatternsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get patternType => $composableBuilder(
    column: $table.patternType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get patternData => $composableBuilder(
    column: $table.patternData,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get occurrenceCount => $composableBuilder(
    column: $table.occurrenceCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get discoveredAt => $composableBuilder(
    column: $table.discoveredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastObserved => $composableBuilder(
    column: $table.lastObserved,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TemporalPatternsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TemporalPatternsTable> {
  $$TemporalPatternsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get patternType => $composableBuilder(
    column: $table.patternType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get patternData => $composableBuilder(
    column: $table.patternData,
    builder: (column) => column,
  );

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<int> get occurrenceCount => $composableBuilder(
    column: $table.occurrenceCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get discoveredAt => $composableBuilder(
    column: $table.discoveredAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastObserved => $composableBuilder(
    column: $table.lastObserved,
    builder: (column) => column,
  );
}

class $$TemporalPatternsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TemporalPatternsTable,
          TemporalPattern,
          $$TemporalPatternsTableFilterComposer,
          $$TemporalPatternsTableOrderingComposer,
          $$TemporalPatternsTableAnnotationComposer,
          $$TemporalPatternsTableCreateCompanionBuilder,
          $$TemporalPatternsTableUpdateCompanionBuilder,
          (
            TemporalPattern,
            BaseReferences<
              _$AppDatabase,
              $TemporalPatternsTable,
              TemporalPattern
            >,
          ),
          TemporalPattern,
          PrefetchHooks Function()
        > {
  $$TemporalPatternsTableTableManager(
    _$AppDatabase db,
    $TemporalPatternsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TemporalPatternsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TemporalPatternsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TemporalPatternsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> patternType = const Value.absent(),
                Value<String> patternData = const Value.absent(),
                Value<double> confidence = const Value.absent(),
                Value<int> occurrenceCount = const Value.absent(),
                Value<DateTime> discoveredAt = const Value.absent(),
                Value<DateTime> lastObserved = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TemporalPatternsCompanion(
                id: id,
                entityId: entityId,
                patternType: patternType,
                patternData: patternData,
                confidence: confidence,
                occurrenceCount: occurrenceCount,
                discoveredAt: discoveredAt,
                lastObserved: lastObserved,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String entityId,
                required String patternType,
                required String patternData,
                Value<double> confidence = const Value.absent(),
                Value<int> occurrenceCount = const Value.absent(),
                Value<DateTime> discoveredAt = const Value.absent(),
                Value<DateTime> lastObserved = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TemporalPatternsCompanion.insert(
                id: id,
                entityId: entityId,
                patternType: patternType,
                patternData: patternData,
                confidence: confidence,
                occurrenceCount: occurrenceCount,
                discoveredAt: discoveredAt,
                lastObserved: lastObserved,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TemporalPatternsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TemporalPatternsTable,
      TemporalPattern,
      $$TemporalPatternsTableFilterComposer,
      $$TemporalPatternsTableOrderingComposer,
      $$TemporalPatternsTableAnnotationComposer,
      $$TemporalPatternsTableCreateCompanionBuilder,
      $$TemporalPatternsTableUpdateCompanionBuilder,
      (
        TemporalPattern,
        BaseReferences<_$AppDatabase, $TemporalPatternsTable, TemporalPattern>,
      ),
      TemporalPattern,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$ConversationsTableTableManager get conversations =>
      $$ConversationsTableTableManager(_db, _db.conversations);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db, _db.messages);
  $$MemoryNodesTableTableManager get memoryNodes =>
      $$MemoryNodesTableTableManager(_db, _db.memoryNodes);
  $$MemoryEdgesTableTableManager get memoryEdges =>
      $$MemoryEdgesTableTableManager(_db, _db.memoryEdges);
  $$ConnectionsTableTableManager get connections =>
      $$ConnectionsTableTableManager(_db, _db.connections);
  $$InsightsTableTableManager get insights =>
      $$InsightsTableTableManager(_db, _db.insights);
  $$EntityCooccurrencesTableTableManager get entityCooccurrences =>
      $$EntityCooccurrencesTableTableManager(_db, _db.entityCooccurrences);
  $$TemporalPatternsTableTableManager get temporalPatterns =>
      $$TemporalPatternsTableTableManager(_db, _db.temporalPatterns);
}
