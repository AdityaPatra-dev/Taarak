import 'package:taarak/core/error/failure.dart';
import 'package:taarak/core/repository/result.dart';
import 'package:taarak/features/verification/domain/incident_verification_status.dart';

/// M13's deterministic core: is this status transition even allowed. Pure
/// — no I/O — so [[IncidentVerificationService]] can check a requested
/// transition before touching the database.
class IncidentVerificationEngine {
  Result<IncidentVerificationStatus> validateTransition({
    required IncidentVerificationStatus from,
    required IncidentVerificationStatus to,
  }) {
    final allowed = allowedIncidentStatusTransitions[from] ?? const {};
    if (!allowed.contains(to)) {
      return Result.failure(
        ValidationFailure(
          'Cannot move an incident from "${from.label}" to "${to.label}"',
        ),
      );
    }
    return Result.success(to);
  }
}
