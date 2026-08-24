import 'package:flutter_test/flutter_test.dart';
import 'package:taarak/features/reporting/domain/citizen_report_type.dart';

void main() {
  test('every type round-trips through its storage value', () {
    for (final type in CitizenReportType.values) {
      expect(CitizenReportType.fromStorageValue(type.storageValue), type);
    }
  });

  test('an unrecognized storage value maps to null', () {
    expect(CitizenReportType.fromStorageValue('earthquake'), isNull);
  });

  test('only the four hazard/issue types are selectable in the report form', () {
    expect(CitizenReportType.landslide.isHazardIssue, isTrue);
    expect(CitizenReportType.flood.isHazardIssue, isTrue);
    expect(CitizenReportType.roadBlockage.isHazardIssue, isTrue);
    expect(CitizenReportType.other.isHazardIssue, isTrue);
    expect(CitizenReportType.sos.isHazardIssue, isFalse);
    expect(CitizenReportType.safeStatus.isHazardIssue, isFalse);
  });
}
