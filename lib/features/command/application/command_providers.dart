import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/providers/core_providers.dart';
import 'package:taarak/features/admin/application/admin_providers.dart';
import 'package:taarak/features/admin/domain/admin_user_summary.dart';
import 'package:taarak/features/auth/domain/user_role.dart';
import 'package:taarak/features/command/application/resource_management_service.dart';

final resourceManagementServiceProvider = Provider<ResourceManagementService>(
  (ref) => ResourceManagementService(
    repository: ref.watch(localResourceRepositoryProvider),
    auditLogDao: ref.watch(auditLogDaoProvider),
    syncQueueDao: ref.watch(syncQueueDaoProvider),
  ),
);

final resourcesProvider = FutureProvider.autoDispose<List<LocalResource>>((
  ref,
) async {
  final result = await ref
      .watch(resourceManagementServiceProvider)
      .listResources();
  return result.dataOrNull ?? const [];
});

/// The responder picker's source list — reuses the System Admin's account
/// read path (Firestore rules also grant District/Command read access to
/// the same `users` collection) rather than duplicating a second "list
/// accounts" query just to filter it differently.
final fieldRespondersProvider = FutureProvider.autoDispose<
  List<AdminUserSummary>
>((ref) async {
  final users = await ref.watch(adminUsersProvider.future);
  return users.where((user) => user.role == UserRole.fieldResponder).toList();
});
