import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/features/admin/data/user_admin_data_source.dart';
import 'package:taarak/features/admin/domain/admin_user_summary.dart';

final userAdminDataSourceProvider = Provider<UserAdminDataSource>(
  (ref) => UserAdminDataSource(),
);

final adminUsersProvider =
    FutureProvider.autoDispose<List<AdminUserSummary>>((ref) async {
      final result = await ref.watch(userAdminDataSourceProvider).listUsers();
      return result.dataOrNull ?? const [];
    });
