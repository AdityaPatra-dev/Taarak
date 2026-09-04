import 'package:flutter_test/flutter_test.dart';
import 'package:taarak/features/hazard_automation/domain/auto_hazard_decision.dart';

void main() {
  const createThreshold = 0.6;
  const deleteThreshold = 0.35;
  const deleteConfirmationPolls = 2;

  AutoHazardAction decide({
    required double? score,
    bool zoneCurrentlyActive = false,
    int consecutiveBelowDeleteThreshold = 0,
  }) => decideAutoHazardAction(
    score: score,
    zoneCurrentlyActive: zoneCurrentlyActive,
    consecutiveBelowDeleteThreshold: consecutiveBelowDeleteThreshold,
    createThreshold: createThreshold,
    deleteThreshold: deleteThreshold,
    deleteConfirmationPolls: deleteConfirmationPolls,
  );

  test('null score always no-ops, regardless of existing state', () {
    final action = decide(score: null, zoneCurrentlyActive: true, consecutiveBelowDeleteThreshold: 1);

    expect(action.type, AutoHazardActionType.noOp);
    expect(action.nextZoneActive, isTrue);
    expect(action.nextConsecutiveBelowDeleteThreshold, 1);
  });

  test('score exactly at the create threshold creates a new zone', () {
    final action = decide(score: 0.6, zoneCurrentlyActive: false);

    expect(action.type, AutoHazardActionType.create);
    expect(action.nextZoneActive, isTrue);
    expect(action.nextConsecutiveBelowDeleteThreshold, 0);
  });

  test('score just under the create threshold does not create', () {
    final action = decide(score: 0.599999, zoneCurrentlyActive: false);

    expect(action.type, isNot(AutoHazardActionType.create));
  });

  test('score at/above the create threshold updates an already-active zone', () {
    final action = decide(score: 0.75, zoneCurrentlyActive: true, consecutiveBelowDeleteThreshold: 1);

    expect(action.type, AutoHazardActionType.update);
    expect(action.nextZoneActive, isTrue);
    expect(action.nextConsecutiveBelowDeleteThreshold, 0); // reset by a qualifying poll
  });

  test('score just under the delete threshold, on an active zone, keeps and counts up', () {
    final action = decide(score: 0.349999, zoneCurrentlyActive: true, consecutiveBelowDeleteThreshold: 0);

    expect(action.type, AutoHazardActionType.keep);
    expect(action.nextZoneActive, isTrue);
    expect(action.nextConsecutiveBelowDeleteThreshold, 1);
  });

  test('score exactly at the delete threshold does not count as below it', () {
    final action = decide(score: 0.35, zoneCurrentlyActive: true, consecutiveBelowDeleteThreshold: 1);

    expect(action.type, AutoHazardActionType.keep);
    expect(action.nextZoneActive, isTrue);
    expect(action.nextConsecutiveBelowDeleteThreshold, 0); // dead-band poll resets the streak
  });

  test('counter reaching exactly deleteConfirmationPolls deletes the zone', () {
    final action = decide(score: 0.1, zoneCurrentlyActive: true, consecutiveBelowDeleteThreshold: 1);

    expect(action.type, AutoHazardActionType.delete);
    expect(action.nextZoneActive, isFalse);
    expect(action.nextConsecutiveBelowDeleteThreshold, 0);
  });

  test('counter at deleteConfirmationPolls - 1 keeps, does not yet delete', () {
    final action = decide(score: 0.1, zoneCurrentlyActive: true, consecutiveBelowDeleteThreshold: 0);

    expect(action.type, AutoHazardActionType.keep);
    expect(action.nextZoneActive, isTrue);
    expect(action.nextConsecutiveBelowDeleteThreshold, 1);
  });

  test('a low score with no active zone is a no-op keep, not a delete', () {
    final action = decide(score: 0.1, zoneCurrentlyActive: false, consecutiveBelowDeleteThreshold: 0);

    expect(action.type, AutoHazardActionType.keep);
    expect(action.nextZoneActive, isFalse);
    expect(action.nextConsecutiveBelowDeleteThreshold, 0);
  });

  test('a dead-band score (between thresholds) does not touch an active zone', () {
    final action = decide(score: 0.5, zoneCurrentlyActive: true, consecutiveBelowDeleteThreshold: 1);

    expect(action.type, AutoHazardActionType.keep);
    expect(action.nextZoneActive, isTrue);
    expect(action.nextConsecutiveBelowDeleteThreshold, 0); // any dead-band poll resets the streak
  });
}
