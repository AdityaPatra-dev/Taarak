import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/network/api_client.dart';
import 'package:taarak/core/repository/result.dart';
import 'package:taarak/features/sync/domain/remote_sync_record.dart';
import 'package:taarak/features/sync/domain/sync_push_outcome.dart';

/// The calls [SyncCoordinatorService] needs to exchange data with
/// somewhere — abstracted so the sync engine's queueing/retry/dedup/
/// conflict/priority logic is testable without a real backend.
abstract class SyncTransport {
  Future<Result<SyncPushOutcome>> push(SyncQueueEntry entry);

  /// Every record another device has pushed for [table] — the mechanism
  /// that lets a second device (a different login, or a different role)
  /// actually see data the first one created. Without this, push alone
  /// only ever sends data one way into the backend; nothing ever comes
  /// back out to a second client.
  Future<Result<List<RemoteSyncRecord>>> pullAll(String table);
}

/// Talks to a generic `/sync/<entityTable>` endpoint. Exercised in
/// production once a real backend exists; until then this genuinely fails
/// with a [NetworkFailure]/[ServerFailure] against the placeholder
/// `apiBaseUrl`, same as every other [ApiClient] caller in this codebase.
class ApiSyncTransport implements SyncTransport {
  final ApiClient _apiClient;

  ApiSyncTransport(this._apiClient);

  @override
  Future<Result<SyncPushOutcome>> push(SyncQueueEntry entry) {
    return _apiClient.post<SyncPushOutcome>(
      '/sync/${entry.entityTable}',
      data: {
        'entityId': entry.entityId,
        'operation': entry.operation,
        'payload': entry.payloadJson,
      },
      parser: (json) {
        final map = json as Map<String, dynamic>;
        if (map['conflict'] == true) {
          return SyncPushOutcome.conflict(
            (map['serverVersion'] as num?)?.toInt(),
          );
        }
        return const SyncPushOutcome.accepted();
      },
    );
  }

  @override
  Future<Result<List<RemoteSyncRecord>>> pullAll(String table) {
    return _apiClient.get<List<RemoteSyncRecord>>(
      '/sync/$table',
      parser: (json) {
        final list = json as List<dynamic>;
        return [
          for (final entry in list)
            RemoteSyncRecord(
              entityId: entry['entityId'] as String,
              payloadJson: entry['payload'] as String,
              version: (entry['version'] as num).toInt(),
            ),
        ];
      },
    );
  }
}
