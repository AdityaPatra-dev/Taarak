/// What [[AutoHazardScanService]] should do this poll for one
/// habitation/hazard-type pair.
enum AutoHazardActionType { create, update, keep, delete, noOp }

class AutoHazardAction {
  final AutoHazardActionType type;

  /// The hysteresis counter's value *after* this decision — the caller
  /// persists this back into `local_hazard_automation_states`.
  final int nextConsecutiveBelowDeleteThreshold;

  /// Whether a zone should be considered active *after* this decision.
  final bool nextZoneActive;

  const AutoHazardAction({
    required this.type,
    required this.nextConsecutiveBelowDeleteThreshold,
    required this.nextZoneActive,
  });
}

/// Pure hysteresis rule for automatic hazard-zone create/keep/delete — no
/// I/O, so every boundary is exactly unit-testable. Deliberately
/// asymmetric: a warning appears the instant conditions cross
/// [createThreshold] (a disaster app should err toward warning fast — a
/// false positive self-corrects via the delete path below), but only
/// disappears after [deleteConfirmationPolls] *consecutive* polls below
/// [deleteThreshold] (a missed warning does not self-correct, so a single
/// noisy low reading must not retract a real one).
AutoHazardAction decideAutoHazardAction({
  required double? score,
  required bool zoneCurrentlyActive,
  required int consecutiveBelowDeleteThreshold,
  required double createThreshold,
  required double deleteThreshold,
  required int deleteConfirmationPolls,
}) {
  if (score == null) {
    // No fresh signal this poll — a fetch outage must never silently
    // retract a real warning, so state (and any active zone) is untouched.
    return AutoHazardAction(
      type: AutoHazardActionType.noOp,
      nextConsecutiveBelowDeleteThreshold: consecutiveBelowDeleteThreshold,
      nextZoneActive: zoneCurrentlyActive,
    );
  }

  if (score >= createThreshold) {
    return AutoHazardAction(
      type: zoneCurrentlyActive ? AutoHazardActionType.update : AutoHazardActionType.create,
      nextConsecutiveBelowDeleteThreshold: 0,
      nextZoneActive: true,
    );
  }

  if (score < deleteThreshold && zoneCurrentlyActive) {
    final nextCount = consecutiveBelowDeleteThreshold + 1;
    if (nextCount >= deleteConfirmationPolls) {
      return AutoHazardAction(
        type: AutoHazardActionType.delete,
        nextConsecutiveBelowDeleteThreshold: 0,
        nextZoneActive: false,
      );
    }
    return AutoHazardAction(
      type: AutoHazardActionType.keep,
      nextConsecutiveBelowDeleteThreshold: nextCount,
      nextZoneActive: true,
    );
  }

  // In the dead band [deleteThreshold, createThreshold), or below
  // deleteThreshold with no active zone to delete: reset the counter
  // without touching anything.
  return AutoHazardAction(
    type: AutoHazardActionType.keep,
    nextConsecutiveBelowDeleteThreshold: 0,
    nextZoneActive: zoneCurrentlyActive,
  );
}
