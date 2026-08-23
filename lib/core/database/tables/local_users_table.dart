import 'package:drift/drift.dart';

/// Cached profiles of other users (e.g. a responder's name shown on an
/// assigned incident) for offline lookup. Distinct from the signed-in
/// device's own session, which lives in encrypted storage
/// (see [[AuthLocalDataSource]]) rather than this general-purpose cache.
class LocalUsers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get email => text()();
  TextColumn get role => text()();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get version => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}
