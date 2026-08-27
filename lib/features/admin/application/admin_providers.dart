import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/features/admin/data/role_permission_overrides_data_source.dart';
import 'package:taarak/features/admin/data/technical_config_data_source.dart';
import 'package:taarak/features/admin/data/user_admin_data_source.dart';
import 'package:taarak/features/admin/domain/admin_user_summary.dart';
import 'package:taarak/features/admin/domain/role_permission_overrides.dart';
import 'package:taarak/features/admin/domain/technical_config.dart';

final userAdminDataSourceProvider = Provider<UserAdminDataSource>(
  (ref) => UserAdminDataSource(),
);

final adminUsersProvider =
    FutureProvider.autoDispose<List<AdminUserSummary>>((ref) async {
      final result = await ref.watch(userAdminDataSourceProvider).listUsers();
      return result.dataOrNull ?? const [];
    });

final rolePermissionOverridesDataSourceProvider =
    Provider<RolePermissionOverridesDataSource>(
      (ref) => RolePermissionOverridesDataSource(),
    );

/// Watched from both [computeRedirect]'s call site and the home screen, so
/// an admin's edit here is the single source of truth every permission
/// check in the app defers to — see [RolePermissionOverrides].
final rolePermissionOverridesProvider =
    FutureProvider.autoDispose<RolePermissionOverrides>((ref) async {
      final result = await ref
          .watch(rolePermissionOverridesDataSourceProvider)
          .read();
      return result.dataOrNull ?? RolePermissionOverrides.empty;
    });

final technicalConfigDataSourceProvider = Provider<TechnicalConfigDataSource>(
  (ref) => TechnicalConfigDataSource(),
);

final technicalConfigProvider = FutureProvider.autoDispose<TechnicalConfig>((
  ref,
) async {
  final result = await ref.watch(technicalConfigDataSourceProvider).read();
  return result.dataOrNull ?? TechnicalConfig.defaults;
});
