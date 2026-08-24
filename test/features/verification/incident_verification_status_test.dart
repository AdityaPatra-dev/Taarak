import 'package:flutter_test/flutter_test.dart';
import 'package:taarak/features/verification/domain/incident_verification_status.dart';

void main() {
  test('the initial state stores as the literal string "new"', () {
    expect(IncidentVerificationStatus.reported.storageValue, 'new');
  });

  test('every status round-trips through its storage value', () {
    for (final status in IncidentVerificationStatus.values) {
      expect(
        IncidentVerificationStatus.fromStorageValue(status.storageValue),
        status,
      );
    }
  });

  test('an unrecognized storage value maps to null', () {
    expect(IncidentVerificationStatus.fromStorageValue('closed'), isNull);
  });

  test('follows the spec\'s literal lifecycle: new->acknowledged->verified/rejected->active->resolved', () {
    expect(
      allowedIncidentStatusTransitions[IncidentVerificationStatus.reported],
      {IncidentVerificationStatus.acknowledged},
    );
    expect(
      allowedIncidentStatusTransitions[IncidentVerificationStatus.acknowledged],
      {IncidentVerificationStatus.verified, IncidentVerificationStatus.rejected},
    );
    expect(
      allowedIncidentStatusTransitions[IncidentVerificationStatus.verified],
      {IncidentVerificationStatus.active},
    );
    expect(
      allowedIncidentStatusTransitions[IncidentVerificationStatus.active],
      {IncidentVerificationStatus.resolved},
    );
  });

  test('rejected and resolved are terminal', () {
    expect(allowedIncidentStatusTransitions[IncidentVerificationStatus.rejected], isEmpty);
    expect(allowedIncidentStatusTransitions[IncidentVerificationStatus.resolved], isEmpty);
  });
}
