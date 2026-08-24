import 'package:flutter_test/flutter_test.dart';
import 'package:taarak/features/verification/application/incident_verification_engine.dart';
import 'package:taarak/features/verification/domain/incident_verification_status.dart';

void main() {
  final engine = IncidentVerificationEngine();

  test('allows a valid forward transition', () {
    final result = engine.validateTransition(
      from: IncidentVerificationStatus.reported,
      to: IncidentVerificationStatus.acknowledged,
    );
    expect(result.isSuccess, isTrue);
  });

  test('allows the acknowledged fork to either verified or rejected', () {
    expect(
      engine
          .validateTransition(
            from: IncidentVerificationStatus.acknowledged,
            to: IncidentVerificationStatus.verified,
          )
          .isSuccess,
      isTrue,
    );
    expect(
      engine
          .validateTransition(
            from: IncidentVerificationStatus.acknowledged,
            to: IncidentVerificationStatus.rejected,
          )
          .isSuccess,
      isTrue,
    );
  });

  test('rejects skipping a state (new straight to active)', () {
    final result = engine.validateTransition(
      from: IncidentVerificationStatus.reported,
      to: IncidentVerificationStatus.active,
    );
    expect(result.isFailure, isTrue);
  });

  test('rejects moving backward', () {
    final result = engine.validateTransition(
      from: IncidentVerificationStatus.active,
      to: IncidentVerificationStatus.verified,
    );
    expect(result.isFailure, isTrue);
  });

  test('rejects any transition out of a terminal state', () {
    expect(
      engine
          .validateTransition(
            from: IncidentVerificationStatus.rejected,
            to: IncidentVerificationStatus.acknowledged,
          )
          .isFailure,
      isTrue,
    );
    expect(
      engine
          .validateTransition(
            from: IncidentVerificationStatus.resolved,
            to: IncidentVerificationStatus.active,
          )
          .isFailure,
      isTrue,
    );
  });
}
