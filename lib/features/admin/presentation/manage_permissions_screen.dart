import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/app/spacing.dart';
import 'package:taarak/features/admin/application/admin_providers.dart';
import 'package:taarak/features/admin/domain/role_permission_overrides.dart';
import 'package:taarak/features/auth/domain/permission.dart';
import 'package:taarak/features/auth/domain/user_role.dart';
import 'package:taarak/shared/widgets/async_state_views.dart';
import 'package:taarak/shared/widgets/responsive.dart';
import 'package:taarak/shared/widgets/taarak_app_bar.dart';

/// A permission a role can never have toggled off from here — removing
/// [Permission.manageAccounts] or [Permission.managePermissions] from
/// System Admin through this very screen could lock every admin out of
/// both account recovery and this screen itself, with no other way back
/// in (unlike a role mis-assignment, which any other System Admin can
/// still fix through Manage Accounts).
bool _isProtected(UserRole role, Permission permission) =>
    role == UserRole.systemAdmin &&
    (permission == Permission.manageAccounts ||
        permission == Permission.managePermissions);

/// System Admin's ([Permission.managePermissions]) screen for the
/// capability that, until now, was declared and granted but had nothing
/// behind it — see [RolePermissionOverrides]. Every permission is toggled
/// per role rather than scoped to "what that role normally has", since the
/// whole point of a permissions screen is being able to grant or remove
/// any capability from any role.
class ManagePermissionsScreen extends ConsumerWidget {
  const ManagePermissionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overridesAsync = ref.watch(rolePermissionOverridesProvider);

    return Scaffold(
      appBar: const TaarakAppBar(title: 'Manage Permissions'),
      body: overridesAsync.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          message: 'Could not load permission overrides: $error',
          onRetry: () => ref.invalidate(rolePermissionOverridesProvider),
        ),
        data: (overrides) => ListView(
          padding: const EdgeInsets.all(Spacing.md),
          children: [
            ContentWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: Spacing.sm),
                    child: Text(
                      'Changes apply immediately across the app for every '
                      'signed-in user of that role.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  for (final role in UserRole.values)
                    _RolePermissionsCard(role: role, overrides: overrides),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RolePermissionsCard extends ConsumerWidget {
  final UserRole role;
  final RolePermissionOverrides overrides;

  const _RolePermissionsCard({required this.role, required this.overrides});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effective = overrides.effectivePermissionsFor(role);
    final isCustomized = overrides.overridesByRole.containsKey(role);

    return Card(
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      child: ExpansionTile(
        title: Row(
          children: [
            Expanded(child: Text(role.label)),
            if (isCustomized)
              const Padding(
                padding: EdgeInsets.only(right: Spacing.xs),
                child: Chip(
                  label: Text('Customized'),
                  visualDensity: VisualDensity.compact,
                ),
              ),
          ],
        ),
        subtitle: Text('${effective.length} permissions granted'),
        children: [
          for (final permission in Permission.values)
            CheckboxListTile(
              value: effective.contains(permission),
              title: Text(permission.label),
              subtitle: _isProtected(role, permission)
                  ? const Text('Required to prevent locking out all admins')
                  : null,
              onChanged: _isProtected(role, permission)
                  ? null
                  : (checked) => _toggle(ref, permission, checked ?? false),
            ),
          if (isCustomized)
            Padding(
              padding: const EdgeInsets.only(
                left: Spacing.md,
                right: Spacing.md,
                bottom: Spacing.sm,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => _resetToDefault(ref),
                  child: const Text('Reset to default'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _toggle(WidgetRef ref, Permission permission, bool grant) async {
    final current = overrides.effectivePermissionsFor(role);
    final updated = grant
        ? {...current, permission}
        : (current.toSet()..remove(permission));
    await _save(ref, overrides.withRole(role, updated));
  }

  Future<void> _resetToDefault(WidgetRef ref) async {
    final remaining = {...overrides.overridesByRole}..remove(role);
    await _save(ref, RolePermissionOverrides(overridesByRole: remaining));
  }

  Future<void> _save(WidgetRef ref, RolePermissionOverrides updated) async {
    await ref.read(rolePermissionOverridesDataSourceProvider).write(updated);
    ref.invalidate(rolePermissionOverridesProvider);
  }
}
