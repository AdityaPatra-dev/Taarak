import 'package:taarak/features/reporting/domain/citizen_report_type.dart';

/// What the UI collects before handing off to
/// [[CitizenReportSubmissionService]] — GPS is deliberately not part of
/// this: it's captured fresh at submit time (M04's [[GeoTagService]]),
/// not something the form asks the citizen for.
class CitizenReportDraft {
  final CitizenReportType type;
  final String description;

  /// One of the app's standard severity bands ('low'/'medium'/'high'/
  /// 'critical'), or 'unknown' if the citizen didn't specify.
  final String severity;

  final int? affectedPeopleCount;
  final String? mediaPath;

  const CitizenReportDraft({
    required this.type,
    this.description = '',
    this.severity = 'unknown',
    this.affectedPeopleCount,
    this.mediaPath,
  });
}
