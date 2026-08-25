import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/error/failure.dart';
import 'package:taarak/core/repository/result.dart';
import 'package:taarak/features/sync/application/sync_transport.dart';
import 'package:taarak/features/sync/domain/remote_sync_record.dart';
import 'package:taarak/features/sync/domain/sync_push_outcome.dart';

/// Real, hosted sync transport — replaces [[ApiSyncTransport]]'s call to
/// the never-deployed backend/ stub. One Firestore collection per
/// `entityTable`, one document per `entityId`, same version-based conflict
/// contract [[SyncEngine.resolveConflict]] already expects: a push whose
/// version isn't strictly newer than what's stored comes back as a
/// conflict instead of silently overwriting.
class FirestoreSyncTransport implements SyncTransport {
  final FirebaseFirestore _firestore;

  FirestoreSyncTransport({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Result<SyncPushOutcome>> push(SyncQueueEntry entry) async {
    try {
      final docRef = _firestore
          .collection(entry.entityTable)
          .doc(entry.entityId);
      final incomingVersion = _versionOf(entry.payloadJson);

      final outcome = await _firestore.runTransaction<SyncPushOutcome>((
        transaction,
      ) async {
        final snapshot = await transaction.get(docRef);
        if (snapshot.exists) {
          final existingVersion =
              (snapshot.data()?['version'] as num?)?.toInt() ?? 1;
          if (incomingVersion <= existingVersion) {
            return SyncPushOutcome.conflict(existingVersion);
          }
        }
        transaction.set(docRef, {
          'payload': entry.payloadJson,
          'version': incomingVersion,
        });
        return const SyncPushOutcome.accepted();
      });
      return Result.success(outcome);
    } catch (_) {
      return const Result.failure(NetworkFailure());
    }
  }

  @override
  Future<Result<List<RemoteSyncRecord>>> pullAll(String table) async {
    try {
      final snapshot = await _firestore.collection(table).get();
      return Result.success([
        for (final doc in snapshot.docs)
          RemoteSyncRecord(
            entityId: doc.id,
            payloadJson: doc.data()['payload'] as String,
            version: (doc.data()['version'] as num).toInt(),
          ),
      ]);
    } catch (_) {
      return const Result.failure(NetworkFailure());
    }
  }

  int _versionOf(String payloadJson) {
    try {
      final decoded = jsonDecode(payloadJson);
      if (decoded is Map && decoded['version'] is int) {
        return decoded['version'] as int;
      }
    } on FormatException {
      // Not JSON, or no version field — treated as version 1 below.
    }
    return 1;
  }
}
