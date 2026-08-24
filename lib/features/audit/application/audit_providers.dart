import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/providers/core_providers.dart';

final auditEventsProvider = FutureProvider.autoDispose<List<LocalAuditEvent>>((
  ref,
) async {
  final result = await ref.watch(auditLogDaoProvider).getAll();
  return result.dataOrNull ?? const [];
});
