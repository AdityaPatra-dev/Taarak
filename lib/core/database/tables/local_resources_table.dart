import 'package:drift/drift.dart';

/// District/Command's tracked response resources (vehicles, medical
/// supplies, personnel counts, ...) — deliberately a flat, generic
/// name/type/quantity shape rather than a type-specific schema per
/// resource kind, since the blueprint doesn't call for anything richer
/// than "what do we have, how much, where is it".
class LocalResources extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  IntColumn get quantity => integer().withDefault(const Constant(0))();

  /// Optional — a resource doesn't have to be tied to a specific shelter
  /// to be tracked (e.g. a district-wide vehicle pool).
  TextColumn get shelterId => text().nullable()();

  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get version => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}
