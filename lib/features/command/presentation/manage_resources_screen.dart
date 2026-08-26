import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/app/spacing.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/features/auth/application/auth_controller.dart';
import 'package:taarak/features/command/application/command_providers.dart';
import 'package:taarak/shared/widgets/async_state_views.dart';
import 'package:taarak/shared/widgets/responsive.dart';
import 'package:taarak/shared/widgets/taarak_app_bar.dart';

/// District/Command's ([Permission.manageResources]) tracker for response
/// resources — same create-or-edit dialog shape as
/// `shelter_management_screen.dart`'s "Add shelter" flow.
class ManageResourcesScreen extends ConsumerWidget {
  const ManageResourcesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resourcesAsync = ref.watch(resourcesProvider);

    return Scaffold(
      appBar: const TaarakAppBar(title: 'Manage Resources'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEditDialog(context, ref, existing: null),
        icon: const Icon(Icons.add),
        label: const Text('Add resource'),
      ),
      body: resourcesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const ErrorView(message: 'Unable to load resources'),
        data: (resources) {
          if (resources.isEmpty) {
            return const EmptyView(
              icon: Icons.inventory_2_outlined,
              title: 'No resources tracked yet',
              message: 'Add one with the button below.',
            );
          }
          return ListView(
            padding: const EdgeInsets.all(Spacing.md),
            children: [
              ContentWidth(
                child: Column(
                  children: [
                    for (final resource in resources)
                      Card(
                        margin: const EdgeInsets.only(bottom: Spacing.sm),
                        child: ListTile(
                          leading: const Icon(Icons.inventory_2_outlined),
                          title: Text(resource.name),
                          subtitle: Text(
                            '${resource.type} · qty ${resource.quantity}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.tune),
                            onPressed: () => _showEditDialog(
                              context,
                              ref,
                              existing: resource,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

Future<void> _showEditDialog(
  BuildContext context,
  WidgetRef ref, {
  required LocalResource? existing,
}) async {
  final nameController = TextEditingController(text: existing?.name ?? '');
  final typeController = TextEditingController(text: existing?.type ?? '');
  final quantityController = TextEditingController(
    text: existing?.quantity.toString() ?? '',
  );

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(existing == null ? 'Add resource' : 'Edit resource'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          TextField(
            controller: typeController,
            decoration: const InputDecoration(
              labelText: 'Type (e.g. vehicle, medical, personnel)',
            ),
          ),
          TextField(
            controller: quantityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Quantity'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Save'),
        ),
      ],
    ),
  );

  if (confirmed != true) return;

  final name = nameController.text.trim();
  final type = typeController.text.trim();
  final quantity = int.tryParse(quantityController.text.trim());
  if (name.isEmpty || type.isEmpty || quantity == null) return;

  final officialId = ref.read(currentUserProvider)?.id;
  if (officialId == null) return;

  final result = await ref
      .read(resourceManagementServiceProvider)
      .upsertResource(
        id: existing?.id,
        name: name,
        type: type,
        quantity: quantity,
        officialId: officialId,
      );

  ref.invalidate(resourcesProvider);

  if (!context.mounted) return;
  result.when(
    success: (_) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(existing == null ? 'Resource added' : 'Resource updated'),
      ),
    ),
    failure: (failure) => ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(failure.message))),
  );
}
