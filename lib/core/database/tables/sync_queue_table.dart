import 'package:drift/drift.dart';

/// Store-and-forward outbox for offline-created/edited data (blueprint
/// M17). Each row is one pending change against one of the entity tables;
/// `attemptCount`/`lastAttemptAt` exist so the future sync engine can back
/// off on repeated failures instead of retrying in a tight loop.
class SyncQueueEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityTable => text()();
  TextColumn get entityId => text()();
  // 'create' | 'update' | 'delete'
  TextColumn get operation => text()();
  TextColumn get payloadJson => text()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();
  // 'pending' | 'inFlight' | 'failed' | 'synced'
  TextColumn get status => text().withDefault(const Constant('pending'))();
}
