import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/core/media/image_picker_media_service.dart';
import 'package:taarak/core/media/media_picker_service.dart';
import 'package:taarak/core/providers/core_providers.dart';
import 'package:taarak/features/reporting/application/citizen_report_submission_service.dart';

final mediaPickerServiceProvider = Provider<MediaPickerService>(
  (ref) => ImagePickerMediaService(),
);

final citizenReportSubmissionServiceProvider =
    Provider<CitizenReportSubmissionService>(
      (ref) => CitizenReportSubmissionService(
        reportRepository: ref.watch(localIncidentReportRepositoryProvider),
        syncQueueDao: ref.watch(syncQueueDaoProvider),
        geoTagService: ref.watch(geoTagServiceProvider),
      ),
    );
