import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/app/spacing.dart';
import 'package:taarak/features/admin/application/admin_providers.dart';
import 'package:taarak/features/admin/domain/admin_user_summary.dart';
import 'package:taarak/features/auth/application/auth_controller.dart';
import 'package:taarak/features/auth/domain/user_role.dart';
import 'package:taarak/shared/widgets/async_state_views.dart';
import 'package:taarak/shared/widgets/responsive.dart';
import 'package:taarak/shared/widgets/taarak_app_bar.dart';

/// Lets a System Admin ([Permission.manageAccounts]) assign any role to any
/// account — the gap flagged (but deliberately deferred) when the app
/// migrated to Firebase: until this screen existed, every non-citizen role
/// could only be set by hand-editing Firestore in the console.
class UserAdminScreen extends ConsumerWidget {
  const UserAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(adminUsersProvider);
    final selfId = ref.watch(currentUserProvider)?.id;

    return Scaffold(
      appBar: const TaarakAppBar(title: 'Manage Accounts'),
      body: usersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorView(
          message: 'Unable to load accounts',
          onRetry: () => ref.invalidate(adminUsersProvider),
        ),
        data: (users) {
          if (users.isEmpty) {
            return const EmptyView(
              icon: Icons.people_outline,
              title: 'No accounts found',
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(adminUsersProvider),
            child: ListView(
              padding: const EdgeInsets.all(Spacing.md),
              children: [
                ContentWidth(
                  child: Column(
                    children: [
                      for (final user in users)
                        _UserRow(
                          user: user,
                          isSelf: user.uid == selfId,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _UserRow extends ConsumerWidget {
  final AdminUserSummary user;
  final bool isSelf;

  const _UserRow({required this.user, required this.isSelf});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: scheme.primaryContainer,
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                style: TextStyle(color: scheme.onPrimaryContainer),
              ),
            ),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isSelf ? '${user.name} (you)' : user.name,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    user.email,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: Spacing.sm),
            // Changing your own role would risk locking yourself out of
            // this very screen (manageAccounts might no longer apply) —
            // simplest safe rule is to just not offer it.
            if (isSelf)
              Chip(label: Text(user.role.label))
            else
              DropdownButton<UserRole>(
                value: user.role,
                onChanged: (role) {
                  if (role != null) _changeRole(context, ref, role);
                },
                items: [
                  for (final role in UserRole.values)
                    DropdownMenuItem(value: role, child: Text(role.label)),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _changeRole(
    BuildContext context,
    WidgetRef ref,
    UserRole role,
  ) async {
    if (role == user.role) return;
    final messenger = ScaffoldMessenger.of(context);

    final result = await ref
        .read(userAdminDataSourceProvider)
        .updateRole(uid: user.uid, role: role);
    ref.invalidate(adminUsersProvider);

    result.when(
      success: (_) => messenger.showSnackBar(
        SnackBar(content: Text('${user.name} is now ${role.label}')),
      ),
      failure: (failure) =>
          messenger.showSnackBar(SnackBar(content: Text(failure.message))),
    );
  }
}
