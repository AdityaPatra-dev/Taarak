// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LocalUsersTable extends LocalUsers
    with TableInfo<$LocalUsersTable, LocalUser> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalUsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    email,
    role,
    updatedAt,
    version,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_users';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalUser> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalUser map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalUser(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
    );
  }

  @override
  $LocalUsersTable createAlias(String alias) {
    return $LocalUsersTable(attachedDatabase, alias);
  }
}

class LocalUser extends DataClass implements Insertable<LocalUser> {
  final String id;
  final String name;
  final String email;
  final String role;
  final DateTime updatedAt;
  final int version;
  const LocalUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.updatedAt,
    required this.version,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['email'] = Variable<String>(email);
    map['role'] = Variable<String>(role);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['version'] = Variable<int>(version);
    return map;
  }

  LocalUsersCompanion toCompanion(bool nullToAbsent) {
    return LocalUsersCompanion(
      id: Value(id),
      name: Value(name),
      email: Value(email),
      role: Value(role),
      updatedAt: Value(updatedAt),
      version: Value(version),
    );
  }

  factory LocalUser.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalUser(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      email: serializer.fromJson<String>(json['email']),
      role: serializer.fromJson<String>(json['role']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      version: serializer.fromJson<int>(json['version']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'email': serializer.toJson<String>(email),
      'role': serializer.toJson<String>(role),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'version': serializer.toJson<int>(version),
    };
  }

  LocalUser copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    DateTime? updatedAt,
    int? version,
  }) => LocalUser(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
    role: role ?? this.role,
    updatedAt: updatedAt ?? this.updatedAt,
    version: version ?? this.version,
  );
  LocalUser copyWithCompanion(LocalUsersCompanion data) {
    return LocalUser(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      email: data.email.present ? data.email.value : this.email,
      role: data.role.present ? data.role.value : this.role,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      version: data.version.present ? data.version.value : this.version,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalUser(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('role: $role, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, email, role, updatedAt, version);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalUser &&
          other.id == this.id &&
          other.name == this.name &&
          other.email == this.email &&
          other.role == this.role &&
          other.updatedAt == this.updatedAt &&
          other.version == this.version);
}

class LocalUsersCompanion extends UpdateCompanion<LocalUser> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> email;
  final Value<String> role;
  final Value<DateTime> updatedAt;
  final Value<int> version;
  final Value<int> rowid;
  const LocalUsersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.role = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalUsersCompanion.insert({
    required String id,
    required String name,
    required String email,
    required String role,
    required DateTime updatedAt,
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       email = Value(email),
       role = Value(role),
       updatedAt = Value(updatedAt);
  static Insertable<LocalUser> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? email,
    Expression<String>? role,
    Expression<DateTime>? updatedAt,
    Expression<int>? version,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (role != null) 'role': role,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (version != null) 'version': version,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalUsersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? email,
    Value<String>? role,
    Value<DateTime>? updatedAt,
    Value<int>? version,
    Value<int>? rowid,
  }) {
    return LocalUsersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalUsersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('role: $role, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalHazardZonesTable extends LocalHazardZones
    with TableInfo<$LocalHazardZonesTable, LocalHazardZone> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalHazardZonesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hazardTypeMeta = const VerificationMeta(
    'hazardType',
  );
  @override
  late final GeneratedColumn<String> hazardType = GeneratedColumn<String>(
    'hazard_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _severityMeta = const VerificationMeta(
    'severity',
  );
  @override
  late final GeneratedColumn<String> severity = GeneratedColumn<String>(
    'severity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _geometryJsonMeta = const VerificationMeta(
    'geometryJson',
  );
  @override
  late final GeneratedColumn<String> geometryJson = GeneratedColumn<String>(
    'geometry_json',
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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _observedAtMeta = const VerificationMeta(
    'observedAt',
  );
  @override
  late final GeneratedColumn<DateTime> observedAt = GeneratedColumn<DateTime>(
    'observed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
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
    defaultValue: const Constant(1),
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    hazardType,
    severity,
    geometryJson,
    source,
    observedAt,
    confidence,
    updatedAt,
    version,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_hazard_zones';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalHazardZone> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('hazard_type')) {
      context.handle(
        _hazardTypeMeta,
        hazardType.isAcceptableOrUnknown(data['hazard_type']!, _hazardTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_hazardTypeMeta);
    }
    if (data.containsKey('severity')) {
      context.handle(
        _severityMeta,
        severity.isAcceptableOrUnknown(data['severity']!, _severityMeta),
      );
    } else if (isInserting) {
      context.missing(_severityMeta);
    }
    if (data.containsKey('geometry_json')) {
      context.handle(
        _geometryJsonMeta,
        geometryJson.isAcceptableOrUnknown(
          data['geometry_json']!,
          _geometryJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_geometryJsonMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('observed_at')) {
      context.handle(
        _observedAtMeta,
        observedAt.isAcceptableOrUnknown(data['observed_at']!, _observedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_observedAtMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalHazardZone map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalHazardZone(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      hazardType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hazard_type'],
      )!,
      severity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}severity'],
      )!,
      geometryJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}geometry_json'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      observedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}observed_at'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
    );
  }

  @override
  $LocalHazardZonesTable createAlias(String alias) {
    return $LocalHazardZonesTable(attachedDatabase, alias);
  }
}

class LocalHazardZone extends DataClass implements Insertable<LocalHazardZone> {
  final String id;
  final String hazardType;
  final String severity;
  final String geometryJson;
  final String source;
  final DateTime observedAt;
  final double confidence;
  final DateTime updatedAt;
  final int version;
  const LocalHazardZone({
    required this.id,
    required this.hazardType,
    required this.severity,
    required this.geometryJson,
    required this.source,
    required this.observedAt,
    required this.confidence,
    required this.updatedAt,
    required this.version,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['hazard_type'] = Variable<String>(hazardType);
    map['severity'] = Variable<String>(severity);
    map['geometry_json'] = Variable<String>(geometryJson);
    map['source'] = Variable<String>(source);
    map['observed_at'] = Variable<DateTime>(observedAt);
    map['confidence'] = Variable<double>(confidence);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['version'] = Variable<int>(version);
    return map;
  }

  LocalHazardZonesCompanion toCompanion(bool nullToAbsent) {
    return LocalHazardZonesCompanion(
      id: Value(id),
      hazardType: Value(hazardType),
      severity: Value(severity),
      geometryJson: Value(geometryJson),
      source: Value(source),
      observedAt: Value(observedAt),
      confidence: Value(confidence),
      updatedAt: Value(updatedAt),
      version: Value(version),
    );
  }

  factory LocalHazardZone.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalHazardZone(
      id: serializer.fromJson<String>(json['id']),
      hazardType: serializer.fromJson<String>(json['hazardType']),
      severity: serializer.fromJson<String>(json['severity']),
      geometryJson: serializer.fromJson<String>(json['geometryJson']),
      source: serializer.fromJson<String>(json['source']),
      observedAt: serializer.fromJson<DateTime>(json['observedAt']),
      confidence: serializer.fromJson<double>(json['confidence']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      version: serializer.fromJson<int>(json['version']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'hazardType': serializer.toJson<String>(hazardType),
      'severity': serializer.toJson<String>(severity),
      'geometryJson': serializer.toJson<String>(geometryJson),
      'source': serializer.toJson<String>(source),
      'observedAt': serializer.toJson<DateTime>(observedAt),
      'confidence': serializer.toJson<double>(confidence),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'version': serializer.toJson<int>(version),
    };
  }

  LocalHazardZone copyWith({
    String? id,
    String? hazardType,
    String? severity,
    String? geometryJson,
    String? source,
    DateTime? observedAt,
    double? confidence,
    DateTime? updatedAt,
    int? version,
  }) => LocalHazardZone(
    id: id ?? this.id,
    hazardType: hazardType ?? this.hazardType,
    severity: severity ?? this.severity,
    geometryJson: geometryJson ?? this.geometryJson,
    source: source ?? this.source,
    observedAt: observedAt ?? this.observedAt,
    confidence: confidence ?? this.confidence,
    updatedAt: updatedAt ?? this.updatedAt,
    version: version ?? this.version,
  );
  LocalHazardZone copyWithCompanion(LocalHazardZonesCompanion data) {
    return LocalHazardZone(
      id: data.id.present ? data.id.value : this.id,
      hazardType: data.hazardType.present
          ? data.hazardType.value
          : this.hazardType,
      severity: data.severity.present ? data.severity.value : this.severity,
      geometryJson: data.geometryJson.present
          ? data.geometryJson.value
          : this.geometryJson,
      source: data.source.present ? data.source.value : this.source,
      observedAt: data.observedAt.present
          ? data.observedAt.value
          : this.observedAt,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      version: data.version.present ? data.version.value : this.version,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalHazardZone(')
          ..write('id: $id, ')
          ..write('hazardType: $hazardType, ')
          ..write('severity: $severity, ')
          ..write('geometryJson: $geometryJson, ')
          ..write('source: $source, ')
          ..write('observedAt: $observedAt, ')
          ..write('confidence: $confidence, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    hazardType,
    severity,
    geometryJson,
    source,
    observedAt,
    confidence,
    updatedAt,
    version,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalHazardZone &&
          other.id == this.id &&
          other.hazardType == this.hazardType &&
          other.severity == this.severity &&
          other.geometryJson == this.geometryJson &&
          other.source == this.source &&
          other.observedAt == this.observedAt &&
          other.confidence == this.confidence &&
          other.updatedAt == this.updatedAt &&
          other.version == this.version);
}

class LocalHazardZonesCompanion extends UpdateCompanion<LocalHazardZone> {
  final Value<String> id;
  final Value<String> hazardType;
  final Value<String> severity;
  final Value<String> geometryJson;
  final Value<String> source;
  final Value<DateTime> observedAt;
  final Value<double> confidence;
  final Value<DateTime> updatedAt;
  final Value<int> version;
  final Value<int> rowid;
  const LocalHazardZonesCompanion({
    this.id = const Value.absent(),
    this.hazardType = const Value.absent(),
    this.severity = const Value.absent(),
    this.geometryJson = const Value.absent(),
    this.source = const Value.absent(),
    this.observedAt = const Value.absent(),
    this.confidence = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalHazardZonesCompanion.insert({
    required String id,
    required String hazardType,
    required String severity,
    required String geometryJson,
    required String source,
    required DateTime observedAt,
    this.confidence = const Value.absent(),
    required DateTime updatedAt,
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       hazardType = Value(hazardType),
       severity = Value(severity),
       geometryJson = Value(geometryJson),
       source = Value(source),
       observedAt = Value(observedAt),
       updatedAt = Value(updatedAt);
  static Insertable<LocalHazardZone> custom({
    Expression<String>? id,
    Expression<String>? hazardType,
    Expression<String>? severity,
    Expression<String>? geometryJson,
    Expression<String>? source,
    Expression<DateTime>? observedAt,
    Expression<double>? confidence,
    Expression<DateTime>? updatedAt,
    Expression<int>? version,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (hazardType != null) 'hazard_type': hazardType,
      if (severity != null) 'severity': severity,
      if (geometryJson != null) 'geometry_json': geometryJson,
      if (source != null) 'source': source,
      if (observedAt != null) 'observed_at': observedAt,
      if (confidence != null) 'confidence': confidence,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (version != null) 'version': version,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalHazardZonesCompanion copyWith({
    Value<String>? id,
    Value<String>? hazardType,
    Value<String>? severity,
    Value<String>? geometryJson,
    Value<String>? source,
    Value<DateTime>? observedAt,
    Value<double>? confidence,
    Value<DateTime>? updatedAt,
    Value<int>? version,
    Value<int>? rowid,
  }) {
    return LocalHazardZonesCompanion(
      id: id ?? this.id,
      hazardType: hazardType ?? this.hazardType,
      severity: severity ?? this.severity,
      geometryJson: geometryJson ?? this.geometryJson,
      source: source ?? this.source,
      observedAt: observedAt ?? this.observedAt,
      confidence: confidence ?? this.confidence,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (hazardType.present) {
      map['hazard_type'] = Variable<String>(hazardType.value);
    }
    if (severity.present) {
      map['severity'] = Variable<String>(severity.value);
    }
    if (geometryJson.present) {
      map['geometry_json'] = Variable<String>(geometryJson.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (observedAt.present) {
      map['observed_at'] = Variable<DateTime>(observedAt.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalHazardZonesCompanion(')
          ..write('id: $id, ')
          ..write('hazardType: $hazardType, ')
          ..write('severity: $severity, ')
          ..write('geometryJson: $geometryJson, ')
          ..write('source: $source, ')
          ..write('observedAt: $observedAt, ')
          ..write('confidence: $confidence, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalIncidentsTable extends LocalIncidents
    with TableInfo<$LocalIncidentsTable, LocalIncident> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalIncidentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _severityMeta = const VerificationMeta(
    'severity',
  );
  @override
  late final GeneratedColumn<String> severity = GeneratedColumn<String>(
    'severity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('unknown'),
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
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    status,
    latitude,
    longitude,
    description,
    severity,
    createdAt,
    updatedAt,
    version,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_incidents';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalIncident> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('severity')) {
      context.handle(
        _severityMeta,
        severity.isAcceptableOrUnknown(data['severity']!, _severityMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalIncident map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalIncident(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      severity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}severity'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  $LocalIncidentsTable createAlias(String alias) {
    return $LocalIncidentsTable(attachedDatabase, alias);
  }
}

class LocalIncident extends DataClass implements Insertable<LocalIncident> {
  final String id;
  final String type;
  final String status;
  final double latitude;
  final double longitude;
  final String description;
  final String severity;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;
  final bool isSynced;
  const LocalIncident({
    required this.id,
    required this.type,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.severity,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['status'] = Variable<String>(status);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['description'] = Variable<String>(description);
    map['severity'] = Variable<String>(severity);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['version'] = Variable<int>(version);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  LocalIncidentsCompanion toCompanion(bool nullToAbsent) {
    return LocalIncidentsCompanion(
      id: Value(id),
      type: Value(type),
      status: Value(status),
      latitude: Value(latitude),
      longitude: Value(longitude),
      description: Value(description),
      severity: Value(severity),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      version: Value(version),
      isSynced: Value(isSynced),
    );
  }

  factory LocalIncident.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalIncident(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      status: serializer.fromJson<String>(json['status']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      description: serializer.fromJson<String>(json['description']),
      severity: serializer.fromJson<String>(json['severity']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      version: serializer.fromJson<int>(json['version']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'status': serializer.toJson<String>(status),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'description': serializer.toJson<String>(description),
      'severity': serializer.toJson<String>(severity),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'version': serializer.toJson<int>(version),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  LocalIncident copyWith({
    String? id,
    String? type,
    String? status,
    double? latitude,
    double? longitude,
    String? description,
    String? severity,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
    bool? isSynced,
  }) => LocalIncident(
    id: id ?? this.id,
    type: type ?? this.type,
    status: status ?? this.status,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    description: description ?? this.description,
    severity: severity ?? this.severity,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    version: version ?? this.version,
    isSynced: isSynced ?? this.isSynced,
  );
  LocalIncident copyWithCompanion(LocalIncidentsCompanion data) {
    return LocalIncident(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      status: data.status.present ? data.status.value : this.status,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      description: data.description.present
          ? data.description.value
          : this.description,
      severity: data.severity.present ? data.severity.value : this.severity,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      version: data.version.present ? data.version.value : this.version,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalIncident(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('description: $description, ')
          ..write('severity: $severity, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    status,
    latitude,
    longitude,
    description,
    severity,
    createdAt,
    updatedAt,
    version,
    isSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalIncident &&
          other.id == this.id &&
          other.type == this.type &&
          other.status == this.status &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.description == this.description &&
          other.severity == this.severity &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.version == this.version &&
          other.isSynced == this.isSynced);
}

class LocalIncidentsCompanion extends UpdateCompanion<LocalIncident> {
  final Value<String> id;
  final Value<String> type;
  final Value<String> status;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<String> description;
  final Value<String> severity;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> version;
  final Value<bool> isSynced;
  final Value<int> rowid;
  const LocalIncidentsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.status = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.description = const Value.absent(),
    this.severity = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalIncidentsCompanion.insert({
    required String id,
    required String type,
    required String status,
    required double latitude,
    required double longitude,
    this.description = const Value.absent(),
    this.severity = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.version = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       status = Value(status),
       latitude = Value(latitude),
       longitude = Value(longitude),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LocalIncident> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? status,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? description,
    Expression<String>? severity,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? version,
    Expression<bool>? isSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (status != null) 'status': status,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (description != null) 'description': description,
      if (severity != null) 'severity': severity,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (version != null) 'version': version,
      if (isSynced != null) 'is_synced': isSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalIncidentsCompanion copyWith({
    Value<String>? id,
    Value<String>? type,
    Value<String>? status,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<String>? description,
    Value<String>? severity,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? version,
    Value<bool>? isSynced,
    Value<int>? rowid,
  }) {
    return LocalIncidentsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      status: status ?? this.status,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      description: description ?? this.description,
      severity: severity ?? this.severity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      isSynced: isSynced ?? this.isSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (severity.present) {
      map['severity'] = Variable<String>(severity.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalIncidentsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('description: $description, ')
          ..write('severity: $severity, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('isSynced: $isSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalIncidentReportsTable extends LocalIncidentReports
    with TableInfo<$LocalIncidentReportsTable, LocalIncidentReport> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalIncidentReportsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _incidentIdMeta = const VerificationMeta(
    'incidentId',
  );
  @override
  late final GeneratedColumn<String> incidentId = GeneratedColumn<String>(
    'incident_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reporterIdMeta = const VerificationMeta(
    'reporterId',
  );
  @override
  late final GeneratedColumn<String> reporterId = GeneratedColumn<String>(
    'reporter_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _severityMeta = const VerificationMeta(
    'severity',
  );
  @override
  late final GeneratedColumn<String> severity = GeneratedColumn<String>(
    'severity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('unknown'),
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
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    incidentId,
    reporterId,
    latitude,
    longitude,
    description,
    severity,
    createdAt,
    updatedAt,
    version,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_incident_reports';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalIncidentReport> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('incident_id')) {
      context.handle(
        _incidentIdMeta,
        incidentId.isAcceptableOrUnknown(data['incident_id']!, _incidentIdMeta),
      );
    }
    if (data.containsKey('reporter_id')) {
      context.handle(
        _reporterIdMeta,
        reporterId.isAcceptableOrUnknown(data['reporter_id']!, _reporterIdMeta),
      );
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('severity')) {
      context.handle(
        _severityMeta,
        severity.isAcceptableOrUnknown(data['severity']!, _severityMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalIncidentReport map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalIncidentReport(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      incidentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}incident_id'],
      ),
      reporterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reporter_id'],
      ),
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      severity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}severity'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  $LocalIncidentReportsTable createAlias(String alias) {
    return $LocalIncidentReportsTable(attachedDatabase, alias);
  }
}

class LocalIncidentReport extends DataClass
    implements Insertable<LocalIncidentReport> {
  final String id;
  final String? incidentId;
  final String? reporterId;
  final double latitude;
  final double longitude;
  final String description;
  final String severity;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;
  final bool isSynced;
  const LocalIncidentReport({
    required this.id,
    this.incidentId,
    this.reporterId,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.severity,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || incidentId != null) {
      map['incident_id'] = Variable<String>(incidentId);
    }
    if (!nullToAbsent || reporterId != null) {
      map['reporter_id'] = Variable<String>(reporterId);
    }
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['description'] = Variable<String>(description);
    map['severity'] = Variable<String>(severity);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['version'] = Variable<int>(version);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  LocalIncidentReportsCompanion toCompanion(bool nullToAbsent) {
    return LocalIncidentReportsCompanion(
      id: Value(id),
      incidentId: incidentId == null && nullToAbsent
          ? const Value.absent()
          : Value(incidentId),
      reporterId: reporterId == null && nullToAbsent
          ? const Value.absent()
          : Value(reporterId),
      latitude: Value(latitude),
      longitude: Value(longitude),
      description: Value(description),
      severity: Value(severity),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      version: Value(version),
      isSynced: Value(isSynced),
    );
  }

  factory LocalIncidentReport.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalIncidentReport(
      id: serializer.fromJson<String>(json['id']),
      incidentId: serializer.fromJson<String?>(json['incidentId']),
      reporterId: serializer.fromJson<String?>(json['reporterId']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      description: serializer.fromJson<String>(json['description']),
      severity: serializer.fromJson<String>(json['severity']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      version: serializer.fromJson<int>(json['version']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'incidentId': serializer.toJson<String?>(incidentId),
      'reporterId': serializer.toJson<String?>(reporterId),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'description': serializer.toJson<String>(description),
      'severity': serializer.toJson<String>(severity),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'version': serializer.toJson<int>(version),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  LocalIncidentReport copyWith({
    String? id,
    Value<String?> incidentId = const Value.absent(),
    Value<String?> reporterId = const Value.absent(),
    double? latitude,
    double? longitude,
    String? description,
    String? severity,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
    bool? isSynced,
  }) => LocalIncidentReport(
    id: id ?? this.id,
    incidentId: incidentId.present ? incidentId.value : this.incidentId,
    reporterId: reporterId.present ? reporterId.value : this.reporterId,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    description: description ?? this.description,
    severity: severity ?? this.severity,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    version: version ?? this.version,
    isSynced: isSynced ?? this.isSynced,
  );
  LocalIncidentReport copyWithCompanion(LocalIncidentReportsCompanion data) {
    return LocalIncidentReport(
      id: data.id.present ? data.id.value : this.id,
      incidentId: data.incidentId.present
          ? data.incidentId.value
          : this.incidentId,
      reporterId: data.reporterId.present
          ? data.reporterId.value
          : this.reporterId,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      description: data.description.present
          ? data.description.value
          : this.description,
      severity: data.severity.present ? data.severity.value : this.severity,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      version: data.version.present ? data.version.value : this.version,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalIncidentReport(')
          ..write('id: $id, ')
          ..write('incidentId: $incidentId, ')
          ..write('reporterId: $reporterId, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('description: $description, ')
          ..write('severity: $severity, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    incidentId,
    reporterId,
    latitude,
    longitude,
    description,
    severity,
    createdAt,
    updatedAt,
    version,
    isSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalIncidentReport &&
          other.id == this.id &&
          other.incidentId == this.incidentId &&
          other.reporterId == this.reporterId &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.description == this.description &&
          other.severity == this.severity &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.version == this.version &&
          other.isSynced == this.isSynced);
}

class LocalIncidentReportsCompanion
    extends UpdateCompanion<LocalIncidentReport> {
  final Value<String> id;
  final Value<String?> incidentId;
  final Value<String?> reporterId;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<String> description;
  final Value<String> severity;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> version;
  final Value<bool> isSynced;
  final Value<int> rowid;
  const LocalIncidentReportsCompanion({
    this.id = const Value.absent(),
    this.incidentId = const Value.absent(),
    this.reporterId = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.description = const Value.absent(),
    this.severity = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalIncidentReportsCompanion.insert({
    required String id,
    this.incidentId = const Value.absent(),
    this.reporterId = const Value.absent(),
    required double latitude,
    required double longitude,
    this.description = const Value.absent(),
    this.severity = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.version = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       latitude = Value(latitude),
       longitude = Value(longitude),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LocalIncidentReport> custom({
    Expression<String>? id,
    Expression<String>? incidentId,
    Expression<String>? reporterId,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? description,
    Expression<String>? severity,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? version,
    Expression<bool>? isSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (incidentId != null) 'incident_id': incidentId,
      if (reporterId != null) 'reporter_id': reporterId,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (description != null) 'description': description,
      if (severity != null) 'severity': severity,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (version != null) 'version': version,
      if (isSynced != null) 'is_synced': isSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalIncidentReportsCompanion copyWith({
    Value<String>? id,
    Value<String?>? incidentId,
    Value<String?>? reporterId,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<String>? description,
    Value<String>? severity,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? version,
    Value<bool>? isSynced,
    Value<int>? rowid,
  }) {
    return LocalIncidentReportsCompanion(
      id: id ?? this.id,
      incidentId: incidentId ?? this.incidentId,
      reporterId: reporterId ?? this.reporterId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      description: description ?? this.description,
      severity: severity ?? this.severity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      isSynced: isSynced ?? this.isSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (incidentId.present) {
      map['incident_id'] = Variable<String>(incidentId.value);
    }
    if (reporterId.present) {
      map['reporter_id'] = Variable<String>(reporterId.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (severity.present) {
      map['severity'] = Variable<String>(severity.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalIncidentReportsCompanion(')
          ..write('id: $id, ')
          ..write('incidentId: $incidentId, ')
          ..write('reporterId: $reporterId, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('description: $description, ')
          ..write('severity: $severity, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('isSynced: $isSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalSheltersTable extends LocalShelters
    with TableInfo<$LocalSheltersTable, LocalShelter> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalSheltersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _capacityTotalMeta = const VerificationMeta(
    'capacityTotal',
  );
  @override
  late final GeneratedColumn<int> capacityTotal = GeneratedColumn<int>(
    'capacity_total',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _occupancyMeta = const VerificationMeta(
    'occupancy',
  );
  @override
  late final GeneratedColumn<int> occupancy = GeneratedColumn<int>(
    'occupancy',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _facilitiesJsonMeta = const VerificationMeta(
    'facilitiesJson',
  );
  @override
  late final GeneratedColumn<String> facilitiesJson = GeneratedColumn<String>(
    'facilities_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _accessQualityMeta = const VerificationMeta(
    'accessQuality',
  );
  @override
  late final GeneratedColumn<double> accessQuality = GeneratedColumn<double>(
    'access_quality',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    latitude,
    longitude,
    capacityTotal,
    occupancy,
    facilitiesJson,
    accessQuality,
    updatedAt,
    version,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_shelters';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalShelter> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('capacity_total')) {
      context.handle(
        _capacityTotalMeta,
        capacityTotal.isAcceptableOrUnknown(
          data['capacity_total']!,
          _capacityTotalMeta,
        ),
      );
    }
    if (data.containsKey('occupancy')) {
      context.handle(
        _occupancyMeta,
        occupancy.isAcceptableOrUnknown(data['occupancy']!, _occupancyMeta),
      );
    }
    if (data.containsKey('facilities_json')) {
      context.handle(
        _facilitiesJsonMeta,
        facilitiesJson.isAcceptableOrUnknown(
          data['facilities_json']!,
          _facilitiesJsonMeta,
        ),
      );
    }
    if (data.containsKey('access_quality')) {
      context.handle(
        _accessQualityMeta,
        accessQuality.isAcceptableOrUnknown(
          data['access_quality']!,
          _accessQualityMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalShelter map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalShelter(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      capacityTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}capacity_total'],
      )!,
      occupancy: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}occupancy'],
      )!,
      facilitiesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}facilities_json'],
      )!,
      accessQuality: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}access_quality'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
    );
  }

  @override
  $LocalSheltersTable createAlias(String alias) {
    return $LocalSheltersTable(attachedDatabase, alias);
  }
}

class LocalShelter extends DataClass implements Insertable<LocalShelter> {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final int capacityTotal;
  final int occupancy;
  final String facilitiesJson;

  /// M10's "access" factor: 0.0 (easy road access) – 1.0 (difficult),
  /// configured the same way as a habitation's indicators (M08) — null
  /// means "not yet surveyed", not "assumed easy".
  final double? accessQuality;
  final DateTime updatedAt;
  final int version;
  const LocalShelter({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.capacityTotal,
    required this.occupancy,
    required this.facilitiesJson,
    this.accessQuality,
    required this.updatedAt,
    required this.version,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['capacity_total'] = Variable<int>(capacityTotal);
    map['occupancy'] = Variable<int>(occupancy);
    map['facilities_json'] = Variable<String>(facilitiesJson);
    if (!nullToAbsent || accessQuality != null) {
      map['access_quality'] = Variable<double>(accessQuality);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['version'] = Variable<int>(version);
    return map;
  }

  LocalSheltersCompanion toCompanion(bool nullToAbsent) {
    return LocalSheltersCompanion(
      id: Value(id),
      name: Value(name),
      latitude: Value(latitude),
      longitude: Value(longitude),
      capacityTotal: Value(capacityTotal),
      occupancy: Value(occupancy),
      facilitiesJson: Value(facilitiesJson),
      accessQuality: accessQuality == null && nullToAbsent
          ? const Value.absent()
          : Value(accessQuality),
      updatedAt: Value(updatedAt),
      version: Value(version),
    );
  }

  factory LocalShelter.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalShelter(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      capacityTotal: serializer.fromJson<int>(json['capacityTotal']),
      occupancy: serializer.fromJson<int>(json['occupancy']),
      facilitiesJson: serializer.fromJson<String>(json['facilitiesJson']),
      accessQuality: serializer.fromJson<double?>(json['accessQuality']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      version: serializer.fromJson<int>(json['version']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'capacityTotal': serializer.toJson<int>(capacityTotal),
      'occupancy': serializer.toJson<int>(occupancy),
      'facilitiesJson': serializer.toJson<String>(facilitiesJson),
      'accessQuality': serializer.toJson<double?>(accessQuality),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'version': serializer.toJson<int>(version),
    };
  }

  LocalShelter copyWith({
    String? id,
    String? name,
    double? latitude,
    double? longitude,
    int? capacityTotal,
    int? occupancy,
    String? facilitiesJson,
    Value<double?> accessQuality = const Value.absent(),
    DateTime? updatedAt,
    int? version,
  }) => LocalShelter(
    id: id ?? this.id,
    name: name ?? this.name,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    capacityTotal: capacityTotal ?? this.capacityTotal,
    occupancy: occupancy ?? this.occupancy,
    facilitiesJson: facilitiesJson ?? this.facilitiesJson,
    accessQuality: accessQuality.present
        ? accessQuality.value
        : this.accessQuality,
    updatedAt: updatedAt ?? this.updatedAt,
    version: version ?? this.version,
  );
  LocalShelter copyWithCompanion(LocalSheltersCompanion data) {
    return LocalShelter(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      capacityTotal: data.capacityTotal.present
          ? data.capacityTotal.value
          : this.capacityTotal,
      occupancy: data.occupancy.present ? data.occupancy.value : this.occupancy,
      facilitiesJson: data.facilitiesJson.present
          ? data.facilitiesJson.value
          : this.facilitiesJson,
      accessQuality: data.accessQuality.present
          ? data.accessQuality.value
          : this.accessQuality,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      version: data.version.present ? data.version.value : this.version,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalShelter(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('capacityTotal: $capacityTotal, ')
          ..write('occupancy: $occupancy, ')
          ..write('facilitiesJson: $facilitiesJson, ')
          ..write('accessQuality: $accessQuality, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    latitude,
    longitude,
    capacityTotal,
    occupancy,
    facilitiesJson,
    accessQuality,
    updatedAt,
    version,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalShelter &&
          other.id == this.id &&
          other.name == this.name &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.capacityTotal == this.capacityTotal &&
          other.occupancy == this.occupancy &&
          other.facilitiesJson == this.facilitiesJson &&
          other.accessQuality == this.accessQuality &&
          other.updatedAt == this.updatedAt &&
          other.version == this.version);
}

class LocalSheltersCompanion extends UpdateCompanion<LocalShelter> {
  final Value<String> id;
  final Value<String> name;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<int> capacityTotal;
  final Value<int> occupancy;
  final Value<String> facilitiesJson;
  final Value<double?> accessQuality;
  final Value<DateTime> updatedAt;
  final Value<int> version;
  final Value<int> rowid;
  const LocalSheltersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.capacityTotal = const Value.absent(),
    this.occupancy = const Value.absent(),
    this.facilitiesJson = const Value.absent(),
    this.accessQuality = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalSheltersCompanion.insert({
    required String id,
    required String name,
    required double latitude,
    required double longitude,
    this.capacityTotal = const Value.absent(),
    this.occupancy = const Value.absent(),
    this.facilitiesJson = const Value.absent(),
    this.accessQuality = const Value.absent(),
    required DateTime updatedAt,
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       latitude = Value(latitude),
       longitude = Value(longitude),
       updatedAt = Value(updatedAt);
  static Insertable<LocalShelter> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<int>? capacityTotal,
    Expression<int>? occupancy,
    Expression<String>? facilitiesJson,
    Expression<double>? accessQuality,
    Expression<DateTime>? updatedAt,
    Expression<int>? version,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (capacityTotal != null) 'capacity_total': capacityTotal,
      if (occupancy != null) 'occupancy': occupancy,
      if (facilitiesJson != null) 'facilities_json': facilitiesJson,
      if (accessQuality != null) 'access_quality': accessQuality,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (version != null) 'version': version,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalSheltersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<int>? capacityTotal,
    Value<int>? occupancy,
    Value<String>? facilitiesJson,
    Value<double?>? accessQuality,
    Value<DateTime>? updatedAt,
    Value<int>? version,
    Value<int>? rowid,
  }) {
    return LocalSheltersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      capacityTotal: capacityTotal ?? this.capacityTotal,
      occupancy: occupancy ?? this.occupancy,
      facilitiesJson: facilitiesJson ?? this.facilitiesJson,
      accessQuality: accessQuality ?? this.accessQuality,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (capacityTotal.present) {
      map['capacity_total'] = Variable<int>(capacityTotal.value);
    }
    if (occupancy.present) {
      map['occupancy'] = Variable<int>(occupancy.value);
    }
    if (facilitiesJson.present) {
      map['facilities_json'] = Variable<String>(facilitiesJson.value);
    }
    if (accessQuality.present) {
      map['access_quality'] = Variable<double>(accessQuality.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalSheltersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('capacityTotal: $capacityTotal, ')
          ..write('occupancy: $occupancy, ')
          ..write('facilitiesJson: $facilitiesJson, ')
          ..write('accessQuality: $accessQuality, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalRoutesTable extends LocalRoutes
    with TableInfo<$LocalRoutesTable, LocalRoute> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalRoutesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originLatMeta = const VerificationMeta(
    'originLat',
  );
  @override
  late final GeneratedColumn<double> originLat = GeneratedColumn<double>(
    'origin_lat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originLngMeta = const VerificationMeta(
    'originLng',
  );
  @override
  late final GeneratedColumn<double> originLng = GeneratedColumn<double>(
    'origin_lng',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _destLatMeta = const VerificationMeta(
    'destLat',
  );
  @override
  late final GeneratedColumn<double> destLat = GeneratedColumn<double>(
    'dest_lat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _destLngMeta = const VerificationMeta(
    'destLng',
  );
  @override
  late final GeneratedColumn<double> destLng = GeneratedColumn<double>(
    'dest_lng',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _polylineJsonMeta = const VerificationMeta(
    'polylineJson',
  );
  @override
  late final GeneratedColumn<String> polylineJson = GeneratedColumn<String>(
    'polyline_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _distanceMetersMeta = const VerificationMeta(
    'distanceMeters',
  );
  @override
  late final GeneratedColumn<double> distanceMeters = GeneratedColumn<double>(
    'distance_meters',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _etaSecondsMeta = const VerificationMeta(
    'etaSeconds',
  );
  @override
  late final GeneratedColumn<int> etaSeconds = GeneratedColumn<int>(
    'eta_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    originLat,
    originLng,
    destLat,
    destLng,
    polylineJson,
    distanceMeters,
    etaSeconds,
    cachedAt,
    version,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_routes';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalRoute> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('origin_lat')) {
      context.handle(
        _originLatMeta,
        originLat.isAcceptableOrUnknown(data['origin_lat']!, _originLatMeta),
      );
    } else if (isInserting) {
      context.missing(_originLatMeta);
    }
    if (data.containsKey('origin_lng')) {
      context.handle(
        _originLngMeta,
        originLng.isAcceptableOrUnknown(data['origin_lng']!, _originLngMeta),
      );
    } else if (isInserting) {
      context.missing(_originLngMeta);
    }
    if (data.containsKey('dest_lat')) {
      context.handle(
        _destLatMeta,
        destLat.isAcceptableOrUnknown(data['dest_lat']!, _destLatMeta),
      );
    } else if (isInserting) {
      context.missing(_destLatMeta);
    }
    if (data.containsKey('dest_lng')) {
      context.handle(
        _destLngMeta,
        destLng.isAcceptableOrUnknown(data['dest_lng']!, _destLngMeta),
      );
    } else if (isInserting) {
      context.missing(_destLngMeta);
    }
    if (data.containsKey('polyline_json')) {
      context.handle(
        _polylineJsonMeta,
        polylineJson.isAcceptableOrUnknown(
          data['polyline_json']!,
          _polylineJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_polylineJsonMeta);
    }
    if (data.containsKey('distance_meters')) {
      context.handle(
        _distanceMetersMeta,
        distanceMeters.isAcceptableOrUnknown(
          data['distance_meters']!,
          _distanceMetersMeta,
        ),
      );
    }
    if (data.containsKey('eta_seconds')) {
      context.handle(
        _etaSecondsMeta,
        etaSeconds.isAcceptableOrUnknown(data['eta_seconds']!, _etaSecondsMeta),
      );
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalRoute map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalRoute(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      originLat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}origin_lat'],
      )!,
      originLng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}origin_lng'],
      )!,
      destLat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}dest_lat'],
      )!,
      destLng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}dest_lng'],
      )!,
      polylineJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}polyline_json'],
      )!,
      distanceMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance_meters'],
      )!,
      etaSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}eta_seconds'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
    );
  }

  @override
  $LocalRoutesTable createAlias(String alias) {
    return $LocalRoutesTable(attachedDatabase, alias);
  }
}

class LocalRoute extends DataClass implements Insertable<LocalRoute> {
  final String id;
  final double originLat;
  final double originLng;
  final double destLat;
  final double destLng;
  final String polylineJson;
  final double distanceMeters;
  final int etaSeconds;
  final DateTime cachedAt;
  final int version;
  const LocalRoute({
    required this.id,
    required this.originLat,
    required this.originLng,
    required this.destLat,
    required this.destLng,
    required this.polylineJson,
    required this.distanceMeters,
    required this.etaSeconds,
    required this.cachedAt,
    required this.version,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['origin_lat'] = Variable<double>(originLat);
    map['origin_lng'] = Variable<double>(originLng);
    map['dest_lat'] = Variable<double>(destLat);
    map['dest_lng'] = Variable<double>(destLng);
    map['polyline_json'] = Variable<String>(polylineJson);
    map['distance_meters'] = Variable<double>(distanceMeters);
    map['eta_seconds'] = Variable<int>(etaSeconds);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    map['version'] = Variable<int>(version);
    return map;
  }

  LocalRoutesCompanion toCompanion(bool nullToAbsent) {
    return LocalRoutesCompanion(
      id: Value(id),
      originLat: Value(originLat),
      originLng: Value(originLng),
      destLat: Value(destLat),
      destLng: Value(destLng),
      polylineJson: Value(polylineJson),
      distanceMeters: Value(distanceMeters),
      etaSeconds: Value(etaSeconds),
      cachedAt: Value(cachedAt),
      version: Value(version),
    );
  }

  factory LocalRoute.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalRoute(
      id: serializer.fromJson<String>(json['id']),
      originLat: serializer.fromJson<double>(json['originLat']),
      originLng: serializer.fromJson<double>(json['originLng']),
      destLat: serializer.fromJson<double>(json['destLat']),
      destLng: serializer.fromJson<double>(json['destLng']),
      polylineJson: serializer.fromJson<String>(json['polylineJson']),
      distanceMeters: serializer.fromJson<double>(json['distanceMeters']),
      etaSeconds: serializer.fromJson<int>(json['etaSeconds']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
      version: serializer.fromJson<int>(json['version']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'originLat': serializer.toJson<double>(originLat),
      'originLng': serializer.toJson<double>(originLng),
      'destLat': serializer.toJson<double>(destLat),
      'destLng': serializer.toJson<double>(destLng),
      'polylineJson': serializer.toJson<String>(polylineJson),
      'distanceMeters': serializer.toJson<double>(distanceMeters),
      'etaSeconds': serializer.toJson<int>(etaSeconds),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
      'version': serializer.toJson<int>(version),
    };
  }

  LocalRoute copyWith({
    String? id,
    double? originLat,
    double? originLng,
    double? destLat,
    double? destLng,
    String? polylineJson,
    double? distanceMeters,
    int? etaSeconds,
    DateTime? cachedAt,
    int? version,
  }) => LocalRoute(
    id: id ?? this.id,
    originLat: originLat ?? this.originLat,
    originLng: originLng ?? this.originLng,
    destLat: destLat ?? this.destLat,
    destLng: destLng ?? this.destLng,
    polylineJson: polylineJson ?? this.polylineJson,
    distanceMeters: distanceMeters ?? this.distanceMeters,
    etaSeconds: etaSeconds ?? this.etaSeconds,
    cachedAt: cachedAt ?? this.cachedAt,
    version: version ?? this.version,
  );
  LocalRoute copyWithCompanion(LocalRoutesCompanion data) {
    return LocalRoute(
      id: data.id.present ? data.id.value : this.id,
      originLat: data.originLat.present ? data.originLat.value : this.originLat,
      originLng: data.originLng.present ? data.originLng.value : this.originLng,
      destLat: data.destLat.present ? data.destLat.value : this.destLat,
      destLng: data.destLng.present ? data.destLng.value : this.destLng,
      polylineJson: data.polylineJson.present
          ? data.polylineJson.value
          : this.polylineJson,
      distanceMeters: data.distanceMeters.present
          ? data.distanceMeters.value
          : this.distanceMeters,
      etaSeconds: data.etaSeconds.present
          ? data.etaSeconds.value
          : this.etaSeconds,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
      version: data.version.present ? data.version.value : this.version,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalRoute(')
          ..write('id: $id, ')
          ..write('originLat: $originLat, ')
          ..write('originLng: $originLng, ')
          ..write('destLat: $destLat, ')
          ..write('destLng: $destLng, ')
          ..write('polylineJson: $polylineJson, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('etaSeconds: $etaSeconds, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    originLat,
    originLng,
    destLat,
    destLng,
    polylineJson,
    distanceMeters,
    etaSeconds,
    cachedAt,
    version,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalRoute &&
          other.id == this.id &&
          other.originLat == this.originLat &&
          other.originLng == this.originLng &&
          other.destLat == this.destLat &&
          other.destLng == this.destLng &&
          other.polylineJson == this.polylineJson &&
          other.distanceMeters == this.distanceMeters &&
          other.etaSeconds == this.etaSeconds &&
          other.cachedAt == this.cachedAt &&
          other.version == this.version);
}

class LocalRoutesCompanion extends UpdateCompanion<LocalRoute> {
  final Value<String> id;
  final Value<double> originLat;
  final Value<double> originLng;
  final Value<double> destLat;
  final Value<double> destLng;
  final Value<String> polylineJson;
  final Value<double> distanceMeters;
  final Value<int> etaSeconds;
  final Value<DateTime> cachedAt;
  final Value<int> version;
  final Value<int> rowid;
  const LocalRoutesCompanion({
    this.id = const Value.absent(),
    this.originLat = const Value.absent(),
    this.originLng = const Value.absent(),
    this.destLat = const Value.absent(),
    this.destLng = const Value.absent(),
    this.polylineJson = const Value.absent(),
    this.distanceMeters = const Value.absent(),
    this.etaSeconds = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalRoutesCompanion.insert({
    required String id,
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    required String polylineJson,
    this.distanceMeters = const Value.absent(),
    this.etaSeconds = const Value.absent(),
    required DateTime cachedAt,
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       originLat = Value(originLat),
       originLng = Value(originLng),
       destLat = Value(destLat),
       destLng = Value(destLng),
       polylineJson = Value(polylineJson),
       cachedAt = Value(cachedAt);
  static Insertable<LocalRoute> custom({
    Expression<String>? id,
    Expression<double>? originLat,
    Expression<double>? originLng,
    Expression<double>? destLat,
    Expression<double>? destLng,
    Expression<String>? polylineJson,
    Expression<double>? distanceMeters,
    Expression<int>? etaSeconds,
    Expression<DateTime>? cachedAt,
    Expression<int>? version,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (originLat != null) 'origin_lat': originLat,
      if (originLng != null) 'origin_lng': originLng,
      if (destLat != null) 'dest_lat': destLat,
      if (destLng != null) 'dest_lng': destLng,
      if (polylineJson != null) 'polyline_json': polylineJson,
      if (distanceMeters != null) 'distance_meters': distanceMeters,
      if (etaSeconds != null) 'eta_seconds': etaSeconds,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (version != null) 'version': version,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalRoutesCompanion copyWith({
    Value<String>? id,
    Value<double>? originLat,
    Value<double>? originLng,
    Value<double>? destLat,
    Value<double>? destLng,
    Value<String>? polylineJson,
    Value<double>? distanceMeters,
    Value<int>? etaSeconds,
    Value<DateTime>? cachedAt,
    Value<int>? version,
    Value<int>? rowid,
  }) {
    return LocalRoutesCompanion(
      id: id ?? this.id,
      originLat: originLat ?? this.originLat,
      originLng: originLng ?? this.originLng,
      destLat: destLat ?? this.destLat,
      destLng: destLng ?? this.destLng,
      polylineJson: polylineJson ?? this.polylineJson,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      etaSeconds: etaSeconds ?? this.etaSeconds,
      cachedAt: cachedAt ?? this.cachedAt,
      version: version ?? this.version,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (originLat.present) {
      map['origin_lat'] = Variable<double>(originLat.value);
    }
    if (originLng.present) {
      map['origin_lng'] = Variable<double>(originLng.value);
    }
    if (destLat.present) {
      map['dest_lat'] = Variable<double>(destLat.value);
    }
    if (destLng.present) {
      map['dest_lng'] = Variable<double>(destLng.value);
    }
    if (polylineJson.present) {
      map['polyline_json'] = Variable<String>(polylineJson.value);
    }
    if (distanceMeters.present) {
      map['distance_meters'] = Variable<double>(distanceMeters.value);
    }
    if (etaSeconds.present) {
      map['eta_seconds'] = Variable<int>(etaSeconds.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalRoutesCompanion(')
          ..write('id: $id, ')
          ..write('originLat: $originLat, ')
          ..write('originLng: $originLng, ')
          ..write('destLat: $destLat, ')
          ..write('destLng: $destLng, ')
          ..write('polylineJson: $polylineJson, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('etaSeconds: $etaSeconds, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('version: $version, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalHabitationsTable extends LocalHabitations
    with TableInfo<$LocalHabitationsTable, LocalHabitation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalHabitationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _populationMeta = const VerificationMeta(
    'population',
  );
  @override
  late final GeneratedColumn<int> population = GeneratedColumn<int>(
    'population',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _administrativeRegionNameMeta =
      const VerificationMeta('administrativeRegionName');
  @override
  late final GeneratedColumn<String> administrativeRegionName =
      GeneratedColumn<String>(
        'administrative_region_name',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _infrastructureQualityMeta =
      const VerificationMeta('infrastructureQuality');
  @override
  late final GeneratedColumn<double> infrastructureQuality =
      GeneratedColumn<double>(
        'infrastructure_quality',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _accessQualityMeta = const VerificationMeta(
    'accessQuality',
  );
  @override
  late final GeneratedColumn<double> accessQuality = GeneratedColumn<double>(
    'access_quality',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    latitude,
    longitude,
    population,
    administrativeRegionName,
    infrastructureQuality,
    accessQuality,
    updatedAt,
    version,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_habitations';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalHabitation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('population')) {
      context.handle(
        _populationMeta,
        population.isAcceptableOrUnknown(data['population']!, _populationMeta),
      );
    }
    if (data.containsKey('administrative_region_name')) {
      context.handle(
        _administrativeRegionNameMeta,
        administrativeRegionName.isAcceptableOrUnknown(
          data['administrative_region_name']!,
          _administrativeRegionNameMeta,
        ),
      );
    }
    if (data.containsKey('infrastructure_quality')) {
      context.handle(
        _infrastructureQualityMeta,
        infrastructureQuality.isAcceptableOrUnknown(
          data['infrastructure_quality']!,
          _infrastructureQualityMeta,
        ),
      );
    }
    if (data.containsKey('access_quality')) {
      context.handle(
        _accessQualityMeta,
        accessQuality.isAcceptableOrUnknown(
          data['access_quality']!,
          _accessQualityMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalHabitation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalHabitation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      population: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}population'],
      )!,
      administrativeRegionName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}administrative_region_name'],
      ),
      infrastructureQuality: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}infrastructure_quality'],
      ),
      accessQuality: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}access_quality'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
    );
  }

  @override
  $LocalHabitationsTable createAlias(String alias) {
    return $LocalHabitationsTable(attachedDatabase, alias);
  }
}

class LocalHabitation extends DataClass implements Insertable<LocalHabitation> {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final int population;
  final String? administrativeRegionName;

  /// M08's "configured indicators": 0.0 (robust/easy) – 1.0
  /// (fragile/remote), set manually by an official once that data-entry
  /// flow exists. Null means "not yet configured" — the vulnerability
  /// engine falls back to a neutral value rather than treating unset data
  /// as either safe or unsafe.
  final double? infrastructureQuality;
  final double? accessQuality;
  final DateTime updatedAt;
  final int version;
  const LocalHabitation({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.population,
    this.administrativeRegionName,
    this.infrastructureQuality,
    this.accessQuality,
    required this.updatedAt,
    required this.version,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['population'] = Variable<int>(population);
    if (!nullToAbsent || administrativeRegionName != null) {
      map['administrative_region_name'] = Variable<String>(
        administrativeRegionName,
      );
    }
    if (!nullToAbsent || infrastructureQuality != null) {
      map['infrastructure_quality'] = Variable<double>(infrastructureQuality);
    }
    if (!nullToAbsent || accessQuality != null) {
      map['access_quality'] = Variable<double>(accessQuality);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['version'] = Variable<int>(version);
    return map;
  }

  LocalHabitationsCompanion toCompanion(bool nullToAbsent) {
    return LocalHabitationsCompanion(
      id: Value(id),
      name: Value(name),
      latitude: Value(latitude),
      longitude: Value(longitude),
      population: Value(population),
      administrativeRegionName: administrativeRegionName == null && nullToAbsent
          ? const Value.absent()
          : Value(administrativeRegionName),
      infrastructureQuality: infrastructureQuality == null && nullToAbsent
          ? const Value.absent()
          : Value(infrastructureQuality),
      accessQuality: accessQuality == null && nullToAbsent
          ? const Value.absent()
          : Value(accessQuality),
      updatedAt: Value(updatedAt),
      version: Value(version),
    );
  }

  factory LocalHabitation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalHabitation(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      population: serializer.fromJson<int>(json['population']),
      administrativeRegionName: serializer.fromJson<String?>(
        json['administrativeRegionName'],
      ),
      infrastructureQuality: serializer.fromJson<double?>(
        json['infrastructureQuality'],
      ),
      accessQuality: serializer.fromJson<double?>(json['accessQuality']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      version: serializer.fromJson<int>(json['version']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'population': serializer.toJson<int>(population),
      'administrativeRegionName': serializer.toJson<String?>(
        administrativeRegionName,
      ),
      'infrastructureQuality': serializer.toJson<double?>(
        infrastructureQuality,
      ),
      'accessQuality': serializer.toJson<double?>(accessQuality),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'version': serializer.toJson<int>(version),
    };
  }

  LocalHabitation copyWith({
    String? id,
    String? name,
    double? latitude,
    double? longitude,
    int? population,
    Value<String?> administrativeRegionName = const Value.absent(),
    Value<double?> infrastructureQuality = const Value.absent(),
    Value<double?> accessQuality = const Value.absent(),
    DateTime? updatedAt,
    int? version,
  }) => LocalHabitation(
    id: id ?? this.id,
    name: name ?? this.name,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    population: population ?? this.population,
    administrativeRegionName: administrativeRegionName.present
        ? administrativeRegionName.value
        : this.administrativeRegionName,
    infrastructureQuality: infrastructureQuality.present
        ? infrastructureQuality.value
        : this.infrastructureQuality,
    accessQuality: accessQuality.present
        ? accessQuality.value
        : this.accessQuality,
    updatedAt: updatedAt ?? this.updatedAt,
    version: version ?? this.version,
  );
  LocalHabitation copyWithCompanion(LocalHabitationsCompanion data) {
    return LocalHabitation(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      population: data.population.present
          ? data.population.value
          : this.population,
      administrativeRegionName: data.administrativeRegionName.present
          ? data.administrativeRegionName.value
          : this.administrativeRegionName,
      infrastructureQuality: data.infrastructureQuality.present
          ? data.infrastructureQuality.value
          : this.infrastructureQuality,
      accessQuality: data.accessQuality.present
          ? data.accessQuality.value
          : this.accessQuality,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      version: data.version.present ? data.version.value : this.version,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalHabitation(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('population: $population, ')
          ..write('administrativeRegionName: $administrativeRegionName, ')
          ..write('infrastructureQuality: $infrastructureQuality, ')
          ..write('accessQuality: $accessQuality, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    latitude,
    longitude,
    population,
    administrativeRegionName,
    infrastructureQuality,
    accessQuality,
    updatedAt,
    version,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalHabitation &&
          other.id == this.id &&
          other.name == this.name &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.population == this.population &&
          other.administrativeRegionName == this.administrativeRegionName &&
          other.infrastructureQuality == this.infrastructureQuality &&
          other.accessQuality == this.accessQuality &&
          other.updatedAt == this.updatedAt &&
          other.version == this.version);
}

class LocalHabitationsCompanion extends UpdateCompanion<LocalHabitation> {
  final Value<String> id;
  final Value<String> name;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<int> population;
  final Value<String?> administrativeRegionName;
  final Value<double?> infrastructureQuality;
  final Value<double?> accessQuality;
  final Value<DateTime> updatedAt;
  final Value<int> version;
  final Value<int> rowid;
  const LocalHabitationsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.population = const Value.absent(),
    this.administrativeRegionName = const Value.absent(),
    this.infrastructureQuality = const Value.absent(),
    this.accessQuality = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalHabitationsCompanion.insert({
    required String id,
    required String name,
    required double latitude,
    required double longitude,
    this.population = const Value.absent(),
    this.administrativeRegionName = const Value.absent(),
    this.infrastructureQuality = const Value.absent(),
    this.accessQuality = const Value.absent(),
    required DateTime updatedAt,
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       latitude = Value(latitude),
       longitude = Value(longitude),
       updatedAt = Value(updatedAt);
  static Insertable<LocalHabitation> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<int>? population,
    Expression<String>? administrativeRegionName,
    Expression<double>? infrastructureQuality,
    Expression<double>? accessQuality,
    Expression<DateTime>? updatedAt,
    Expression<int>? version,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (population != null) 'population': population,
      if (administrativeRegionName != null)
        'administrative_region_name': administrativeRegionName,
      if (infrastructureQuality != null)
        'infrastructure_quality': infrastructureQuality,
      if (accessQuality != null) 'access_quality': accessQuality,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (version != null) 'version': version,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalHabitationsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<int>? population,
    Value<String?>? administrativeRegionName,
    Value<double?>? infrastructureQuality,
    Value<double?>? accessQuality,
    Value<DateTime>? updatedAt,
    Value<int>? version,
    Value<int>? rowid,
  }) {
    return LocalHabitationsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      population: population ?? this.population,
      administrativeRegionName:
          administrativeRegionName ?? this.administrativeRegionName,
      infrastructureQuality:
          infrastructureQuality ?? this.infrastructureQuality,
      accessQuality: accessQuality ?? this.accessQuality,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (population.present) {
      map['population'] = Variable<int>(population.value);
    }
    if (administrativeRegionName.present) {
      map['administrative_region_name'] = Variable<String>(
        administrativeRegionName.value,
      );
    }
    if (infrastructureQuality.present) {
      map['infrastructure_quality'] = Variable<double>(
        infrastructureQuality.value,
      );
    }
    if (accessQuality.present) {
      map['access_quality'] = Variable<double>(accessQuality.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalHabitationsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('population: $population, ')
          ..write('administrativeRegionName: $administrativeRegionName, ')
          ..write('infrastructureQuality: $infrastructureQuality, ')
          ..write('accessQuality: $accessQuality, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalRiskAssessmentsTable extends LocalRiskAssessments
    with TableInfo<$LocalRiskAssessmentsTable, LocalRiskAssessment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalRiskAssessmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _habitationIdMeta = const VerificationMeta(
    'habitationId',
  );
  @override
  late final GeneratedColumn<String> habitationId = GeneratedColumn<String>(
    'habitation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hazardExposureMeta = const VerificationMeta(
    'hazardExposure',
  );
  @override
  late final GeneratedColumn<double> hazardExposure = GeneratedColumn<double>(
    'hazard_exposure',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vulnerabilityIndexMeta =
      const VerificationMeta('vulnerabilityIndex');
  @override
  late final GeneratedColumn<double> vulnerabilityIndex =
      GeneratedColumn<double>(
        'vulnerability_index',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _riskScoreMeta = const VerificationMeta(
    'riskScore',
  );
  @override
  late final GeneratedColumn<double> riskScore = GeneratedColumn<double>(
    'risk_score',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _riskClassMeta = const VerificationMeta(
    'riskClass',
  );
  @override
  late final GeneratedColumn<String> riskClass = GeneratedColumn<String>(
    'risk_class',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelVersionMeta = const VerificationMeta(
    'modelVersion',
  );
  @override
  late final GeneratedColumn<String> modelVersion = GeneratedColumn<String>(
    'model_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contributingHazardZoneIdsJsonMeta =
      const VerificationMeta('contributingHazardZoneIdsJson');
  @override
  late final GeneratedColumn<String> contributingHazardZoneIdsJson =
      GeneratedColumn<String>(
        'contributing_hazard_zone_ids_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _assessedAtMeta = const VerificationMeta(
    'assessedAt',
  );
  @override
  late final GeneratedColumn<DateTime> assessedAt = GeneratedColumn<DateTime>(
    'assessed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    habitationId,
    hazardExposure,
    vulnerabilityIndex,
    riskScore,
    riskClass,
    modelVersion,
    contributingHazardZoneIdsJson,
    assessedAt,
    version,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_risk_assessments';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalRiskAssessment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('habitation_id')) {
      context.handle(
        _habitationIdMeta,
        habitationId.isAcceptableOrUnknown(
          data['habitation_id']!,
          _habitationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_habitationIdMeta);
    }
    if (data.containsKey('hazard_exposure')) {
      context.handle(
        _hazardExposureMeta,
        hazardExposure.isAcceptableOrUnknown(
          data['hazard_exposure']!,
          _hazardExposureMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_hazardExposureMeta);
    }
    if (data.containsKey('vulnerability_index')) {
      context.handle(
        _vulnerabilityIndexMeta,
        vulnerabilityIndex.isAcceptableOrUnknown(
          data['vulnerability_index']!,
          _vulnerabilityIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_vulnerabilityIndexMeta);
    }
    if (data.containsKey('risk_score')) {
      context.handle(
        _riskScoreMeta,
        riskScore.isAcceptableOrUnknown(data['risk_score']!, _riskScoreMeta),
      );
    } else if (isInserting) {
      context.missing(_riskScoreMeta);
    }
    if (data.containsKey('risk_class')) {
      context.handle(
        _riskClassMeta,
        riskClass.isAcceptableOrUnknown(data['risk_class']!, _riskClassMeta),
      );
    } else if (isInserting) {
      context.missing(_riskClassMeta);
    }
    if (data.containsKey('model_version')) {
      context.handle(
        _modelVersionMeta,
        modelVersion.isAcceptableOrUnknown(
          data['model_version']!,
          _modelVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_modelVersionMeta);
    }
    if (data.containsKey('contributing_hazard_zone_ids_json')) {
      context.handle(
        _contributingHazardZoneIdsJsonMeta,
        contributingHazardZoneIdsJson.isAcceptableOrUnknown(
          data['contributing_hazard_zone_ids_json']!,
          _contributingHazardZoneIdsJsonMeta,
        ),
      );
    }
    if (data.containsKey('assessed_at')) {
      context.handle(
        _assessedAtMeta,
        assessedAt.isAcceptableOrUnknown(data['assessed_at']!, _assessedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_assessedAtMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {habitationId};
  @override
  LocalRiskAssessment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalRiskAssessment(
      habitationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}habitation_id'],
      )!,
      hazardExposure: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hazard_exposure'],
      )!,
      vulnerabilityIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}vulnerability_index'],
      )!,
      riskScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}risk_score'],
      )!,
      riskClass: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}risk_class'],
      )!,
      modelVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_version'],
      )!,
      contributingHazardZoneIdsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contributing_hazard_zone_ids_json'],
      )!,
      assessedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}assessed_at'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
    );
  }

  @override
  $LocalRiskAssessmentsTable createAlias(String alias) {
    return $LocalRiskAssessmentsTable(attachedDatabase, alias);
  }
}

class LocalRiskAssessment extends DataClass
    implements Insertable<LocalRiskAssessment> {
  /// Same as the habitation's id — one current assessment per habitation.
  final String habitationId;
  final double hazardExposure;
  final double vulnerabilityIndex;
  final double riskScore;
  final String riskClass;
  final String modelVersion;
  final String contributingHazardZoneIdsJson;
  final DateTime assessedAt;
  final int version;
  const LocalRiskAssessment({
    required this.habitationId,
    required this.hazardExposure,
    required this.vulnerabilityIndex,
    required this.riskScore,
    required this.riskClass,
    required this.modelVersion,
    required this.contributingHazardZoneIdsJson,
    required this.assessedAt,
    required this.version,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['habitation_id'] = Variable<String>(habitationId);
    map['hazard_exposure'] = Variable<double>(hazardExposure);
    map['vulnerability_index'] = Variable<double>(vulnerabilityIndex);
    map['risk_score'] = Variable<double>(riskScore);
    map['risk_class'] = Variable<String>(riskClass);
    map['model_version'] = Variable<String>(modelVersion);
    map['contributing_hazard_zone_ids_json'] = Variable<String>(
      contributingHazardZoneIdsJson,
    );
    map['assessed_at'] = Variable<DateTime>(assessedAt);
    map['version'] = Variable<int>(version);
    return map;
  }

  LocalRiskAssessmentsCompanion toCompanion(bool nullToAbsent) {
    return LocalRiskAssessmentsCompanion(
      habitationId: Value(habitationId),
      hazardExposure: Value(hazardExposure),
      vulnerabilityIndex: Value(vulnerabilityIndex),
      riskScore: Value(riskScore),
      riskClass: Value(riskClass),
      modelVersion: Value(modelVersion),
      contributingHazardZoneIdsJson: Value(contributingHazardZoneIdsJson),
      assessedAt: Value(assessedAt),
      version: Value(version),
    );
  }

  factory LocalRiskAssessment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalRiskAssessment(
      habitationId: serializer.fromJson<String>(json['habitationId']),
      hazardExposure: serializer.fromJson<double>(json['hazardExposure']),
      vulnerabilityIndex: serializer.fromJson<double>(
        json['vulnerabilityIndex'],
      ),
      riskScore: serializer.fromJson<double>(json['riskScore']),
      riskClass: serializer.fromJson<String>(json['riskClass']),
      modelVersion: serializer.fromJson<String>(json['modelVersion']),
      contributingHazardZoneIdsJson: serializer.fromJson<String>(
        json['contributingHazardZoneIdsJson'],
      ),
      assessedAt: serializer.fromJson<DateTime>(json['assessedAt']),
      version: serializer.fromJson<int>(json['version']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'habitationId': serializer.toJson<String>(habitationId),
      'hazardExposure': serializer.toJson<double>(hazardExposure),
      'vulnerabilityIndex': serializer.toJson<double>(vulnerabilityIndex),
      'riskScore': serializer.toJson<double>(riskScore),
      'riskClass': serializer.toJson<String>(riskClass),
      'modelVersion': serializer.toJson<String>(modelVersion),
      'contributingHazardZoneIdsJson': serializer.toJson<String>(
        contributingHazardZoneIdsJson,
      ),
      'assessedAt': serializer.toJson<DateTime>(assessedAt),
      'version': serializer.toJson<int>(version),
    };
  }

  LocalRiskAssessment copyWith({
    String? habitationId,
    double? hazardExposure,
    double? vulnerabilityIndex,
    double? riskScore,
    String? riskClass,
    String? modelVersion,
    String? contributingHazardZoneIdsJson,
    DateTime? assessedAt,
    int? version,
  }) => LocalRiskAssessment(
    habitationId: habitationId ?? this.habitationId,
    hazardExposure: hazardExposure ?? this.hazardExposure,
    vulnerabilityIndex: vulnerabilityIndex ?? this.vulnerabilityIndex,
    riskScore: riskScore ?? this.riskScore,
    riskClass: riskClass ?? this.riskClass,
    modelVersion: modelVersion ?? this.modelVersion,
    contributingHazardZoneIdsJson:
        contributingHazardZoneIdsJson ?? this.contributingHazardZoneIdsJson,
    assessedAt: assessedAt ?? this.assessedAt,
    version: version ?? this.version,
  );
  LocalRiskAssessment copyWithCompanion(LocalRiskAssessmentsCompanion data) {
    return LocalRiskAssessment(
      habitationId: data.habitationId.present
          ? data.habitationId.value
          : this.habitationId,
      hazardExposure: data.hazardExposure.present
          ? data.hazardExposure.value
          : this.hazardExposure,
      vulnerabilityIndex: data.vulnerabilityIndex.present
          ? data.vulnerabilityIndex.value
          : this.vulnerabilityIndex,
      riskScore: data.riskScore.present ? data.riskScore.value : this.riskScore,
      riskClass: data.riskClass.present ? data.riskClass.value : this.riskClass,
      modelVersion: data.modelVersion.present
          ? data.modelVersion.value
          : this.modelVersion,
      contributingHazardZoneIdsJson: data.contributingHazardZoneIdsJson.present
          ? data.contributingHazardZoneIdsJson.value
          : this.contributingHazardZoneIdsJson,
      assessedAt: data.assessedAt.present
          ? data.assessedAt.value
          : this.assessedAt,
      version: data.version.present ? data.version.value : this.version,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalRiskAssessment(')
          ..write('habitationId: $habitationId, ')
          ..write('hazardExposure: $hazardExposure, ')
          ..write('vulnerabilityIndex: $vulnerabilityIndex, ')
          ..write('riskScore: $riskScore, ')
          ..write('riskClass: $riskClass, ')
          ..write('modelVersion: $modelVersion, ')
          ..write(
            'contributingHazardZoneIdsJson: $contributingHazardZoneIdsJson, ',
          )
          ..write('assessedAt: $assessedAt, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    habitationId,
    hazardExposure,
    vulnerabilityIndex,
    riskScore,
    riskClass,
    modelVersion,
    contributingHazardZoneIdsJson,
    assessedAt,
    version,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalRiskAssessment &&
          other.habitationId == this.habitationId &&
          other.hazardExposure == this.hazardExposure &&
          other.vulnerabilityIndex == this.vulnerabilityIndex &&
          other.riskScore == this.riskScore &&
          other.riskClass == this.riskClass &&
          other.modelVersion == this.modelVersion &&
          other.contributingHazardZoneIdsJson ==
              this.contributingHazardZoneIdsJson &&
          other.assessedAt == this.assessedAt &&
          other.version == this.version);
}

class LocalRiskAssessmentsCompanion
    extends UpdateCompanion<LocalRiskAssessment> {
  final Value<String> habitationId;
  final Value<double> hazardExposure;
  final Value<double> vulnerabilityIndex;
  final Value<double> riskScore;
  final Value<String> riskClass;
  final Value<String> modelVersion;
  final Value<String> contributingHazardZoneIdsJson;
  final Value<DateTime> assessedAt;
  final Value<int> version;
  final Value<int> rowid;
  const LocalRiskAssessmentsCompanion({
    this.habitationId = const Value.absent(),
    this.hazardExposure = const Value.absent(),
    this.vulnerabilityIndex = const Value.absent(),
    this.riskScore = const Value.absent(),
    this.riskClass = const Value.absent(),
    this.modelVersion = const Value.absent(),
    this.contributingHazardZoneIdsJson = const Value.absent(),
    this.assessedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalRiskAssessmentsCompanion.insert({
    required String habitationId,
    required double hazardExposure,
    required double vulnerabilityIndex,
    required double riskScore,
    required String riskClass,
    required String modelVersion,
    this.contributingHazardZoneIdsJson = const Value.absent(),
    required DateTime assessedAt,
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : habitationId = Value(habitationId),
       hazardExposure = Value(hazardExposure),
       vulnerabilityIndex = Value(vulnerabilityIndex),
       riskScore = Value(riskScore),
       riskClass = Value(riskClass),
       modelVersion = Value(modelVersion),
       assessedAt = Value(assessedAt);
  static Insertable<LocalRiskAssessment> custom({
    Expression<String>? habitationId,
    Expression<double>? hazardExposure,
    Expression<double>? vulnerabilityIndex,
    Expression<double>? riskScore,
    Expression<String>? riskClass,
    Expression<String>? modelVersion,
    Expression<String>? contributingHazardZoneIdsJson,
    Expression<DateTime>? assessedAt,
    Expression<int>? version,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (habitationId != null) 'habitation_id': habitationId,
      if (hazardExposure != null) 'hazard_exposure': hazardExposure,
      if (vulnerabilityIndex != null) 'vulnerability_index': vulnerabilityIndex,
      if (riskScore != null) 'risk_score': riskScore,
      if (riskClass != null) 'risk_class': riskClass,
      if (modelVersion != null) 'model_version': modelVersion,
      if (contributingHazardZoneIdsJson != null)
        'contributing_hazard_zone_ids_json': contributingHazardZoneIdsJson,
      if (assessedAt != null) 'assessed_at': assessedAt,
      if (version != null) 'version': version,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalRiskAssessmentsCompanion copyWith({
    Value<String>? habitationId,
    Value<double>? hazardExposure,
    Value<double>? vulnerabilityIndex,
    Value<double>? riskScore,
    Value<String>? riskClass,
    Value<String>? modelVersion,
    Value<String>? contributingHazardZoneIdsJson,
    Value<DateTime>? assessedAt,
    Value<int>? version,
    Value<int>? rowid,
  }) {
    return LocalRiskAssessmentsCompanion(
      habitationId: habitationId ?? this.habitationId,
      hazardExposure: hazardExposure ?? this.hazardExposure,
      vulnerabilityIndex: vulnerabilityIndex ?? this.vulnerabilityIndex,
      riskScore: riskScore ?? this.riskScore,
      riskClass: riskClass ?? this.riskClass,
      modelVersion: modelVersion ?? this.modelVersion,
      contributingHazardZoneIdsJson:
          contributingHazardZoneIdsJson ?? this.contributingHazardZoneIdsJson,
      assessedAt: assessedAt ?? this.assessedAt,
      version: version ?? this.version,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (habitationId.present) {
      map['habitation_id'] = Variable<String>(habitationId.value);
    }
    if (hazardExposure.present) {
      map['hazard_exposure'] = Variable<double>(hazardExposure.value);
    }
    if (vulnerabilityIndex.present) {
      map['vulnerability_index'] = Variable<double>(vulnerabilityIndex.value);
    }
    if (riskScore.present) {
      map['risk_score'] = Variable<double>(riskScore.value);
    }
    if (riskClass.present) {
      map['risk_class'] = Variable<String>(riskClass.value);
    }
    if (modelVersion.present) {
      map['model_version'] = Variable<String>(modelVersion.value);
    }
    if (contributingHazardZoneIdsJson.present) {
      map['contributing_hazard_zone_ids_json'] = Variable<String>(
        contributingHazardZoneIdsJson.value,
      );
    }
    if (assessedAt.present) {
      map['assessed_at'] = Variable<DateTime>(assessedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalRiskAssessmentsCompanion(')
          ..write('habitationId: $habitationId, ')
          ..write('hazardExposure: $hazardExposure, ')
          ..write('vulnerabilityIndex: $vulnerabilityIndex, ')
          ..write('riskScore: $riskScore, ')
          ..write('riskClass: $riskClass, ')
          ..write('modelVersion: $modelVersion, ')
          ..write(
            'contributingHazardZoneIdsJson: $contributingHazardZoneIdsJson, ',
          )
          ..write('assessedAt: $assessedAt, ')
          ..write('version: $version, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalVulnerabilityAssessmentsTable extends LocalVulnerabilityAssessments
    with
        TableInfo<
          $LocalVulnerabilityAssessmentsTable,
          LocalVulnerabilityAssessment
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalVulnerabilityAssessmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _habitationIdMeta = const VerificationMeta(
    'habitationId',
  );
  @override
  late final GeneratedColumn<String> habitationId = GeneratedColumn<String>(
    'habitation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vulnerabilityIndexMeta =
      const VerificationMeta('vulnerabilityIndex');
  @override
  late final GeneratedColumn<double> vulnerabilityIndex =
      GeneratedColumn<double>(
        'vulnerability_index',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _factorsJsonMeta = const VerificationMeta(
    'factorsJson',
  );
  @override
  late final GeneratedColumn<String> factorsJson = GeneratedColumn<String>(
    'factors_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelVersionMeta = const VerificationMeta(
    'modelVersion',
  );
  @override
  late final GeneratedColumn<String> modelVersion = GeneratedColumn<String>(
    'model_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _assessedAtMeta = const VerificationMeta(
    'assessedAt',
  );
  @override
  late final GeneratedColumn<DateTime> assessedAt = GeneratedColumn<DateTime>(
    'assessed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    habitationId,
    vulnerabilityIndex,
    factorsJson,
    modelVersion,
    assessedAt,
    version,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_vulnerability_assessments';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalVulnerabilityAssessment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('habitation_id')) {
      context.handle(
        _habitationIdMeta,
        habitationId.isAcceptableOrUnknown(
          data['habitation_id']!,
          _habitationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_habitationIdMeta);
    }
    if (data.containsKey('vulnerability_index')) {
      context.handle(
        _vulnerabilityIndexMeta,
        vulnerabilityIndex.isAcceptableOrUnknown(
          data['vulnerability_index']!,
          _vulnerabilityIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_vulnerabilityIndexMeta);
    }
    if (data.containsKey('factors_json')) {
      context.handle(
        _factorsJsonMeta,
        factorsJson.isAcceptableOrUnknown(
          data['factors_json']!,
          _factorsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_factorsJsonMeta);
    }
    if (data.containsKey('model_version')) {
      context.handle(
        _modelVersionMeta,
        modelVersion.isAcceptableOrUnknown(
          data['model_version']!,
          _modelVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_modelVersionMeta);
    }
    if (data.containsKey('assessed_at')) {
      context.handle(
        _assessedAtMeta,
        assessedAt.isAcceptableOrUnknown(data['assessed_at']!, _assessedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_assessedAtMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {habitationId};
  @override
  LocalVulnerabilityAssessment map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalVulnerabilityAssessment(
      habitationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}habitation_id'],
      )!,
      vulnerabilityIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}vulnerability_index'],
      )!,
      factorsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}factors_json'],
      )!,
      modelVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_version'],
      )!,
      assessedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}assessed_at'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
    );
  }

  @override
  $LocalVulnerabilityAssessmentsTable createAlias(String alias) {
    return $LocalVulnerabilityAssessmentsTable(attachedDatabase, alias);
  }
}

class LocalVulnerabilityAssessment extends DataClass
    implements Insertable<LocalVulnerabilityAssessment> {
  final String habitationId;
  final double vulnerabilityIndex;

  /// JSON list of {key, label, normalizedScore, weight,
  /// weightedContribution} — the "factor-by-factor" breakdown the
  /// acceptance criterion asks for.
  final String factorsJson;
  final String modelVersion;
  final DateTime assessedAt;
  final int version;
  const LocalVulnerabilityAssessment({
    required this.habitationId,
    required this.vulnerabilityIndex,
    required this.factorsJson,
    required this.modelVersion,
    required this.assessedAt,
    required this.version,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['habitation_id'] = Variable<String>(habitationId);
    map['vulnerability_index'] = Variable<double>(vulnerabilityIndex);
    map['factors_json'] = Variable<String>(factorsJson);
    map['model_version'] = Variable<String>(modelVersion);
    map['assessed_at'] = Variable<DateTime>(assessedAt);
    map['version'] = Variable<int>(version);
    return map;
  }

  LocalVulnerabilityAssessmentsCompanion toCompanion(bool nullToAbsent) {
    return LocalVulnerabilityAssessmentsCompanion(
      habitationId: Value(habitationId),
      vulnerabilityIndex: Value(vulnerabilityIndex),
      factorsJson: Value(factorsJson),
      modelVersion: Value(modelVersion),
      assessedAt: Value(assessedAt),
      version: Value(version),
    );
  }

  factory LocalVulnerabilityAssessment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalVulnerabilityAssessment(
      habitationId: serializer.fromJson<String>(json['habitationId']),
      vulnerabilityIndex: serializer.fromJson<double>(
        json['vulnerabilityIndex'],
      ),
      factorsJson: serializer.fromJson<String>(json['factorsJson']),
      modelVersion: serializer.fromJson<String>(json['modelVersion']),
      assessedAt: serializer.fromJson<DateTime>(json['assessedAt']),
      version: serializer.fromJson<int>(json['version']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'habitationId': serializer.toJson<String>(habitationId),
      'vulnerabilityIndex': serializer.toJson<double>(vulnerabilityIndex),
      'factorsJson': serializer.toJson<String>(factorsJson),
      'modelVersion': serializer.toJson<String>(modelVersion),
      'assessedAt': serializer.toJson<DateTime>(assessedAt),
      'version': serializer.toJson<int>(version),
    };
  }

  LocalVulnerabilityAssessment copyWith({
    String? habitationId,
    double? vulnerabilityIndex,
    String? factorsJson,
    String? modelVersion,
    DateTime? assessedAt,
    int? version,
  }) => LocalVulnerabilityAssessment(
    habitationId: habitationId ?? this.habitationId,
    vulnerabilityIndex: vulnerabilityIndex ?? this.vulnerabilityIndex,
    factorsJson: factorsJson ?? this.factorsJson,
    modelVersion: modelVersion ?? this.modelVersion,
    assessedAt: assessedAt ?? this.assessedAt,
    version: version ?? this.version,
  );
  LocalVulnerabilityAssessment copyWithCompanion(
    LocalVulnerabilityAssessmentsCompanion data,
  ) {
    return LocalVulnerabilityAssessment(
      habitationId: data.habitationId.present
          ? data.habitationId.value
          : this.habitationId,
      vulnerabilityIndex: data.vulnerabilityIndex.present
          ? data.vulnerabilityIndex.value
          : this.vulnerabilityIndex,
      factorsJson: data.factorsJson.present
          ? data.factorsJson.value
          : this.factorsJson,
      modelVersion: data.modelVersion.present
          ? data.modelVersion.value
          : this.modelVersion,
      assessedAt: data.assessedAt.present
          ? data.assessedAt.value
          : this.assessedAt,
      version: data.version.present ? data.version.value : this.version,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalVulnerabilityAssessment(')
          ..write('habitationId: $habitationId, ')
          ..write('vulnerabilityIndex: $vulnerabilityIndex, ')
          ..write('factorsJson: $factorsJson, ')
          ..write('modelVersion: $modelVersion, ')
          ..write('assessedAt: $assessedAt, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    habitationId,
    vulnerabilityIndex,
    factorsJson,
    modelVersion,
    assessedAt,
    version,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalVulnerabilityAssessment &&
          other.habitationId == this.habitationId &&
          other.vulnerabilityIndex == this.vulnerabilityIndex &&
          other.factorsJson == this.factorsJson &&
          other.modelVersion == this.modelVersion &&
          other.assessedAt == this.assessedAt &&
          other.version == this.version);
}

class LocalVulnerabilityAssessmentsCompanion
    extends UpdateCompanion<LocalVulnerabilityAssessment> {
  final Value<String> habitationId;
  final Value<double> vulnerabilityIndex;
  final Value<String> factorsJson;
  final Value<String> modelVersion;
  final Value<DateTime> assessedAt;
  final Value<int> version;
  final Value<int> rowid;
  const LocalVulnerabilityAssessmentsCompanion({
    this.habitationId = const Value.absent(),
    this.vulnerabilityIndex = const Value.absent(),
    this.factorsJson = const Value.absent(),
    this.modelVersion = const Value.absent(),
    this.assessedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalVulnerabilityAssessmentsCompanion.insert({
    required String habitationId,
    required double vulnerabilityIndex,
    required String factorsJson,
    required String modelVersion,
    required DateTime assessedAt,
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : habitationId = Value(habitationId),
       vulnerabilityIndex = Value(vulnerabilityIndex),
       factorsJson = Value(factorsJson),
       modelVersion = Value(modelVersion),
       assessedAt = Value(assessedAt);
  static Insertable<LocalVulnerabilityAssessment> custom({
    Expression<String>? habitationId,
    Expression<double>? vulnerabilityIndex,
    Expression<String>? factorsJson,
    Expression<String>? modelVersion,
    Expression<DateTime>? assessedAt,
    Expression<int>? version,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (habitationId != null) 'habitation_id': habitationId,
      if (vulnerabilityIndex != null) 'vulnerability_index': vulnerabilityIndex,
      if (factorsJson != null) 'factors_json': factorsJson,
      if (modelVersion != null) 'model_version': modelVersion,
      if (assessedAt != null) 'assessed_at': assessedAt,
      if (version != null) 'version': version,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalVulnerabilityAssessmentsCompanion copyWith({
    Value<String>? habitationId,
    Value<double>? vulnerabilityIndex,
    Value<String>? factorsJson,
    Value<String>? modelVersion,
    Value<DateTime>? assessedAt,
    Value<int>? version,
    Value<int>? rowid,
  }) {
    return LocalVulnerabilityAssessmentsCompanion(
      habitationId: habitationId ?? this.habitationId,
      vulnerabilityIndex: vulnerabilityIndex ?? this.vulnerabilityIndex,
      factorsJson: factorsJson ?? this.factorsJson,
      modelVersion: modelVersion ?? this.modelVersion,
      assessedAt: assessedAt ?? this.assessedAt,
      version: version ?? this.version,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (habitationId.present) {
      map['habitation_id'] = Variable<String>(habitationId.value);
    }
    if (vulnerabilityIndex.present) {
      map['vulnerability_index'] = Variable<double>(vulnerabilityIndex.value);
    }
    if (factorsJson.present) {
      map['factors_json'] = Variable<String>(factorsJson.value);
    }
    if (modelVersion.present) {
      map['model_version'] = Variable<String>(modelVersion.value);
    }
    if (assessedAt.present) {
      map['assessed_at'] = Variable<DateTime>(assessedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalVulnerabilityAssessmentsCompanion(')
          ..write('habitationId: $habitationId, ')
          ..write('vulnerabilityIndex: $vulnerabilityIndex, ')
          ..write('factorsJson: $factorsJson, ')
          ..write('modelVersion: $modelVersion, ')
          ..write('assessedAt: $assessedAt, ')
          ..write('version: $version, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalCapacityAssessmentsTable extends LocalCapacityAssessments
    with TableInfo<$LocalCapacityAssessmentsTable, LocalCapacityAssessment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalCapacityAssessmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _habitationIdMeta = const VerificationMeta(
    'habitationId',
  );
  @override
  late final GeneratedColumn<String> habitationId = GeneratedColumn<String>(
    'habitation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exposedPopulationMeta = const VerificationMeta(
    'exposedPopulation',
  );
  @override
  late final GeneratedColumn<int> exposedPopulation = GeneratedColumn<int>(
    'exposed_population',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _availableSafeCapacityMeta =
      const VerificationMeta('availableSafeCapacity');
  @override
  late final GeneratedColumn<int> availableSafeCapacity = GeneratedColumn<int>(
    'available_safe_capacity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _capacityGapMeta = const VerificationMeta(
    'capacityGap',
  );
  @override
  late final GeneratedColumn<int> capacityGap = GeneratedColumn<int>(
    'capacity_gap',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hasSufficientCapacityMeta =
      const VerificationMeta('hasSufficientCapacity');
  @override
  late final GeneratedColumn<bool> hasSufficientCapacity =
      GeneratedColumn<bool>(
        'has_sufficient_capacity',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("has_sufficient_capacity" IN (0, 1))',
        ),
      );
  static const VerificationMeta _contributingSheltersJsonMeta =
      const VerificationMeta('contributingSheltersJson');
  @override
  late final GeneratedColumn<String> contributingSheltersJson =
      GeneratedColumn<String>(
        'contributing_shelters_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _accessibleRadiusMetersMeta =
      const VerificationMeta('accessibleRadiusMeters');
  @override
  late final GeneratedColumn<double> accessibleRadiusMeters =
      GeneratedColumn<double>(
        'accessible_radius_meters',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _modelVersionMeta = const VerificationMeta(
    'modelVersion',
  );
  @override
  late final GeneratedColumn<String> modelVersion = GeneratedColumn<String>(
    'model_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _assessedAtMeta = const VerificationMeta(
    'assessedAt',
  );
  @override
  late final GeneratedColumn<DateTime> assessedAt = GeneratedColumn<DateTime>(
    'assessed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    habitationId,
    exposedPopulation,
    availableSafeCapacity,
    capacityGap,
    hasSufficientCapacity,
    contributingSheltersJson,
    accessibleRadiusMeters,
    modelVersion,
    assessedAt,
    version,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_capacity_assessments';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalCapacityAssessment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('habitation_id')) {
      context.handle(
        _habitationIdMeta,
        habitationId.isAcceptableOrUnknown(
          data['habitation_id']!,
          _habitationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_habitationIdMeta);
    }
    if (data.containsKey('exposed_population')) {
      context.handle(
        _exposedPopulationMeta,
        exposedPopulation.isAcceptableOrUnknown(
          data['exposed_population']!,
          _exposedPopulationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_exposedPopulationMeta);
    }
    if (data.containsKey('available_safe_capacity')) {
      context.handle(
        _availableSafeCapacityMeta,
        availableSafeCapacity.isAcceptableOrUnknown(
          data['available_safe_capacity']!,
          _availableSafeCapacityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_availableSafeCapacityMeta);
    }
    if (data.containsKey('capacity_gap')) {
      context.handle(
        _capacityGapMeta,
        capacityGap.isAcceptableOrUnknown(
          data['capacity_gap']!,
          _capacityGapMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_capacityGapMeta);
    }
    if (data.containsKey('has_sufficient_capacity')) {
      context.handle(
        _hasSufficientCapacityMeta,
        hasSufficientCapacity.isAcceptableOrUnknown(
          data['has_sufficient_capacity']!,
          _hasSufficientCapacityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_hasSufficientCapacityMeta);
    }
    if (data.containsKey('contributing_shelters_json')) {
      context.handle(
        _contributingSheltersJsonMeta,
        contributingSheltersJson.isAcceptableOrUnknown(
          data['contributing_shelters_json']!,
          _contributingSheltersJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contributingSheltersJsonMeta);
    }
    if (data.containsKey('accessible_radius_meters')) {
      context.handle(
        _accessibleRadiusMetersMeta,
        accessibleRadiusMeters.isAcceptableOrUnknown(
          data['accessible_radius_meters']!,
          _accessibleRadiusMetersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_accessibleRadiusMetersMeta);
    }
    if (data.containsKey('model_version')) {
      context.handle(
        _modelVersionMeta,
        modelVersion.isAcceptableOrUnknown(
          data['model_version']!,
          _modelVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_modelVersionMeta);
    }
    if (data.containsKey('assessed_at')) {
      context.handle(
        _assessedAtMeta,
        assessedAt.isAcceptableOrUnknown(data['assessed_at']!, _assessedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_assessedAtMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {habitationId};
  @override
  LocalCapacityAssessment map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalCapacityAssessment(
      habitationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}habitation_id'],
      )!,
      exposedPopulation: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exposed_population'],
      )!,
      availableSafeCapacity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}available_safe_capacity'],
      )!,
      capacityGap: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}capacity_gap'],
      )!,
      hasSufficientCapacity: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_sufficient_capacity'],
      )!,
      contributingSheltersJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contributing_shelters_json'],
      )!,
      accessibleRadiusMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}accessible_radius_meters'],
      )!,
      modelVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_version'],
      )!,
      assessedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}assessed_at'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
    );
  }

  @override
  $LocalCapacityAssessmentsTable createAlias(String alias) {
    return $LocalCapacityAssessmentsTable(attachedDatabase, alias);
  }
}

class LocalCapacityAssessment extends DataClass
    implements Insertable<LocalCapacityAssessment> {
  final String habitationId;
  final int exposedPopulation;
  final int availableSafeCapacity;

  /// exposedPopulation - availableSafeCapacity. Positive means a shortfall.
  final int capacityGap;
  final bool hasSufficientCapacity;

  /// JSON list of {shelterId, shelterName, availableCapacity,
  /// distanceMeters} for the safe, in-range shelters this figure counted.
  final String contributingSheltersJson;
  final double accessibleRadiusMeters;
  final String modelVersion;
  final DateTime assessedAt;
  final int version;
  const LocalCapacityAssessment({
    required this.habitationId,
    required this.exposedPopulation,
    required this.availableSafeCapacity,
    required this.capacityGap,
    required this.hasSufficientCapacity,
    required this.contributingSheltersJson,
    required this.accessibleRadiusMeters,
    required this.modelVersion,
    required this.assessedAt,
    required this.version,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['habitation_id'] = Variable<String>(habitationId);
    map['exposed_population'] = Variable<int>(exposedPopulation);
    map['available_safe_capacity'] = Variable<int>(availableSafeCapacity);
    map['capacity_gap'] = Variable<int>(capacityGap);
    map['has_sufficient_capacity'] = Variable<bool>(hasSufficientCapacity);
    map['contributing_shelters_json'] = Variable<String>(
      contributingSheltersJson,
    );
    map['accessible_radius_meters'] = Variable<double>(accessibleRadiusMeters);
    map['model_version'] = Variable<String>(modelVersion);
    map['assessed_at'] = Variable<DateTime>(assessedAt);
    map['version'] = Variable<int>(version);
    return map;
  }

  LocalCapacityAssessmentsCompanion toCompanion(bool nullToAbsent) {
    return LocalCapacityAssessmentsCompanion(
      habitationId: Value(habitationId),
      exposedPopulation: Value(exposedPopulation),
      availableSafeCapacity: Value(availableSafeCapacity),
      capacityGap: Value(capacityGap),
      hasSufficientCapacity: Value(hasSufficientCapacity),
      contributingSheltersJson: Value(contributingSheltersJson),
      accessibleRadiusMeters: Value(accessibleRadiusMeters),
      modelVersion: Value(modelVersion),
      assessedAt: Value(assessedAt),
      version: Value(version),
    );
  }

  factory LocalCapacityAssessment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalCapacityAssessment(
      habitationId: serializer.fromJson<String>(json['habitationId']),
      exposedPopulation: serializer.fromJson<int>(json['exposedPopulation']),
      availableSafeCapacity: serializer.fromJson<int>(
        json['availableSafeCapacity'],
      ),
      capacityGap: serializer.fromJson<int>(json['capacityGap']),
      hasSufficientCapacity: serializer.fromJson<bool>(
        json['hasSufficientCapacity'],
      ),
      contributingSheltersJson: serializer.fromJson<String>(
        json['contributingSheltersJson'],
      ),
      accessibleRadiusMeters: serializer.fromJson<double>(
        json['accessibleRadiusMeters'],
      ),
      modelVersion: serializer.fromJson<String>(json['modelVersion']),
      assessedAt: serializer.fromJson<DateTime>(json['assessedAt']),
      version: serializer.fromJson<int>(json['version']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'habitationId': serializer.toJson<String>(habitationId),
      'exposedPopulation': serializer.toJson<int>(exposedPopulation),
      'availableSafeCapacity': serializer.toJson<int>(availableSafeCapacity),
      'capacityGap': serializer.toJson<int>(capacityGap),
      'hasSufficientCapacity': serializer.toJson<bool>(hasSufficientCapacity),
      'contributingSheltersJson': serializer.toJson<String>(
        contributingSheltersJson,
      ),
      'accessibleRadiusMeters': serializer.toJson<double>(
        accessibleRadiusMeters,
      ),
      'modelVersion': serializer.toJson<String>(modelVersion),
      'assessedAt': serializer.toJson<DateTime>(assessedAt),
      'version': serializer.toJson<int>(version),
    };
  }

  LocalCapacityAssessment copyWith({
    String? habitationId,
    int? exposedPopulation,
    int? availableSafeCapacity,
    int? capacityGap,
    bool? hasSufficientCapacity,
    String? contributingSheltersJson,
    double? accessibleRadiusMeters,
    String? modelVersion,
    DateTime? assessedAt,
    int? version,
  }) => LocalCapacityAssessment(
    habitationId: habitationId ?? this.habitationId,
    exposedPopulation: exposedPopulation ?? this.exposedPopulation,
    availableSafeCapacity: availableSafeCapacity ?? this.availableSafeCapacity,
    capacityGap: capacityGap ?? this.capacityGap,
    hasSufficientCapacity: hasSufficientCapacity ?? this.hasSufficientCapacity,
    contributingSheltersJson:
        contributingSheltersJson ?? this.contributingSheltersJson,
    accessibleRadiusMeters:
        accessibleRadiusMeters ?? this.accessibleRadiusMeters,
    modelVersion: modelVersion ?? this.modelVersion,
    assessedAt: assessedAt ?? this.assessedAt,
    version: version ?? this.version,
  );
  LocalCapacityAssessment copyWithCompanion(
    LocalCapacityAssessmentsCompanion data,
  ) {
    return LocalCapacityAssessment(
      habitationId: data.habitationId.present
          ? data.habitationId.value
          : this.habitationId,
      exposedPopulation: data.exposedPopulation.present
          ? data.exposedPopulation.value
          : this.exposedPopulation,
      availableSafeCapacity: data.availableSafeCapacity.present
          ? data.availableSafeCapacity.value
          : this.availableSafeCapacity,
      capacityGap: data.capacityGap.present
          ? data.capacityGap.value
          : this.capacityGap,
      hasSufficientCapacity: data.hasSufficientCapacity.present
          ? data.hasSufficientCapacity.value
          : this.hasSufficientCapacity,
      contributingSheltersJson: data.contributingSheltersJson.present
          ? data.contributingSheltersJson.value
          : this.contributingSheltersJson,
      accessibleRadiusMeters: data.accessibleRadiusMeters.present
          ? data.accessibleRadiusMeters.value
          : this.accessibleRadiusMeters,
      modelVersion: data.modelVersion.present
          ? data.modelVersion.value
          : this.modelVersion,
      assessedAt: data.assessedAt.present
          ? data.assessedAt.value
          : this.assessedAt,
      version: data.version.present ? data.version.value : this.version,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalCapacityAssessment(')
          ..write('habitationId: $habitationId, ')
          ..write('exposedPopulation: $exposedPopulation, ')
          ..write('availableSafeCapacity: $availableSafeCapacity, ')
          ..write('capacityGap: $capacityGap, ')
          ..write('hasSufficientCapacity: $hasSufficientCapacity, ')
          ..write('contributingSheltersJson: $contributingSheltersJson, ')
          ..write('accessibleRadiusMeters: $accessibleRadiusMeters, ')
          ..write('modelVersion: $modelVersion, ')
          ..write('assessedAt: $assessedAt, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    habitationId,
    exposedPopulation,
    availableSafeCapacity,
    capacityGap,
    hasSufficientCapacity,
    contributingSheltersJson,
    accessibleRadiusMeters,
    modelVersion,
    assessedAt,
    version,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalCapacityAssessment &&
          other.habitationId == this.habitationId &&
          other.exposedPopulation == this.exposedPopulation &&
          other.availableSafeCapacity == this.availableSafeCapacity &&
          other.capacityGap == this.capacityGap &&
          other.hasSufficientCapacity == this.hasSufficientCapacity &&
          other.contributingSheltersJson == this.contributingSheltersJson &&
          other.accessibleRadiusMeters == this.accessibleRadiusMeters &&
          other.modelVersion == this.modelVersion &&
          other.assessedAt == this.assessedAt &&
          other.version == this.version);
}

class LocalCapacityAssessmentsCompanion
    extends UpdateCompanion<LocalCapacityAssessment> {
  final Value<String> habitationId;
  final Value<int> exposedPopulation;
  final Value<int> availableSafeCapacity;
  final Value<int> capacityGap;
  final Value<bool> hasSufficientCapacity;
  final Value<String> contributingSheltersJson;
  final Value<double> accessibleRadiusMeters;
  final Value<String> modelVersion;
  final Value<DateTime> assessedAt;
  final Value<int> version;
  final Value<int> rowid;
  const LocalCapacityAssessmentsCompanion({
    this.habitationId = const Value.absent(),
    this.exposedPopulation = const Value.absent(),
    this.availableSafeCapacity = const Value.absent(),
    this.capacityGap = const Value.absent(),
    this.hasSufficientCapacity = const Value.absent(),
    this.contributingSheltersJson = const Value.absent(),
    this.accessibleRadiusMeters = const Value.absent(),
    this.modelVersion = const Value.absent(),
    this.assessedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalCapacityAssessmentsCompanion.insert({
    required String habitationId,
    required int exposedPopulation,
    required int availableSafeCapacity,
    required int capacityGap,
    required bool hasSufficientCapacity,
    required String contributingSheltersJson,
    required double accessibleRadiusMeters,
    required String modelVersion,
    required DateTime assessedAt,
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : habitationId = Value(habitationId),
       exposedPopulation = Value(exposedPopulation),
       availableSafeCapacity = Value(availableSafeCapacity),
       capacityGap = Value(capacityGap),
       hasSufficientCapacity = Value(hasSufficientCapacity),
       contributingSheltersJson = Value(contributingSheltersJson),
       accessibleRadiusMeters = Value(accessibleRadiusMeters),
       modelVersion = Value(modelVersion),
       assessedAt = Value(assessedAt);
  static Insertable<LocalCapacityAssessment> custom({
    Expression<String>? habitationId,
    Expression<int>? exposedPopulation,
    Expression<int>? availableSafeCapacity,
    Expression<int>? capacityGap,
    Expression<bool>? hasSufficientCapacity,
    Expression<String>? contributingSheltersJson,
    Expression<double>? accessibleRadiusMeters,
    Expression<String>? modelVersion,
    Expression<DateTime>? assessedAt,
    Expression<int>? version,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (habitationId != null) 'habitation_id': habitationId,
      if (exposedPopulation != null) 'exposed_population': exposedPopulation,
      if (availableSafeCapacity != null)
        'available_safe_capacity': availableSafeCapacity,
      if (capacityGap != null) 'capacity_gap': capacityGap,
      if (hasSufficientCapacity != null)
        'has_sufficient_capacity': hasSufficientCapacity,
      if (contributingSheltersJson != null)
        'contributing_shelters_json': contributingSheltersJson,
      if (accessibleRadiusMeters != null)
        'accessible_radius_meters': accessibleRadiusMeters,
      if (modelVersion != null) 'model_version': modelVersion,
      if (assessedAt != null) 'assessed_at': assessedAt,
      if (version != null) 'version': version,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalCapacityAssessmentsCompanion copyWith({
    Value<String>? habitationId,
    Value<int>? exposedPopulation,
    Value<int>? availableSafeCapacity,
    Value<int>? capacityGap,
    Value<bool>? hasSufficientCapacity,
    Value<String>? contributingSheltersJson,
    Value<double>? accessibleRadiusMeters,
    Value<String>? modelVersion,
    Value<DateTime>? assessedAt,
    Value<int>? version,
    Value<int>? rowid,
  }) {
    return LocalCapacityAssessmentsCompanion(
      habitationId: habitationId ?? this.habitationId,
      exposedPopulation: exposedPopulation ?? this.exposedPopulation,
      availableSafeCapacity:
          availableSafeCapacity ?? this.availableSafeCapacity,
      capacityGap: capacityGap ?? this.capacityGap,
      hasSufficientCapacity:
          hasSufficientCapacity ?? this.hasSufficientCapacity,
      contributingSheltersJson:
          contributingSheltersJson ?? this.contributingSheltersJson,
      accessibleRadiusMeters:
          accessibleRadiusMeters ?? this.accessibleRadiusMeters,
      modelVersion: modelVersion ?? this.modelVersion,
      assessedAt: assessedAt ?? this.assessedAt,
      version: version ?? this.version,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (habitationId.present) {
      map['habitation_id'] = Variable<String>(habitationId.value);
    }
    if (exposedPopulation.present) {
      map['exposed_population'] = Variable<int>(exposedPopulation.value);
    }
    if (availableSafeCapacity.present) {
      map['available_safe_capacity'] = Variable<int>(
        availableSafeCapacity.value,
      );
    }
    if (capacityGap.present) {
      map['capacity_gap'] = Variable<int>(capacityGap.value);
    }
    if (hasSufficientCapacity.present) {
      map['has_sufficient_capacity'] = Variable<bool>(
        hasSufficientCapacity.value,
      );
    }
    if (contributingSheltersJson.present) {
      map['contributing_shelters_json'] = Variable<String>(
        contributingSheltersJson.value,
      );
    }
    if (accessibleRadiusMeters.present) {
      map['accessible_radius_meters'] = Variable<double>(
        accessibleRadiusMeters.value,
      );
    }
    if (modelVersion.present) {
      map['model_version'] = Variable<String>(modelVersion.value);
    }
    if (assessedAt.present) {
      map['assessed_at'] = Variable<DateTime>(assessedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalCapacityAssessmentsCompanion(')
          ..write('habitationId: $habitationId, ')
          ..write('exposedPopulation: $exposedPopulation, ')
          ..write('availableSafeCapacity: $availableSafeCapacity, ')
          ..write('capacityGap: $capacityGap, ')
          ..write('hasSufficientCapacity: $hasSufficientCapacity, ')
          ..write('contributingSheltersJson: $contributingSheltersJson, ')
          ..write('accessibleRadiusMeters: $accessibleRadiusMeters, ')
          ..write('modelVersion: $modelVersion, ')
          ..write('assessedAt: $assessedAt, ')
          ..write('version: $version, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalRelocationPlansTable extends LocalRelocationPlans
    with TableInfo<$LocalRelocationPlansTable, LocalRelocationPlan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalRelocationPlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _habitationIdMeta = const VerificationMeta(
    'habitationId',
  );
  @override
  late final GeneratedColumn<String> habitationId = GeneratedColumn<String>(
    'habitation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _populationToRelocateMeta =
      const VerificationMeta('populationToRelocate');
  @override
  late final GeneratedColumn<int> populationToRelocate = GeneratedColumn<int>(
    'population_to_relocate',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rankedCandidatesJsonMeta =
      const VerificationMeta('rankedCandidatesJson');
  @override
  late final GeneratedColumn<String> rankedCandidatesJson =
      GeneratedColumn<String>(
        'ranked_candidates_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _modelVersionMeta = const VerificationMeta(
    'modelVersion',
  );
  @override
  late final GeneratedColumn<String> modelVersion = GeneratedColumn<String>(
    'model_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plannedAtMeta = const VerificationMeta(
    'plannedAt',
  );
  @override
  late final GeneratedColumn<DateTime> plannedAt = GeneratedColumn<DateTime>(
    'planned_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    habitationId,
    populationToRelocate,
    rankedCandidatesJson,
    modelVersion,
    plannedAt,
    version,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_relocation_plans';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalRelocationPlan> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('habitation_id')) {
      context.handle(
        _habitationIdMeta,
        habitationId.isAcceptableOrUnknown(
          data['habitation_id']!,
          _habitationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_habitationIdMeta);
    }
    if (data.containsKey('population_to_relocate')) {
      context.handle(
        _populationToRelocateMeta,
        populationToRelocate.isAcceptableOrUnknown(
          data['population_to_relocate']!,
          _populationToRelocateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_populationToRelocateMeta);
    }
    if (data.containsKey('ranked_candidates_json')) {
      context.handle(
        _rankedCandidatesJsonMeta,
        rankedCandidatesJson.isAcceptableOrUnknown(
          data['ranked_candidates_json']!,
          _rankedCandidatesJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rankedCandidatesJsonMeta);
    }
    if (data.containsKey('model_version')) {
      context.handle(
        _modelVersionMeta,
        modelVersion.isAcceptableOrUnknown(
          data['model_version']!,
          _modelVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_modelVersionMeta);
    }
    if (data.containsKey('planned_at')) {
      context.handle(
        _plannedAtMeta,
        plannedAt.isAcceptableOrUnknown(data['planned_at']!, _plannedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_plannedAtMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {habitationId};
  @override
  LocalRelocationPlan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalRelocationPlan(
      habitationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}habitation_id'],
      )!,
      populationToRelocate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}population_to_relocate'],
      )!,
      rankedCandidatesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ranked_candidates_json'],
      )!,
      modelVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_version'],
      )!,
      plannedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}planned_at'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
    );
  }

  @override
  $LocalRelocationPlansTable createAlias(String alias) {
    return $LocalRelocationPlansTable(attachedDatabase, alias);
  }
}

class LocalRelocationPlan extends DataClass
    implements Insertable<LocalRelocationPlan> {
  final String habitationId;
  final int populationToRelocate;

  /// JSON list of {shelterId, shelterName, availableCapacity,
  /// distanceMeters, distanceScore, capacityScore, accessScore,
  /// facilitiesScore, compositeScore, reasons} — ranked best-first.
  final String rankedCandidatesJson;
  final String modelVersion;
  final DateTime plannedAt;
  final int version;
  const LocalRelocationPlan({
    required this.habitationId,
    required this.populationToRelocate,
    required this.rankedCandidatesJson,
    required this.modelVersion,
    required this.plannedAt,
    required this.version,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['habitation_id'] = Variable<String>(habitationId);
    map['population_to_relocate'] = Variable<int>(populationToRelocate);
    map['ranked_candidates_json'] = Variable<String>(rankedCandidatesJson);
    map['model_version'] = Variable<String>(modelVersion);
    map['planned_at'] = Variable<DateTime>(plannedAt);
    map['version'] = Variable<int>(version);
    return map;
  }

  LocalRelocationPlansCompanion toCompanion(bool nullToAbsent) {
    return LocalRelocationPlansCompanion(
      habitationId: Value(habitationId),
      populationToRelocate: Value(populationToRelocate),
      rankedCandidatesJson: Value(rankedCandidatesJson),
      modelVersion: Value(modelVersion),
      plannedAt: Value(plannedAt),
      version: Value(version),
    );
  }

  factory LocalRelocationPlan.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalRelocationPlan(
      habitationId: serializer.fromJson<String>(json['habitationId']),
      populationToRelocate: serializer.fromJson<int>(
        json['populationToRelocate'],
      ),
      rankedCandidatesJson: serializer.fromJson<String>(
        json['rankedCandidatesJson'],
      ),
      modelVersion: serializer.fromJson<String>(json['modelVersion']),
      plannedAt: serializer.fromJson<DateTime>(json['plannedAt']),
      version: serializer.fromJson<int>(json['version']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'habitationId': serializer.toJson<String>(habitationId),
      'populationToRelocate': serializer.toJson<int>(populationToRelocate),
      'rankedCandidatesJson': serializer.toJson<String>(rankedCandidatesJson),
      'modelVersion': serializer.toJson<String>(modelVersion),
      'plannedAt': serializer.toJson<DateTime>(plannedAt),
      'version': serializer.toJson<int>(version),
    };
  }

  LocalRelocationPlan copyWith({
    String? habitationId,
    int? populationToRelocate,
    String? rankedCandidatesJson,
    String? modelVersion,
    DateTime? plannedAt,
    int? version,
  }) => LocalRelocationPlan(
    habitationId: habitationId ?? this.habitationId,
    populationToRelocate: populationToRelocate ?? this.populationToRelocate,
    rankedCandidatesJson: rankedCandidatesJson ?? this.rankedCandidatesJson,
    modelVersion: modelVersion ?? this.modelVersion,
    plannedAt: plannedAt ?? this.plannedAt,
    version: version ?? this.version,
  );
  LocalRelocationPlan copyWithCompanion(LocalRelocationPlansCompanion data) {
    return LocalRelocationPlan(
      habitationId: data.habitationId.present
          ? data.habitationId.value
          : this.habitationId,
      populationToRelocate: data.populationToRelocate.present
          ? data.populationToRelocate.value
          : this.populationToRelocate,
      rankedCandidatesJson: data.rankedCandidatesJson.present
          ? data.rankedCandidatesJson.value
          : this.rankedCandidatesJson,
      modelVersion: data.modelVersion.present
          ? data.modelVersion.value
          : this.modelVersion,
      plannedAt: data.plannedAt.present ? data.plannedAt.value : this.plannedAt,
      version: data.version.present ? data.version.value : this.version,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalRelocationPlan(')
          ..write('habitationId: $habitationId, ')
          ..write('populationToRelocate: $populationToRelocate, ')
          ..write('rankedCandidatesJson: $rankedCandidatesJson, ')
          ..write('modelVersion: $modelVersion, ')
          ..write('plannedAt: $plannedAt, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    habitationId,
    populationToRelocate,
    rankedCandidatesJson,
    modelVersion,
    plannedAt,
    version,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalRelocationPlan &&
          other.habitationId == this.habitationId &&
          other.populationToRelocate == this.populationToRelocate &&
          other.rankedCandidatesJson == this.rankedCandidatesJson &&
          other.modelVersion == this.modelVersion &&
          other.plannedAt == this.plannedAt &&
          other.version == this.version);
}

class LocalRelocationPlansCompanion
    extends UpdateCompanion<LocalRelocationPlan> {
  final Value<String> habitationId;
  final Value<int> populationToRelocate;
  final Value<String> rankedCandidatesJson;
  final Value<String> modelVersion;
  final Value<DateTime> plannedAt;
  final Value<int> version;
  final Value<int> rowid;
  const LocalRelocationPlansCompanion({
    this.habitationId = const Value.absent(),
    this.populationToRelocate = const Value.absent(),
    this.rankedCandidatesJson = const Value.absent(),
    this.modelVersion = const Value.absent(),
    this.plannedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalRelocationPlansCompanion.insert({
    required String habitationId,
    required int populationToRelocate,
    required String rankedCandidatesJson,
    required String modelVersion,
    required DateTime plannedAt,
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : habitationId = Value(habitationId),
       populationToRelocate = Value(populationToRelocate),
       rankedCandidatesJson = Value(rankedCandidatesJson),
       modelVersion = Value(modelVersion),
       plannedAt = Value(plannedAt);
  static Insertable<LocalRelocationPlan> custom({
    Expression<String>? habitationId,
    Expression<int>? populationToRelocate,
    Expression<String>? rankedCandidatesJson,
    Expression<String>? modelVersion,
    Expression<DateTime>? plannedAt,
    Expression<int>? version,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (habitationId != null) 'habitation_id': habitationId,
      if (populationToRelocate != null)
        'population_to_relocate': populationToRelocate,
      if (rankedCandidatesJson != null)
        'ranked_candidates_json': rankedCandidatesJson,
      if (modelVersion != null) 'model_version': modelVersion,
      if (plannedAt != null) 'planned_at': plannedAt,
      if (version != null) 'version': version,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalRelocationPlansCompanion copyWith({
    Value<String>? habitationId,
    Value<int>? populationToRelocate,
    Value<String>? rankedCandidatesJson,
    Value<String>? modelVersion,
    Value<DateTime>? plannedAt,
    Value<int>? version,
    Value<int>? rowid,
  }) {
    return LocalRelocationPlansCompanion(
      habitationId: habitationId ?? this.habitationId,
      populationToRelocate: populationToRelocate ?? this.populationToRelocate,
      rankedCandidatesJson: rankedCandidatesJson ?? this.rankedCandidatesJson,
      modelVersion: modelVersion ?? this.modelVersion,
      plannedAt: plannedAt ?? this.plannedAt,
      version: version ?? this.version,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (habitationId.present) {
      map['habitation_id'] = Variable<String>(habitationId.value);
    }
    if (populationToRelocate.present) {
      map['population_to_relocate'] = Variable<int>(populationToRelocate.value);
    }
    if (rankedCandidatesJson.present) {
      map['ranked_candidates_json'] = Variable<String>(
        rankedCandidatesJson.value,
      );
    }
    if (modelVersion.present) {
      map['model_version'] = Variable<String>(modelVersion.value);
    }
    if (plannedAt.present) {
      map['planned_at'] = Variable<DateTime>(plannedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalRelocationPlansCompanion(')
          ..write('habitationId: $habitationId, ')
          ..write('populationToRelocate: $populationToRelocate, ')
          ..write('rankedCandidatesJson: $rankedCandidatesJson, ')
          ..write('modelVersion: $modelVersion, ')
          ..write('plannedAt: $plannedAt, ')
          ..write('version: $version, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueEntriesTable extends SyncQueueEntries
    with TableInfo<$SyncQueueEntriesTable, SyncQueueEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _entityTableMeta = const VerificationMeta(
    'entityTable',
  );
  @override
  late final GeneratedColumn<String> entityTable = GeneratedColumn<String>(
    'entity_table',
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
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptCountMeta = const VerificationMeta(
    'attemptCount',
  );
  @override
  late final GeneratedColumn<int> attemptCount = GeneratedColumn<int>(
    'attempt_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastAttemptAtMeta = const VerificationMeta(
    'lastAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastAttemptAt =
      GeneratedColumn<DateTime>(
        'last_attempt_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityTable,
    entityId,
    operation,
    payloadJson,
    createdAt,
    attemptCount,
    lastAttemptAt,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entity_table')) {
      context.handle(
        _entityTableMeta,
        entityTable.isAcceptableOrUnknown(
          data['entity_table']!,
          _entityTableMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_entityTableMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('attempt_count')) {
      context.handle(
        _attemptCountMeta,
        attemptCount.isAcceptableOrUnknown(
          data['attempt_count']!,
          _attemptCountMeta,
        ),
      );
    }
    if (data.containsKey('last_attempt_at')) {
      context.handle(
        _lastAttemptAtMeta,
        lastAttemptAt.isAcceptableOrUnknown(
          data['last_attempt_at']!,
          _lastAttemptAtMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      entityTable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_table'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      attemptCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_count'],
      )!,
      lastAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_attempt_at'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $SyncQueueEntriesTable createAlias(String alias) {
    return $SyncQueueEntriesTable(attachedDatabase, alias);
  }
}

class SyncQueueEntry extends DataClass implements Insertable<SyncQueueEntry> {
  final int id;
  final String entityTable;
  final String entityId;
  final String operation;
  final String payloadJson;
  final DateTime createdAt;
  final int attemptCount;
  final DateTime? lastAttemptAt;
  final String status;
  const SyncQueueEntry({
    required this.id,
    required this.entityTable,
    required this.entityId,
    required this.operation,
    required this.payloadJson,
    required this.createdAt,
    required this.attemptCount,
    this.lastAttemptAt,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entity_table'] = Variable<String>(entityTable);
    map['entity_id'] = Variable<String>(entityId);
    map['operation'] = Variable<String>(operation);
    map['payload_json'] = Variable<String>(payloadJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['attempt_count'] = Variable<int>(attemptCount);
    if (!nullToAbsent || lastAttemptAt != null) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt);
    }
    map['status'] = Variable<String>(status);
    return map;
  }

  SyncQueueEntriesCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueEntriesCompanion(
      id: Value(id),
      entityTable: Value(entityTable),
      entityId: Value(entityId),
      operation: Value(operation),
      payloadJson: Value(payloadJson),
      createdAt: Value(createdAt),
      attemptCount: Value(attemptCount),
      lastAttemptAt: lastAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAttemptAt),
      status: Value(status),
    );
  }

  factory SyncQueueEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueEntry(
      id: serializer.fromJson<int>(json['id']),
      entityTable: serializer.fromJson<String>(json['entityTable']),
      entityId: serializer.fromJson<String>(json['entityId']),
      operation: serializer.fromJson<String>(json['operation']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      attemptCount: serializer.fromJson<int>(json['attemptCount']),
      lastAttemptAt: serializer.fromJson<DateTime?>(json['lastAttemptAt']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entityTable': serializer.toJson<String>(entityTable),
      'entityId': serializer.toJson<String>(entityId),
      'operation': serializer.toJson<String>(operation),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'attemptCount': serializer.toJson<int>(attemptCount),
      'lastAttemptAt': serializer.toJson<DateTime?>(lastAttemptAt),
      'status': serializer.toJson<String>(status),
    };
  }

  SyncQueueEntry copyWith({
    int? id,
    String? entityTable,
    String? entityId,
    String? operation,
    String? payloadJson,
    DateTime? createdAt,
    int? attemptCount,
    Value<DateTime?> lastAttemptAt = const Value.absent(),
    String? status,
  }) => SyncQueueEntry(
    id: id ?? this.id,
    entityTable: entityTable ?? this.entityTable,
    entityId: entityId ?? this.entityId,
    operation: operation ?? this.operation,
    payloadJson: payloadJson ?? this.payloadJson,
    createdAt: createdAt ?? this.createdAt,
    attemptCount: attemptCount ?? this.attemptCount,
    lastAttemptAt: lastAttemptAt.present
        ? lastAttemptAt.value
        : this.lastAttemptAt,
    status: status ?? this.status,
  );
  SyncQueueEntry copyWithCompanion(SyncQueueEntriesCompanion data) {
    return SyncQueueEntry(
      id: data.id.present ? data.id.value : this.id,
      entityTable: data.entityTable.present
          ? data.entityTable.value
          : this.entityTable,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      operation: data.operation.present ? data.operation.value : this.operation,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      attemptCount: data.attemptCount.present
          ? data.attemptCount.value
          : this.attemptCount,
      lastAttemptAt: data.lastAttemptAt.present
          ? data.lastAttemptAt.value
          : this.lastAttemptAt,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueEntry(')
          ..write('id: $id, ')
          ..write('entityTable: $entityTable, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entityTable,
    entityId,
    operation,
    payloadJson,
    createdAt,
    attemptCount,
    lastAttemptAt,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueEntry &&
          other.id == this.id &&
          other.entityTable == this.entityTable &&
          other.entityId == this.entityId &&
          other.operation == this.operation &&
          other.payloadJson == this.payloadJson &&
          other.createdAt == this.createdAt &&
          other.attemptCount == this.attemptCount &&
          other.lastAttemptAt == this.lastAttemptAt &&
          other.status == this.status);
}

class SyncQueueEntriesCompanion extends UpdateCompanion<SyncQueueEntry> {
  final Value<int> id;
  final Value<String> entityTable;
  final Value<String> entityId;
  final Value<String> operation;
  final Value<String> payloadJson;
  final Value<DateTime> createdAt;
  final Value<int> attemptCount;
  final Value<DateTime?> lastAttemptAt;
  final Value<String> status;
  const SyncQueueEntriesCompanion({
    this.id = const Value.absent(),
    this.entityTable = const Value.absent(),
    this.entityId = const Value.absent(),
    this.operation = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.status = const Value.absent(),
  });
  SyncQueueEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String entityTable,
    required String entityId,
    required String operation,
    required String payloadJson,
    required DateTime createdAt,
    this.attemptCount = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.status = const Value.absent(),
  }) : entityTable = Value(entityTable),
       entityId = Value(entityId),
       operation = Value(operation),
       payloadJson = Value(payloadJson),
       createdAt = Value(createdAt);
  static Insertable<SyncQueueEntry> custom({
    Expression<int>? id,
    Expression<String>? entityTable,
    Expression<String>? entityId,
    Expression<String>? operation,
    Expression<String>? payloadJson,
    Expression<DateTime>? createdAt,
    Expression<int>? attemptCount,
    Expression<DateTime>? lastAttemptAt,
    Expression<String>? status,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityTable != null) 'entity_table': entityTable,
      if (entityId != null) 'entity_id': entityId,
      if (operation != null) 'operation': operation,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdAt != null) 'created_at': createdAt,
      if (attemptCount != null) 'attempt_count': attemptCount,
      if (lastAttemptAt != null) 'last_attempt_at': lastAttemptAt,
      if (status != null) 'status': status,
    });
  }

  SyncQueueEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? entityTable,
    Value<String>? entityId,
    Value<String>? operation,
    Value<String>? payloadJson,
    Value<DateTime>? createdAt,
    Value<int>? attemptCount,
    Value<DateTime?>? lastAttemptAt,
    Value<String>? status,
  }) {
    return SyncQueueEntriesCompanion(
      id: id ?? this.id,
      entityTable: entityTable ?? this.entityTable,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
      attemptCount: attemptCount ?? this.attemptCount,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      status: status ?? this.status,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entityTable.present) {
      map['entity_table'] = Variable<String>(entityTable.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (attemptCount.present) {
      map['attempt_count'] = Variable<int>(attemptCount.value);
    }
    if (lastAttemptAt.present) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueEntriesCompanion(')
          ..write('id: $id, ')
          ..write('entityTable: $entityTable, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalUsersTable localUsers = $LocalUsersTable(this);
  late final $LocalHazardZonesTable localHazardZones = $LocalHazardZonesTable(
    this,
  );
  late final $LocalIncidentsTable localIncidents = $LocalIncidentsTable(this);
  late final $LocalIncidentReportsTable localIncidentReports =
      $LocalIncidentReportsTable(this);
  late final $LocalSheltersTable localShelters = $LocalSheltersTable(this);
  late final $LocalRoutesTable localRoutes = $LocalRoutesTable(this);
  late final $LocalHabitationsTable localHabitations = $LocalHabitationsTable(
    this,
  );
  late final $LocalRiskAssessmentsTable localRiskAssessments =
      $LocalRiskAssessmentsTable(this);
  late final $LocalVulnerabilityAssessmentsTable localVulnerabilityAssessments =
      $LocalVulnerabilityAssessmentsTable(this);
  late final $LocalCapacityAssessmentsTable localCapacityAssessments =
      $LocalCapacityAssessmentsTable(this);
  late final $LocalRelocationPlansTable localRelocationPlans =
      $LocalRelocationPlansTable(this);
  late final $SyncQueueEntriesTable syncQueueEntries = $SyncQueueEntriesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localUsers,
    localHazardZones,
    localIncidents,
    localIncidentReports,
    localShelters,
    localRoutes,
    localHabitations,
    localRiskAssessments,
    localVulnerabilityAssessments,
    localCapacityAssessments,
    localRelocationPlans,
    syncQueueEntries,
  ];
}

typedef $$LocalUsersTableCreateCompanionBuilder =
    LocalUsersCompanion Function({
      required String id,
      required String name,
      required String email,
      required String role,
      required DateTime updatedAt,
      Value<int> version,
      Value<int> rowid,
    });
typedef $$LocalUsersTableUpdateCompanionBuilder =
    LocalUsersCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> email,
      Value<String> role,
      Value<DateTime> updatedAt,
      Value<int> version,
      Value<int> rowid,
    });

class $$LocalUsersTableFilterComposer
    extends Composer<_$AppDatabase, $LocalUsersTable> {
  $$LocalUsersTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalUsersTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalUsersTable> {
  $$LocalUsersTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalUsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalUsersTable> {
  $$LocalUsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);
}

class $$LocalUsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalUsersTable,
          LocalUser,
          $$LocalUsersTableFilterComposer,
          $$LocalUsersTableOrderingComposer,
          $$LocalUsersTableAnnotationComposer,
          $$LocalUsersTableCreateCompanionBuilder,
          $$LocalUsersTableUpdateCompanionBuilder,
          (
            LocalUser,
            BaseReferences<_$AppDatabase, $LocalUsersTable, LocalUser>,
          ),
          LocalUser,
          PrefetchHooks Function()
        > {
  $$LocalUsersTableTableManager(_$AppDatabase db, $LocalUsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalUsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalUsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalUsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalUsersCompanion(
                id: id,
                name: name,
                email: email,
                role: role,
                updatedAt: updatedAt,
                version: version,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String email,
                required String role,
                required DateTime updatedAt,
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalUsersCompanion.insert(
                id: id,
                name: name,
                email: email,
                role: role,
                updatedAt: updatedAt,
                version: version,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalUsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalUsersTable,
      LocalUser,
      $$LocalUsersTableFilterComposer,
      $$LocalUsersTableOrderingComposer,
      $$LocalUsersTableAnnotationComposer,
      $$LocalUsersTableCreateCompanionBuilder,
      $$LocalUsersTableUpdateCompanionBuilder,
      (LocalUser, BaseReferences<_$AppDatabase, $LocalUsersTable, LocalUser>),
      LocalUser,
      PrefetchHooks Function()
    >;
typedef $$LocalHazardZonesTableCreateCompanionBuilder =
    LocalHazardZonesCompanion Function({
      required String id,
      required String hazardType,
      required String severity,
      required String geometryJson,
      required String source,
      required DateTime observedAt,
      Value<double> confidence,
      required DateTime updatedAt,
      Value<int> version,
      Value<int> rowid,
    });
typedef $$LocalHazardZonesTableUpdateCompanionBuilder =
    LocalHazardZonesCompanion Function({
      Value<String> id,
      Value<String> hazardType,
      Value<String> severity,
      Value<String> geometryJson,
      Value<String> source,
      Value<DateTime> observedAt,
      Value<double> confidence,
      Value<DateTime> updatedAt,
      Value<int> version,
      Value<int> rowid,
    });

class $$LocalHazardZonesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalHazardZonesTable> {
  $$LocalHazardZonesTableFilterComposer({
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

  ColumnFilters<String> get hazardType => $composableBuilder(
    column: $table.hazardType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get geometryJson => $composableBuilder(
    column: $table.geometryJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get observedAt => $composableBuilder(
    column: $table.observedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalHazardZonesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalHazardZonesTable> {
  $$LocalHazardZonesTableOrderingComposer({
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

  ColumnOrderings<String> get hazardType => $composableBuilder(
    column: $table.hazardType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get geometryJson => $composableBuilder(
    column: $table.geometryJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get observedAt => $composableBuilder(
    column: $table.observedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalHazardZonesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalHazardZonesTable> {
  $$LocalHazardZonesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get hazardType => $composableBuilder(
    column: $table.hazardType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => column);

  GeneratedColumn<String> get geometryJson => $composableBuilder(
    column: $table.geometryJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get observedAt => $composableBuilder(
    column: $table.observedAt,
    builder: (column) => column,
  );

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);
}

class $$LocalHazardZonesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalHazardZonesTable,
          LocalHazardZone,
          $$LocalHazardZonesTableFilterComposer,
          $$LocalHazardZonesTableOrderingComposer,
          $$LocalHazardZonesTableAnnotationComposer,
          $$LocalHazardZonesTableCreateCompanionBuilder,
          $$LocalHazardZonesTableUpdateCompanionBuilder,
          (
            LocalHazardZone,
            BaseReferences<
              _$AppDatabase,
              $LocalHazardZonesTable,
              LocalHazardZone
            >,
          ),
          LocalHazardZone,
          PrefetchHooks Function()
        > {
  $$LocalHazardZonesTableTableManager(
    _$AppDatabase db,
    $LocalHazardZonesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalHazardZonesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalHazardZonesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalHazardZonesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> hazardType = const Value.absent(),
                Value<String> severity = const Value.absent(),
                Value<String> geometryJson = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<DateTime> observedAt = const Value.absent(),
                Value<double> confidence = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalHazardZonesCompanion(
                id: id,
                hazardType: hazardType,
                severity: severity,
                geometryJson: geometryJson,
                source: source,
                observedAt: observedAt,
                confidence: confidence,
                updatedAt: updatedAt,
                version: version,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String hazardType,
                required String severity,
                required String geometryJson,
                required String source,
                required DateTime observedAt,
                Value<double> confidence = const Value.absent(),
                required DateTime updatedAt,
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalHazardZonesCompanion.insert(
                id: id,
                hazardType: hazardType,
                severity: severity,
                geometryJson: geometryJson,
                source: source,
                observedAt: observedAt,
                confidence: confidence,
                updatedAt: updatedAt,
                version: version,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalHazardZonesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalHazardZonesTable,
      LocalHazardZone,
      $$LocalHazardZonesTableFilterComposer,
      $$LocalHazardZonesTableOrderingComposer,
      $$LocalHazardZonesTableAnnotationComposer,
      $$LocalHazardZonesTableCreateCompanionBuilder,
      $$LocalHazardZonesTableUpdateCompanionBuilder,
      (
        LocalHazardZone,
        BaseReferences<_$AppDatabase, $LocalHazardZonesTable, LocalHazardZone>,
      ),
      LocalHazardZone,
      PrefetchHooks Function()
    >;
typedef $$LocalIncidentsTableCreateCompanionBuilder =
    LocalIncidentsCompanion Function({
      required String id,
      required String type,
      required String status,
      required double latitude,
      required double longitude,
      Value<String> description,
      Value<String> severity,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> version,
      Value<bool> isSynced,
      Value<int> rowid,
    });
typedef $$LocalIncidentsTableUpdateCompanionBuilder =
    LocalIncidentsCompanion Function({
      Value<String> id,
      Value<String> type,
      Value<String> status,
      Value<double> latitude,
      Value<double> longitude,
      Value<String> description,
      Value<String> severity,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> version,
      Value<bool> isSynced,
      Value<int> rowid,
    });

class $$LocalIncidentsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalIncidentsTable> {
  $$LocalIncidentsTableFilterComposer({
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

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get severity => $composableBuilder(
    column: $table.severity,
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

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalIncidentsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalIncidentsTable> {
  $$LocalIncidentsTableOrderingComposer({
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

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get severity => $composableBuilder(
    column: $table.severity,
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

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalIncidentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalIncidentsTable> {
  $$LocalIncidentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);
}

class $$LocalIncidentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalIncidentsTable,
          LocalIncident,
          $$LocalIncidentsTableFilterComposer,
          $$LocalIncidentsTableOrderingComposer,
          $$LocalIncidentsTableAnnotationComposer,
          $$LocalIncidentsTableCreateCompanionBuilder,
          $$LocalIncidentsTableUpdateCompanionBuilder,
          (
            LocalIncident,
            BaseReferences<_$AppDatabase, $LocalIncidentsTable, LocalIncident>,
          ),
          LocalIncident,
          PrefetchHooks Function()
        > {
  $$LocalIncidentsTableTableManager(
    _$AppDatabase db,
    $LocalIncidentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalIncidentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalIncidentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalIncidentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> severity = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalIncidentsCompanion(
                id: id,
                type: type,
                status: status,
                latitude: latitude,
                longitude: longitude,
                description: description,
                severity: severity,
                createdAt: createdAt,
                updatedAt: updatedAt,
                version: version,
                isSynced: isSynced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String type,
                required String status,
                required double latitude,
                required double longitude,
                Value<String> description = const Value.absent(),
                Value<String> severity = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> version = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalIncidentsCompanion.insert(
                id: id,
                type: type,
                status: status,
                latitude: latitude,
                longitude: longitude,
                description: description,
                severity: severity,
                createdAt: createdAt,
                updatedAt: updatedAt,
                version: version,
                isSynced: isSynced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalIncidentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalIncidentsTable,
      LocalIncident,
      $$LocalIncidentsTableFilterComposer,
      $$LocalIncidentsTableOrderingComposer,
      $$LocalIncidentsTableAnnotationComposer,
      $$LocalIncidentsTableCreateCompanionBuilder,
      $$LocalIncidentsTableUpdateCompanionBuilder,
      (
        LocalIncident,
        BaseReferences<_$AppDatabase, $LocalIncidentsTable, LocalIncident>,
      ),
      LocalIncident,
      PrefetchHooks Function()
    >;
typedef $$LocalIncidentReportsTableCreateCompanionBuilder =
    LocalIncidentReportsCompanion Function({
      required String id,
      Value<String?> incidentId,
      Value<String?> reporterId,
      required double latitude,
      required double longitude,
      Value<String> description,
      Value<String> severity,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> version,
      Value<bool> isSynced,
      Value<int> rowid,
    });
typedef $$LocalIncidentReportsTableUpdateCompanionBuilder =
    LocalIncidentReportsCompanion Function({
      Value<String> id,
      Value<String?> incidentId,
      Value<String?> reporterId,
      Value<double> latitude,
      Value<double> longitude,
      Value<String> description,
      Value<String> severity,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> version,
      Value<bool> isSynced,
      Value<int> rowid,
    });

class $$LocalIncidentReportsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalIncidentReportsTable> {
  $$LocalIncidentReportsTableFilterComposer({
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

  ColumnFilters<String> get incidentId => $composableBuilder(
    column: $table.incidentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reporterId => $composableBuilder(
    column: $table.reporterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get severity => $composableBuilder(
    column: $table.severity,
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

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalIncidentReportsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalIncidentReportsTable> {
  $$LocalIncidentReportsTableOrderingComposer({
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

  ColumnOrderings<String> get incidentId => $composableBuilder(
    column: $table.incidentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reporterId => $composableBuilder(
    column: $table.reporterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get severity => $composableBuilder(
    column: $table.severity,
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

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalIncidentReportsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalIncidentReportsTable> {
  $$LocalIncidentReportsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get incidentId => $composableBuilder(
    column: $table.incidentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reporterId => $composableBuilder(
    column: $table.reporterId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);
}

class $$LocalIncidentReportsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalIncidentReportsTable,
          LocalIncidentReport,
          $$LocalIncidentReportsTableFilterComposer,
          $$LocalIncidentReportsTableOrderingComposer,
          $$LocalIncidentReportsTableAnnotationComposer,
          $$LocalIncidentReportsTableCreateCompanionBuilder,
          $$LocalIncidentReportsTableUpdateCompanionBuilder,
          (
            LocalIncidentReport,
            BaseReferences<
              _$AppDatabase,
              $LocalIncidentReportsTable,
              LocalIncidentReport
            >,
          ),
          LocalIncidentReport,
          PrefetchHooks Function()
        > {
  $$LocalIncidentReportsTableTableManager(
    _$AppDatabase db,
    $LocalIncidentReportsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalIncidentReportsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalIncidentReportsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalIncidentReportsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> incidentId = const Value.absent(),
                Value<String?> reporterId = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> severity = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalIncidentReportsCompanion(
                id: id,
                incidentId: incidentId,
                reporterId: reporterId,
                latitude: latitude,
                longitude: longitude,
                description: description,
                severity: severity,
                createdAt: createdAt,
                updatedAt: updatedAt,
                version: version,
                isSynced: isSynced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> incidentId = const Value.absent(),
                Value<String?> reporterId = const Value.absent(),
                required double latitude,
                required double longitude,
                Value<String> description = const Value.absent(),
                Value<String> severity = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> version = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalIncidentReportsCompanion.insert(
                id: id,
                incidentId: incidentId,
                reporterId: reporterId,
                latitude: latitude,
                longitude: longitude,
                description: description,
                severity: severity,
                createdAt: createdAt,
                updatedAt: updatedAt,
                version: version,
                isSynced: isSynced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalIncidentReportsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalIncidentReportsTable,
      LocalIncidentReport,
      $$LocalIncidentReportsTableFilterComposer,
      $$LocalIncidentReportsTableOrderingComposer,
      $$LocalIncidentReportsTableAnnotationComposer,
      $$LocalIncidentReportsTableCreateCompanionBuilder,
      $$LocalIncidentReportsTableUpdateCompanionBuilder,
      (
        LocalIncidentReport,
        BaseReferences<
          _$AppDatabase,
          $LocalIncidentReportsTable,
          LocalIncidentReport
        >,
      ),
      LocalIncidentReport,
      PrefetchHooks Function()
    >;
typedef $$LocalSheltersTableCreateCompanionBuilder =
    LocalSheltersCompanion Function({
      required String id,
      required String name,
      required double latitude,
      required double longitude,
      Value<int> capacityTotal,
      Value<int> occupancy,
      Value<String> facilitiesJson,
      Value<double?> accessQuality,
      required DateTime updatedAt,
      Value<int> version,
      Value<int> rowid,
    });
typedef $$LocalSheltersTableUpdateCompanionBuilder =
    LocalSheltersCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<double> latitude,
      Value<double> longitude,
      Value<int> capacityTotal,
      Value<int> occupancy,
      Value<String> facilitiesJson,
      Value<double?> accessQuality,
      Value<DateTime> updatedAt,
      Value<int> version,
      Value<int> rowid,
    });

class $$LocalSheltersTableFilterComposer
    extends Composer<_$AppDatabase, $LocalSheltersTable> {
  $$LocalSheltersTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get capacityTotal => $composableBuilder(
    column: $table.capacityTotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get occupancy => $composableBuilder(
    column: $table.occupancy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get facilitiesJson => $composableBuilder(
    column: $table.facilitiesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accessQuality => $composableBuilder(
    column: $table.accessQuality,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalSheltersTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalSheltersTable> {
  $$LocalSheltersTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get capacityTotal => $composableBuilder(
    column: $table.capacityTotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get occupancy => $composableBuilder(
    column: $table.occupancy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get facilitiesJson => $composableBuilder(
    column: $table.facilitiesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accessQuality => $composableBuilder(
    column: $table.accessQuality,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalSheltersTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalSheltersTable> {
  $$LocalSheltersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<int> get capacityTotal => $composableBuilder(
    column: $table.capacityTotal,
    builder: (column) => column,
  );

  GeneratedColumn<int> get occupancy =>
      $composableBuilder(column: $table.occupancy, builder: (column) => column);

  GeneratedColumn<String> get facilitiesJson => $composableBuilder(
    column: $table.facilitiesJson,
    builder: (column) => column,
  );

  GeneratedColumn<double> get accessQuality => $composableBuilder(
    column: $table.accessQuality,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);
}

class $$LocalSheltersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalSheltersTable,
          LocalShelter,
          $$LocalSheltersTableFilterComposer,
          $$LocalSheltersTableOrderingComposer,
          $$LocalSheltersTableAnnotationComposer,
          $$LocalSheltersTableCreateCompanionBuilder,
          $$LocalSheltersTableUpdateCompanionBuilder,
          (
            LocalShelter,
            BaseReferences<_$AppDatabase, $LocalSheltersTable, LocalShelter>,
          ),
          LocalShelter,
          PrefetchHooks Function()
        > {
  $$LocalSheltersTableTableManager(_$AppDatabase db, $LocalSheltersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalSheltersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalSheltersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalSheltersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<int> capacityTotal = const Value.absent(),
                Value<int> occupancy = const Value.absent(),
                Value<String> facilitiesJson = const Value.absent(),
                Value<double?> accessQuality = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalSheltersCompanion(
                id: id,
                name: name,
                latitude: latitude,
                longitude: longitude,
                capacityTotal: capacityTotal,
                occupancy: occupancy,
                facilitiesJson: facilitiesJson,
                accessQuality: accessQuality,
                updatedAt: updatedAt,
                version: version,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required double latitude,
                required double longitude,
                Value<int> capacityTotal = const Value.absent(),
                Value<int> occupancy = const Value.absent(),
                Value<String> facilitiesJson = const Value.absent(),
                Value<double?> accessQuality = const Value.absent(),
                required DateTime updatedAt,
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalSheltersCompanion.insert(
                id: id,
                name: name,
                latitude: latitude,
                longitude: longitude,
                capacityTotal: capacityTotal,
                occupancy: occupancy,
                facilitiesJson: facilitiesJson,
                accessQuality: accessQuality,
                updatedAt: updatedAt,
                version: version,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalSheltersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalSheltersTable,
      LocalShelter,
      $$LocalSheltersTableFilterComposer,
      $$LocalSheltersTableOrderingComposer,
      $$LocalSheltersTableAnnotationComposer,
      $$LocalSheltersTableCreateCompanionBuilder,
      $$LocalSheltersTableUpdateCompanionBuilder,
      (
        LocalShelter,
        BaseReferences<_$AppDatabase, $LocalSheltersTable, LocalShelter>,
      ),
      LocalShelter,
      PrefetchHooks Function()
    >;
typedef $$LocalRoutesTableCreateCompanionBuilder =
    LocalRoutesCompanion Function({
      required String id,
      required double originLat,
      required double originLng,
      required double destLat,
      required double destLng,
      required String polylineJson,
      Value<double> distanceMeters,
      Value<int> etaSeconds,
      required DateTime cachedAt,
      Value<int> version,
      Value<int> rowid,
    });
typedef $$LocalRoutesTableUpdateCompanionBuilder =
    LocalRoutesCompanion Function({
      Value<String> id,
      Value<double> originLat,
      Value<double> originLng,
      Value<double> destLat,
      Value<double> destLng,
      Value<String> polylineJson,
      Value<double> distanceMeters,
      Value<int> etaSeconds,
      Value<DateTime> cachedAt,
      Value<int> version,
      Value<int> rowid,
    });

class $$LocalRoutesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalRoutesTable> {
  $$LocalRoutesTableFilterComposer({
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

  ColumnFilters<double> get originLat => $composableBuilder(
    column: $table.originLat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get originLng => $composableBuilder(
    column: $table.originLng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get destLat => $composableBuilder(
    column: $table.destLat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get destLng => $composableBuilder(
    column: $table.destLng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get polylineJson => $composableBuilder(
    column: $table.polylineJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get etaSeconds => $composableBuilder(
    column: $table.etaSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalRoutesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalRoutesTable> {
  $$LocalRoutesTableOrderingComposer({
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

  ColumnOrderings<double> get originLat => $composableBuilder(
    column: $table.originLat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get originLng => $composableBuilder(
    column: $table.originLng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get destLat => $composableBuilder(
    column: $table.destLat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get destLng => $composableBuilder(
    column: $table.destLng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get polylineJson => $composableBuilder(
    column: $table.polylineJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get etaSeconds => $composableBuilder(
    column: $table.etaSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalRoutesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalRoutesTable> {
  $$LocalRoutesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get originLat =>
      $composableBuilder(column: $table.originLat, builder: (column) => column);

  GeneratedColumn<double> get originLng =>
      $composableBuilder(column: $table.originLng, builder: (column) => column);

  GeneratedColumn<double> get destLat =>
      $composableBuilder(column: $table.destLat, builder: (column) => column);

  GeneratedColumn<double> get destLng =>
      $composableBuilder(column: $table.destLng, builder: (column) => column);

  GeneratedColumn<String> get polylineJson => $composableBuilder(
    column: $table.polylineJson,
    builder: (column) => column,
  );

  GeneratedColumn<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get etaSeconds => $composableBuilder(
    column: $table.etaSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);
}

class $$LocalRoutesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalRoutesTable,
          LocalRoute,
          $$LocalRoutesTableFilterComposer,
          $$LocalRoutesTableOrderingComposer,
          $$LocalRoutesTableAnnotationComposer,
          $$LocalRoutesTableCreateCompanionBuilder,
          $$LocalRoutesTableUpdateCompanionBuilder,
          (
            LocalRoute,
            BaseReferences<_$AppDatabase, $LocalRoutesTable, LocalRoute>,
          ),
          LocalRoute,
          PrefetchHooks Function()
        > {
  $$LocalRoutesTableTableManager(_$AppDatabase db, $LocalRoutesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalRoutesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalRoutesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalRoutesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<double> originLat = const Value.absent(),
                Value<double> originLng = const Value.absent(),
                Value<double> destLat = const Value.absent(),
                Value<double> destLng = const Value.absent(),
                Value<String> polylineJson = const Value.absent(),
                Value<double> distanceMeters = const Value.absent(),
                Value<int> etaSeconds = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalRoutesCompanion(
                id: id,
                originLat: originLat,
                originLng: originLng,
                destLat: destLat,
                destLng: destLng,
                polylineJson: polylineJson,
                distanceMeters: distanceMeters,
                etaSeconds: etaSeconds,
                cachedAt: cachedAt,
                version: version,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required double originLat,
                required double originLng,
                required double destLat,
                required double destLng,
                required String polylineJson,
                Value<double> distanceMeters = const Value.absent(),
                Value<int> etaSeconds = const Value.absent(),
                required DateTime cachedAt,
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalRoutesCompanion.insert(
                id: id,
                originLat: originLat,
                originLng: originLng,
                destLat: destLat,
                destLng: destLng,
                polylineJson: polylineJson,
                distanceMeters: distanceMeters,
                etaSeconds: etaSeconds,
                cachedAt: cachedAt,
                version: version,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalRoutesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalRoutesTable,
      LocalRoute,
      $$LocalRoutesTableFilterComposer,
      $$LocalRoutesTableOrderingComposer,
      $$LocalRoutesTableAnnotationComposer,
      $$LocalRoutesTableCreateCompanionBuilder,
      $$LocalRoutesTableUpdateCompanionBuilder,
      (
        LocalRoute,
        BaseReferences<_$AppDatabase, $LocalRoutesTable, LocalRoute>,
      ),
      LocalRoute,
      PrefetchHooks Function()
    >;
typedef $$LocalHabitationsTableCreateCompanionBuilder =
    LocalHabitationsCompanion Function({
      required String id,
      required String name,
      required double latitude,
      required double longitude,
      Value<int> population,
      Value<String?> administrativeRegionName,
      Value<double?> infrastructureQuality,
      Value<double?> accessQuality,
      required DateTime updatedAt,
      Value<int> version,
      Value<int> rowid,
    });
typedef $$LocalHabitationsTableUpdateCompanionBuilder =
    LocalHabitationsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<double> latitude,
      Value<double> longitude,
      Value<int> population,
      Value<String?> administrativeRegionName,
      Value<double?> infrastructureQuality,
      Value<double?> accessQuality,
      Value<DateTime> updatedAt,
      Value<int> version,
      Value<int> rowid,
    });

class $$LocalHabitationsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalHabitationsTable> {
  $$LocalHabitationsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get population => $composableBuilder(
    column: $table.population,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get administrativeRegionName => $composableBuilder(
    column: $table.administrativeRegionName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get infrastructureQuality => $composableBuilder(
    column: $table.infrastructureQuality,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accessQuality => $composableBuilder(
    column: $table.accessQuality,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalHabitationsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalHabitationsTable> {
  $$LocalHabitationsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get population => $composableBuilder(
    column: $table.population,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get administrativeRegionName => $composableBuilder(
    column: $table.administrativeRegionName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get infrastructureQuality => $composableBuilder(
    column: $table.infrastructureQuality,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accessQuality => $composableBuilder(
    column: $table.accessQuality,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalHabitationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalHabitationsTable> {
  $$LocalHabitationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<int> get population => $composableBuilder(
    column: $table.population,
    builder: (column) => column,
  );

  GeneratedColumn<String> get administrativeRegionName => $composableBuilder(
    column: $table.administrativeRegionName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get infrastructureQuality => $composableBuilder(
    column: $table.infrastructureQuality,
    builder: (column) => column,
  );

  GeneratedColumn<double> get accessQuality => $composableBuilder(
    column: $table.accessQuality,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);
}

class $$LocalHabitationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalHabitationsTable,
          LocalHabitation,
          $$LocalHabitationsTableFilterComposer,
          $$LocalHabitationsTableOrderingComposer,
          $$LocalHabitationsTableAnnotationComposer,
          $$LocalHabitationsTableCreateCompanionBuilder,
          $$LocalHabitationsTableUpdateCompanionBuilder,
          (
            LocalHabitation,
            BaseReferences<
              _$AppDatabase,
              $LocalHabitationsTable,
              LocalHabitation
            >,
          ),
          LocalHabitation,
          PrefetchHooks Function()
        > {
  $$LocalHabitationsTableTableManager(
    _$AppDatabase db,
    $LocalHabitationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalHabitationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalHabitationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalHabitationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<int> population = const Value.absent(),
                Value<String?> administrativeRegionName = const Value.absent(),
                Value<double?> infrastructureQuality = const Value.absent(),
                Value<double?> accessQuality = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalHabitationsCompanion(
                id: id,
                name: name,
                latitude: latitude,
                longitude: longitude,
                population: population,
                administrativeRegionName: administrativeRegionName,
                infrastructureQuality: infrastructureQuality,
                accessQuality: accessQuality,
                updatedAt: updatedAt,
                version: version,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required double latitude,
                required double longitude,
                Value<int> population = const Value.absent(),
                Value<String?> administrativeRegionName = const Value.absent(),
                Value<double?> infrastructureQuality = const Value.absent(),
                Value<double?> accessQuality = const Value.absent(),
                required DateTime updatedAt,
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalHabitationsCompanion.insert(
                id: id,
                name: name,
                latitude: latitude,
                longitude: longitude,
                population: population,
                administrativeRegionName: administrativeRegionName,
                infrastructureQuality: infrastructureQuality,
                accessQuality: accessQuality,
                updatedAt: updatedAt,
                version: version,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalHabitationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalHabitationsTable,
      LocalHabitation,
      $$LocalHabitationsTableFilterComposer,
      $$LocalHabitationsTableOrderingComposer,
      $$LocalHabitationsTableAnnotationComposer,
      $$LocalHabitationsTableCreateCompanionBuilder,
      $$LocalHabitationsTableUpdateCompanionBuilder,
      (
        LocalHabitation,
        BaseReferences<_$AppDatabase, $LocalHabitationsTable, LocalHabitation>,
      ),
      LocalHabitation,
      PrefetchHooks Function()
    >;
typedef $$LocalRiskAssessmentsTableCreateCompanionBuilder =
    LocalRiskAssessmentsCompanion Function({
      required String habitationId,
      required double hazardExposure,
      required double vulnerabilityIndex,
      required double riskScore,
      required String riskClass,
      required String modelVersion,
      Value<String> contributingHazardZoneIdsJson,
      required DateTime assessedAt,
      Value<int> version,
      Value<int> rowid,
    });
typedef $$LocalRiskAssessmentsTableUpdateCompanionBuilder =
    LocalRiskAssessmentsCompanion Function({
      Value<String> habitationId,
      Value<double> hazardExposure,
      Value<double> vulnerabilityIndex,
      Value<double> riskScore,
      Value<String> riskClass,
      Value<String> modelVersion,
      Value<String> contributingHazardZoneIdsJson,
      Value<DateTime> assessedAt,
      Value<int> version,
      Value<int> rowid,
    });

class $$LocalRiskAssessmentsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalRiskAssessmentsTable> {
  $$LocalRiskAssessmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get habitationId => $composableBuilder(
    column: $table.habitationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get hazardExposure => $composableBuilder(
    column: $table.hazardExposure,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get vulnerabilityIndex => $composableBuilder(
    column: $table.vulnerabilityIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get riskScore => $composableBuilder(
    column: $table.riskScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get riskClass => $composableBuilder(
    column: $table.riskClass,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contributingHazardZoneIdsJson => $composableBuilder(
    column: $table.contributingHazardZoneIdsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get assessedAt => $composableBuilder(
    column: $table.assessedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalRiskAssessmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalRiskAssessmentsTable> {
  $$LocalRiskAssessmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get habitationId => $composableBuilder(
    column: $table.habitationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hazardExposure => $composableBuilder(
    column: $table.hazardExposure,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get vulnerabilityIndex => $composableBuilder(
    column: $table.vulnerabilityIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get riskScore => $composableBuilder(
    column: $table.riskScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get riskClass => $composableBuilder(
    column: $table.riskClass,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contributingHazardZoneIdsJson =>
      $composableBuilder(
        column: $table.contributingHazardZoneIdsJson,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<DateTime> get assessedAt => $composableBuilder(
    column: $table.assessedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalRiskAssessmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalRiskAssessmentsTable> {
  $$LocalRiskAssessmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get habitationId => $composableBuilder(
    column: $table.habitationId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get hazardExposure => $composableBuilder(
    column: $table.hazardExposure,
    builder: (column) => column,
  );

  GeneratedColumn<double> get vulnerabilityIndex => $composableBuilder(
    column: $table.vulnerabilityIndex,
    builder: (column) => column,
  );

  GeneratedColumn<double> get riskScore =>
      $composableBuilder(column: $table.riskScore, builder: (column) => column);

  GeneratedColumn<String> get riskClass =>
      $composableBuilder(column: $table.riskClass, builder: (column) => column);

  GeneratedColumn<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contributingHazardZoneIdsJson =>
      $composableBuilder(
        column: $table.contributingHazardZoneIdsJson,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get assessedAt => $composableBuilder(
    column: $table.assessedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);
}

class $$LocalRiskAssessmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalRiskAssessmentsTable,
          LocalRiskAssessment,
          $$LocalRiskAssessmentsTableFilterComposer,
          $$LocalRiskAssessmentsTableOrderingComposer,
          $$LocalRiskAssessmentsTableAnnotationComposer,
          $$LocalRiskAssessmentsTableCreateCompanionBuilder,
          $$LocalRiskAssessmentsTableUpdateCompanionBuilder,
          (
            LocalRiskAssessment,
            BaseReferences<
              _$AppDatabase,
              $LocalRiskAssessmentsTable,
              LocalRiskAssessment
            >,
          ),
          LocalRiskAssessment,
          PrefetchHooks Function()
        > {
  $$LocalRiskAssessmentsTableTableManager(
    _$AppDatabase db,
    $LocalRiskAssessmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalRiskAssessmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalRiskAssessmentsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalRiskAssessmentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> habitationId = const Value.absent(),
                Value<double> hazardExposure = const Value.absent(),
                Value<double> vulnerabilityIndex = const Value.absent(),
                Value<double> riskScore = const Value.absent(),
                Value<String> riskClass = const Value.absent(),
                Value<String> modelVersion = const Value.absent(),
                Value<String> contributingHazardZoneIdsJson =
                    const Value.absent(),
                Value<DateTime> assessedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalRiskAssessmentsCompanion(
                habitationId: habitationId,
                hazardExposure: hazardExposure,
                vulnerabilityIndex: vulnerabilityIndex,
                riskScore: riskScore,
                riskClass: riskClass,
                modelVersion: modelVersion,
                contributingHazardZoneIdsJson: contributingHazardZoneIdsJson,
                assessedAt: assessedAt,
                version: version,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String habitationId,
                required double hazardExposure,
                required double vulnerabilityIndex,
                required double riskScore,
                required String riskClass,
                required String modelVersion,
                Value<String> contributingHazardZoneIdsJson =
                    const Value.absent(),
                required DateTime assessedAt,
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalRiskAssessmentsCompanion.insert(
                habitationId: habitationId,
                hazardExposure: hazardExposure,
                vulnerabilityIndex: vulnerabilityIndex,
                riskScore: riskScore,
                riskClass: riskClass,
                modelVersion: modelVersion,
                contributingHazardZoneIdsJson: contributingHazardZoneIdsJson,
                assessedAt: assessedAt,
                version: version,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalRiskAssessmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalRiskAssessmentsTable,
      LocalRiskAssessment,
      $$LocalRiskAssessmentsTableFilterComposer,
      $$LocalRiskAssessmentsTableOrderingComposer,
      $$LocalRiskAssessmentsTableAnnotationComposer,
      $$LocalRiskAssessmentsTableCreateCompanionBuilder,
      $$LocalRiskAssessmentsTableUpdateCompanionBuilder,
      (
        LocalRiskAssessment,
        BaseReferences<
          _$AppDatabase,
          $LocalRiskAssessmentsTable,
          LocalRiskAssessment
        >,
      ),
      LocalRiskAssessment,
      PrefetchHooks Function()
    >;
typedef $$LocalVulnerabilityAssessmentsTableCreateCompanionBuilder =
    LocalVulnerabilityAssessmentsCompanion Function({
      required String habitationId,
      required double vulnerabilityIndex,
      required String factorsJson,
      required String modelVersion,
      required DateTime assessedAt,
      Value<int> version,
      Value<int> rowid,
    });
typedef $$LocalVulnerabilityAssessmentsTableUpdateCompanionBuilder =
    LocalVulnerabilityAssessmentsCompanion Function({
      Value<String> habitationId,
      Value<double> vulnerabilityIndex,
      Value<String> factorsJson,
      Value<String> modelVersion,
      Value<DateTime> assessedAt,
      Value<int> version,
      Value<int> rowid,
    });

class $$LocalVulnerabilityAssessmentsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalVulnerabilityAssessmentsTable> {
  $$LocalVulnerabilityAssessmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get habitationId => $composableBuilder(
    column: $table.habitationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get vulnerabilityIndex => $composableBuilder(
    column: $table.vulnerabilityIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get factorsJson => $composableBuilder(
    column: $table.factorsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get assessedAt => $composableBuilder(
    column: $table.assessedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalVulnerabilityAssessmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalVulnerabilityAssessmentsTable> {
  $$LocalVulnerabilityAssessmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get habitationId => $composableBuilder(
    column: $table.habitationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get vulnerabilityIndex => $composableBuilder(
    column: $table.vulnerabilityIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get factorsJson => $composableBuilder(
    column: $table.factorsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get assessedAt => $composableBuilder(
    column: $table.assessedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalVulnerabilityAssessmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalVulnerabilityAssessmentsTable> {
  $$LocalVulnerabilityAssessmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get habitationId => $composableBuilder(
    column: $table.habitationId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get vulnerabilityIndex => $composableBuilder(
    column: $table.vulnerabilityIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get factorsJson => $composableBuilder(
    column: $table.factorsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get assessedAt => $composableBuilder(
    column: $table.assessedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);
}

class $$LocalVulnerabilityAssessmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalVulnerabilityAssessmentsTable,
          LocalVulnerabilityAssessment,
          $$LocalVulnerabilityAssessmentsTableFilterComposer,
          $$LocalVulnerabilityAssessmentsTableOrderingComposer,
          $$LocalVulnerabilityAssessmentsTableAnnotationComposer,
          $$LocalVulnerabilityAssessmentsTableCreateCompanionBuilder,
          $$LocalVulnerabilityAssessmentsTableUpdateCompanionBuilder,
          (
            LocalVulnerabilityAssessment,
            BaseReferences<
              _$AppDatabase,
              $LocalVulnerabilityAssessmentsTable,
              LocalVulnerabilityAssessment
            >,
          ),
          LocalVulnerabilityAssessment,
          PrefetchHooks Function()
        > {
  $$LocalVulnerabilityAssessmentsTableTableManager(
    _$AppDatabase db,
    $LocalVulnerabilityAssessmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalVulnerabilityAssessmentsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LocalVulnerabilityAssessmentsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalVulnerabilityAssessmentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> habitationId = const Value.absent(),
                Value<double> vulnerabilityIndex = const Value.absent(),
                Value<String> factorsJson = const Value.absent(),
                Value<String> modelVersion = const Value.absent(),
                Value<DateTime> assessedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalVulnerabilityAssessmentsCompanion(
                habitationId: habitationId,
                vulnerabilityIndex: vulnerabilityIndex,
                factorsJson: factorsJson,
                modelVersion: modelVersion,
                assessedAt: assessedAt,
                version: version,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String habitationId,
                required double vulnerabilityIndex,
                required String factorsJson,
                required String modelVersion,
                required DateTime assessedAt,
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalVulnerabilityAssessmentsCompanion.insert(
                habitationId: habitationId,
                vulnerabilityIndex: vulnerabilityIndex,
                factorsJson: factorsJson,
                modelVersion: modelVersion,
                assessedAt: assessedAt,
                version: version,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalVulnerabilityAssessmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalVulnerabilityAssessmentsTable,
      LocalVulnerabilityAssessment,
      $$LocalVulnerabilityAssessmentsTableFilterComposer,
      $$LocalVulnerabilityAssessmentsTableOrderingComposer,
      $$LocalVulnerabilityAssessmentsTableAnnotationComposer,
      $$LocalVulnerabilityAssessmentsTableCreateCompanionBuilder,
      $$LocalVulnerabilityAssessmentsTableUpdateCompanionBuilder,
      (
        LocalVulnerabilityAssessment,
        BaseReferences<
          _$AppDatabase,
          $LocalVulnerabilityAssessmentsTable,
          LocalVulnerabilityAssessment
        >,
      ),
      LocalVulnerabilityAssessment,
      PrefetchHooks Function()
    >;
typedef $$LocalCapacityAssessmentsTableCreateCompanionBuilder =
    LocalCapacityAssessmentsCompanion Function({
      required String habitationId,
      required int exposedPopulation,
      required int availableSafeCapacity,
      required int capacityGap,
      required bool hasSufficientCapacity,
      required String contributingSheltersJson,
      required double accessibleRadiusMeters,
      required String modelVersion,
      required DateTime assessedAt,
      Value<int> version,
      Value<int> rowid,
    });
typedef $$LocalCapacityAssessmentsTableUpdateCompanionBuilder =
    LocalCapacityAssessmentsCompanion Function({
      Value<String> habitationId,
      Value<int> exposedPopulation,
      Value<int> availableSafeCapacity,
      Value<int> capacityGap,
      Value<bool> hasSufficientCapacity,
      Value<String> contributingSheltersJson,
      Value<double> accessibleRadiusMeters,
      Value<String> modelVersion,
      Value<DateTime> assessedAt,
      Value<int> version,
      Value<int> rowid,
    });

class $$LocalCapacityAssessmentsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalCapacityAssessmentsTable> {
  $$LocalCapacityAssessmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get habitationId => $composableBuilder(
    column: $table.habitationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get exposedPopulation => $composableBuilder(
    column: $table.exposedPopulation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get availableSafeCapacity => $composableBuilder(
    column: $table.availableSafeCapacity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get capacityGap => $composableBuilder(
    column: $table.capacityGap,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasSufficientCapacity => $composableBuilder(
    column: $table.hasSufficientCapacity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contributingSheltersJson => $composableBuilder(
    column: $table.contributingSheltersJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accessibleRadiusMeters => $composableBuilder(
    column: $table.accessibleRadiusMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get assessedAt => $composableBuilder(
    column: $table.assessedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalCapacityAssessmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalCapacityAssessmentsTable> {
  $$LocalCapacityAssessmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get habitationId => $composableBuilder(
    column: $table.habitationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get exposedPopulation => $composableBuilder(
    column: $table.exposedPopulation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get availableSafeCapacity => $composableBuilder(
    column: $table.availableSafeCapacity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get capacityGap => $composableBuilder(
    column: $table.capacityGap,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasSufficientCapacity => $composableBuilder(
    column: $table.hasSufficientCapacity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contributingSheltersJson => $composableBuilder(
    column: $table.contributingSheltersJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accessibleRadiusMeters => $composableBuilder(
    column: $table.accessibleRadiusMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get assessedAt => $composableBuilder(
    column: $table.assessedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalCapacityAssessmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalCapacityAssessmentsTable> {
  $$LocalCapacityAssessmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get habitationId => $composableBuilder(
    column: $table.habitationId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get exposedPopulation => $composableBuilder(
    column: $table.exposedPopulation,
    builder: (column) => column,
  );

  GeneratedColumn<int> get availableSafeCapacity => $composableBuilder(
    column: $table.availableSafeCapacity,
    builder: (column) => column,
  );

  GeneratedColumn<int> get capacityGap => $composableBuilder(
    column: $table.capacityGap,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasSufficientCapacity => $composableBuilder(
    column: $table.hasSufficientCapacity,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contributingSheltersJson => $composableBuilder(
    column: $table.contributingSheltersJson,
    builder: (column) => column,
  );

  GeneratedColumn<double> get accessibleRadiusMeters => $composableBuilder(
    column: $table.accessibleRadiusMeters,
    builder: (column) => column,
  );

  GeneratedColumn<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get assessedAt => $composableBuilder(
    column: $table.assessedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);
}

class $$LocalCapacityAssessmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalCapacityAssessmentsTable,
          LocalCapacityAssessment,
          $$LocalCapacityAssessmentsTableFilterComposer,
          $$LocalCapacityAssessmentsTableOrderingComposer,
          $$LocalCapacityAssessmentsTableAnnotationComposer,
          $$LocalCapacityAssessmentsTableCreateCompanionBuilder,
          $$LocalCapacityAssessmentsTableUpdateCompanionBuilder,
          (
            LocalCapacityAssessment,
            BaseReferences<
              _$AppDatabase,
              $LocalCapacityAssessmentsTable,
              LocalCapacityAssessment
            >,
          ),
          LocalCapacityAssessment,
          PrefetchHooks Function()
        > {
  $$LocalCapacityAssessmentsTableTableManager(
    _$AppDatabase db,
    $LocalCapacityAssessmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalCapacityAssessmentsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LocalCapacityAssessmentsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalCapacityAssessmentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> habitationId = const Value.absent(),
                Value<int> exposedPopulation = const Value.absent(),
                Value<int> availableSafeCapacity = const Value.absent(),
                Value<int> capacityGap = const Value.absent(),
                Value<bool> hasSufficientCapacity = const Value.absent(),
                Value<String> contributingSheltersJson = const Value.absent(),
                Value<double> accessibleRadiusMeters = const Value.absent(),
                Value<String> modelVersion = const Value.absent(),
                Value<DateTime> assessedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalCapacityAssessmentsCompanion(
                habitationId: habitationId,
                exposedPopulation: exposedPopulation,
                availableSafeCapacity: availableSafeCapacity,
                capacityGap: capacityGap,
                hasSufficientCapacity: hasSufficientCapacity,
                contributingSheltersJson: contributingSheltersJson,
                accessibleRadiusMeters: accessibleRadiusMeters,
                modelVersion: modelVersion,
                assessedAt: assessedAt,
                version: version,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String habitationId,
                required int exposedPopulation,
                required int availableSafeCapacity,
                required int capacityGap,
                required bool hasSufficientCapacity,
                required String contributingSheltersJson,
                required double accessibleRadiusMeters,
                required String modelVersion,
                required DateTime assessedAt,
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalCapacityAssessmentsCompanion.insert(
                habitationId: habitationId,
                exposedPopulation: exposedPopulation,
                availableSafeCapacity: availableSafeCapacity,
                capacityGap: capacityGap,
                hasSufficientCapacity: hasSufficientCapacity,
                contributingSheltersJson: contributingSheltersJson,
                accessibleRadiusMeters: accessibleRadiusMeters,
                modelVersion: modelVersion,
                assessedAt: assessedAt,
                version: version,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalCapacityAssessmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalCapacityAssessmentsTable,
      LocalCapacityAssessment,
      $$LocalCapacityAssessmentsTableFilterComposer,
      $$LocalCapacityAssessmentsTableOrderingComposer,
      $$LocalCapacityAssessmentsTableAnnotationComposer,
      $$LocalCapacityAssessmentsTableCreateCompanionBuilder,
      $$LocalCapacityAssessmentsTableUpdateCompanionBuilder,
      (
        LocalCapacityAssessment,
        BaseReferences<
          _$AppDatabase,
          $LocalCapacityAssessmentsTable,
          LocalCapacityAssessment
        >,
      ),
      LocalCapacityAssessment,
      PrefetchHooks Function()
    >;
typedef $$LocalRelocationPlansTableCreateCompanionBuilder =
    LocalRelocationPlansCompanion Function({
      required String habitationId,
      required int populationToRelocate,
      required String rankedCandidatesJson,
      required String modelVersion,
      required DateTime plannedAt,
      Value<int> version,
      Value<int> rowid,
    });
typedef $$LocalRelocationPlansTableUpdateCompanionBuilder =
    LocalRelocationPlansCompanion Function({
      Value<String> habitationId,
      Value<int> populationToRelocate,
      Value<String> rankedCandidatesJson,
      Value<String> modelVersion,
      Value<DateTime> plannedAt,
      Value<int> version,
      Value<int> rowid,
    });

class $$LocalRelocationPlansTableFilterComposer
    extends Composer<_$AppDatabase, $LocalRelocationPlansTable> {
  $$LocalRelocationPlansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get habitationId => $composableBuilder(
    column: $table.habitationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get populationToRelocate => $composableBuilder(
    column: $table.populationToRelocate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rankedCandidatesJson => $composableBuilder(
    column: $table.rankedCandidatesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get plannedAt => $composableBuilder(
    column: $table.plannedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalRelocationPlansTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalRelocationPlansTable> {
  $$LocalRelocationPlansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get habitationId => $composableBuilder(
    column: $table.habitationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get populationToRelocate => $composableBuilder(
    column: $table.populationToRelocate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rankedCandidatesJson => $composableBuilder(
    column: $table.rankedCandidatesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get plannedAt => $composableBuilder(
    column: $table.plannedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalRelocationPlansTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalRelocationPlansTable> {
  $$LocalRelocationPlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get habitationId => $composableBuilder(
    column: $table.habitationId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get populationToRelocate => $composableBuilder(
    column: $table.populationToRelocate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rankedCandidatesJson => $composableBuilder(
    column: $table.rankedCandidatesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get plannedAt =>
      $composableBuilder(column: $table.plannedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);
}

class $$LocalRelocationPlansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalRelocationPlansTable,
          LocalRelocationPlan,
          $$LocalRelocationPlansTableFilterComposer,
          $$LocalRelocationPlansTableOrderingComposer,
          $$LocalRelocationPlansTableAnnotationComposer,
          $$LocalRelocationPlansTableCreateCompanionBuilder,
          $$LocalRelocationPlansTableUpdateCompanionBuilder,
          (
            LocalRelocationPlan,
            BaseReferences<
              _$AppDatabase,
              $LocalRelocationPlansTable,
              LocalRelocationPlan
            >,
          ),
          LocalRelocationPlan,
          PrefetchHooks Function()
        > {
  $$LocalRelocationPlansTableTableManager(
    _$AppDatabase db,
    $LocalRelocationPlansTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalRelocationPlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalRelocationPlansTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalRelocationPlansTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> habitationId = const Value.absent(),
                Value<int> populationToRelocate = const Value.absent(),
                Value<String> rankedCandidatesJson = const Value.absent(),
                Value<String> modelVersion = const Value.absent(),
                Value<DateTime> plannedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalRelocationPlansCompanion(
                habitationId: habitationId,
                populationToRelocate: populationToRelocate,
                rankedCandidatesJson: rankedCandidatesJson,
                modelVersion: modelVersion,
                plannedAt: plannedAt,
                version: version,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String habitationId,
                required int populationToRelocate,
                required String rankedCandidatesJson,
                required String modelVersion,
                required DateTime plannedAt,
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalRelocationPlansCompanion.insert(
                habitationId: habitationId,
                populationToRelocate: populationToRelocate,
                rankedCandidatesJson: rankedCandidatesJson,
                modelVersion: modelVersion,
                plannedAt: plannedAt,
                version: version,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalRelocationPlansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalRelocationPlansTable,
      LocalRelocationPlan,
      $$LocalRelocationPlansTableFilterComposer,
      $$LocalRelocationPlansTableOrderingComposer,
      $$LocalRelocationPlansTableAnnotationComposer,
      $$LocalRelocationPlansTableCreateCompanionBuilder,
      $$LocalRelocationPlansTableUpdateCompanionBuilder,
      (
        LocalRelocationPlan,
        BaseReferences<
          _$AppDatabase,
          $LocalRelocationPlansTable,
          LocalRelocationPlan
        >,
      ),
      LocalRelocationPlan,
      PrefetchHooks Function()
    >;
typedef $$SyncQueueEntriesTableCreateCompanionBuilder =
    SyncQueueEntriesCompanion Function({
      Value<int> id,
      required String entityTable,
      required String entityId,
      required String operation,
      required String payloadJson,
      required DateTime createdAt,
      Value<int> attemptCount,
      Value<DateTime?> lastAttemptAt,
      Value<String> status,
    });
typedef $$SyncQueueEntriesTableUpdateCompanionBuilder =
    SyncQueueEntriesCompanion Function({
      Value<int> id,
      Value<String> entityTable,
      Value<String> entityId,
      Value<String> operation,
      Value<String> payloadJson,
      Value<DateTime> createdAt,
      Value<int> attemptCount,
      Value<DateTime?> lastAttemptAt,
      Value<String> status,
    });

class $$SyncQueueEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueEntriesTable> {
  $$SyncQueueEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityTable => $composableBuilder(
    column: $table.entityTable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncQueueEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueEntriesTable> {
  $$SyncQueueEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityTable => $composableBuilder(
    column: $table.entityTable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncQueueEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueEntriesTable> {
  $$SyncQueueEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityTable => $composableBuilder(
    column: $table.entityTable,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$SyncQueueEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQueueEntriesTable,
          SyncQueueEntry,
          $$SyncQueueEntriesTableFilterComposer,
          $$SyncQueueEntriesTableOrderingComposer,
          $$SyncQueueEntriesTableAnnotationComposer,
          $$SyncQueueEntriesTableCreateCompanionBuilder,
          $$SyncQueueEntriesTableUpdateCompanionBuilder,
          (
            SyncQueueEntry,
            BaseReferences<
              _$AppDatabase,
              $SyncQueueEntriesTable,
              SyncQueueEntry
            >,
          ),
          SyncQueueEntry,
          PrefetchHooks Function()
        > {
  $$SyncQueueEntriesTableTableManager(
    _$AppDatabase db,
    $SyncQueueEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> entityTable = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<DateTime?> lastAttemptAt = const Value.absent(),
                Value<String> status = const Value.absent(),
              }) => SyncQueueEntriesCompanion(
                id: id,
                entityTable: entityTable,
                entityId: entityId,
                operation: operation,
                payloadJson: payloadJson,
                createdAt: createdAt,
                attemptCount: attemptCount,
                lastAttemptAt: lastAttemptAt,
                status: status,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String entityTable,
                required String entityId,
                required String operation,
                required String payloadJson,
                required DateTime createdAt,
                Value<int> attemptCount = const Value.absent(),
                Value<DateTime?> lastAttemptAt = const Value.absent(),
                Value<String> status = const Value.absent(),
              }) => SyncQueueEntriesCompanion.insert(
                id: id,
                entityTable: entityTable,
                entityId: entityId,
                operation: operation,
                payloadJson: payloadJson,
                createdAt: createdAt,
                attemptCount: attemptCount,
                lastAttemptAt: lastAttemptAt,
                status: status,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncQueueEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncQueueEntriesTable,
      SyncQueueEntry,
      $$SyncQueueEntriesTableFilterComposer,
      $$SyncQueueEntriesTableOrderingComposer,
      $$SyncQueueEntriesTableAnnotationComposer,
      $$SyncQueueEntriesTableCreateCompanionBuilder,
      $$SyncQueueEntriesTableUpdateCompanionBuilder,
      (
        SyncQueueEntry,
        BaseReferences<_$AppDatabase, $SyncQueueEntriesTable, SyncQueueEntry>,
      ),
      SyncQueueEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalUsersTableTableManager get localUsers =>
      $$LocalUsersTableTableManager(_db, _db.localUsers);
  $$LocalHazardZonesTableTableManager get localHazardZones =>
      $$LocalHazardZonesTableTableManager(_db, _db.localHazardZones);
  $$LocalIncidentsTableTableManager get localIncidents =>
      $$LocalIncidentsTableTableManager(_db, _db.localIncidents);
  $$LocalIncidentReportsTableTableManager get localIncidentReports =>
      $$LocalIncidentReportsTableTableManager(_db, _db.localIncidentReports);
  $$LocalSheltersTableTableManager get localShelters =>
      $$LocalSheltersTableTableManager(_db, _db.localShelters);
  $$LocalRoutesTableTableManager get localRoutes =>
      $$LocalRoutesTableTableManager(_db, _db.localRoutes);
  $$LocalHabitationsTableTableManager get localHabitations =>
      $$LocalHabitationsTableTableManager(_db, _db.localHabitations);
  $$LocalRiskAssessmentsTableTableManager get localRiskAssessments =>
      $$LocalRiskAssessmentsTableTableManager(_db, _db.localRiskAssessments);
  $$LocalVulnerabilityAssessmentsTableTableManager
  get localVulnerabilityAssessments =>
      $$LocalVulnerabilityAssessmentsTableTableManager(
        _db,
        _db.localVulnerabilityAssessments,
      );
  $$LocalCapacityAssessmentsTableTableManager get localCapacityAssessments =>
      $$LocalCapacityAssessmentsTableTableManager(
        _db,
        _db.localCapacityAssessments,
      );
  $$LocalRelocationPlansTableTableManager get localRelocationPlans =>
      $$LocalRelocationPlansTableTableManager(_db, _db.localRelocationPlans);
  $$SyncQueueEntriesTableTableManager get syncQueueEntries =>
      $$SyncQueueEntriesTableTableManager(_db, _db.syncQueueEntries);
}
