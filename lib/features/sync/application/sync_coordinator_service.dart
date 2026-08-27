import 'dart:convert';

import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/database/repositories/local_alert_repository.dart';
import 'package:taarak/core/database/repositories/local_damage_report_repository.dart';
import 'package:taarak/core/database/repositories/local_habitation_repository.dart';
import 'package:taarak/core/database/repositories/local_hazard_zone_repository.dart';
import 'package:taarak/core/database/repositories/local_incident_report_repository.dart';
import 'package:taarak/core/database/repositories/local_incident_repository.dart';
import 'package:taarak/core/database/repositories/local_resource_repository.dart';
import 'package:taarak/core/database/repositories/local_shelter_repository.dart';
import 'package:taarak/core/database/sync_queue_dao.dart';
import 'package:taarak/core/network/network_info.dart';
import 'package:taarak/core/repository/result.dart';
import 'package:taarak/features/sync/application/sync_engine.dart';
import 'package:taarak/features/sync/application/sync_transport.dart';
import 'package:taarak/features/sync/domain/remote_sync_record.dart';
import 'package:taarak/features/sync/domain/sync_conflict_resolution.dart';
import 'package:taarak/features/sync/domain/sync_push_outcome.dart';
import 'package:taarak/features/sync/domain/sync_run_summary.dart';

/// Orchestrates M17: drains the M03 sync outbox — every offline-created
/// citizen action, regardless of which feature enqueued it — through
/// [SyncEngine]'s dedup/priority/backoff/conflict rules and a
/// [SyncTransport]. The acceptance criterion is this class's whole job:
/// offline data must synchronize safely once connectivity is back, "safely"
/// meaning no duplicate pushes, no silent data loss on conflict, and no
/// hammering a backend that just rejected a request.
class SyncCoordinatorService {
  final SyncQueueDao _syncQueueDao;
  final NetworkInfo _networkInfo;
  final SyncTransport _transport;
  final SyncEngine _engine;
  final LocalIncidentReportRepository? _incidentReportRepository;
  final LocalIncidentRepository? _incidentRepository;
  final LocalHazardZoneRepository? _hazardZoneRepository;
  final LocalShelterRepository? _shelterRepository;
  final LocalAlertRepository? _alertRepository;
  final LocalDamageReportRepository? _damageReportRepository;
  final LocalResourceRepository? _resourceRepository;
  final LocalHabitationRepository? _habitationRepository;

  SyncCoordinatorService({
    required SyncQueueDao syncQueueDao,
    required NetworkInfo networkInfo,
    required SyncTransport transport,
    SyncEngine? engine,
    LocalIncidentReportRepository? incidentReportRepository,
    LocalIncidentRepository? incidentRepository,
    LocalHazardZoneRepository? hazardZoneRepository,
    LocalShelterRepository? shelterRepository,
    LocalAlertRepository? alertRepository,
    LocalDamageReportRepository? damageReportRepository,
    LocalResourceRepository? resourceRepository,
    LocalHabitationRepository? habitationRepository,
  }) : _syncQueueDao = syncQueueDao,
       _networkInfo = networkInfo,
       _transport = transport,
       _engine = engine ?? SyncEngine(),
       _incidentReportRepository = incidentReportRepository,
       _incidentRepository = incidentRepository,
       _hazardZoneRepository = hazardZoneRepository,
       _shelterRepository = shelterRepository,
       _alertRepository = alertRepository,
       _damageReportRepository = damageReportRepository,
       _resourceRepository = resourceRepository,
       _habitationRepository = habitationRepository;

  Future<SyncRunSummary> syncPendingEntries({DateTime? now}) async {
    if (!await _networkInfo.isConnected) {
      return const SyncRunSummary(skippedOffline: true);
    }

    final occurredAt = now ?? DateTime.now();

    final pendingResult = await _syncQueueDao.listSyncable();
    final pending = pendingResult.dataOrNull ?? const [];
    if (pending.isEmpty) {
      // Nothing of ours to push, but an official/command device that
      // never creates its own citizen reports should still pull in
      // whatever other devices have pushed — an empty outbox isn't a
      // reason to skip that half of sync.
      final pulled = await _pullAll();
      return SyncRunSummary(pulledCount: pulled);
    }

    final deduped = _engine.dedupe(pending);
    for (final stale in deduped.superseded) {
      await _syncQueueDao.markSynced(stale.id);
    }

    final ordered = _engine.prioritize(deduped.toPush);

    var synced = 0;
    var conflicts = 0;
    var failed = 0;
    var abandoned = 0;

    for (final entry in ordered) {
      if (_engine.shouldGiveUp(entry)) {
        abandoned++;
        continue;
      }
      if (!_engine.isReadyToRetry(entry, occurredAt)) {
        continue;
      }

      final pushResult = await _transport.push(entry);
      switch (pushResult) {
        case Success<SyncPushOutcome>(:final data):
          if (data.status == SyncPushStatus.accepted) {
            await _syncQueueDao.markSynced(entry.id);
            synced++;
          } else {
            conflicts++;
            final resolution = _engine.resolveConflict(
              localVersion: _engine.localVersionOf(entry),
              serverVersion:
                  data.serverVersion ?? _engine.localVersionOf(entry),
            );
            if (resolution == SyncConflictResolution.serverWins) {
              // The server already has an equal-or-newer version — this
              // push is redundant, not an error, so it's done, not failed.
              await _syncQueueDao.markSynced(entry.id);
            } else {
              await _syncQueueDao.markFailed(entry.id, now: occurredAt);
            }
          }
        case Failed<SyncPushOutcome>():
          failed++;
          await _syncQueueDao.markFailed(entry.id, now: occurredAt);
      }
    }

    final pulled = await _pullAll();

    return SyncRunSummary(
      syncedCount: synced,
      conflictCount: conflicts,
      failedCount: failed,
      abandonedCount: abandoned,
      pulledCount: pulled,
    );
  }

  /// The other half of "sync": brings in every shared-state table other
  /// devices have pushed to, so a citizen's report — or an official's
  /// incident update, hazard zone, shelter, or alert — is actually visible
  /// on a second device, not just accepted into a backend no one ever
  /// reads from. Each table is only pulled when its repository was wired
  /// in — tests that only care about a subset (or the push path only) can
  /// omit the rest and those pulls are simply no-ops.
  Future<int> _pullAll() async {
    // A table's still-pending/failed sync entries at this point are local
    // creations that haven't reached Firestore yet — excluded from each
    // pull's delete-diff below so a System Admin's removal elsewhere
    // never gets confused with "not synced yet" and wipes a fresh local
    // creation before it's had a chance to actually push.
    final stillPendingResult = await _syncQueueDao.listSyncable();
    final pendingIdsByTable = <String, Set<String>>{};
    for (final entry in stillPendingResult.dataOrNull ?? const []) {
      pendingIdsByTable
          .putIfAbsent(entry.entityTable, () => <String>{})
          .add(entry.entityId);
    }

    var applied = 0;
    applied += await _pullIncidentReports();
    applied += await _pullIncidents(
      pendingIdsByTable['local_incidents'] ?? const {},
    );
    applied += await _pullHazardZones(
      pendingIdsByTable['local_hazard_zones'] ?? const {},
    );
    applied += await _pullShelters();
    applied += await _pullAlerts(pendingIdsByTable['local_alerts'] ?? const {});
    applied += await _pullDamageReports();
    applied += await _pullResources();
    applied += await _pullHabitations();
    return applied;
  }

  /// A System Admin's content-moderation delete is only visible to this
  /// device as "this id is no longer in the remote set" — there's no
  /// per-record delete event to react to, since [SyncTransport.pullAll]
  /// just returns whatever currently exists. So after applying every
  /// create/update above, anything cached locally that's missing from the
  /// current remote set (and isn't itself a not-yet-pushed local creation)
  /// was deleted elsewhere, and gets deleted here too.
  Future<int> _deleteLocallyMissing<T>({
    required Future<Result<List<T>>> Function() getAllLocal,
    required Future<Result<void>> Function(String id) deleteLocal,
    required String Function(T) idOf,
    required Set<String> remoteIds,
    required Set<String> pendingIds,
  }) async {
    final localResult = await getAllLocal();
    var deleted = 0;
    for (final item in localResult.dataOrNull ?? const []) {
      final id = idOf(item);
      if (remoteIds.contains(id) || pendingIds.contains(id)) continue;
      await deleteLocal(id);
      deleted++;
    }
    return deleted;
  }

  Future<int> _pullIncidentReports() async {
    final repository = _incidentReportRepository;
    if (repository == null) return 0;

    final pullResult = await _transport.pullAll('local_incident_reports');
    final remoteRecords = pullResult.dataOrNull ?? const <RemoteSyncRecord>[];

    var applied = 0;
    for (final record in remoteRecords) {
      final localResult = await repository.getById(record.entityId);
      final local = localResult.dataOrNull;
      if (local != null && local.version >= record.version) continue;

      final report = _reportFromPayload(record);
      if (report == null) continue;

      await repository.save(report);
      applied++;
    }
    return applied;
  }

  LocalIncidentReport? _reportFromPayload(RemoteSyncRecord record) {
    try {
      final payload = jsonDecode(record.payloadJson) as Map<String, dynamic>;
      return LocalIncidentReport(
        id: record.entityId,
        incidentId: null,
        reporterId: payload['reporterId'] as String?,
        latitude: (payload['latitude'] as num).toDouble(),
        longitude: (payload['longitude'] as num).toDouble(),
        reportType: payload['reportType'] as String,
        description: payload['description'] as String? ?? '',
        severity: payload['severity'] as String? ?? 'unknown',
        affectedPeopleCount: (payload['affectedPeopleCount'] as num?)?.toInt(),
        // A remote report's photo, if any, lives on the device that took
        // it — there's no media upload/download path in this backend
        // stub, so pulling a path that only resolves on another device
        // would be a broken reference here, not a real attachment.
        mediaPath: null,
        createdAt: DateTime.parse(payload['createdAt'] as String),
        updatedAt: DateTime.now(),
        version: record.version,
        isSynced: true,
      );
    } catch (_) {
      return null;
    }
  }

  Future<int> _pullIncidents(Set<String> pendingIds) async {
    final repository = _incidentRepository;
    if (repository == null) return 0;

    final pullResult = await _transport.pullAll('local_incidents');
    final remoteRecords = pullResult.dataOrNull ?? const <RemoteSyncRecord>[];

    var applied = 0;
    for (final record in remoteRecords) {
      final localResult = await repository.getById(record.entityId);
      final local = localResult.dataOrNull;
      if (local != null && local.version >= record.version) continue;

      final incident = _incidentFromPayload(record);
      if (incident == null) continue;

      await repository.save(incident);
      applied++;
    }
    applied += await _deleteLocallyMissing<LocalIncident>(
      getAllLocal: repository.getAll,
      deleteLocal: repository.delete,
      idOf: (incident) => incident.id,
      remoteIds: remoteRecords.map((r) => r.entityId).toSet(),
      pendingIds: pendingIds,
    );
    return applied;
  }

  LocalIncident? _incidentFromPayload(RemoteSyncRecord record) {
    try {
      final payload = jsonDecode(record.payloadJson) as Map<String, dynamic>;
      return LocalIncident(
        id: record.entityId,
        type: payload['type'] as String,
        status: payload['status'] as String,
        latitude: (payload['latitude'] as num).toDouble(),
        longitude: (payload['longitude'] as num).toDouble(),
        description: payload['description'] as String? ?? '',
        severity: payload['severity'] as String? ?? 'unknown',
        independentSourceCount:
            (payload['independentSourceCount'] as num?)?.toInt() ?? 1,
        confidence: (payload['confidence'] as num?)?.toDouble() ?? 0,
        createdAt: DateTime.parse(payload['createdAt'] as String),
        updatedAt: DateTime.now(),
        version: record.version,
        isSynced: true,
        assignedResponderId: payload['assignedResponderId'] as String?,
      );
    } catch (_) {
      return null;
    }
  }

  Future<int> _pullHazardZones(Set<String> pendingIds) async {
    final repository = _hazardZoneRepository;
    if (repository == null) return 0;

    final pullResult = await _transport.pullAll('local_hazard_zones');
    final remoteRecords = pullResult.dataOrNull ?? const <RemoteSyncRecord>[];

    var applied = 0;
    for (final record in remoteRecords) {
      final localResult = await repository.getById(record.entityId);
      final local = localResult.dataOrNull;
      if (local != null && local.version >= record.version) continue;

      final zone = _hazardZoneFromPayload(record);
      if (zone == null) continue;

      await repository.save(zone);
      applied++;
    }
    applied += await _deleteLocallyMissing<LocalHazardZone>(
      getAllLocal: repository.getAll,
      deleteLocal: repository.delete,
      idOf: (zone) => zone.id,
      remoteIds: remoteRecords.map((r) => r.entityId).toSet(),
      pendingIds: pendingIds,
    );
    return applied;
  }

  LocalHazardZone? _hazardZoneFromPayload(RemoteSyncRecord record) {
    try {
      final payload = jsonDecode(record.payloadJson) as Map<String, dynamic>;
      return LocalHazardZone(
        id: record.entityId,
        hazardType: payload['hazardType'] as String,
        severity: payload['severity'] as String,
        geometryJson: payload['geometryJson'] as String,
        source: payload['source'] as String,
        observedAt: DateTime.parse(payload['observedAt'] as String),
        confidence: (payload['confidence'] as num).toDouble(),
        updatedAt: DateTime.now(),
        version: record.version,
      );
    } catch (_) {
      return null;
    }
  }

  Future<int> _pullShelters() async {
    final repository = _shelterRepository;
    if (repository == null) return 0;

    final pullResult = await _transport.pullAll('local_shelters');
    final remoteRecords = pullResult.dataOrNull ?? const <RemoteSyncRecord>[];

    var applied = 0;
    for (final record in remoteRecords) {
      final localResult = await repository.getById(record.entityId);
      final local = localResult.dataOrNull;
      if (local != null && local.version >= record.version) continue;

      final shelter = _shelterFromPayload(record);
      if (shelter == null) continue;

      await repository.save(shelter);
      applied++;
    }
    return applied;
  }

  LocalShelter? _shelterFromPayload(RemoteSyncRecord record) {
    try {
      final payload = jsonDecode(record.payloadJson) as Map<String, dynamic>;
      return LocalShelter(
        id: record.entityId,
        name: payload['name'] as String,
        latitude: (payload['latitude'] as num).toDouble(),
        longitude: (payload['longitude'] as num).toDouble(),
        capacityTotal: (payload['capacityTotal'] as num).toInt(),
        occupancy: (payload['occupancy'] as num?)?.toInt() ?? 0,
        facilitiesJson: payload['facilitiesJson'] as String? ?? '[]',
        accessQuality: (payload['accessQuality'] as num?)?.toDouble(),
        updatedAt: DateTime.now(),
        version: record.version,
      );
    } catch (_) {
      return null;
    }
  }

  Future<int> _pullAlerts(Set<String> pendingIds) async {
    final repository = _alertRepository;
    if (repository == null) return 0;

    final pullResult = await _transport.pullAll('local_alerts');
    final remoteRecords = pullResult.dataOrNull ?? const <RemoteSyncRecord>[];

    var applied = 0;
    for (final record in remoteRecords) {
      final localResult = await repository.getById(record.entityId);
      final local = localResult.dataOrNull;
      if (local != null && local.version >= record.version) continue;

      final alert = _alertFromPayload(record);
      if (alert == null) continue;

      await repository.save(alert);
      applied++;
    }
    applied += await _deleteLocallyMissing<LocalAlert>(
      getAllLocal: repository.getAll,
      deleteLocal: repository.delete,
      idOf: (alert) => alert.id,
      remoteIds: remoteRecords.map((r) => r.entityId).toSet(),
      pendingIds: pendingIds,
    );
    return applied;
  }

  LocalAlert? _alertFromPayload(RemoteSyncRecord record) {
    try {
      final payload = jsonDecode(record.payloadJson) as Map<String, dynamic>;
      final cancelledAt = payload['cancelledAt'] as String?;
      return LocalAlert(
        id: record.entityId,
        title: payload['title'] as String,
        message: payload['message'] as String,
        severity: payload['severity'] as String,
        zoneId: payload['zoneId'] as String,
        zoneLabel: payload['zoneLabel'] as String? ?? '',
        geometryJson: payload['geometryJson'] as String,
        issuedBy: payload['issuedBy'] as String,
        issuedAt: DateTime.parse(payload['issuedAt'] as String),
        validUntil: DateTime.parse(payload['validUntil'] as String),
        cancelledAt: cancelledAt == null ? null : DateTime.parse(cancelledAt),
        version: record.version,
      );
    } catch (_) {
      return null;
    }
  }

  Future<int> _pullDamageReports() async {
    final repository = _damageReportRepository;
    if (repository == null) return 0;

    final pullResult = await _transport.pullAll('local_damage_reports');
    final remoteRecords = pullResult.dataOrNull ?? const <RemoteSyncRecord>[];

    var applied = 0;
    for (final record in remoteRecords) {
      final localResult = await repository.getById(record.entityId);
      final local = localResult.dataOrNull;
      if (local != null && local.version >= record.version) continue;

      final report = _damageReportFromPayload(record);
      if (report == null) continue;

      await repository.save(report);
      applied++;
    }
    return applied;
  }

  LocalDamageReport? _damageReportFromPayload(RemoteSyncRecord record) {
    try {
      final payload = jsonDecode(record.payloadJson) as Map<String, dynamic>;
      return LocalDamageReport(
        id: record.entityId,
        incidentId: payload['incidentId'] as String,
        responderId: payload['responderId'] as String,
        description: payload['description'] as String? ?? '',
        severity: payload['severity'] as String? ?? 'unknown',
        mediaPath: null,
        submittedAt: DateTime.parse(payload['submittedAt'] as String),
        version: record.version,
      );
    } catch (_) {
      return null;
    }
  }

  Future<int> _pullResources() async {
    final repository = _resourceRepository;
    if (repository == null) return 0;

    final pullResult = await _transport.pullAll('local_resources');
    final remoteRecords = pullResult.dataOrNull ?? const <RemoteSyncRecord>[];

    var applied = 0;
    for (final record in remoteRecords) {
      final localResult = await repository.getById(record.entityId);
      final local = localResult.dataOrNull;
      if (local != null && local.version >= record.version) continue;

      final resource = _resourceFromPayload(record);
      if (resource == null) continue;

      await repository.save(resource);
      applied++;
    }
    return applied;
  }

  /// Habitations don't support a moderation-style delete like incidents/
  /// alerts/hazard zones do — nothing in the app removes one today — so
  /// this pull skips the [_deleteLocallyMissing] diff those three use.
  Future<int> _pullHabitations() async {
    final repository = _habitationRepository;
    if (repository == null) return 0;

    final pullResult = await _transport.pullAll('local_habitations');
    final remoteRecords = pullResult.dataOrNull ?? const <RemoteSyncRecord>[];

    var applied = 0;
    for (final record in remoteRecords) {
      final localResult = await repository.getById(record.entityId);
      final local = localResult.dataOrNull;
      if (local != null && local.version >= record.version) continue;

      final habitation = _habitationFromPayload(record);
      if (habitation == null) continue;

      await repository.save(habitation);
      applied++;
    }
    return applied;
  }

  LocalHabitation? _habitationFromPayload(RemoteSyncRecord record) {
    try {
      final payload = jsonDecode(record.payloadJson) as Map<String, dynamic>;
      return LocalHabitation(
        id: record.entityId,
        name: payload['name'] as String,
        latitude: (payload['latitude'] as num).toDouble(),
        longitude: (payload['longitude'] as num).toDouble(),
        population: (payload['population'] as num?)?.toInt() ?? 0,
        administrativeRegionName: payload['administrativeRegionName'] as String?,
        infrastructureQuality: (payload['infrastructureQuality'] as num?)
            ?.toDouble(),
        accessQuality: (payload['accessQuality'] as num?)?.toDouble(),
        updatedAt: DateTime.now(),
        version: record.version,
      );
    } catch (_) {
      return null;
    }
  }

  LocalResource? _resourceFromPayload(RemoteSyncRecord record) {
    try {
      final payload = jsonDecode(record.payloadJson) as Map<String, dynamic>;
      return LocalResource(
        id: record.entityId,
        name: payload['name'] as String,
        type: payload['type'] as String,
        quantity: (payload['quantity'] as num?)?.toInt() ?? 0,
        shelterId: payload['shelterId'] as String?,
        updatedAt: DateTime.now(),
        version: record.version,
      );
    } catch (_) {
      return null;
    }
  }
}
