import 'dart:convert';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/features/sync/application/firestore_sync_transport.dart';
import 'package:taarak/features/sync/domain/sync_push_outcome.dart';

SyncQueueEntry _entry({
  String entityTable = 'local_incident_reports',
  String entityId = 'report-1',
  Map<String, dynamic> payload = const {},
}) => SyncQueueEntry(
  id: 0,
  entityTable: entityTable,
  entityId: entityId,
  operation: 'create',
  payloadJson: jsonEncode(payload),
  createdAt: DateTime.now(),
  attemptCount: 0,
  status: 'pending',
);

void main() {
  group('push', () {
    test('a brand-new entity is accepted with no conflict', () async {
      final firestore = FakeFirebaseFirestore();
      final transport = FirestoreSyncTransport(firestore: firestore);

      final result = await transport.push(_entry(payload: {'version': 1}));

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?.status, SyncPushStatus.accepted);
      final doc = await firestore
          .collection('local_incident_reports')
          .doc('report-1')
          .get();
      expect(doc.data()?['version'], 1);
    });

    test(
      'INTRODUCE GENUINE BACKEND CONNECTIVITY — the acceptance criterion: pushing a '
      'strictly newer version is accepted and overwrites the stored one',
      () async {
        final firestore = FakeFirebaseFirestore();
        final transport = FirestoreSyncTransport(firestore: firestore);

        await transport.push(_entry(payload: {'version': 1}));
        final result = await transport.push(_entry(payload: {'version': 2}));

        expect(result.dataOrNull?.status, SyncPushStatus.accepted);
        final doc = await firestore
            .collection('local_incident_reports')
            .doc('report-1')
            .get();
        expect(doc.data()?['version'], 2);
      },
    );

    test(
      'pushing a version that is not strictly newer than what is stored is a '
      'conflict, and does not overwrite the stored data',
      () async {
        final firestore = FakeFirebaseFirestore();
        final transport = FirestoreSyncTransport(firestore: firestore);

        await transport.push(_entry(payload: {'version': 3}));
        final result = await transport.push(_entry(payload: {'version': 2}));

        expect(result.dataOrNull?.status, SyncPushStatus.conflict);
        expect(result.dataOrNull?.serverVersion, 3);
        final doc = await firestore
            .collection('local_incident_reports')
            .doc('report-1')
            .get();
        expect(doc.data()?['version'], 3); // unchanged
      },
    );

    test(
      'different tables with the same entityId are tracked independently',
      () async {
        final firestore = FakeFirebaseFirestore();
        final transport = FirestoreSyncTransport(firestore: firestore);

        await transport.push(
          _entry(
            entityTable: 'local_incidents',
            entityId: 'x1',
            payload: {'version': 5},
          ),
        );
        await transport.push(
          _entry(
            entityTable: 'local_alerts',
            entityId: 'x1',
            payload: {'version': 1},
          ),
        );

        final incidentDoc = await firestore
            .collection('local_incidents')
            .doc('x1')
            .get();
        final alertDoc = await firestore
            .collection('local_alerts')
            .doc('x1')
            .get();
        expect(incidentDoc.data()?['version'], 5);
        expect(alertDoc.data()?['version'], 1);
      },
    );
  });

  group('pullAll', () {
    test(
      'A DEVICE THAT PULLS SEES WHAT ANOTHER DEVICE PUSHED — the multi-device '
      'acceptance criterion',
      () async {
        final firestore = FakeFirebaseFirestore();
        final transport = FirestoreSyncTransport(firestore: firestore);
        await transport.push(
          _entry(
            entityId: 'report-from-device-a',
            payload: {'id': 'report-from-device-a', 'version': 1},
          ),
        );

        final result = await transport.pullAll('local_incident_reports');

        expect(result.isSuccess, isTrue);
        final records = result.dataOrNull!;
        expect(records, hasLength(1));
        expect(records.single.entityId, 'report-from-device-a');
        expect(records.single.version, 1);
        expect(
          jsonDecode(records.single.payloadJson)['id'],
          'report-from-device-a',
        );
      },
    );

    test('an empty table pulls back an empty list, not an error', () async {
      final firestore = FakeFirebaseFirestore();
      final transport = FirestoreSyncTransport(firestore: firestore);

      final result = await transport.pullAll('local_alerts');

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, isEmpty);
    });
  });
}
