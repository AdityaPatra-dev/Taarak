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

class $LocalHazardAutomationStatesTable extends LocalHazardAutomationStates
    with
        TableInfo<
          $LocalHazardAutomationStatesTable,
          LocalHazardAutomationState
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalHazardAutomationStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
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
  static const VerificationMeta _lastScoreMeta = const VerificationMeta(
    'lastScore',
  );
  @override
  late final GeneratedColumn<double> lastScore = GeneratedColumn<double>(
    'last_score',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _consecutiveBelowDeleteThresholdMeta =
      const VerificationMeta('consecutiveBelowDeleteThreshold');
  @override
  late final GeneratedColumn<int> consecutiveBelowDeleteThreshold =
      GeneratedColumn<int>(
        'consecutive_below_delete_threshold',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _zoneActiveMeta = const VerificationMeta(
    'zoneActive',
  );
  @override
  late final GeneratedColumn<bool> zoneActive = GeneratedColumn<bool>(
    'zone_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("zone_active" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastEvaluatedAtMeta = const VerificationMeta(
    'lastEvaluatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastEvaluatedAt =
      GeneratedColumn<DateTime>(
        'last_evaluated_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    habitationId,
    hazardType,
    lastScore,
    consecutiveBelowDeleteThreshold,
    zoneActive,
    lastEvaluatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_hazard_automation_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalHazardAutomationState> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
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
    if (data.containsKey('hazard_type')) {
      context.handle(
        _hazardTypeMeta,
        hazardType.isAcceptableOrUnknown(data['hazard_type']!, _hazardTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_hazardTypeMeta);
    }
    if (data.containsKey('last_score')) {
      context.handle(
        _lastScoreMeta,
        lastScore.isAcceptableOrUnknown(data['last_score']!, _lastScoreMeta),
      );
    } else if (isInserting) {
      context.missing(_lastScoreMeta);
    }
    if (data.containsKey('consecutive_below_delete_threshold')) {
      context.handle(
        _consecutiveBelowDeleteThresholdMeta,
        consecutiveBelowDeleteThreshold.isAcceptableOrUnknown(
          data['consecutive_below_delete_threshold']!,
          _consecutiveBelowDeleteThresholdMeta,
        ),
      );
    }
    if (data.containsKey('zone_active')) {
      context.handle(
        _zoneActiveMeta,
        zoneActive.isAcceptableOrUnknown(data['zone_active']!, _zoneActiveMeta),
      );
    }
    if (data.containsKey('last_evaluated_at')) {
      context.handle(
        _lastEvaluatedAtMeta,
        lastEvaluatedAt.isAcceptableOrUnknown(
          data['last_evaluated_at']!,
          _lastEvaluatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastEvaluatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalHazardAutomationState map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalHazardAutomationState(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      habitationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}habitation_id'],
      )!,
      hazardType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hazard_type'],
      )!,
      lastScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}last_score'],
      )!,
      consecutiveBelowDeleteThreshold: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}consecutive_below_delete_threshold'],
      )!,
      zoneActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}zone_active'],
      )!,
      lastEvaluatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_evaluated_at'],
      )!,
    );
  }

  @override
  $LocalHazardAutomationStatesTable createAlias(String alias) {
    return $LocalHazardAutomationStatesTable(attachedDatabase, alias);
  }
}

class LocalHazardAutomationState extends DataClass
    implements Insertable<LocalHazardAutomationState> {
  final String id;
  final String habitationId;
  final String hazardType;
  final double lastScore;
  final int consecutiveBelowDeleteThreshold;
  final bool zoneActive;
  final DateTime lastEvaluatedAt;
  const LocalHazardAutomationState({
    required this.id,
    required this.habitationId,
    required this.hazardType,
    required this.lastScore,
    required this.consecutiveBelowDeleteThreshold,
    required this.zoneActive,
    required this.lastEvaluatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['habitation_id'] = Variable<String>(habitationId);
    map['hazard_type'] = Variable<String>(hazardType);
    map['last_score'] = Variable<double>(lastScore);
    map['consecutive_below_delete_threshold'] = Variable<int>(
      consecutiveBelowDeleteThreshold,
    );
    map['zone_active'] = Variable<bool>(zoneActive);
    map['last_evaluated_at'] = Variable<DateTime>(lastEvaluatedAt);
    return map;
  }

  LocalHazardAutomationStatesCompanion toCompanion(bool nullToAbsent) {
    return LocalHazardAutomationStatesCompanion(
      id: Value(id),
      habitationId: Value(habitationId),
      hazardType: Value(hazardType),
      lastScore: Value(lastScore),
      consecutiveBelowDeleteThreshold: Value(consecutiveBelowDeleteThreshold),
      zoneActive: Value(zoneActive),
      lastEvaluatedAt: Value(lastEvaluatedAt),
    );
  }

  factory LocalHazardAutomationState.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalHazardAutomationState(
      id: serializer.fromJson<String>(json['id']),
      habitationId: serializer.fromJson<String>(json['habitationId']),
      hazardType: serializer.fromJson<String>(json['hazardType']),
      lastScore: serializer.fromJson<double>(json['lastScore']),
      consecutiveBelowDeleteThreshold: serializer.fromJson<int>(
        json['consecutiveBelowDeleteThreshold'],
      ),
      zoneActive: serializer.fromJson<bool>(json['zoneActive']),
      lastEvaluatedAt: serializer.fromJson<DateTime>(json['lastEvaluatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'habitationId': serializer.toJson<String>(habitationId),
      'hazardType': serializer.toJson<String>(hazardType),
      'lastScore': serializer.toJson<double>(lastScore),
      'consecutiveBelowDeleteThreshold': serializer.toJson<int>(
        consecutiveBelowDeleteThreshold,
      ),
      'zoneActive': serializer.toJson<bool>(zoneActive),
      'lastEvaluatedAt': serializer.toJson<DateTime>(lastEvaluatedAt),
    };
  }

  LocalHazardAutomationState copyWith({
    String? id,
    String? habitationId,
    String? hazardType,
    double? lastScore,
    int? consecutiveBelowDeleteThreshold,
    bool? zoneActive,
    DateTime? lastEvaluatedAt,
  }) => LocalHazardAutomationState(
    id: id ?? this.id,
    habitationId: habitationId ?? this.habitationId,
    hazardType: hazardType ?? this.hazardType,
    lastScore: lastScore ?? this.lastScore,
    consecutiveBelowDeleteThreshold:
        consecutiveBelowDeleteThreshold ?? this.consecutiveBelowDeleteThreshold,
    zoneActive: zoneActive ?? this.zoneActive,
    lastEvaluatedAt: lastEvaluatedAt ?? this.lastEvaluatedAt,
  );
  LocalHazardAutomationState copyWithCompanion(
    LocalHazardAutomationStatesCompanion data,
  ) {
    return LocalHazardAutomationState(
      id: data.id.present ? data.id.value : this.id,
      habitationId: data.habitationId.present
          ? data.habitationId.value
          : this.habitationId,
      hazardType: data.hazardType.present
          ? data.hazardType.value
          : this.hazardType,
      lastScore: data.lastScore.present ? data.lastScore.value : this.lastScore,
      consecutiveBelowDeleteThreshold:
          data.consecutiveBelowDeleteThreshold.present
          ? data.consecutiveBelowDeleteThreshold.value
          : this.consecutiveBelowDeleteThreshold,
      zoneActive: data.zoneActive.present
          ? data.zoneActive.value
          : this.zoneActive,
      lastEvaluatedAt: data.lastEvaluatedAt.present
          ? data.lastEvaluatedAt.value
          : this.lastEvaluatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalHazardAutomationState(')
          ..write('id: $id, ')
          ..write('habitationId: $habitationId, ')
          ..write('hazardType: $hazardType, ')
          ..write('lastScore: $lastScore, ')
          ..write(
            'consecutiveBelowDeleteThreshold: $consecutiveBelowDeleteThreshold, ',
          )
          ..write('zoneActive: $zoneActive, ')
          ..write('lastEvaluatedAt: $lastEvaluatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    habitationId,
    hazardType,
    lastScore,
    consecutiveBelowDeleteThreshold,
    zoneActive,
    lastEvaluatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalHazardAutomationState &&
          other.id == this.id &&
          other.habitationId == this.habitationId &&
          other.hazardType == this.hazardType &&
          other.lastScore == this.lastScore &&
          other.consecutiveBelowDeleteThreshold ==
              this.consecutiveBelowDeleteThreshold &&
          other.zoneActive == this.zoneActive &&
          other.lastEvaluatedAt == this.lastEvaluatedAt);
}

class LocalHazardAutomationStatesCompanion
    extends UpdateCompanion<LocalHazardAutomationState> {
  final Value<String> id;
  final Value<String> habitationId;
  final Value<String> hazardType;
  final Value<double> lastScore;
  final Value<int> consecutiveBelowDeleteThreshold;
  final Value<bool> zoneActive;
  final Value<DateTime> lastEvaluatedAt;
  final Value<int> rowid;
  const LocalHazardAutomationStatesCompanion({
    this.id = const Value.absent(),
    this.habitationId = const Value.absent(),
    this.hazardType = const Value.absent(),
    this.lastScore = const Value.absent(),
    this.consecutiveBelowDeleteThreshold = const Value.absent(),
    this.zoneActive = const Value.absent(),
    this.lastEvaluatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalHazardAutomationStatesCompanion.insert({
    required String id,
    required String habitationId,
    required String hazardType,
    required double lastScore,
    this.consecutiveBelowDeleteThreshold = const Value.absent(),
    this.zoneActive = const Value.absent(),
    required DateTime lastEvaluatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       habitationId = Value(habitationId),
       hazardType = Value(hazardType),
       lastScore = Value(lastScore),
       lastEvaluatedAt = Value(lastEvaluatedAt);
  static Insertable<LocalHazardAutomationState> custom({
    Expression<String>? id,
    Expression<String>? habitationId,
    Expression<String>? hazardType,
    Expression<double>? lastScore,
    Expression<int>? consecutiveBelowDeleteThreshold,
    Expression<bool>? zoneActive,
    Expression<DateTime>? lastEvaluatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (habitationId != null) 'habitation_id': habitationId,
      if (hazardType != null) 'hazard_type': hazardType,
      if (lastScore != null) 'last_score': lastScore,
      if (consecutiveBelowDeleteThreshold != null)
        'consecutive_below_delete_threshold': consecutiveBelowDeleteThreshold,
      if (zoneActive != null) 'zone_active': zoneActive,
      if (lastEvaluatedAt != null) 'last_evaluated_at': lastEvaluatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalHazardAutomationStatesCompanion copyWith({
    Value<String>? id,
    Value<String>? habitationId,
    Value<String>? hazardType,
    Value<double>? lastScore,
    Value<int>? consecutiveBelowDeleteThreshold,
    Value<bool>? zoneActive,
    Value<DateTime>? lastEvaluatedAt,
    Value<int>? rowid,
  }) {
    return LocalHazardAutomationStatesCompanion(
      id: id ?? this.id,
      habitationId: habitationId ?? this.habitationId,
      hazardType: hazardType ?? this.hazardType,
      lastScore: lastScore ?? this.lastScore,
      consecutiveBelowDeleteThreshold:
          consecutiveBelowDeleteThreshold ??
          this.consecutiveBelowDeleteThreshold,
      zoneActive: zoneActive ?? this.zoneActive,
      lastEvaluatedAt: lastEvaluatedAt ?? this.lastEvaluatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (habitationId.present) {
      map['habitation_id'] = Variable<String>(habitationId.value);
    }
    if (hazardType.present) {
      map['hazard_type'] = Variable<String>(hazardType.value);
    }
    if (lastScore.present) {
      map['last_score'] = Variable<double>(lastScore.value);
    }
    if (consecutiveBelowDeleteThreshold.present) {
      map['consecutive_below_delete_threshold'] = Variable<int>(
        consecutiveBelowDeleteThreshold.value,
      );
    }
    if (zoneActive.present) {
      map['zone_active'] = Variable<bool>(zoneActive.value);
    }
    if (lastEvaluatedAt.present) {
      map['last_evaluated_at'] = Variable<DateTime>(lastEvaluatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalHazardAutomationStatesCompanion(')
          ..write('id: $id, ')
          ..write('habitationId: $habitationId, ')
          ..write('hazardType: $hazardType, ')
          ..write('lastScore: $lastScore, ')
          ..write(
            'consecutiveBelowDeleteThreshold: $consecutiveBelowDeleteThreshold, ',
          )
          ..write('zoneActive: $zoneActive, ')
          ..write('lastEvaluatedAt: $lastEvaluatedAt, ')
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
  static const VerificationMeta _independentSourceCountMeta =
      const VerificationMeta('independentSourceCount');
  @override
  late final GeneratedColumn<int> independentSourceCount = GeneratedColumn<int>(
    'independent_source_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
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
  static const VerificationMeta _assignedResponderIdMeta =
      const VerificationMeta('assignedResponderId');
  @override
  late final GeneratedColumn<String> assignedResponderId =
      GeneratedColumn<String>(
        'assigned_responder_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
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
    independentSourceCount,
    confidence,
    createdAt,
    updatedAt,
    version,
    isSynced,
    assignedResponderId,
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
    if (data.containsKey('independent_source_count')) {
      context.handle(
        _independentSourceCountMeta,
        independentSourceCount.isAcceptableOrUnknown(
          data['independent_source_count']!,
          _independentSourceCountMeta,
        ),
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
    if (data.containsKey('assigned_responder_id')) {
      context.handle(
        _assignedResponderIdMeta,
        assignedResponderId.isAcceptableOrUnknown(
          data['assigned_responder_id']!,
          _assignedResponderIdMeta,
        ),
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
      independentSourceCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}independent_source_count'],
      )!,
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
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
      assignedResponderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assigned_responder_id'],
      ),
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

  /// M14's ground-truth fusion output: how many *independent* reporters
  /// (deduplicated by reporter id) have corroborated this incident, and
  /// the resulting confidence — both start at a single-source baseline
  /// and are recomputed each time another report is fused in.
  final int independentSourceCount;
  final double confidence;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;
  final bool isSynced;

  /// Set by District/Command's responder-assignment screen; read by a
  /// Field Responder's "my assigned incidents" list. Null means
  /// unassigned — not every incident needs a responder sent to it.
  final String? assignedResponderId;
  const LocalIncident({
    required this.id,
    required this.type,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.severity,
    required this.independentSourceCount,
    required this.confidence,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    required this.isSynced,
    this.assignedResponderId,
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
    map['independent_source_count'] = Variable<int>(independentSourceCount);
    map['confidence'] = Variable<double>(confidence);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['version'] = Variable<int>(version);
    map['is_synced'] = Variable<bool>(isSynced);
    if (!nullToAbsent || assignedResponderId != null) {
      map['assigned_responder_id'] = Variable<String>(assignedResponderId);
    }
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
      independentSourceCount: Value(independentSourceCount),
      confidence: Value(confidence),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      version: Value(version),
      isSynced: Value(isSynced),
      assignedResponderId: assignedResponderId == null && nullToAbsent
          ? const Value.absent()
          : Value(assignedResponderId),
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
      independentSourceCount: serializer.fromJson<int>(
        json['independentSourceCount'],
      ),
      confidence: serializer.fromJson<double>(json['confidence']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      version: serializer.fromJson<int>(json['version']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      assignedResponderId: serializer.fromJson<String?>(
        json['assignedResponderId'],
      ),
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
      'independentSourceCount': serializer.toJson<int>(independentSourceCount),
      'confidence': serializer.toJson<double>(confidence),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'version': serializer.toJson<int>(version),
      'isSynced': serializer.toJson<bool>(isSynced),
      'assignedResponderId': serializer.toJson<String?>(assignedResponderId),
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
    int? independentSourceCount,
    double? confidence,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
    bool? isSynced,
    Value<String?> assignedResponderId = const Value.absent(),
  }) => LocalIncident(
    id: id ?? this.id,
    type: type ?? this.type,
    status: status ?? this.status,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    description: description ?? this.description,
    severity: severity ?? this.severity,
    independentSourceCount:
        independentSourceCount ?? this.independentSourceCount,
    confidence: confidence ?? this.confidence,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    version: version ?? this.version,
    isSynced: isSynced ?? this.isSynced,
    assignedResponderId: assignedResponderId.present
        ? assignedResponderId.value
        : this.assignedResponderId,
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
      independentSourceCount: data.independentSourceCount.present
          ? data.independentSourceCount.value
          : this.independentSourceCount,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      version: data.version.present ? data.version.value : this.version,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      assignedResponderId: data.assignedResponderId.present
          ? data.assignedResponderId.value
          : this.assignedResponderId,
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
          ..write('independentSourceCount: $independentSourceCount, ')
          ..write('confidence: $confidence, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('isSynced: $isSynced, ')
          ..write('assignedResponderId: $assignedResponderId')
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
    independentSourceCount,
    confidence,
    createdAt,
    updatedAt,
    version,
    isSynced,
    assignedResponderId,
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
          other.independentSourceCount == this.independentSourceCount &&
          other.confidence == this.confidence &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.version == this.version &&
          other.isSynced == this.isSynced &&
          other.assignedResponderId == this.assignedResponderId);
}

class LocalIncidentsCompanion extends UpdateCompanion<LocalIncident> {
  final Value<String> id;
  final Value<String> type;
  final Value<String> status;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<String> description;
  final Value<String> severity;
  final Value<int> independentSourceCount;
  final Value<double> confidence;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> version;
  final Value<bool> isSynced;
  final Value<String?> assignedResponderId;
  final Value<int> rowid;
  const LocalIncidentsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.status = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.description = const Value.absent(),
    this.severity = const Value.absent(),
    this.independentSourceCount = const Value.absent(),
    this.confidence = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.assignedResponderId = const Value.absent(),
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
    this.independentSourceCount = const Value.absent(),
    this.confidence = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.version = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.assignedResponderId = const Value.absent(),
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
    Expression<int>? independentSourceCount,
    Expression<double>? confidence,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? version,
    Expression<bool>? isSynced,
    Expression<String>? assignedResponderId,
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
      if (independentSourceCount != null)
        'independent_source_count': independentSourceCount,
      if (confidence != null) 'confidence': confidence,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (version != null) 'version': version,
      if (isSynced != null) 'is_synced': isSynced,
      if (assignedResponderId != null)
        'assigned_responder_id': assignedResponderId,
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
    Value<int>? independentSourceCount,
    Value<double>? confidence,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? version,
    Value<bool>? isSynced,
    Value<String?>? assignedResponderId,
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
      independentSourceCount:
          independentSourceCount ?? this.independentSourceCount,
      confidence: confidence ?? this.confidence,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      isSynced: isSynced ?? this.isSynced,
      assignedResponderId: assignedResponderId ?? this.assignedResponderId,
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
    if (independentSourceCount.present) {
      map['independent_source_count'] = Variable<int>(
        independentSourceCount.value,
      );
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
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (assignedResponderId.present) {
      map['assigned_responder_id'] = Variable<String>(
        assignedResponderId.value,
      );
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
          ..write('independentSourceCount: $independentSourceCount, ')
          ..write('confidence: $confidence, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version, ')
          ..write('isSynced: $isSynced, ')
          ..write('assignedResponderId: $assignedResponderId, ')
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
  static const VerificationMeta _reportTypeMeta = const VerificationMeta(
    'reportType',
  );
  @override
  late final GeneratedColumn<String> reportType = GeneratedColumn<String>(
    'report_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
  static const VerificationMeta _affectedPeopleCountMeta =
      const VerificationMeta('affectedPeopleCount');
  @override
  late final GeneratedColumn<int> affectedPeopleCount = GeneratedColumn<int>(
    'affected_people_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mediaPathMeta = const VerificationMeta(
    'mediaPath',
  );
  @override
  late final GeneratedColumn<String> mediaPath = GeneratedColumn<String>(
    'media_path',
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
    reportType,
    description,
    severity,
    affectedPeopleCount,
    mediaPath,
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
    if (data.containsKey('report_type')) {
      context.handle(
        _reportTypeMeta,
        reportType.isAcceptableOrUnknown(data['report_type']!, _reportTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_reportTypeMeta);
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
    if (data.containsKey('affected_people_count')) {
      context.handle(
        _affectedPeopleCountMeta,
        affectedPeopleCount.isAcceptableOrUnknown(
          data['affected_people_count']!,
          _affectedPeopleCountMeta,
        ),
      );
    }
    if (data.containsKey('media_path')) {
      context.handle(
        _mediaPathMeta,
        mediaPath.isAcceptableOrUnknown(data['media_path']!, _mediaPathMeta),
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
      reportType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}report_type'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      severity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}severity'],
      )!,
      affectedPeopleCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}affected_people_count'],
      ),
      mediaPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_path'],
      ),
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

  /// One of [CitizenReportType]'s storage values — landslide/flood/
  /// road_blockage/other for a hazard report, or 'sos'/'safe_status' for
  /// the two special-case citizen actions (M12).
  final String reportType;
  final String description;
  final String severity;

  /// The reporting citizen's own estimate — not required for sos/safe_status.
  final int? affectedPeopleCount;

  /// Local file path to an optionally-attached photo. Compression/upload
  /// prioritization for this is M21's job, not this module's.
  final String? mediaPath;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;

  /// Always false at submission time — every report is written locally
  /// and queued first, regardless of current connectivity, and only M17's
  /// future sync pass flips this once the backend has it.
  final bool isSynced;
  const LocalIncidentReport({
    required this.id,
    this.incidentId,
    this.reporterId,
    required this.latitude,
    required this.longitude,
    required this.reportType,
    required this.description,
    required this.severity,
    this.affectedPeopleCount,
    this.mediaPath,
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
    map['report_type'] = Variable<String>(reportType);
    map['description'] = Variable<String>(description);
    map['severity'] = Variable<String>(severity);
    if (!nullToAbsent || affectedPeopleCount != null) {
      map['affected_people_count'] = Variable<int>(affectedPeopleCount);
    }
    if (!nullToAbsent || mediaPath != null) {
      map['media_path'] = Variable<String>(mediaPath);
    }
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
      reportType: Value(reportType),
      description: Value(description),
      severity: Value(severity),
      affectedPeopleCount: affectedPeopleCount == null && nullToAbsent
          ? const Value.absent()
          : Value(affectedPeopleCount),
      mediaPath: mediaPath == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaPath),
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
      reportType: serializer.fromJson<String>(json['reportType']),
      description: serializer.fromJson<String>(json['description']),
      severity: serializer.fromJson<String>(json['severity']),
      affectedPeopleCount: serializer.fromJson<int?>(
        json['affectedPeopleCount'],
      ),
      mediaPath: serializer.fromJson<String?>(json['mediaPath']),
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
      'reportType': serializer.toJson<String>(reportType),
      'description': serializer.toJson<String>(description),
      'severity': serializer.toJson<String>(severity),
      'affectedPeopleCount': serializer.toJson<int?>(affectedPeopleCount),
      'mediaPath': serializer.toJson<String?>(mediaPath),
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
    String? reportType,
    String? description,
    String? severity,
    Value<int?> affectedPeopleCount = const Value.absent(),
    Value<String?> mediaPath = const Value.absent(),
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
    reportType: reportType ?? this.reportType,
    description: description ?? this.description,
    severity: severity ?? this.severity,
    affectedPeopleCount: affectedPeopleCount.present
        ? affectedPeopleCount.value
        : this.affectedPeopleCount,
    mediaPath: mediaPath.present ? mediaPath.value : this.mediaPath,
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
      reportType: data.reportType.present
          ? data.reportType.value
          : this.reportType,
      description: data.description.present
          ? data.description.value
          : this.description,
      severity: data.severity.present ? data.severity.value : this.severity,
      affectedPeopleCount: data.affectedPeopleCount.present
          ? data.affectedPeopleCount.value
          : this.affectedPeopleCount,
      mediaPath: data.mediaPath.present ? data.mediaPath.value : this.mediaPath,
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
          ..write('reportType: $reportType, ')
          ..write('description: $description, ')
          ..write('severity: $severity, ')
          ..write('affectedPeopleCount: $affectedPeopleCount, ')
          ..write('mediaPath: $mediaPath, ')
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
    reportType,
    description,
    severity,
    affectedPeopleCount,
    mediaPath,
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
          other.reportType == this.reportType &&
          other.description == this.description &&
          other.severity == this.severity &&
          other.affectedPeopleCount == this.affectedPeopleCount &&
          other.mediaPath == this.mediaPath &&
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
  final Value<String> reportType;
  final Value<String> description;
  final Value<String> severity;
  final Value<int?> affectedPeopleCount;
  final Value<String?> mediaPath;
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
    this.reportType = const Value.absent(),
    this.description = const Value.absent(),
    this.severity = const Value.absent(),
    this.affectedPeopleCount = const Value.absent(),
    this.mediaPath = const Value.absent(),
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
    required String reportType,
    this.description = const Value.absent(),
    this.severity = const Value.absent(),
    this.affectedPeopleCount = const Value.absent(),
    this.mediaPath = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.version = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       latitude = Value(latitude),
       longitude = Value(longitude),
       reportType = Value(reportType),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LocalIncidentReport> custom({
    Expression<String>? id,
    Expression<String>? incidentId,
    Expression<String>? reporterId,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? reportType,
    Expression<String>? description,
    Expression<String>? severity,
    Expression<int>? affectedPeopleCount,
    Expression<String>? mediaPath,
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
      if (reportType != null) 'report_type': reportType,
      if (description != null) 'description': description,
      if (severity != null) 'severity': severity,
      if (affectedPeopleCount != null)
        'affected_people_count': affectedPeopleCount,
      if (mediaPath != null) 'media_path': mediaPath,
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
    Value<String>? reportType,
    Value<String>? description,
    Value<String>? severity,
    Value<int?>? affectedPeopleCount,
    Value<String?>? mediaPath,
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
      reportType: reportType ?? this.reportType,
      description: description ?? this.description,
      severity: severity ?? this.severity,
      affectedPeopleCount: affectedPeopleCount ?? this.affectedPeopleCount,
      mediaPath: mediaPath ?? this.mediaPath,
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
    if (reportType.present) {
      map['report_type'] = Variable<String>(reportType.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (severity.present) {
      map['severity'] = Variable<String>(severity.value);
    }
    if (affectedPeopleCount.present) {
      map['affected_people_count'] = Variable<int>(affectedPeopleCount.value);
    }
    if (mediaPath.present) {
      map['media_path'] = Variable<String>(mediaPath.value);
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
          ..write('reportType: $reportType, ')
          ..write('description: $description, ')
          ..write('severity: $severity, ')
          ..write('affectedPeopleCount: $affectedPeopleCount, ')
          ..write('mediaPath: $mediaPath, ')
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
  static const VerificationMeta _isSafeMeta = const VerificationMeta('isSafe');
  @override
  late final GeneratedColumn<bool> isSafe = GeneratedColumn<bool>(
    'is_safe',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_safe" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _isRoadSnappedMeta = const VerificationMeta(
    'isRoadSnapped',
  );
  @override
  late final GeneratedColumn<bool> isRoadSnapped = GeneratedColumn<bool>(
    'is_road_snapped',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_road_snapped" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
    isSafe,
    isRoadSnapped,
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
    if (data.containsKey('is_safe')) {
      context.handle(
        _isSafeMeta,
        isSafe.isAcceptableOrUnknown(data['is_safe']!, _isSafeMeta),
      );
    }
    if (data.containsKey('is_road_snapped')) {
      context.handle(
        _isRoadSnappedMeta,
        isRoadSnapped.isAcceptableOrUnknown(
          data['is_road_snapped']!,
          _isRoadSnappedMeta,
        ),
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
      isSafe: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_safe'],
      )!,
      isRoadSnapped: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_road_snapped'],
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

  /// Whether every segment of the cached (recommended) route cleared M11's
  /// hazard/blockage checks — lets the map color a route without needing
  /// the full per-segment breakdown just to render it.
  final bool isSafe;

  /// Whether [polylineJson] came from a real [RoadNetworkProvider] (true
  /// road geometry) or the engine's own straight-line/detour fallback —
  /// the map renders these differently so a route is never mistaken for
  /// the other kind.
  final bool isRoadSnapped;
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
    required this.isSafe,
    required this.isRoadSnapped,
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
    map['is_safe'] = Variable<bool>(isSafe);
    map['is_road_snapped'] = Variable<bool>(isRoadSnapped);
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
      isSafe: Value(isSafe),
      isRoadSnapped: Value(isRoadSnapped),
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
      isSafe: serializer.fromJson<bool>(json['isSafe']),
      isRoadSnapped: serializer.fromJson<bool>(json['isRoadSnapped']),
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
      'isSafe': serializer.toJson<bool>(isSafe),
      'isRoadSnapped': serializer.toJson<bool>(isRoadSnapped),
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
    bool? isSafe,
    bool? isRoadSnapped,
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
    isSafe: isSafe ?? this.isSafe,
    isRoadSnapped: isRoadSnapped ?? this.isRoadSnapped,
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
      isSafe: data.isSafe.present ? data.isSafe.value : this.isSafe,
      isRoadSnapped: data.isRoadSnapped.present
          ? data.isRoadSnapped.value
          : this.isRoadSnapped,
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
          ..write('isSafe: $isSafe, ')
          ..write('isRoadSnapped: $isRoadSnapped, ')
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
    isSafe,
    isRoadSnapped,
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
          other.isSafe == this.isSafe &&
          other.isRoadSnapped == this.isRoadSnapped &&
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
  final Value<bool> isSafe;
  final Value<bool> isRoadSnapped;
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
    this.isSafe = const Value.absent(),
    this.isRoadSnapped = const Value.absent(),
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
    this.isSafe = const Value.absent(),
    this.isRoadSnapped = const Value.absent(),
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
    Expression<bool>? isSafe,
    Expression<bool>? isRoadSnapped,
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
      if (isSafe != null) 'is_safe': isSafe,
      if (isRoadSnapped != null) 'is_road_snapped': isRoadSnapped,
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
    Value<bool>? isSafe,
    Value<bool>? isRoadSnapped,
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
      isSafe: isSafe ?? this.isSafe,
      isRoadSnapped: isRoadSnapped ?? this.isRoadSnapped,
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
    if (isSafe.present) {
      map['is_safe'] = Variable<bool>(isSafe.value);
    }
    if (isRoadSnapped.present) {
      map['is_road_snapped'] = Variable<bool>(isRoadSnapped.value);
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
          ..write('isSafe: $isSafe, ')
          ..write('isRoadSnapped: $isRoadSnapped, ')
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
  static const VerificationMeta _environmentalAdjustmentMeta =
      const VerificationMeta('environmentalAdjustment');
  @override
  late final GeneratedColumn<double> environmentalAdjustment =
      GeneratedColumn<double>(
        'environmental_adjustment',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _environmentalProvenanceJsonMeta =
      const VerificationMeta('environmentalProvenanceJson');
  @override
  late final GeneratedColumn<String> environmentalProvenanceJson =
      GeneratedColumn<String>(
        'environmental_provenance_json',
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
    environmentalAdjustment,
    environmentalProvenanceJson,
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
    if (data.containsKey('environmental_adjustment')) {
      context.handle(
        _environmentalAdjustmentMeta,
        environmentalAdjustment.isAcceptableOrUnknown(
          data['environmental_adjustment']!,
          _environmentalAdjustmentMeta,
        ),
      );
    }
    if (data.containsKey('environmental_provenance_json')) {
      context.handle(
        _environmentalProvenanceJsonMeta,
        environmentalProvenanceJson.isAcceptableOrUnknown(
          data['environmental_provenance_json']!,
          _environmentalProvenanceJsonMeta,
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
      environmentalAdjustment: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}environmental_adjustment'],
      )!,
      environmentalProvenanceJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}environmental_provenance_json'],
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

  /// M24: how much [[EnvironmentalRiskEngine]] nudged the score above the
  /// hazard/vulnerability base — 0.0 when no fresh environmental data was
  /// available for this habitation. Kept separate from `hazardExposure`
  /// rather than folded into it, so the UI can show "here's what external
  /// data added" as its own, visibly-attributed line.
  final double environmentalAdjustment;

  /// JSON list of {parameter, value, source, observedAt} for the fresh
  /// observations that actually contributed — the "visible provenance"
  /// the acceptance criterion asks for.
  final String environmentalProvenanceJson;
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
    required this.environmentalAdjustment,
    required this.environmentalProvenanceJson,
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
    map['environmental_adjustment'] = Variable<double>(environmentalAdjustment);
    map['environmental_provenance_json'] = Variable<String>(
      environmentalProvenanceJson,
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
      environmentalAdjustment: Value(environmentalAdjustment),
      environmentalProvenanceJson: Value(environmentalProvenanceJson),
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
      environmentalAdjustment: serializer.fromJson<double>(
        json['environmentalAdjustment'],
      ),
      environmentalProvenanceJson: serializer.fromJson<String>(
        json['environmentalProvenanceJson'],
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
      'environmentalAdjustment': serializer.toJson<double>(
        environmentalAdjustment,
      ),
      'environmentalProvenanceJson': serializer.toJson<String>(
        environmentalProvenanceJson,
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
    double? environmentalAdjustment,
    String? environmentalProvenanceJson,
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
    environmentalAdjustment:
        environmentalAdjustment ?? this.environmentalAdjustment,
    environmentalProvenanceJson:
        environmentalProvenanceJson ?? this.environmentalProvenanceJson,
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
      environmentalAdjustment: data.environmentalAdjustment.present
          ? data.environmentalAdjustment.value
          : this.environmentalAdjustment,
      environmentalProvenanceJson: data.environmentalProvenanceJson.present
          ? data.environmentalProvenanceJson.value
          : this.environmentalProvenanceJson,
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
          ..write('environmentalAdjustment: $environmentalAdjustment, ')
          ..write('environmentalProvenanceJson: $environmentalProvenanceJson, ')
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
    environmentalAdjustment,
    environmentalProvenanceJson,
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
          other.environmentalAdjustment == this.environmentalAdjustment &&
          other.environmentalProvenanceJson ==
              this.environmentalProvenanceJson &&
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
  final Value<double> environmentalAdjustment;
  final Value<String> environmentalProvenanceJson;
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
    this.environmentalAdjustment = const Value.absent(),
    this.environmentalProvenanceJson = const Value.absent(),
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
    this.environmentalAdjustment = const Value.absent(),
    this.environmentalProvenanceJson = const Value.absent(),
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
    Expression<double>? environmentalAdjustment,
    Expression<String>? environmentalProvenanceJson,
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
      if (environmentalAdjustment != null)
        'environmental_adjustment': environmentalAdjustment,
      if (environmentalProvenanceJson != null)
        'environmental_provenance_json': environmentalProvenanceJson,
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
    Value<double>? environmentalAdjustment,
    Value<String>? environmentalProvenanceJson,
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
      environmentalAdjustment:
          environmentalAdjustment ?? this.environmentalAdjustment,
      environmentalProvenanceJson:
          environmentalProvenanceJson ?? this.environmentalProvenanceJson,
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
    if (environmentalAdjustment.present) {
      map['environmental_adjustment'] = Variable<double>(
        environmentalAdjustment.value,
      );
    }
    if (environmentalProvenanceJson.present) {
      map['environmental_provenance_json'] = Variable<String>(
        environmentalProvenanceJson.value,
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
          ..write('environmentalAdjustment: $environmentalAdjustment, ')
          ..write('environmentalProvenanceJson: $environmentalProvenanceJson, ')
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

class $LocalAuditEventsTable extends LocalAuditEvents
    with TableInfo<$LocalAuditEventsTable, LocalAuditEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAuditEventsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _actorIdMeta = const VerificationMeta(
    'actorId',
  );
  @override
  late final GeneratedColumn<String> actorId = GeneratedColumn<String>(
    'actor_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _objectTypeMeta = const VerificationMeta(
    'objectType',
  );
  @override
  late final GeneratedColumn<String> objectType = GeneratedColumn<String>(
    'object_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _objectIdMeta = const VerificationMeta(
    'objectId',
  );
  @override
  late final GeneratedColumn<String> objectId = GeneratedColumn<String>(
    'object_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _oldValueMeta = const VerificationMeta(
    'oldValue',
  );
  @override
  late final GeneratedColumn<String> oldValue = GeneratedColumn<String>(
    'old_value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _newValueMeta = const VerificationMeta(
    'newValue',
  );
  @override
  late final GeneratedColumn<String> newValue = GeneratedColumn<String>(
    'new_value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    actorId,
    action,
    objectType,
    objectId,
    oldValue,
    newValue,
    reason,
    occurredAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_audit_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalAuditEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('actor_id')) {
      context.handle(
        _actorIdMeta,
        actorId.isAcceptableOrUnknown(data['actor_id']!, _actorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_actorIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('object_type')) {
      context.handle(
        _objectTypeMeta,
        objectType.isAcceptableOrUnknown(data['object_type']!, _objectTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_objectTypeMeta);
    }
    if (data.containsKey('object_id')) {
      context.handle(
        _objectIdMeta,
        objectId.isAcceptableOrUnknown(data['object_id']!, _objectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_objectIdMeta);
    }
    if (data.containsKey('old_value')) {
      context.handle(
        _oldValueMeta,
        oldValue.isAcceptableOrUnknown(data['old_value']!, _oldValueMeta),
      );
    }
    if (data.containsKey('new_value')) {
      context.handle(
        _newValueMeta,
        newValue.isAcceptableOrUnknown(data['new_value']!, _newValueMeta),
      );
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalAuditEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalAuditEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      actorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actor_id'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      objectType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}object_type'],
      )!,
      objectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}object_id'],
      )!,
      oldValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}old_value'],
      ),
      newValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}new_value'],
      ),
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      ),
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
    );
  }

  @override
  $LocalAuditEventsTable createAlias(String alias) {
    return $LocalAuditEventsTable(attachedDatabase, alias);
  }
}

class LocalAuditEvent extends DataClass implements Insertable<LocalAuditEvent> {
  final int id;
  final String actorId;
  final String action;
  final String objectType;
  final String objectId;
  final String? oldValue;
  final String? newValue;
  final String? reason;
  final DateTime occurredAt;
  const LocalAuditEvent({
    required this.id,
    required this.actorId,
    required this.action,
    required this.objectType,
    required this.objectId,
    this.oldValue,
    this.newValue,
    this.reason,
    required this.occurredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['actor_id'] = Variable<String>(actorId);
    map['action'] = Variable<String>(action);
    map['object_type'] = Variable<String>(objectType);
    map['object_id'] = Variable<String>(objectId);
    if (!nullToAbsent || oldValue != null) {
      map['old_value'] = Variable<String>(oldValue);
    }
    if (!nullToAbsent || newValue != null) {
      map['new_value'] = Variable<String>(newValue);
    }
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    return map;
  }

  LocalAuditEventsCompanion toCompanion(bool nullToAbsent) {
    return LocalAuditEventsCompanion(
      id: Value(id),
      actorId: Value(actorId),
      action: Value(action),
      objectType: Value(objectType),
      objectId: Value(objectId),
      oldValue: oldValue == null && nullToAbsent
          ? const Value.absent()
          : Value(oldValue),
      newValue: newValue == null && nullToAbsent
          ? const Value.absent()
          : Value(newValue),
      reason: reason == null && nullToAbsent
          ? const Value.absent()
          : Value(reason),
      occurredAt: Value(occurredAt),
    );
  }

  factory LocalAuditEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalAuditEvent(
      id: serializer.fromJson<int>(json['id']),
      actorId: serializer.fromJson<String>(json['actorId']),
      action: serializer.fromJson<String>(json['action']),
      objectType: serializer.fromJson<String>(json['objectType']),
      objectId: serializer.fromJson<String>(json['objectId']),
      oldValue: serializer.fromJson<String?>(json['oldValue']),
      newValue: serializer.fromJson<String?>(json['newValue']),
      reason: serializer.fromJson<String?>(json['reason']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'actorId': serializer.toJson<String>(actorId),
      'action': serializer.toJson<String>(action),
      'objectType': serializer.toJson<String>(objectType),
      'objectId': serializer.toJson<String>(objectId),
      'oldValue': serializer.toJson<String?>(oldValue),
      'newValue': serializer.toJson<String?>(newValue),
      'reason': serializer.toJson<String?>(reason),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
    };
  }

  LocalAuditEvent copyWith({
    int? id,
    String? actorId,
    String? action,
    String? objectType,
    String? objectId,
    Value<String?> oldValue = const Value.absent(),
    Value<String?> newValue = const Value.absent(),
    Value<String?> reason = const Value.absent(),
    DateTime? occurredAt,
  }) => LocalAuditEvent(
    id: id ?? this.id,
    actorId: actorId ?? this.actorId,
    action: action ?? this.action,
    objectType: objectType ?? this.objectType,
    objectId: objectId ?? this.objectId,
    oldValue: oldValue.present ? oldValue.value : this.oldValue,
    newValue: newValue.present ? newValue.value : this.newValue,
    reason: reason.present ? reason.value : this.reason,
    occurredAt: occurredAt ?? this.occurredAt,
  );
  LocalAuditEvent copyWithCompanion(LocalAuditEventsCompanion data) {
    return LocalAuditEvent(
      id: data.id.present ? data.id.value : this.id,
      actorId: data.actorId.present ? data.actorId.value : this.actorId,
      action: data.action.present ? data.action.value : this.action,
      objectType: data.objectType.present
          ? data.objectType.value
          : this.objectType,
      objectId: data.objectId.present ? data.objectId.value : this.objectId,
      oldValue: data.oldValue.present ? data.oldValue.value : this.oldValue,
      newValue: data.newValue.present ? data.newValue.value : this.newValue,
      reason: data.reason.present ? data.reason.value : this.reason,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalAuditEvent(')
          ..write('id: $id, ')
          ..write('actorId: $actorId, ')
          ..write('action: $action, ')
          ..write('objectType: $objectType, ')
          ..write('objectId: $objectId, ')
          ..write('oldValue: $oldValue, ')
          ..write('newValue: $newValue, ')
          ..write('reason: $reason, ')
          ..write('occurredAt: $occurredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    actorId,
    action,
    objectType,
    objectId,
    oldValue,
    newValue,
    reason,
    occurredAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalAuditEvent &&
          other.id == this.id &&
          other.actorId == this.actorId &&
          other.action == this.action &&
          other.objectType == this.objectType &&
          other.objectId == this.objectId &&
          other.oldValue == this.oldValue &&
          other.newValue == this.newValue &&
          other.reason == this.reason &&
          other.occurredAt == this.occurredAt);
}

class LocalAuditEventsCompanion extends UpdateCompanion<LocalAuditEvent> {
  final Value<int> id;
  final Value<String> actorId;
  final Value<String> action;
  final Value<String> objectType;
  final Value<String> objectId;
  final Value<String?> oldValue;
  final Value<String?> newValue;
  final Value<String?> reason;
  final Value<DateTime> occurredAt;
  const LocalAuditEventsCompanion({
    this.id = const Value.absent(),
    this.actorId = const Value.absent(),
    this.action = const Value.absent(),
    this.objectType = const Value.absent(),
    this.objectId = const Value.absent(),
    this.oldValue = const Value.absent(),
    this.newValue = const Value.absent(),
    this.reason = const Value.absent(),
    this.occurredAt = const Value.absent(),
  });
  LocalAuditEventsCompanion.insert({
    this.id = const Value.absent(),
    required String actorId,
    required String action,
    required String objectType,
    required String objectId,
    this.oldValue = const Value.absent(),
    this.newValue = const Value.absent(),
    this.reason = const Value.absent(),
    required DateTime occurredAt,
  }) : actorId = Value(actorId),
       action = Value(action),
       objectType = Value(objectType),
       objectId = Value(objectId),
       occurredAt = Value(occurredAt);
  static Insertable<LocalAuditEvent> custom({
    Expression<int>? id,
    Expression<String>? actorId,
    Expression<String>? action,
    Expression<String>? objectType,
    Expression<String>? objectId,
    Expression<String>? oldValue,
    Expression<String>? newValue,
    Expression<String>? reason,
    Expression<DateTime>? occurredAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (actorId != null) 'actor_id': actorId,
      if (action != null) 'action': action,
      if (objectType != null) 'object_type': objectType,
      if (objectId != null) 'object_id': objectId,
      if (oldValue != null) 'old_value': oldValue,
      if (newValue != null) 'new_value': newValue,
      if (reason != null) 'reason': reason,
      if (occurredAt != null) 'occurred_at': occurredAt,
    });
  }

  LocalAuditEventsCompanion copyWith({
    Value<int>? id,
    Value<String>? actorId,
    Value<String>? action,
    Value<String>? objectType,
    Value<String>? objectId,
    Value<String?>? oldValue,
    Value<String?>? newValue,
    Value<String?>? reason,
    Value<DateTime>? occurredAt,
  }) {
    return LocalAuditEventsCompanion(
      id: id ?? this.id,
      actorId: actorId ?? this.actorId,
      action: action ?? this.action,
      objectType: objectType ?? this.objectType,
      objectId: objectId ?? this.objectId,
      oldValue: oldValue ?? this.oldValue,
      newValue: newValue ?? this.newValue,
      reason: reason ?? this.reason,
      occurredAt: occurredAt ?? this.occurredAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (actorId.present) {
      map['actor_id'] = Variable<String>(actorId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (objectType.present) {
      map['object_type'] = Variable<String>(objectType.value);
    }
    if (objectId.present) {
      map['object_id'] = Variable<String>(objectId.value);
    }
    if (oldValue.present) {
      map['old_value'] = Variable<String>(oldValue.value);
    }
    if (newValue.present) {
      map['new_value'] = Variable<String>(newValue.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalAuditEventsCompanion(')
          ..write('id: $id, ')
          ..write('actorId: $actorId, ')
          ..write('action: $action, ')
          ..write('objectType: $objectType, ')
          ..write('objectId: $objectId, ')
          ..write('oldValue: $oldValue, ')
          ..write('newValue: $newValue, ')
          ..write('reason: $reason, ')
          ..write('occurredAt: $occurredAt')
          ..write(')'))
        .toString();
  }
}

class $LocalAlertsTable extends LocalAlerts
    with TableInfo<$LocalAlertsTable, LocalAlert> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAlertsTable(this.attachedDatabase, [this._alias]);
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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
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
  static const VerificationMeta _zoneIdMeta = const VerificationMeta('zoneId');
  @override
  late final GeneratedColumn<String> zoneId = GeneratedColumn<String>(
    'zone_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _zoneLabelMeta = const VerificationMeta(
    'zoneLabel',
  );
  @override
  late final GeneratedColumn<String> zoneLabel = GeneratedColumn<String>(
    'zone_label',
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
  static const VerificationMeta _issuedByMeta = const VerificationMeta(
    'issuedBy',
  );
  @override
  late final GeneratedColumn<String> issuedBy = GeneratedColumn<String>(
    'issued_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _issuedAtMeta = const VerificationMeta(
    'issuedAt',
  );
  @override
  late final GeneratedColumn<DateTime> issuedAt = GeneratedColumn<DateTime>(
    'issued_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _validUntilMeta = const VerificationMeta(
    'validUntil',
  );
  @override
  late final GeneratedColumn<DateTime> validUntil = GeneratedColumn<DateTime>(
    'valid_until',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cancelledAtMeta = const VerificationMeta(
    'cancelledAt',
  );
  @override
  late final GeneratedColumn<DateTime> cancelledAt = GeneratedColumn<DateTime>(
    'cancelled_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
    title,
    message,
    severity,
    zoneId,
    zoneLabel,
    geometryJson,
    issuedBy,
    issuedAt,
    validUntil,
    cancelledAt,
    version,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_alerts';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalAlert> instance, {
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
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('severity')) {
      context.handle(
        _severityMeta,
        severity.isAcceptableOrUnknown(data['severity']!, _severityMeta),
      );
    } else if (isInserting) {
      context.missing(_severityMeta);
    }
    if (data.containsKey('zone_id')) {
      context.handle(
        _zoneIdMeta,
        zoneId.isAcceptableOrUnknown(data['zone_id']!, _zoneIdMeta),
      );
    } else if (isInserting) {
      context.missing(_zoneIdMeta);
    }
    if (data.containsKey('zone_label')) {
      context.handle(
        _zoneLabelMeta,
        zoneLabel.isAcceptableOrUnknown(data['zone_label']!, _zoneLabelMeta),
      );
    } else if (isInserting) {
      context.missing(_zoneLabelMeta);
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
    if (data.containsKey('issued_by')) {
      context.handle(
        _issuedByMeta,
        issuedBy.isAcceptableOrUnknown(data['issued_by']!, _issuedByMeta),
      );
    } else if (isInserting) {
      context.missing(_issuedByMeta);
    }
    if (data.containsKey('issued_at')) {
      context.handle(
        _issuedAtMeta,
        issuedAt.isAcceptableOrUnknown(data['issued_at']!, _issuedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_issuedAtMeta);
    }
    if (data.containsKey('valid_until')) {
      context.handle(
        _validUntilMeta,
        validUntil.isAcceptableOrUnknown(data['valid_until']!, _validUntilMeta),
      );
    } else if (isInserting) {
      context.missing(_validUntilMeta);
    }
    if (data.containsKey('cancelled_at')) {
      context.handle(
        _cancelledAtMeta,
        cancelledAt.isAcceptableOrUnknown(
          data['cancelled_at']!,
          _cancelledAtMeta,
        ),
      );
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
  LocalAlert map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalAlert(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      message: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message'],
      )!,
      severity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}severity'],
      )!,
      zoneId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}zone_id'],
      )!,
      zoneLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}zone_label'],
      )!,
      geometryJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}geometry_json'],
      )!,
      issuedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}issued_by'],
      )!,
      issuedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}issued_at'],
      )!,
      validUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}valid_until'],
      )!,
      cancelledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cancelled_at'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
    );
  }

  @override
  $LocalAlertsTable createAlias(String alias) {
    return $LocalAlertsTable(attachedDatabase, alias);
  }
}

class LocalAlert extends DataClass implements Insertable<LocalAlert> {
  final String id;
  final String title;
  final String message;

  /// low/medium/high/critical — same vocabulary as
  /// [LocalHazardZones.severity] and [LocalIncidents.severity], so
  /// [severityColor] applies unchanged.
  final String severity;
  final String zoneId;
  final String zoneLabel;
  final String geometryJson;
  final String issuedBy;
  final DateTime issuedAt;

  /// The end of the alert's validity window (spec: "severity, validity,
  /// acknowledgement and history"). An alert with `validUntil` in the past
  /// is no longer active but is never deleted — it stays in the table as
  /// part of the broadcast history.
  final DateTime validUntil;

  /// Set when an official ends an alert early, distinct from simply
  /// expiring — both make [AlertEngine.isActive] false, but only
  /// cancellation is a deliberate act worth its own audit action.
  final DateTime? cancelledAt;
  final int version;
  const LocalAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.severity,
    required this.zoneId,
    required this.zoneLabel,
    required this.geometryJson,
    required this.issuedBy,
    required this.issuedAt,
    required this.validUntil,
    this.cancelledAt,
    required this.version,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['message'] = Variable<String>(message);
    map['severity'] = Variable<String>(severity);
    map['zone_id'] = Variable<String>(zoneId);
    map['zone_label'] = Variable<String>(zoneLabel);
    map['geometry_json'] = Variable<String>(geometryJson);
    map['issued_by'] = Variable<String>(issuedBy);
    map['issued_at'] = Variable<DateTime>(issuedAt);
    map['valid_until'] = Variable<DateTime>(validUntil);
    if (!nullToAbsent || cancelledAt != null) {
      map['cancelled_at'] = Variable<DateTime>(cancelledAt);
    }
    map['version'] = Variable<int>(version);
    return map;
  }

  LocalAlertsCompanion toCompanion(bool nullToAbsent) {
    return LocalAlertsCompanion(
      id: Value(id),
      title: Value(title),
      message: Value(message),
      severity: Value(severity),
      zoneId: Value(zoneId),
      zoneLabel: Value(zoneLabel),
      geometryJson: Value(geometryJson),
      issuedBy: Value(issuedBy),
      issuedAt: Value(issuedAt),
      validUntil: Value(validUntil),
      cancelledAt: cancelledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(cancelledAt),
      version: Value(version),
    );
  }

  factory LocalAlert.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalAlert(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      message: serializer.fromJson<String>(json['message']),
      severity: serializer.fromJson<String>(json['severity']),
      zoneId: serializer.fromJson<String>(json['zoneId']),
      zoneLabel: serializer.fromJson<String>(json['zoneLabel']),
      geometryJson: serializer.fromJson<String>(json['geometryJson']),
      issuedBy: serializer.fromJson<String>(json['issuedBy']),
      issuedAt: serializer.fromJson<DateTime>(json['issuedAt']),
      validUntil: serializer.fromJson<DateTime>(json['validUntil']),
      cancelledAt: serializer.fromJson<DateTime?>(json['cancelledAt']),
      version: serializer.fromJson<int>(json['version']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'message': serializer.toJson<String>(message),
      'severity': serializer.toJson<String>(severity),
      'zoneId': serializer.toJson<String>(zoneId),
      'zoneLabel': serializer.toJson<String>(zoneLabel),
      'geometryJson': serializer.toJson<String>(geometryJson),
      'issuedBy': serializer.toJson<String>(issuedBy),
      'issuedAt': serializer.toJson<DateTime>(issuedAt),
      'validUntil': serializer.toJson<DateTime>(validUntil),
      'cancelledAt': serializer.toJson<DateTime?>(cancelledAt),
      'version': serializer.toJson<int>(version),
    };
  }

  LocalAlert copyWith({
    String? id,
    String? title,
    String? message,
    String? severity,
    String? zoneId,
    String? zoneLabel,
    String? geometryJson,
    String? issuedBy,
    DateTime? issuedAt,
    DateTime? validUntil,
    Value<DateTime?> cancelledAt = const Value.absent(),
    int? version,
  }) => LocalAlert(
    id: id ?? this.id,
    title: title ?? this.title,
    message: message ?? this.message,
    severity: severity ?? this.severity,
    zoneId: zoneId ?? this.zoneId,
    zoneLabel: zoneLabel ?? this.zoneLabel,
    geometryJson: geometryJson ?? this.geometryJson,
    issuedBy: issuedBy ?? this.issuedBy,
    issuedAt: issuedAt ?? this.issuedAt,
    validUntil: validUntil ?? this.validUntil,
    cancelledAt: cancelledAt.present ? cancelledAt.value : this.cancelledAt,
    version: version ?? this.version,
  );
  LocalAlert copyWithCompanion(LocalAlertsCompanion data) {
    return LocalAlert(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      message: data.message.present ? data.message.value : this.message,
      severity: data.severity.present ? data.severity.value : this.severity,
      zoneId: data.zoneId.present ? data.zoneId.value : this.zoneId,
      zoneLabel: data.zoneLabel.present ? data.zoneLabel.value : this.zoneLabel,
      geometryJson: data.geometryJson.present
          ? data.geometryJson.value
          : this.geometryJson,
      issuedBy: data.issuedBy.present ? data.issuedBy.value : this.issuedBy,
      issuedAt: data.issuedAt.present ? data.issuedAt.value : this.issuedAt,
      validUntil: data.validUntil.present
          ? data.validUntil.value
          : this.validUntil,
      cancelledAt: data.cancelledAt.present
          ? data.cancelledAt.value
          : this.cancelledAt,
      version: data.version.present ? data.version.value : this.version,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalAlert(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('message: $message, ')
          ..write('severity: $severity, ')
          ..write('zoneId: $zoneId, ')
          ..write('zoneLabel: $zoneLabel, ')
          ..write('geometryJson: $geometryJson, ')
          ..write('issuedBy: $issuedBy, ')
          ..write('issuedAt: $issuedAt, ')
          ..write('validUntil: $validUntil, ')
          ..write('cancelledAt: $cancelledAt, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    message,
    severity,
    zoneId,
    zoneLabel,
    geometryJson,
    issuedBy,
    issuedAt,
    validUntil,
    cancelledAt,
    version,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalAlert &&
          other.id == this.id &&
          other.title == this.title &&
          other.message == this.message &&
          other.severity == this.severity &&
          other.zoneId == this.zoneId &&
          other.zoneLabel == this.zoneLabel &&
          other.geometryJson == this.geometryJson &&
          other.issuedBy == this.issuedBy &&
          other.issuedAt == this.issuedAt &&
          other.validUntil == this.validUntil &&
          other.cancelledAt == this.cancelledAt &&
          other.version == this.version);
}

class LocalAlertsCompanion extends UpdateCompanion<LocalAlert> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> message;
  final Value<String> severity;
  final Value<String> zoneId;
  final Value<String> zoneLabel;
  final Value<String> geometryJson;
  final Value<String> issuedBy;
  final Value<DateTime> issuedAt;
  final Value<DateTime> validUntil;
  final Value<DateTime?> cancelledAt;
  final Value<int> version;
  final Value<int> rowid;
  const LocalAlertsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.message = const Value.absent(),
    this.severity = const Value.absent(),
    this.zoneId = const Value.absent(),
    this.zoneLabel = const Value.absent(),
    this.geometryJson = const Value.absent(),
    this.issuedBy = const Value.absent(),
    this.issuedAt = const Value.absent(),
    this.validUntil = const Value.absent(),
    this.cancelledAt = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalAlertsCompanion.insert({
    required String id,
    required String title,
    required String message,
    required String severity,
    required String zoneId,
    required String zoneLabel,
    required String geometryJson,
    required String issuedBy,
    required DateTime issuedAt,
    required DateTime validUntil,
    this.cancelledAt = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       message = Value(message),
       severity = Value(severity),
       zoneId = Value(zoneId),
       zoneLabel = Value(zoneLabel),
       geometryJson = Value(geometryJson),
       issuedBy = Value(issuedBy),
       issuedAt = Value(issuedAt),
       validUntil = Value(validUntil);
  static Insertable<LocalAlert> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? message,
    Expression<String>? severity,
    Expression<String>? zoneId,
    Expression<String>? zoneLabel,
    Expression<String>? geometryJson,
    Expression<String>? issuedBy,
    Expression<DateTime>? issuedAt,
    Expression<DateTime>? validUntil,
    Expression<DateTime>? cancelledAt,
    Expression<int>? version,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (message != null) 'message': message,
      if (severity != null) 'severity': severity,
      if (zoneId != null) 'zone_id': zoneId,
      if (zoneLabel != null) 'zone_label': zoneLabel,
      if (geometryJson != null) 'geometry_json': geometryJson,
      if (issuedBy != null) 'issued_by': issuedBy,
      if (issuedAt != null) 'issued_at': issuedAt,
      if (validUntil != null) 'valid_until': validUntil,
      if (cancelledAt != null) 'cancelled_at': cancelledAt,
      if (version != null) 'version': version,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalAlertsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? message,
    Value<String>? severity,
    Value<String>? zoneId,
    Value<String>? zoneLabel,
    Value<String>? geometryJson,
    Value<String>? issuedBy,
    Value<DateTime>? issuedAt,
    Value<DateTime>? validUntil,
    Value<DateTime?>? cancelledAt,
    Value<int>? version,
    Value<int>? rowid,
  }) {
    return LocalAlertsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      severity: severity ?? this.severity,
      zoneId: zoneId ?? this.zoneId,
      zoneLabel: zoneLabel ?? this.zoneLabel,
      geometryJson: geometryJson ?? this.geometryJson,
      issuedBy: issuedBy ?? this.issuedBy,
      issuedAt: issuedAt ?? this.issuedAt,
      validUntil: validUntil ?? this.validUntil,
      cancelledAt: cancelledAt ?? this.cancelledAt,
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
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (severity.present) {
      map['severity'] = Variable<String>(severity.value);
    }
    if (zoneId.present) {
      map['zone_id'] = Variable<String>(zoneId.value);
    }
    if (zoneLabel.present) {
      map['zone_label'] = Variable<String>(zoneLabel.value);
    }
    if (geometryJson.present) {
      map['geometry_json'] = Variable<String>(geometryJson.value);
    }
    if (issuedBy.present) {
      map['issued_by'] = Variable<String>(issuedBy.value);
    }
    if (issuedAt.present) {
      map['issued_at'] = Variable<DateTime>(issuedAt.value);
    }
    if (validUntil.present) {
      map['valid_until'] = Variable<DateTime>(validUntil.value);
    }
    if (cancelledAt.present) {
      map['cancelled_at'] = Variable<DateTime>(cancelledAt.value);
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
    return (StringBuffer('LocalAlertsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('message: $message, ')
          ..write('severity: $severity, ')
          ..write('zoneId: $zoneId, ')
          ..write('zoneLabel: $zoneLabel, ')
          ..write('geometryJson: $geometryJson, ')
          ..write('issuedBy: $issuedBy, ')
          ..write('issuedAt: $issuedAt, ')
          ..write('validUntil: $validUntil, ')
          ..write('cancelledAt: $cancelledAt, ')
          ..write('version: $version, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalAlertAcknowledgementsTable extends LocalAlertAcknowledgements
    with
        TableInfo<$LocalAlertAcknowledgementsTable, LocalAlertAcknowledgement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAlertAcknowledgementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _alertIdMeta = const VerificationMeta(
    'alertId',
  );
  @override
  late final GeneratedColumn<String> alertId = GeneratedColumn<String>(
    'alert_id',
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
  );
  static const VerificationMeta _acknowledgedAtMeta = const VerificationMeta(
    'acknowledgedAt',
  );
  @override
  late final GeneratedColumn<DateTime> acknowledgedAt =
      GeneratedColumn<DateTime>(
        'acknowledged_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [id, alertId, userId, acknowledgedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_alert_acknowledgements';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalAlertAcknowledgement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('alert_id')) {
      context.handle(
        _alertIdMeta,
        alertId.isAcceptableOrUnknown(data['alert_id']!, _alertIdMeta),
      );
    } else if (isInserting) {
      context.missing(_alertIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('acknowledged_at')) {
      context.handle(
        _acknowledgedAtMeta,
        acknowledgedAt.isAcceptableOrUnknown(
          data['acknowledged_at']!,
          _acknowledgedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_acknowledgedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalAlertAcknowledgement map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalAlertAcknowledgement(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      alertId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alert_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      acknowledgedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}acknowledged_at'],
      )!,
    );
  }

  @override
  $LocalAlertAcknowledgementsTable createAlias(String alias) {
    return $LocalAlertAcknowledgementsTable(attachedDatabase, alias);
  }
}

class LocalAlertAcknowledgement extends DataClass
    implements Insertable<LocalAlertAcknowledgement> {
  final String id;
  final String alertId;
  final String userId;
  final DateTime acknowledgedAt;
  const LocalAlertAcknowledgement({
    required this.id,
    required this.alertId,
    required this.userId,
    required this.acknowledgedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['alert_id'] = Variable<String>(alertId);
    map['user_id'] = Variable<String>(userId);
    map['acknowledged_at'] = Variable<DateTime>(acknowledgedAt);
    return map;
  }

  LocalAlertAcknowledgementsCompanion toCompanion(bool nullToAbsent) {
    return LocalAlertAcknowledgementsCompanion(
      id: Value(id),
      alertId: Value(alertId),
      userId: Value(userId),
      acknowledgedAt: Value(acknowledgedAt),
    );
  }

  factory LocalAlertAcknowledgement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalAlertAcknowledgement(
      id: serializer.fromJson<String>(json['id']),
      alertId: serializer.fromJson<String>(json['alertId']),
      userId: serializer.fromJson<String>(json['userId']),
      acknowledgedAt: serializer.fromJson<DateTime>(json['acknowledgedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'alertId': serializer.toJson<String>(alertId),
      'userId': serializer.toJson<String>(userId),
      'acknowledgedAt': serializer.toJson<DateTime>(acknowledgedAt),
    };
  }

  LocalAlertAcknowledgement copyWith({
    String? id,
    String? alertId,
    String? userId,
    DateTime? acknowledgedAt,
  }) => LocalAlertAcknowledgement(
    id: id ?? this.id,
    alertId: alertId ?? this.alertId,
    userId: userId ?? this.userId,
    acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
  );
  LocalAlertAcknowledgement copyWithCompanion(
    LocalAlertAcknowledgementsCompanion data,
  ) {
    return LocalAlertAcknowledgement(
      id: data.id.present ? data.id.value : this.id,
      alertId: data.alertId.present ? data.alertId.value : this.alertId,
      userId: data.userId.present ? data.userId.value : this.userId,
      acknowledgedAt: data.acknowledgedAt.present
          ? data.acknowledgedAt.value
          : this.acknowledgedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalAlertAcknowledgement(')
          ..write('id: $id, ')
          ..write('alertId: $alertId, ')
          ..write('userId: $userId, ')
          ..write('acknowledgedAt: $acknowledgedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, alertId, userId, acknowledgedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalAlertAcknowledgement &&
          other.id == this.id &&
          other.alertId == this.alertId &&
          other.userId == this.userId &&
          other.acknowledgedAt == this.acknowledgedAt);
}

class LocalAlertAcknowledgementsCompanion
    extends UpdateCompanion<LocalAlertAcknowledgement> {
  final Value<String> id;
  final Value<String> alertId;
  final Value<String> userId;
  final Value<DateTime> acknowledgedAt;
  final Value<int> rowid;
  const LocalAlertAcknowledgementsCompanion({
    this.id = const Value.absent(),
    this.alertId = const Value.absent(),
    this.userId = const Value.absent(),
    this.acknowledgedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalAlertAcknowledgementsCompanion.insert({
    required String id,
    required String alertId,
    required String userId,
    required DateTime acknowledgedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       alertId = Value(alertId),
       userId = Value(userId),
       acknowledgedAt = Value(acknowledgedAt);
  static Insertable<LocalAlertAcknowledgement> custom({
    Expression<String>? id,
    Expression<String>? alertId,
    Expression<String>? userId,
    Expression<DateTime>? acknowledgedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (alertId != null) 'alert_id': alertId,
      if (userId != null) 'user_id': userId,
      if (acknowledgedAt != null) 'acknowledged_at': acknowledgedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalAlertAcknowledgementsCompanion copyWith({
    Value<String>? id,
    Value<String>? alertId,
    Value<String>? userId,
    Value<DateTime>? acknowledgedAt,
    Value<int>? rowid,
  }) {
    return LocalAlertAcknowledgementsCompanion(
      id: id ?? this.id,
      alertId: alertId ?? this.alertId,
      userId: userId ?? this.userId,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (alertId.present) {
      map['alert_id'] = Variable<String>(alertId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (acknowledgedAt.present) {
      map['acknowledged_at'] = Variable<DateTime>(acknowledgedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalAlertAcknowledgementsCompanion(')
          ..write('id: $id, ')
          ..write('alertId: $alertId, ')
          ..write('userId: $userId, ')
          ..write('acknowledgedAt: $acknowledgedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalEnvironmentalObservationsTable
    extends LocalEnvironmentalObservations
    with
        TableInfo<
          $LocalEnvironmentalObservationsTable,
          LocalEnvironmentalObservation
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalEnvironmentalObservationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
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
  static const VerificationMeta _parameterMeta = const VerificationMeta(
    'parameter',
  );
  @override
  late final GeneratedColumn<String> parameter = GeneratedColumn<String>(
    'parameter',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<double> value = GeneratedColumn<double>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.double,
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
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
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
    defaultValue: const Constant(0.7),
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
    habitationId,
    parameter,
    value,
    source,
    observedAt,
    fetchedAt,
    confidence,
    version,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_environmental_observations';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalEnvironmentalObservation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
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
    if (data.containsKey('parameter')) {
      context.handle(
        _parameterMeta,
        parameter.isAcceptableOrUnknown(data['parameter']!, _parameterMeta),
      );
    } else if (isInserting) {
      context.missing(_parameterMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
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
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
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
  LocalEnvironmentalObservation map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalEnvironmentalObservation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      habitationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}habitation_id'],
      )!,
      parameter: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parameter'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      observedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}observed_at'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
    );
  }

  @override
  $LocalEnvironmentalObservationsTable createAlias(String alias) {
    return $LocalEnvironmentalObservationsTable(attachedDatabase, alias);
  }
}

class LocalEnvironmentalObservation extends DataClass
    implements Insertable<LocalEnvironmentalObservation> {
  final String id;
  final String habitationId;

  /// One of [EnvironmentalParameter]'s storage values.
  final String parameter;
  final double value;

  /// Free-text attribution — "IMD", "CWC River Gauge", etc. — the
  /// "visible provenance" the acceptance criterion asks for.
  final String source;

  /// When the source itself took this reading — distinct from when this
  /// device fetched it, and what [[EnvironmentalRiskEngine]]'s freshness
  /// check is measured against ("do not present stale environmental data
  /// as current without freshness information").
  final DateTime observedAt;
  final DateTime fetchedAt;
  final double confidence;
  final int version;
  const LocalEnvironmentalObservation({
    required this.id,
    required this.habitationId,
    required this.parameter,
    required this.value,
    required this.source,
    required this.observedAt,
    required this.fetchedAt,
    required this.confidence,
    required this.version,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['habitation_id'] = Variable<String>(habitationId);
    map['parameter'] = Variable<String>(parameter);
    map['value'] = Variable<double>(value);
    map['source'] = Variable<String>(source);
    map['observed_at'] = Variable<DateTime>(observedAt);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    map['confidence'] = Variable<double>(confidence);
    map['version'] = Variable<int>(version);
    return map;
  }

  LocalEnvironmentalObservationsCompanion toCompanion(bool nullToAbsent) {
    return LocalEnvironmentalObservationsCompanion(
      id: Value(id),
      habitationId: Value(habitationId),
      parameter: Value(parameter),
      value: Value(value),
      source: Value(source),
      observedAt: Value(observedAt),
      fetchedAt: Value(fetchedAt),
      confidence: Value(confidence),
      version: Value(version),
    );
  }

  factory LocalEnvironmentalObservation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalEnvironmentalObservation(
      id: serializer.fromJson<String>(json['id']),
      habitationId: serializer.fromJson<String>(json['habitationId']),
      parameter: serializer.fromJson<String>(json['parameter']),
      value: serializer.fromJson<double>(json['value']),
      source: serializer.fromJson<String>(json['source']),
      observedAt: serializer.fromJson<DateTime>(json['observedAt']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
      confidence: serializer.fromJson<double>(json['confidence']),
      version: serializer.fromJson<int>(json['version']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'habitationId': serializer.toJson<String>(habitationId),
      'parameter': serializer.toJson<String>(parameter),
      'value': serializer.toJson<double>(value),
      'source': serializer.toJson<String>(source),
      'observedAt': serializer.toJson<DateTime>(observedAt),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
      'confidence': serializer.toJson<double>(confidence),
      'version': serializer.toJson<int>(version),
    };
  }

  LocalEnvironmentalObservation copyWith({
    String? id,
    String? habitationId,
    String? parameter,
    double? value,
    String? source,
    DateTime? observedAt,
    DateTime? fetchedAt,
    double? confidence,
    int? version,
  }) => LocalEnvironmentalObservation(
    id: id ?? this.id,
    habitationId: habitationId ?? this.habitationId,
    parameter: parameter ?? this.parameter,
    value: value ?? this.value,
    source: source ?? this.source,
    observedAt: observedAt ?? this.observedAt,
    fetchedAt: fetchedAt ?? this.fetchedAt,
    confidence: confidence ?? this.confidence,
    version: version ?? this.version,
  );
  LocalEnvironmentalObservation copyWithCompanion(
    LocalEnvironmentalObservationsCompanion data,
  ) {
    return LocalEnvironmentalObservation(
      id: data.id.present ? data.id.value : this.id,
      habitationId: data.habitationId.present
          ? data.habitationId.value
          : this.habitationId,
      parameter: data.parameter.present ? data.parameter.value : this.parameter,
      value: data.value.present ? data.value.value : this.value,
      source: data.source.present ? data.source.value : this.source,
      observedAt: data.observedAt.present
          ? data.observedAt.value
          : this.observedAt,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      version: data.version.present ? data.version.value : this.version,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalEnvironmentalObservation(')
          ..write('id: $id, ')
          ..write('habitationId: $habitationId, ')
          ..write('parameter: $parameter, ')
          ..write('value: $value, ')
          ..write('source: $source, ')
          ..write('observedAt: $observedAt, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('confidence: $confidence, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    habitationId,
    parameter,
    value,
    source,
    observedAt,
    fetchedAt,
    confidence,
    version,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalEnvironmentalObservation &&
          other.id == this.id &&
          other.habitationId == this.habitationId &&
          other.parameter == this.parameter &&
          other.value == this.value &&
          other.source == this.source &&
          other.observedAt == this.observedAt &&
          other.fetchedAt == this.fetchedAt &&
          other.confidence == this.confidence &&
          other.version == this.version);
}

class LocalEnvironmentalObservationsCompanion
    extends UpdateCompanion<LocalEnvironmentalObservation> {
  final Value<String> id;
  final Value<String> habitationId;
  final Value<String> parameter;
  final Value<double> value;
  final Value<String> source;
  final Value<DateTime> observedAt;
  final Value<DateTime> fetchedAt;
  final Value<double> confidence;
  final Value<int> version;
  final Value<int> rowid;
  const LocalEnvironmentalObservationsCompanion({
    this.id = const Value.absent(),
    this.habitationId = const Value.absent(),
    this.parameter = const Value.absent(),
    this.value = const Value.absent(),
    this.source = const Value.absent(),
    this.observedAt = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.confidence = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalEnvironmentalObservationsCompanion.insert({
    required String id,
    required String habitationId,
    required String parameter,
    required double value,
    required String source,
    required DateTime observedAt,
    required DateTime fetchedAt,
    this.confidence = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       habitationId = Value(habitationId),
       parameter = Value(parameter),
       value = Value(value),
       source = Value(source),
       observedAt = Value(observedAt),
       fetchedAt = Value(fetchedAt);
  static Insertable<LocalEnvironmentalObservation> custom({
    Expression<String>? id,
    Expression<String>? habitationId,
    Expression<String>? parameter,
    Expression<double>? value,
    Expression<String>? source,
    Expression<DateTime>? observedAt,
    Expression<DateTime>? fetchedAt,
    Expression<double>? confidence,
    Expression<int>? version,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (habitationId != null) 'habitation_id': habitationId,
      if (parameter != null) 'parameter': parameter,
      if (value != null) 'value': value,
      if (source != null) 'source': source,
      if (observedAt != null) 'observed_at': observedAt,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (confidence != null) 'confidence': confidence,
      if (version != null) 'version': version,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalEnvironmentalObservationsCompanion copyWith({
    Value<String>? id,
    Value<String>? habitationId,
    Value<String>? parameter,
    Value<double>? value,
    Value<String>? source,
    Value<DateTime>? observedAt,
    Value<DateTime>? fetchedAt,
    Value<double>? confidence,
    Value<int>? version,
    Value<int>? rowid,
  }) {
    return LocalEnvironmentalObservationsCompanion(
      id: id ?? this.id,
      habitationId: habitationId ?? this.habitationId,
      parameter: parameter ?? this.parameter,
      value: value ?? this.value,
      source: source ?? this.source,
      observedAt: observedAt ?? this.observedAt,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      confidence: confidence ?? this.confidence,
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
    if (habitationId.present) {
      map['habitation_id'] = Variable<String>(habitationId.value);
    }
    if (parameter.present) {
      map['parameter'] = Variable<String>(parameter.value);
    }
    if (value.present) {
      map['value'] = Variable<double>(value.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (observedAt.present) {
      map['observed_at'] = Variable<DateTime>(observedAt.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
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
    return (StringBuffer('LocalEnvironmentalObservationsCompanion(')
          ..write('id: $id, ')
          ..write('habitationId: $habitationId, ')
          ..write('parameter: $parameter, ')
          ..write('value: $value, ')
          ..write('source: $source, ')
          ..write('observedAt: $observedAt, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('confidence: $confidence, ')
          ..write('version: $version, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalDamageReportsTable extends LocalDamageReports
    with TableInfo<$LocalDamageReportsTable, LocalDamageReport> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalDamageReportsTable(this.attachedDatabase, [this._alias]);
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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _responderIdMeta = const VerificationMeta(
    'responderId',
  );
  @override
  late final GeneratedColumn<String> responderId = GeneratedColumn<String>(
    'responder_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
  static const VerificationMeta _mediaPathMeta = const VerificationMeta(
    'mediaPath',
  );
  @override
  late final GeneratedColumn<String> mediaPath = GeneratedColumn<String>(
    'media_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _submittedAtMeta = const VerificationMeta(
    'submittedAt',
  );
  @override
  late final GeneratedColumn<DateTime> submittedAt = GeneratedColumn<DateTime>(
    'submitted_at',
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
    incidentId,
    responderId,
    description,
    severity,
    mediaPath,
    submittedAt,
    version,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_damage_reports';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalDamageReport> instance, {
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
    } else if (isInserting) {
      context.missing(_incidentIdMeta);
    }
    if (data.containsKey('responder_id')) {
      context.handle(
        _responderIdMeta,
        responderId.isAcceptableOrUnknown(
          data['responder_id']!,
          _responderIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_responderIdMeta);
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
    if (data.containsKey('media_path')) {
      context.handle(
        _mediaPathMeta,
        mediaPath.isAcceptableOrUnknown(data['media_path']!, _mediaPathMeta),
      );
    }
    if (data.containsKey('submitted_at')) {
      context.handle(
        _submittedAtMeta,
        submittedAt.isAcceptableOrUnknown(
          data['submitted_at']!,
          _submittedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_submittedAtMeta);
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
  LocalDamageReport map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalDamageReport(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      incidentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}incident_id'],
      )!,
      responderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}responder_id'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      severity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}severity'],
      )!,
      mediaPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_path'],
      ),
      submittedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}submitted_at'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
    );
  }

  @override
  $LocalDamageReportsTable createAlias(String alias) {
    return $LocalDamageReportsTable(attachedDatabase, alias);
  }
}

class LocalDamageReport extends DataClass
    implements Insertable<LocalDamageReport> {
  final String id;
  final String incidentId;
  final String responderId;
  final String description;
  final String severity;

  /// Local file path to an optionally-attached photo, same pattern as
  /// [LocalIncidentReports.mediaPath].
  final String? mediaPath;
  final DateTime submittedAt;
  final int version;
  const LocalDamageReport({
    required this.id,
    required this.incidentId,
    required this.responderId,
    required this.description,
    required this.severity,
    this.mediaPath,
    required this.submittedAt,
    required this.version,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['incident_id'] = Variable<String>(incidentId);
    map['responder_id'] = Variable<String>(responderId);
    map['description'] = Variable<String>(description);
    map['severity'] = Variable<String>(severity);
    if (!nullToAbsent || mediaPath != null) {
      map['media_path'] = Variable<String>(mediaPath);
    }
    map['submitted_at'] = Variable<DateTime>(submittedAt);
    map['version'] = Variable<int>(version);
    return map;
  }

  LocalDamageReportsCompanion toCompanion(bool nullToAbsent) {
    return LocalDamageReportsCompanion(
      id: Value(id),
      incidentId: Value(incidentId),
      responderId: Value(responderId),
      description: Value(description),
      severity: Value(severity),
      mediaPath: mediaPath == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaPath),
      submittedAt: Value(submittedAt),
      version: Value(version),
    );
  }

  factory LocalDamageReport.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalDamageReport(
      id: serializer.fromJson<String>(json['id']),
      incidentId: serializer.fromJson<String>(json['incidentId']),
      responderId: serializer.fromJson<String>(json['responderId']),
      description: serializer.fromJson<String>(json['description']),
      severity: serializer.fromJson<String>(json['severity']),
      mediaPath: serializer.fromJson<String?>(json['mediaPath']),
      submittedAt: serializer.fromJson<DateTime>(json['submittedAt']),
      version: serializer.fromJson<int>(json['version']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'incidentId': serializer.toJson<String>(incidentId),
      'responderId': serializer.toJson<String>(responderId),
      'description': serializer.toJson<String>(description),
      'severity': serializer.toJson<String>(severity),
      'mediaPath': serializer.toJson<String?>(mediaPath),
      'submittedAt': serializer.toJson<DateTime>(submittedAt),
      'version': serializer.toJson<int>(version),
    };
  }

  LocalDamageReport copyWith({
    String? id,
    String? incidentId,
    String? responderId,
    String? description,
    String? severity,
    Value<String?> mediaPath = const Value.absent(),
    DateTime? submittedAt,
    int? version,
  }) => LocalDamageReport(
    id: id ?? this.id,
    incidentId: incidentId ?? this.incidentId,
    responderId: responderId ?? this.responderId,
    description: description ?? this.description,
    severity: severity ?? this.severity,
    mediaPath: mediaPath.present ? mediaPath.value : this.mediaPath,
    submittedAt: submittedAt ?? this.submittedAt,
    version: version ?? this.version,
  );
  LocalDamageReport copyWithCompanion(LocalDamageReportsCompanion data) {
    return LocalDamageReport(
      id: data.id.present ? data.id.value : this.id,
      incidentId: data.incidentId.present
          ? data.incidentId.value
          : this.incidentId,
      responderId: data.responderId.present
          ? data.responderId.value
          : this.responderId,
      description: data.description.present
          ? data.description.value
          : this.description,
      severity: data.severity.present ? data.severity.value : this.severity,
      mediaPath: data.mediaPath.present ? data.mediaPath.value : this.mediaPath,
      submittedAt: data.submittedAt.present
          ? data.submittedAt.value
          : this.submittedAt,
      version: data.version.present ? data.version.value : this.version,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalDamageReport(')
          ..write('id: $id, ')
          ..write('incidentId: $incidentId, ')
          ..write('responderId: $responderId, ')
          ..write('description: $description, ')
          ..write('severity: $severity, ')
          ..write('mediaPath: $mediaPath, ')
          ..write('submittedAt: $submittedAt, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    incidentId,
    responderId,
    description,
    severity,
    mediaPath,
    submittedAt,
    version,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalDamageReport &&
          other.id == this.id &&
          other.incidentId == this.incidentId &&
          other.responderId == this.responderId &&
          other.description == this.description &&
          other.severity == this.severity &&
          other.mediaPath == this.mediaPath &&
          other.submittedAt == this.submittedAt &&
          other.version == this.version);
}

class LocalDamageReportsCompanion extends UpdateCompanion<LocalDamageReport> {
  final Value<String> id;
  final Value<String> incidentId;
  final Value<String> responderId;
  final Value<String> description;
  final Value<String> severity;
  final Value<String?> mediaPath;
  final Value<DateTime> submittedAt;
  final Value<int> version;
  final Value<int> rowid;
  const LocalDamageReportsCompanion({
    this.id = const Value.absent(),
    this.incidentId = const Value.absent(),
    this.responderId = const Value.absent(),
    this.description = const Value.absent(),
    this.severity = const Value.absent(),
    this.mediaPath = const Value.absent(),
    this.submittedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalDamageReportsCompanion.insert({
    required String id,
    required String incidentId,
    required String responderId,
    this.description = const Value.absent(),
    this.severity = const Value.absent(),
    this.mediaPath = const Value.absent(),
    required DateTime submittedAt,
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       incidentId = Value(incidentId),
       responderId = Value(responderId),
       submittedAt = Value(submittedAt);
  static Insertable<LocalDamageReport> custom({
    Expression<String>? id,
    Expression<String>? incidentId,
    Expression<String>? responderId,
    Expression<String>? description,
    Expression<String>? severity,
    Expression<String>? mediaPath,
    Expression<DateTime>? submittedAt,
    Expression<int>? version,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (incidentId != null) 'incident_id': incidentId,
      if (responderId != null) 'responder_id': responderId,
      if (description != null) 'description': description,
      if (severity != null) 'severity': severity,
      if (mediaPath != null) 'media_path': mediaPath,
      if (submittedAt != null) 'submitted_at': submittedAt,
      if (version != null) 'version': version,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalDamageReportsCompanion copyWith({
    Value<String>? id,
    Value<String>? incidentId,
    Value<String>? responderId,
    Value<String>? description,
    Value<String>? severity,
    Value<String?>? mediaPath,
    Value<DateTime>? submittedAt,
    Value<int>? version,
    Value<int>? rowid,
  }) {
    return LocalDamageReportsCompanion(
      id: id ?? this.id,
      incidentId: incidentId ?? this.incidentId,
      responderId: responderId ?? this.responderId,
      description: description ?? this.description,
      severity: severity ?? this.severity,
      mediaPath: mediaPath ?? this.mediaPath,
      submittedAt: submittedAt ?? this.submittedAt,
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
    if (incidentId.present) {
      map['incident_id'] = Variable<String>(incidentId.value);
    }
    if (responderId.present) {
      map['responder_id'] = Variable<String>(responderId.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (severity.present) {
      map['severity'] = Variable<String>(severity.value);
    }
    if (mediaPath.present) {
      map['media_path'] = Variable<String>(mediaPath.value);
    }
    if (submittedAt.present) {
      map['submitted_at'] = Variable<DateTime>(submittedAt.value);
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
    return (StringBuffer('LocalDamageReportsCompanion(')
          ..write('id: $id, ')
          ..write('incidentId: $incidentId, ')
          ..write('responderId: $responderId, ')
          ..write('description: $description, ')
          ..write('severity: $severity, ')
          ..write('mediaPath: $mediaPath, ')
          ..write('submittedAt: $submittedAt, ')
          ..write('version: $version, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalResourcesTable extends LocalResources
    with TableInfo<$LocalResourcesTable, LocalResource> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalResourcesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _shelterIdMeta = const VerificationMeta(
    'shelterId',
  );
  @override
  late final GeneratedColumn<String> shelterId = GeneratedColumn<String>(
    'shelter_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
    type,
    quantity,
    shelterId,
    updatedAt,
    version,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_resources';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalResource> instance, {
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
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    if (data.containsKey('shelter_id')) {
      context.handle(
        _shelterIdMeta,
        shelterId.isAcceptableOrUnknown(data['shelter_id']!, _shelterIdMeta),
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
  LocalResource map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalResource(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      shelterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shelter_id'],
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
  $LocalResourcesTable createAlias(String alias) {
    return $LocalResourcesTable(attachedDatabase, alias);
  }
}

class LocalResource extends DataClass implements Insertable<LocalResource> {
  final String id;
  final String name;
  final String type;
  final int quantity;

  /// Optional — a resource doesn't have to be tied to a specific shelter
  /// to be tracked (e.g. a district-wide vehicle pool).
  final String? shelterId;
  final DateTime updatedAt;
  final int version;
  const LocalResource({
    required this.id,
    required this.name,
    required this.type,
    required this.quantity,
    this.shelterId,
    required this.updatedAt,
    required this.version,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['quantity'] = Variable<int>(quantity);
    if (!nullToAbsent || shelterId != null) {
      map['shelter_id'] = Variable<String>(shelterId);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['version'] = Variable<int>(version);
    return map;
  }

  LocalResourcesCompanion toCompanion(bool nullToAbsent) {
    return LocalResourcesCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      quantity: Value(quantity),
      shelterId: shelterId == null && nullToAbsent
          ? const Value.absent()
          : Value(shelterId),
      updatedAt: Value(updatedAt),
      version: Value(version),
    );
  }

  factory LocalResource.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalResource(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      quantity: serializer.fromJson<int>(json['quantity']),
      shelterId: serializer.fromJson<String?>(json['shelterId']),
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
      'type': serializer.toJson<String>(type),
      'quantity': serializer.toJson<int>(quantity),
      'shelterId': serializer.toJson<String?>(shelterId),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'version': serializer.toJson<int>(version),
    };
  }

  LocalResource copyWith({
    String? id,
    String? name,
    String? type,
    int? quantity,
    Value<String?> shelterId = const Value.absent(),
    DateTime? updatedAt,
    int? version,
  }) => LocalResource(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    quantity: quantity ?? this.quantity,
    shelterId: shelterId.present ? shelterId.value : this.shelterId,
    updatedAt: updatedAt ?? this.updatedAt,
    version: version ?? this.version,
  );
  LocalResource copyWithCompanion(LocalResourcesCompanion data) {
    return LocalResource(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      shelterId: data.shelterId.present ? data.shelterId.value : this.shelterId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      version: data.version.present ? data.version.value : this.version,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalResource(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('quantity: $quantity, ')
          ..write('shelterId: $shelterId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, type, quantity, shelterId, updatedAt, version);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalResource &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.quantity == this.quantity &&
          other.shelterId == this.shelterId &&
          other.updatedAt == this.updatedAt &&
          other.version == this.version);
}

class LocalResourcesCompanion extends UpdateCompanion<LocalResource> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> type;
  final Value<int> quantity;
  final Value<String?> shelterId;
  final Value<DateTime> updatedAt;
  final Value<int> version;
  final Value<int> rowid;
  const LocalResourcesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.quantity = const Value.absent(),
    this.shelterId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalResourcesCompanion.insert({
    required String id,
    required String name,
    required String type,
    this.quantity = const Value.absent(),
    this.shelterId = const Value.absent(),
    required DateTime updatedAt,
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       type = Value(type),
       updatedAt = Value(updatedAt);
  static Insertable<LocalResource> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<int>? quantity,
    Expression<String>? shelterId,
    Expression<DateTime>? updatedAt,
    Expression<int>? version,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (quantity != null) 'quantity': quantity,
      if (shelterId != null) 'shelter_id': shelterId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (version != null) 'version': version,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalResourcesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? type,
    Value<int>? quantity,
    Value<String?>? shelterId,
    Value<DateTime>? updatedAt,
    Value<int>? version,
    Value<int>? rowid,
  }) {
    return LocalResourcesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      shelterId: shelterId ?? this.shelterId,
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
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (shelterId.present) {
      map['shelter_id'] = Variable<String>(shelterId.value);
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
    return (StringBuffer('LocalResourcesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('quantity: $quantity, ')
          ..write('shelterId: $shelterId, ')
          ..write('updatedAt: $updatedAt, ')
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
  late final $LocalHazardAutomationStatesTable localHazardAutomationStates =
      $LocalHazardAutomationStatesTable(this);
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
  late final $LocalAuditEventsTable localAuditEvents = $LocalAuditEventsTable(
    this,
  );
  late final $LocalAlertsTable localAlerts = $LocalAlertsTable(this);
  late final $LocalAlertAcknowledgementsTable localAlertAcknowledgements =
      $LocalAlertAcknowledgementsTable(this);
  late final $LocalEnvironmentalObservationsTable
  localEnvironmentalObservations = $LocalEnvironmentalObservationsTable(this);
  late final $LocalDamageReportsTable localDamageReports =
      $LocalDamageReportsTable(this);
  late final $LocalResourcesTable localResources = $LocalResourcesTable(this);
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
    localHazardAutomationStates,
    localIncidents,
    localIncidentReports,
    localShelters,
    localRoutes,
    localHabitations,
    localRiskAssessments,
    localVulnerabilityAssessments,
    localCapacityAssessments,
    localRelocationPlans,
    localAuditEvents,
    localAlerts,
    localAlertAcknowledgements,
    localEnvironmentalObservations,
    localDamageReports,
    localResources,
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
typedef $$LocalHazardAutomationStatesTableCreateCompanionBuilder =
    LocalHazardAutomationStatesCompanion Function({
      required String id,
      required String habitationId,
      required String hazardType,
      required double lastScore,
      Value<int> consecutiveBelowDeleteThreshold,
      Value<bool> zoneActive,
      required DateTime lastEvaluatedAt,
      Value<int> rowid,
    });
typedef $$LocalHazardAutomationStatesTableUpdateCompanionBuilder =
    LocalHazardAutomationStatesCompanion Function({
      Value<String> id,
      Value<String> habitationId,
      Value<String> hazardType,
      Value<double> lastScore,
      Value<int> consecutiveBelowDeleteThreshold,
      Value<bool> zoneActive,
      Value<DateTime> lastEvaluatedAt,
      Value<int> rowid,
    });

class $$LocalHazardAutomationStatesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalHazardAutomationStatesTable> {
  $$LocalHazardAutomationStatesTableFilterComposer({
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

  ColumnFilters<String> get habitationId => $composableBuilder(
    column: $table.habitationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hazardType => $composableBuilder(
    column: $table.hazardType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lastScore => $composableBuilder(
    column: $table.lastScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get consecutiveBelowDeleteThreshold => $composableBuilder(
    column: $table.consecutiveBelowDeleteThreshold,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get zoneActive => $composableBuilder(
    column: $table.zoneActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastEvaluatedAt => $composableBuilder(
    column: $table.lastEvaluatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalHazardAutomationStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalHazardAutomationStatesTable> {
  $$LocalHazardAutomationStatesTableOrderingComposer({
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

  ColumnOrderings<String> get habitationId => $composableBuilder(
    column: $table.habitationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hazardType => $composableBuilder(
    column: $table.hazardType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lastScore => $composableBuilder(
    column: $table.lastScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get consecutiveBelowDeleteThreshold =>
      $composableBuilder(
        column: $table.consecutiveBelowDeleteThreshold,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<bool> get zoneActive => $composableBuilder(
    column: $table.zoneActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastEvaluatedAt => $composableBuilder(
    column: $table.lastEvaluatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalHazardAutomationStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalHazardAutomationStatesTable> {
  $$LocalHazardAutomationStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get habitationId => $composableBuilder(
    column: $table.habitationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get hazardType => $composableBuilder(
    column: $table.hazardType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get lastScore =>
      $composableBuilder(column: $table.lastScore, builder: (column) => column);

  GeneratedColumn<int> get consecutiveBelowDeleteThreshold =>
      $composableBuilder(
        column: $table.consecutiveBelowDeleteThreshold,
        builder: (column) => column,
      );

  GeneratedColumn<bool> get zoneActive => $composableBuilder(
    column: $table.zoneActive,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastEvaluatedAt => $composableBuilder(
    column: $table.lastEvaluatedAt,
    builder: (column) => column,
  );
}

class $$LocalHazardAutomationStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalHazardAutomationStatesTable,
          LocalHazardAutomationState,
          $$LocalHazardAutomationStatesTableFilterComposer,
          $$LocalHazardAutomationStatesTableOrderingComposer,
          $$LocalHazardAutomationStatesTableAnnotationComposer,
          $$LocalHazardAutomationStatesTableCreateCompanionBuilder,
          $$LocalHazardAutomationStatesTableUpdateCompanionBuilder,
          (
            LocalHazardAutomationState,
            BaseReferences<
              _$AppDatabase,
              $LocalHazardAutomationStatesTable,
              LocalHazardAutomationState
            >,
          ),
          LocalHazardAutomationState,
          PrefetchHooks Function()
        > {
  $$LocalHazardAutomationStatesTableTableManager(
    _$AppDatabase db,
    $LocalHazardAutomationStatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalHazardAutomationStatesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LocalHazardAutomationStatesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalHazardAutomationStatesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> habitationId = const Value.absent(),
                Value<String> hazardType = const Value.absent(),
                Value<double> lastScore = const Value.absent(),
                Value<int> consecutiveBelowDeleteThreshold =
                    const Value.absent(),
                Value<bool> zoneActive = const Value.absent(),
                Value<DateTime> lastEvaluatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalHazardAutomationStatesCompanion(
                id: id,
                habitationId: habitationId,
                hazardType: hazardType,
                lastScore: lastScore,
                consecutiveBelowDeleteThreshold:
                    consecutiveBelowDeleteThreshold,
                zoneActive: zoneActive,
                lastEvaluatedAt: lastEvaluatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String habitationId,
                required String hazardType,
                required double lastScore,
                Value<int> consecutiveBelowDeleteThreshold =
                    const Value.absent(),
                Value<bool> zoneActive = const Value.absent(),
                required DateTime lastEvaluatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalHazardAutomationStatesCompanion.insert(
                id: id,
                habitationId: habitationId,
                hazardType: hazardType,
                lastScore: lastScore,
                consecutiveBelowDeleteThreshold:
                    consecutiveBelowDeleteThreshold,
                zoneActive: zoneActive,
                lastEvaluatedAt: lastEvaluatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalHazardAutomationStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalHazardAutomationStatesTable,
      LocalHazardAutomationState,
      $$LocalHazardAutomationStatesTableFilterComposer,
      $$LocalHazardAutomationStatesTableOrderingComposer,
      $$LocalHazardAutomationStatesTableAnnotationComposer,
      $$LocalHazardAutomationStatesTableCreateCompanionBuilder,
      $$LocalHazardAutomationStatesTableUpdateCompanionBuilder,
      (
        LocalHazardAutomationState,
        BaseReferences<
          _$AppDatabase,
          $LocalHazardAutomationStatesTable,
          LocalHazardAutomationState
        >,
      ),
      LocalHazardAutomationState,
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
      Value<int> independentSourceCount,
      Value<double> confidence,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> version,
      Value<bool> isSynced,
      Value<String?> assignedResponderId,
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
      Value<int> independentSourceCount,
      Value<double> confidence,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> version,
      Value<bool> isSynced,
      Value<String?> assignedResponderId,
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

  ColumnFilters<int> get independentSourceCount => $composableBuilder(
    column: $table.independentSourceCount,
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

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assignedResponderId => $composableBuilder(
    column: $table.assignedResponderId,
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

  ColumnOrderings<int> get independentSourceCount => $composableBuilder(
    column: $table.independentSourceCount,
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

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assignedResponderId => $composableBuilder(
    column: $table.assignedResponderId,
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

  GeneratedColumn<int> get independentSourceCount => $composableBuilder(
    column: $table.independentSourceCount,
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

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<String> get assignedResponderId => $composableBuilder(
    column: $table.assignedResponderId,
    builder: (column) => column,
  );
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
                Value<int> independentSourceCount = const Value.absent(),
                Value<double> confidence = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<String?> assignedResponderId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalIncidentsCompanion(
                id: id,
                type: type,
                status: status,
                latitude: latitude,
                longitude: longitude,
                description: description,
                severity: severity,
                independentSourceCount: independentSourceCount,
                confidence: confidence,
                createdAt: createdAt,
                updatedAt: updatedAt,
                version: version,
                isSynced: isSynced,
                assignedResponderId: assignedResponderId,
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
                Value<int> independentSourceCount = const Value.absent(),
                Value<double> confidence = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> version = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<String?> assignedResponderId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalIncidentsCompanion.insert(
                id: id,
                type: type,
                status: status,
                latitude: latitude,
                longitude: longitude,
                description: description,
                severity: severity,
                independentSourceCount: independentSourceCount,
                confidence: confidence,
                createdAt: createdAt,
                updatedAt: updatedAt,
                version: version,
                isSynced: isSynced,
                assignedResponderId: assignedResponderId,
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
      required String reportType,
      Value<String> description,
      Value<String> severity,
      Value<int?> affectedPeopleCount,
      Value<String?> mediaPath,
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
      Value<String> reportType,
      Value<String> description,
      Value<String> severity,
      Value<int?> affectedPeopleCount,
      Value<String?> mediaPath,
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

  ColumnFilters<String> get reportType => $composableBuilder(
    column: $table.reportType,
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

  ColumnFilters<int> get affectedPeopleCount => $composableBuilder(
    column: $table.affectedPeopleCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mediaPath => $composableBuilder(
    column: $table.mediaPath,
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

  ColumnOrderings<String> get reportType => $composableBuilder(
    column: $table.reportType,
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

  ColumnOrderings<int> get affectedPeopleCount => $composableBuilder(
    column: $table.affectedPeopleCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mediaPath => $composableBuilder(
    column: $table.mediaPath,
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

  GeneratedColumn<String> get reportType => $composableBuilder(
    column: $table.reportType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => column);

  GeneratedColumn<int> get affectedPeopleCount => $composableBuilder(
    column: $table.affectedPeopleCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mediaPath =>
      $composableBuilder(column: $table.mediaPath, builder: (column) => column);

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
                Value<String> reportType = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> severity = const Value.absent(),
                Value<int?> affectedPeopleCount = const Value.absent(),
                Value<String?> mediaPath = const Value.absent(),
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
                reportType: reportType,
                description: description,
                severity: severity,
                affectedPeopleCount: affectedPeopleCount,
                mediaPath: mediaPath,
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
                required String reportType,
                Value<String> description = const Value.absent(),
                Value<String> severity = const Value.absent(),
                Value<int?> affectedPeopleCount = const Value.absent(),
                Value<String?> mediaPath = const Value.absent(),
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
                reportType: reportType,
                description: description,
                severity: severity,
                affectedPeopleCount: affectedPeopleCount,
                mediaPath: mediaPath,
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
      Value<bool> isSafe,
      Value<bool> isRoadSnapped,
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
      Value<bool> isSafe,
      Value<bool> isRoadSnapped,
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

  ColumnFilters<bool> get isSafe => $composableBuilder(
    column: $table.isSafe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRoadSnapped => $composableBuilder(
    column: $table.isRoadSnapped,
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

  ColumnOrderings<bool> get isSafe => $composableBuilder(
    column: $table.isSafe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRoadSnapped => $composableBuilder(
    column: $table.isRoadSnapped,
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

  GeneratedColumn<bool> get isSafe =>
      $composableBuilder(column: $table.isSafe, builder: (column) => column);

  GeneratedColumn<bool> get isRoadSnapped => $composableBuilder(
    column: $table.isRoadSnapped,
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
                Value<bool> isSafe = const Value.absent(),
                Value<bool> isRoadSnapped = const Value.absent(),
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
                isSafe: isSafe,
                isRoadSnapped: isRoadSnapped,
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
                Value<bool> isSafe = const Value.absent(),
                Value<bool> isRoadSnapped = const Value.absent(),
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
                isSafe: isSafe,
                isRoadSnapped: isRoadSnapped,
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
      Value<double> environmentalAdjustment,
      Value<String> environmentalProvenanceJson,
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
      Value<double> environmentalAdjustment,
      Value<String> environmentalProvenanceJson,
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

  ColumnFilters<double> get environmentalAdjustment => $composableBuilder(
    column: $table.environmentalAdjustment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get environmentalProvenanceJson => $composableBuilder(
    column: $table.environmentalProvenanceJson,
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

  ColumnOrderings<double> get environmentalAdjustment => $composableBuilder(
    column: $table.environmentalAdjustment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get environmentalProvenanceJson => $composableBuilder(
    column: $table.environmentalProvenanceJson,
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

  GeneratedColumn<double> get environmentalAdjustment => $composableBuilder(
    column: $table.environmentalAdjustment,
    builder: (column) => column,
  );

  GeneratedColumn<String> get environmentalProvenanceJson => $composableBuilder(
    column: $table.environmentalProvenanceJson,
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
                Value<double> environmentalAdjustment = const Value.absent(),
                Value<String> environmentalProvenanceJson =
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
                environmentalAdjustment: environmentalAdjustment,
                environmentalProvenanceJson: environmentalProvenanceJson,
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
                Value<double> environmentalAdjustment = const Value.absent(),
                Value<String> environmentalProvenanceJson =
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
                environmentalAdjustment: environmentalAdjustment,
                environmentalProvenanceJson: environmentalProvenanceJson,
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
typedef $$LocalAuditEventsTableCreateCompanionBuilder =
    LocalAuditEventsCompanion Function({
      Value<int> id,
      required String actorId,
      required String action,
      required String objectType,
      required String objectId,
      Value<String?> oldValue,
      Value<String?> newValue,
      Value<String?> reason,
      required DateTime occurredAt,
    });
typedef $$LocalAuditEventsTableUpdateCompanionBuilder =
    LocalAuditEventsCompanion Function({
      Value<int> id,
      Value<String> actorId,
      Value<String> action,
      Value<String> objectType,
      Value<String> objectId,
      Value<String?> oldValue,
      Value<String?> newValue,
      Value<String?> reason,
      Value<DateTime> occurredAt,
    });

class $$LocalAuditEventsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalAuditEventsTable> {
  $$LocalAuditEventsTableFilterComposer({
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

  ColumnFilters<String> get actorId => $composableBuilder(
    column: $table.actorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get objectType => $composableBuilder(
    column: $table.objectType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get objectId => $composableBuilder(
    column: $table.objectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get oldValue => $composableBuilder(
    column: $table.oldValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get newValue => $composableBuilder(
    column: $table.newValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalAuditEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalAuditEventsTable> {
  $$LocalAuditEventsTableOrderingComposer({
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

  ColumnOrderings<String> get actorId => $composableBuilder(
    column: $table.actorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get objectType => $composableBuilder(
    column: $table.objectType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get objectId => $composableBuilder(
    column: $table.objectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get oldValue => $composableBuilder(
    column: $table.oldValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get newValue => $composableBuilder(
    column: $table.newValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalAuditEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalAuditEventsTable> {
  $$LocalAuditEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get actorId =>
      $composableBuilder(column: $table.actorId, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get objectType => $composableBuilder(
    column: $table.objectType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get objectId =>
      $composableBuilder(column: $table.objectId, builder: (column) => column);

  GeneratedColumn<String> get oldValue =>
      $composableBuilder(column: $table.oldValue, builder: (column) => column);

  GeneratedColumn<String> get newValue =>
      $composableBuilder(column: $table.newValue, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );
}

class $$LocalAuditEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalAuditEventsTable,
          LocalAuditEvent,
          $$LocalAuditEventsTableFilterComposer,
          $$LocalAuditEventsTableOrderingComposer,
          $$LocalAuditEventsTableAnnotationComposer,
          $$LocalAuditEventsTableCreateCompanionBuilder,
          $$LocalAuditEventsTableUpdateCompanionBuilder,
          (
            LocalAuditEvent,
            BaseReferences<
              _$AppDatabase,
              $LocalAuditEventsTable,
              LocalAuditEvent
            >,
          ),
          LocalAuditEvent,
          PrefetchHooks Function()
        > {
  $$LocalAuditEventsTableTableManager(
    _$AppDatabase db,
    $LocalAuditEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalAuditEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalAuditEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalAuditEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> actorId = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String> objectType = const Value.absent(),
                Value<String> objectId = const Value.absent(),
                Value<String?> oldValue = const Value.absent(),
                Value<String?> newValue = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
              }) => LocalAuditEventsCompanion(
                id: id,
                actorId: actorId,
                action: action,
                objectType: objectType,
                objectId: objectId,
                oldValue: oldValue,
                newValue: newValue,
                reason: reason,
                occurredAt: occurredAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String actorId,
                required String action,
                required String objectType,
                required String objectId,
                Value<String?> oldValue = const Value.absent(),
                Value<String?> newValue = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                required DateTime occurredAt,
              }) => LocalAuditEventsCompanion.insert(
                id: id,
                actorId: actorId,
                action: action,
                objectType: objectType,
                objectId: objectId,
                oldValue: oldValue,
                newValue: newValue,
                reason: reason,
                occurredAt: occurredAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalAuditEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalAuditEventsTable,
      LocalAuditEvent,
      $$LocalAuditEventsTableFilterComposer,
      $$LocalAuditEventsTableOrderingComposer,
      $$LocalAuditEventsTableAnnotationComposer,
      $$LocalAuditEventsTableCreateCompanionBuilder,
      $$LocalAuditEventsTableUpdateCompanionBuilder,
      (
        LocalAuditEvent,
        BaseReferences<_$AppDatabase, $LocalAuditEventsTable, LocalAuditEvent>,
      ),
      LocalAuditEvent,
      PrefetchHooks Function()
    >;
typedef $$LocalAlertsTableCreateCompanionBuilder =
    LocalAlertsCompanion Function({
      required String id,
      required String title,
      required String message,
      required String severity,
      required String zoneId,
      required String zoneLabel,
      required String geometryJson,
      required String issuedBy,
      required DateTime issuedAt,
      required DateTime validUntil,
      Value<DateTime?> cancelledAt,
      Value<int> version,
      Value<int> rowid,
    });
typedef $$LocalAlertsTableUpdateCompanionBuilder =
    LocalAlertsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> message,
      Value<String> severity,
      Value<String> zoneId,
      Value<String> zoneLabel,
      Value<String> geometryJson,
      Value<String> issuedBy,
      Value<DateTime> issuedAt,
      Value<DateTime> validUntil,
      Value<DateTime?> cancelledAt,
      Value<int> version,
      Value<int> rowid,
    });

class $$LocalAlertsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalAlertsTable> {
  $$LocalAlertsTableFilterComposer({
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

  ColumnFilters<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get zoneId => $composableBuilder(
    column: $table.zoneId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get zoneLabel => $composableBuilder(
    column: $table.zoneLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get geometryJson => $composableBuilder(
    column: $table.geometryJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get issuedBy => $composableBuilder(
    column: $table.issuedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get issuedAt => $composableBuilder(
    column: $table.issuedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get validUntil => $composableBuilder(
    column: $table.validUntil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cancelledAt => $composableBuilder(
    column: $table.cancelledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalAlertsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalAlertsTable> {
  $$LocalAlertsTableOrderingComposer({
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

  ColumnOrderings<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get zoneId => $composableBuilder(
    column: $table.zoneId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get zoneLabel => $composableBuilder(
    column: $table.zoneLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get geometryJson => $composableBuilder(
    column: $table.geometryJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get issuedBy => $composableBuilder(
    column: $table.issuedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get issuedAt => $composableBuilder(
    column: $table.issuedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get validUntil => $composableBuilder(
    column: $table.validUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cancelledAt => $composableBuilder(
    column: $table.cancelledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalAlertsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalAlertsTable> {
  $$LocalAlertsTableAnnotationComposer({
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

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<String> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => column);

  GeneratedColumn<String> get zoneId =>
      $composableBuilder(column: $table.zoneId, builder: (column) => column);

  GeneratedColumn<String> get zoneLabel =>
      $composableBuilder(column: $table.zoneLabel, builder: (column) => column);

  GeneratedColumn<String> get geometryJson => $composableBuilder(
    column: $table.geometryJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get issuedBy =>
      $composableBuilder(column: $table.issuedBy, builder: (column) => column);

  GeneratedColumn<DateTime> get issuedAt =>
      $composableBuilder(column: $table.issuedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get validUntil => $composableBuilder(
    column: $table.validUntil,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get cancelledAt => $composableBuilder(
    column: $table.cancelledAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);
}

class $$LocalAlertsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalAlertsTable,
          LocalAlert,
          $$LocalAlertsTableFilterComposer,
          $$LocalAlertsTableOrderingComposer,
          $$LocalAlertsTableAnnotationComposer,
          $$LocalAlertsTableCreateCompanionBuilder,
          $$LocalAlertsTableUpdateCompanionBuilder,
          (
            LocalAlert,
            BaseReferences<_$AppDatabase, $LocalAlertsTable, LocalAlert>,
          ),
          LocalAlert,
          PrefetchHooks Function()
        > {
  $$LocalAlertsTableTableManager(_$AppDatabase db, $LocalAlertsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalAlertsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalAlertsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalAlertsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> message = const Value.absent(),
                Value<String> severity = const Value.absent(),
                Value<String> zoneId = const Value.absent(),
                Value<String> zoneLabel = const Value.absent(),
                Value<String> geometryJson = const Value.absent(),
                Value<String> issuedBy = const Value.absent(),
                Value<DateTime> issuedAt = const Value.absent(),
                Value<DateTime> validUntil = const Value.absent(),
                Value<DateTime?> cancelledAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAlertsCompanion(
                id: id,
                title: title,
                message: message,
                severity: severity,
                zoneId: zoneId,
                zoneLabel: zoneLabel,
                geometryJson: geometryJson,
                issuedBy: issuedBy,
                issuedAt: issuedAt,
                validUntil: validUntil,
                cancelledAt: cancelledAt,
                version: version,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String message,
                required String severity,
                required String zoneId,
                required String zoneLabel,
                required String geometryJson,
                required String issuedBy,
                required DateTime issuedAt,
                required DateTime validUntil,
                Value<DateTime?> cancelledAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAlertsCompanion.insert(
                id: id,
                title: title,
                message: message,
                severity: severity,
                zoneId: zoneId,
                zoneLabel: zoneLabel,
                geometryJson: geometryJson,
                issuedBy: issuedBy,
                issuedAt: issuedAt,
                validUntil: validUntil,
                cancelledAt: cancelledAt,
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

typedef $$LocalAlertsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalAlertsTable,
      LocalAlert,
      $$LocalAlertsTableFilterComposer,
      $$LocalAlertsTableOrderingComposer,
      $$LocalAlertsTableAnnotationComposer,
      $$LocalAlertsTableCreateCompanionBuilder,
      $$LocalAlertsTableUpdateCompanionBuilder,
      (
        LocalAlert,
        BaseReferences<_$AppDatabase, $LocalAlertsTable, LocalAlert>,
      ),
      LocalAlert,
      PrefetchHooks Function()
    >;
typedef $$LocalAlertAcknowledgementsTableCreateCompanionBuilder =
    LocalAlertAcknowledgementsCompanion Function({
      required String id,
      required String alertId,
      required String userId,
      required DateTime acknowledgedAt,
      Value<int> rowid,
    });
typedef $$LocalAlertAcknowledgementsTableUpdateCompanionBuilder =
    LocalAlertAcknowledgementsCompanion Function({
      Value<String> id,
      Value<String> alertId,
      Value<String> userId,
      Value<DateTime> acknowledgedAt,
      Value<int> rowid,
    });

class $$LocalAlertAcknowledgementsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalAlertAcknowledgementsTable> {
  $$LocalAlertAcknowledgementsTableFilterComposer({
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

  ColumnFilters<String> get alertId => $composableBuilder(
    column: $table.alertId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get acknowledgedAt => $composableBuilder(
    column: $table.acknowledgedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalAlertAcknowledgementsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalAlertAcknowledgementsTable> {
  $$LocalAlertAcknowledgementsTableOrderingComposer({
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

  ColumnOrderings<String> get alertId => $composableBuilder(
    column: $table.alertId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get acknowledgedAt => $composableBuilder(
    column: $table.acknowledgedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalAlertAcknowledgementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalAlertAcknowledgementsTable> {
  $$LocalAlertAcknowledgementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get alertId =>
      $composableBuilder(column: $table.alertId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get acknowledgedAt => $composableBuilder(
    column: $table.acknowledgedAt,
    builder: (column) => column,
  );
}

class $$LocalAlertAcknowledgementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalAlertAcknowledgementsTable,
          LocalAlertAcknowledgement,
          $$LocalAlertAcknowledgementsTableFilterComposer,
          $$LocalAlertAcknowledgementsTableOrderingComposer,
          $$LocalAlertAcknowledgementsTableAnnotationComposer,
          $$LocalAlertAcknowledgementsTableCreateCompanionBuilder,
          $$LocalAlertAcknowledgementsTableUpdateCompanionBuilder,
          (
            LocalAlertAcknowledgement,
            BaseReferences<
              _$AppDatabase,
              $LocalAlertAcknowledgementsTable,
              LocalAlertAcknowledgement
            >,
          ),
          LocalAlertAcknowledgement,
          PrefetchHooks Function()
        > {
  $$LocalAlertAcknowledgementsTableTableManager(
    _$AppDatabase db,
    $LocalAlertAcknowledgementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalAlertAcknowledgementsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LocalAlertAcknowledgementsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalAlertAcknowledgementsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> alertId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<DateTime> acknowledgedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAlertAcknowledgementsCompanion(
                id: id,
                alertId: alertId,
                userId: userId,
                acknowledgedAt: acknowledgedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String alertId,
                required String userId,
                required DateTime acknowledgedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalAlertAcknowledgementsCompanion.insert(
                id: id,
                alertId: alertId,
                userId: userId,
                acknowledgedAt: acknowledgedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalAlertAcknowledgementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalAlertAcknowledgementsTable,
      LocalAlertAcknowledgement,
      $$LocalAlertAcknowledgementsTableFilterComposer,
      $$LocalAlertAcknowledgementsTableOrderingComposer,
      $$LocalAlertAcknowledgementsTableAnnotationComposer,
      $$LocalAlertAcknowledgementsTableCreateCompanionBuilder,
      $$LocalAlertAcknowledgementsTableUpdateCompanionBuilder,
      (
        LocalAlertAcknowledgement,
        BaseReferences<
          _$AppDatabase,
          $LocalAlertAcknowledgementsTable,
          LocalAlertAcknowledgement
        >,
      ),
      LocalAlertAcknowledgement,
      PrefetchHooks Function()
    >;
typedef $$LocalEnvironmentalObservationsTableCreateCompanionBuilder =
    LocalEnvironmentalObservationsCompanion Function({
      required String id,
      required String habitationId,
      required String parameter,
      required double value,
      required String source,
      required DateTime observedAt,
      required DateTime fetchedAt,
      Value<double> confidence,
      Value<int> version,
      Value<int> rowid,
    });
typedef $$LocalEnvironmentalObservationsTableUpdateCompanionBuilder =
    LocalEnvironmentalObservationsCompanion Function({
      Value<String> id,
      Value<String> habitationId,
      Value<String> parameter,
      Value<double> value,
      Value<String> source,
      Value<DateTime> observedAt,
      Value<DateTime> fetchedAt,
      Value<double> confidence,
      Value<int> version,
      Value<int> rowid,
    });

class $$LocalEnvironmentalObservationsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalEnvironmentalObservationsTable> {
  $$LocalEnvironmentalObservationsTableFilterComposer({
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

  ColumnFilters<String> get habitationId => $composableBuilder(
    column: $table.habitationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parameter => $composableBuilder(
    column: $table.parameter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get value => $composableBuilder(
    column: $table.value,
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

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalEnvironmentalObservationsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalEnvironmentalObservationsTable> {
  $$LocalEnvironmentalObservationsTableOrderingComposer({
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

  ColumnOrderings<String> get habitationId => $composableBuilder(
    column: $table.habitationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parameter => $composableBuilder(
    column: $table.parameter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get value => $composableBuilder(
    column: $table.value,
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

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalEnvironmentalObservationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalEnvironmentalObservationsTable> {
  $$LocalEnvironmentalObservationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get habitationId => $composableBuilder(
    column: $table.habitationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get parameter =>
      $composableBuilder(column: $table.parameter, builder: (column) => column);

  GeneratedColumn<double> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get observedAt => $composableBuilder(
    column: $table.observedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);
}

class $$LocalEnvironmentalObservationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalEnvironmentalObservationsTable,
          LocalEnvironmentalObservation,
          $$LocalEnvironmentalObservationsTableFilterComposer,
          $$LocalEnvironmentalObservationsTableOrderingComposer,
          $$LocalEnvironmentalObservationsTableAnnotationComposer,
          $$LocalEnvironmentalObservationsTableCreateCompanionBuilder,
          $$LocalEnvironmentalObservationsTableUpdateCompanionBuilder,
          (
            LocalEnvironmentalObservation,
            BaseReferences<
              _$AppDatabase,
              $LocalEnvironmentalObservationsTable,
              LocalEnvironmentalObservation
            >,
          ),
          LocalEnvironmentalObservation,
          PrefetchHooks Function()
        > {
  $$LocalEnvironmentalObservationsTableTableManager(
    _$AppDatabase db,
    $LocalEnvironmentalObservationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalEnvironmentalObservationsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LocalEnvironmentalObservationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalEnvironmentalObservationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> habitationId = const Value.absent(),
                Value<String> parameter = const Value.absent(),
                Value<double> value = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<DateTime> observedAt = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<double> confidence = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalEnvironmentalObservationsCompanion(
                id: id,
                habitationId: habitationId,
                parameter: parameter,
                value: value,
                source: source,
                observedAt: observedAt,
                fetchedAt: fetchedAt,
                confidence: confidence,
                version: version,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String habitationId,
                required String parameter,
                required double value,
                required String source,
                required DateTime observedAt,
                required DateTime fetchedAt,
                Value<double> confidence = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalEnvironmentalObservationsCompanion.insert(
                id: id,
                habitationId: habitationId,
                parameter: parameter,
                value: value,
                source: source,
                observedAt: observedAt,
                fetchedAt: fetchedAt,
                confidence: confidence,
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

typedef $$LocalEnvironmentalObservationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalEnvironmentalObservationsTable,
      LocalEnvironmentalObservation,
      $$LocalEnvironmentalObservationsTableFilterComposer,
      $$LocalEnvironmentalObservationsTableOrderingComposer,
      $$LocalEnvironmentalObservationsTableAnnotationComposer,
      $$LocalEnvironmentalObservationsTableCreateCompanionBuilder,
      $$LocalEnvironmentalObservationsTableUpdateCompanionBuilder,
      (
        LocalEnvironmentalObservation,
        BaseReferences<
          _$AppDatabase,
          $LocalEnvironmentalObservationsTable,
          LocalEnvironmentalObservation
        >,
      ),
      LocalEnvironmentalObservation,
      PrefetchHooks Function()
    >;
typedef $$LocalDamageReportsTableCreateCompanionBuilder =
    LocalDamageReportsCompanion Function({
      required String id,
      required String incidentId,
      required String responderId,
      Value<String> description,
      Value<String> severity,
      Value<String?> mediaPath,
      required DateTime submittedAt,
      Value<int> version,
      Value<int> rowid,
    });
typedef $$LocalDamageReportsTableUpdateCompanionBuilder =
    LocalDamageReportsCompanion Function({
      Value<String> id,
      Value<String> incidentId,
      Value<String> responderId,
      Value<String> description,
      Value<String> severity,
      Value<String?> mediaPath,
      Value<DateTime> submittedAt,
      Value<int> version,
      Value<int> rowid,
    });

class $$LocalDamageReportsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalDamageReportsTable> {
  $$LocalDamageReportsTableFilterComposer({
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

  ColumnFilters<String> get responderId => $composableBuilder(
    column: $table.responderId,
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

  ColumnFilters<String> get mediaPath => $composableBuilder(
    column: $table.mediaPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get submittedAt => $composableBuilder(
    column: $table.submittedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalDamageReportsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalDamageReportsTable> {
  $$LocalDamageReportsTableOrderingComposer({
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

  ColumnOrderings<String> get responderId => $composableBuilder(
    column: $table.responderId,
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

  ColumnOrderings<String> get mediaPath => $composableBuilder(
    column: $table.mediaPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get submittedAt => $composableBuilder(
    column: $table.submittedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalDamageReportsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalDamageReportsTable> {
  $$LocalDamageReportsTableAnnotationComposer({
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

  GeneratedColumn<String> get responderId => $composableBuilder(
    column: $table.responderId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => column);

  GeneratedColumn<String> get mediaPath =>
      $composableBuilder(column: $table.mediaPath, builder: (column) => column);

  GeneratedColumn<DateTime> get submittedAt => $composableBuilder(
    column: $table.submittedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);
}

class $$LocalDamageReportsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalDamageReportsTable,
          LocalDamageReport,
          $$LocalDamageReportsTableFilterComposer,
          $$LocalDamageReportsTableOrderingComposer,
          $$LocalDamageReportsTableAnnotationComposer,
          $$LocalDamageReportsTableCreateCompanionBuilder,
          $$LocalDamageReportsTableUpdateCompanionBuilder,
          (
            LocalDamageReport,
            BaseReferences<
              _$AppDatabase,
              $LocalDamageReportsTable,
              LocalDamageReport
            >,
          ),
          LocalDamageReport,
          PrefetchHooks Function()
        > {
  $$LocalDamageReportsTableTableManager(
    _$AppDatabase db,
    $LocalDamageReportsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalDamageReportsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalDamageReportsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalDamageReportsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> incidentId = const Value.absent(),
                Value<String> responderId = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> severity = const Value.absent(),
                Value<String?> mediaPath = const Value.absent(),
                Value<DateTime> submittedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalDamageReportsCompanion(
                id: id,
                incidentId: incidentId,
                responderId: responderId,
                description: description,
                severity: severity,
                mediaPath: mediaPath,
                submittedAt: submittedAt,
                version: version,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String incidentId,
                required String responderId,
                Value<String> description = const Value.absent(),
                Value<String> severity = const Value.absent(),
                Value<String?> mediaPath = const Value.absent(),
                required DateTime submittedAt,
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalDamageReportsCompanion.insert(
                id: id,
                incidentId: incidentId,
                responderId: responderId,
                description: description,
                severity: severity,
                mediaPath: mediaPath,
                submittedAt: submittedAt,
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

typedef $$LocalDamageReportsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalDamageReportsTable,
      LocalDamageReport,
      $$LocalDamageReportsTableFilterComposer,
      $$LocalDamageReportsTableOrderingComposer,
      $$LocalDamageReportsTableAnnotationComposer,
      $$LocalDamageReportsTableCreateCompanionBuilder,
      $$LocalDamageReportsTableUpdateCompanionBuilder,
      (
        LocalDamageReport,
        BaseReferences<
          _$AppDatabase,
          $LocalDamageReportsTable,
          LocalDamageReport
        >,
      ),
      LocalDamageReport,
      PrefetchHooks Function()
    >;
typedef $$LocalResourcesTableCreateCompanionBuilder =
    LocalResourcesCompanion Function({
      required String id,
      required String name,
      required String type,
      Value<int> quantity,
      Value<String?> shelterId,
      required DateTime updatedAt,
      Value<int> version,
      Value<int> rowid,
    });
typedef $$LocalResourcesTableUpdateCompanionBuilder =
    LocalResourcesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> type,
      Value<int> quantity,
      Value<String?> shelterId,
      Value<DateTime> updatedAt,
      Value<int> version,
      Value<int> rowid,
    });

class $$LocalResourcesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalResourcesTable> {
  $$LocalResourcesTableFilterComposer({
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

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shelterId => $composableBuilder(
    column: $table.shelterId,
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

class $$LocalResourcesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalResourcesTable> {
  $$LocalResourcesTableOrderingComposer({
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

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shelterId => $composableBuilder(
    column: $table.shelterId,
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

class $$LocalResourcesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalResourcesTable> {
  $$LocalResourcesTableAnnotationComposer({
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

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get shelterId =>
      $composableBuilder(column: $table.shelterId, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);
}

class $$LocalResourcesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalResourcesTable,
          LocalResource,
          $$LocalResourcesTableFilterComposer,
          $$LocalResourcesTableOrderingComposer,
          $$LocalResourcesTableAnnotationComposer,
          $$LocalResourcesTableCreateCompanionBuilder,
          $$LocalResourcesTableUpdateCompanionBuilder,
          (
            LocalResource,
            BaseReferences<_$AppDatabase, $LocalResourcesTable, LocalResource>,
          ),
          LocalResource,
          PrefetchHooks Function()
        > {
  $$LocalResourcesTableTableManager(
    _$AppDatabase db,
    $LocalResourcesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalResourcesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalResourcesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalResourcesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<String?> shelterId = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalResourcesCompanion(
                id: id,
                name: name,
                type: type,
                quantity: quantity,
                shelterId: shelterId,
                updatedAt: updatedAt,
                version: version,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String type,
                Value<int> quantity = const Value.absent(),
                Value<String?> shelterId = const Value.absent(),
                required DateTime updatedAt,
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalResourcesCompanion.insert(
                id: id,
                name: name,
                type: type,
                quantity: quantity,
                shelterId: shelterId,
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

typedef $$LocalResourcesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalResourcesTable,
      LocalResource,
      $$LocalResourcesTableFilterComposer,
      $$LocalResourcesTableOrderingComposer,
      $$LocalResourcesTableAnnotationComposer,
      $$LocalResourcesTableCreateCompanionBuilder,
      $$LocalResourcesTableUpdateCompanionBuilder,
      (
        LocalResource,
        BaseReferences<_$AppDatabase, $LocalResourcesTable, LocalResource>,
      ),
      LocalResource,
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
  $$LocalHazardAutomationStatesTableTableManager
  get localHazardAutomationStates =>
      $$LocalHazardAutomationStatesTableTableManager(
        _db,
        _db.localHazardAutomationStates,
      );
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
  $$LocalAuditEventsTableTableManager get localAuditEvents =>
      $$LocalAuditEventsTableTableManager(_db, _db.localAuditEvents);
  $$LocalAlertsTableTableManager get localAlerts =>
      $$LocalAlertsTableTableManager(_db, _db.localAlerts);
  $$LocalAlertAcknowledgementsTableTableManager
  get localAlertAcknowledgements =>
      $$LocalAlertAcknowledgementsTableTableManager(
        _db,
        _db.localAlertAcknowledgements,
      );
  $$LocalEnvironmentalObservationsTableTableManager
  get localEnvironmentalObservations =>
      $$LocalEnvironmentalObservationsTableTableManager(
        _db,
        _db.localEnvironmentalObservations,
      );
  $$LocalDamageReportsTableTableManager get localDamageReports =>
      $$LocalDamageReportsTableTableManager(_db, _db.localDamageReports);
  $$LocalResourcesTableTableManager get localResources =>
      $$LocalResourcesTableTableManager(_db, _db.localResources);
  $$SyncQueueEntriesTableTableManager get syncQueueEntries =>
      $$SyncQueueEntriesTableTableManager(_db, _db.syncQueueEntries);
}
