import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/features/auth/application/auth_controller.dart';
import 'package:taarak/features/map/application/map_data_providers.dart';
import 'package:taarak/features/shelters/application/shelter_management_providers.dart';
import 'package:taarak/features/shelters/domain/shelter_facility_type.dart';

/// M15: lets a Local Official ([Permission.manageSheltersResources]) keep
/// shelter capacity, occupancy and facilities current. This is the write
/// side of data M09/M10 already read — updating a shelter here changes
/// its ranking as a relocation candidate immediately, since both read from
/// the same [LocalShelters] table.
class ShelterManagementScreen extends ConsumerWidget {
  const ShelterManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shelters = ref.watch(sheltersProvider).valueOrNull ?? const [];

    return Scaffold(
      appBar: AppBar(title: const Text('Shelters & Resources')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEditDialog(context, ref, existing: null),
        icon: const Icon(Icons.add),
        label: const Text('Add shelter'),
      ),
      body: shelters.isEmpty
          ? const Center(child: Text('No shelters recorded yet.'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final shelter in shelters)
                  _ShelterCard(shelter: shelter),
              ],
            ),
    );
  }
}

class _ShelterCard extends ConsumerWidget {
  final LocalShelter shelter;

  const _ShelterCard({required this.shelter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final facilities = ref
        .read(shelterManagementServiceProvider)
        .facilitiesOf(shelter);
    final available = shelter.capacityTotal - shelter.occupancy;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(shelter.name, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              '${shelter.occupancy}/${shelter.capacityTotal} occupied · '
              '$available available',
            ),
            if (facilities.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Wrap(
                  spacing: 6,
                  children: [
                    for (final facility in facilities)
                      Chip(label: Text(facility.label)),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton(
                  onPressed: () => _showOccupancyDialog(context, ref),
                  child: const Text('Update occupancy'),
                ),
                OutlinedButton(
                  onPressed: () =>
                      _showEditDialog(context, ref, existing: shelter),
                  child: const Text('Edit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showOccupancyDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(text: shelter.occupancy.toString());

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Update occupancy'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Current occupancy'),
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
    final occupancy = int.tryParse(controller.text.trim());
    if (occupancy == null) return;

    final officialId = ref.read(currentUserProvider)?.id;
    if (officialId == null) return;

    final result = await ref
        .read(shelterManagementServiceProvider)
        .updateOccupancy(
          shelterId: shelter.id,
          occupancy: occupancy,
          officialId: officialId,
        );

    ref.invalidate(sheltersProvider);

    if (!context.mounted) return;
    result.when(
      success: (_) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Occupancy updated')),
      ),
      failure: (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
    );
  }
}

Future<void> _showEditDialog(
  BuildContext context,
  WidgetRef ref, {
  required LocalShelter? existing,
}) async {
  final nameController = TextEditingController(text: existing?.name ?? '');
  final latController = TextEditingController(
    text: existing?.latitude.toString() ?? '',
  );
  final lngController = TextEditingController(
    text: existing?.longitude.toString() ?? '',
  );
  final capacityController = TextEditingController(
    text: existing?.capacityTotal.toString() ?? '',
  );
  final selectedFacilities = existing == null
      ? <ShelterFacilityType>{}
      : ref.read(shelterManagementServiceProvider).facilitiesOf(existing);

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setState) => AlertDialog(
        title: Text(existing == null ? 'Add shelter' : 'Edit shelter'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: latController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: const InputDecoration(labelText: 'Latitude'),
              ),
              TextField(
                controller: lngController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: const InputDecoration(labelText: 'Longitude'),
              ),
              TextField(
                controller: capacityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Total capacity'),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  for (final type in ShelterFacilityType.values)
                    FilterChip(
                      label: Text(type.label),
                      selected: selectedFacilities.contains(type),
                      onSelected: (selected) => setState(() {
                        if (selected) {
                          selectedFacilities.add(type);
                        } else {
                          selectedFacilities.remove(type);
                        }
                      }),
                    ),
                ],
              ),
            ],
          ),
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
    ),
  );

  if (confirmed != true) return;

  final latitude = double.tryParse(latController.text.trim());
  final longitude = double.tryParse(lngController.text.trim());
  final capacityTotal = int.tryParse(capacityController.text.trim());
  final name = nameController.text.trim();
  if (name.isEmpty || latitude == null || longitude == null || capacityTotal == null) {
    return;
  }

  final officialId = ref.read(currentUserProvider)?.id;
  if (officialId == null) return;

  final result = await ref
      .read(shelterManagementServiceProvider)
      .upsertShelter(
        id: existing?.id,
        name: name,
        latitude: latitude,
        longitude: longitude,
        capacityTotal: capacityTotal,
        facilities: selectedFacilities,
        officialId: officialId,
      );

  ref.invalidate(sheltersProvider);

  if (!context.mounted) return;
  result.when(
    success: (_) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(existing == null ? 'Shelter added' : 'Shelter updated')),
    ),
    failure: (failure) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(failure.message)),
    ),
  );
}
