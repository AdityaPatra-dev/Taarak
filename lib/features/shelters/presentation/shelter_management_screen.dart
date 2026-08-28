import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:latlong2/latlong.dart';
import 'package:taarak/app/spacing.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/core/gis/default_map_center.dart';
import 'package:taarak/features/auth/application/auth_controller.dart';
import 'package:taarak/features/map/application/map_data_providers.dart';
import 'package:taarak/features/map/presentation/widgets/taarak_map_controller.dart';
import 'package:taarak/features/map/presentation/widgets/taarak_map_view.dart';
import 'package:taarak/features/profile/application/location_status_controller.dart';
import 'package:taarak/features/shelters/application/shelter_management_providers.dart';
import 'package:taarak/features/shelters/domain/shelter_facility_type.dart';
import 'package:taarak/shared/widgets/async_state_views.dart';
import 'package:taarak/shared/widgets/responsive.dart';
import 'package:taarak/shared/widgets/section_header.dart';
import 'package:taarak/shared/widgets/taarak_app_bar.dart';

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
      appBar: const TaarakAppBar(title: 'Shelters & Resources'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openShelterForm(context, ref, existing: null),
        icon: const Icon(Icons.add),
        label: const Text('Add shelter'),
      ),
      body: shelters.isEmpty
          ? const EmptyView(
              icon: Icons.home_work_outlined,
              title: 'No shelters recorded yet',
              message: 'Add one with the button below.',
            )
          : ResponsiveBuilder(
              builder: (context, size) {
                if (size == ScreenSize.mobile) {
                  return ListView(
                    padding: const EdgeInsets.all(Spacing.md),
                    children: [
                      for (final shelter in shelters)
                        _ShelterCard(shelter: shelter),
                    ],
                  );
                }
                // Wide viewport: a real grid instead of one long stretched
                // column of cards.
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(Spacing.lg),
                  child: Wrap(
                    spacing: Spacing.md,
                    runSpacing: Spacing.md,
                    children: [
                      for (final shelter in shelters)
                        SizedBox(
                          width: 360,
                          child: _ShelterCard(shelter: shelter),
                        ),
                    ],
                  ),
                );
              },
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
    final occupancyFraction = shelter.capacityTotal == 0
        ? 0.0
        : (shelter.occupancy / shelter.capacityTotal).clamp(0.0, 1.0);
    final scheme = Theme.of(context).colorScheme;
    final barColor = occupancyFraction >= 0.9
        ? scheme.error
        : occupancyFraction >= 0.7
        ? Colors.orange.shade600
        : Colors.green.shade600;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.home_work_outlined,
                    size: 18,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Text(
                    shelter.name,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: occupancyFraction,
                minHeight: 8,
                backgroundColor: scheme.surfaceContainerHighest,
                color: barColor,
              ),
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              '${shelter.occupancy}/${shelter.capacityTotal} occupied · $available available',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (facilities.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: Spacing.sm),
                child: Wrap(
                  spacing: Spacing.xs,
                  children: [
                    for (final facility in facilities)
                      Chip(
                        visualDensity: VisualDensity.compact,
                        label: Text(facility.label),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: Spacing.sm),
            Wrap(
              spacing: Spacing.sm,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _showOccupancyDialog(context, ref),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Update occupancy'),
                ),
                OutlinedButton.icon(
                  onPressed: () =>
                      _openShelterForm(context, ref, existing: shelter),
                  icon: const Icon(Icons.tune, size: 16),
                  label: const Text('Edit'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _confirmRemove(context, ref),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: scheme.error,
                    side: BorderSide(color: scheme.error),
                  ),
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Remove'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showOccupancyDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(
      text: shelter.occupancy.toString(),
    );

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
      success: (_) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Occupancy updated'))),
      failure: (failure) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message))),
    );
  }

  Future<void> _confirmRemove(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove shelter?'),
        content: Text(
          'This removes "${shelter.name}" from the shelter list. This can\'t be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final officialId = ref.read(currentUserProvider)?.id;
    if (officialId == null) return;

    final result = await ref
        .read(shelterManagementServiceProvider)
        .removeShelter(shelterId: shelter.id, officialId: officialId);

    ref.invalidate(sheltersProvider);

    if (!context.mounted) return;
    result.when(
      success: (_) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Shelter removed'))),
      failure: (failure) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message))),
    );
  }
}

void _openShelterForm(
  BuildContext context,
  WidgetRef ref, {
  required LocalShelter? existing,
}) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => _ShelterFormScreen(existing: existing),
    ),
  );
}

/// The location a shelter sits at needs to be pinpointed on the map it'll
/// later show up on — asking an official to type raw latitude/longitude is
/// exactly the kind of friction/error surface a tap-to-place map avoids,
/// matching [ReportHazardZoneScreen]'s pattern.
class _ShelterFormScreen extends ConsumerStatefulWidget {
  final LocalShelter? existing;

  const _ShelterFormScreen({required this.existing});

  @override
  ConsumerState<_ShelterFormScreen> createState() => _ShelterFormScreenState();
}

class _ShelterFormScreenState extends ConsumerState<_ShelterFormScreen> {
  final _mapController = TaarakMapController();
  late final TextEditingController _nameController;
  late final TextEditingController _capacityController;
  late final Set<ShelterFacilityType> _selectedFacilities;
  LatLng? _location;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _capacityController = TextEditingController(
      text: existing?.capacityTotal.toString() ?? '',
    );
    _selectedFacilities = existing == null
        ? <ShelterFacilityType>{}
        : ref.read(shelterManagementServiceProvider).facilitiesOf(existing);
    _location = existing == null
        ? null
        : LatLng(existing.latitude, existing.longitude);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userPoint = ref.watch(locationStatusProvider).valueOrNull?.geoTag;
    final fallbackCenter = _location ??
        (userPoint == null
            ? defaultMapCenter
            : LatLng(userPoint.fix.latitude, userPoint.fix.longitude));

    return Scaffold(
      appBar: TaarakAppBar(
        title: widget.existing == null ? 'Add Shelter' : 'Edit Shelter',
      ),
      body: ListView(
        children: [
          const SectionHeader(
            title: 'Mark the shelter\'s location',
            icon: Icons.home_work_outlined,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
            child: Text(
              'Tap the map where the shelter actually is.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          SizedBox(
            height: 320,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: TaarakMapView(
                  initialCenter: fallbackCenter,
                  initialZoom: _location != null || userPoint != null ? 14 : defaultMapZoom,
                  mapController: _mapController,
                  onTap: (point) {
                    setState(() => _location = point);
                    _mapController.move(point, 14);
                  },
                  markers: _location == null
                      ? const {}
                      : {
                          gmaps.Marker(
                            markerId: const gmaps.MarkerId('shelter-location'),
                            position: gmaps.LatLng(
                              _location!.latitude,
                              _location!.longitude,
                            ),
                          ),
                        },
                ),
              ),
            ),
          ),
          const SizedBox(height: Spacing.md),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: Spacing.md),
            child: Padding(
              padding: const EdgeInsets.all(Spacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  const SizedBox(height: Spacing.sm),
                  TextField(
                    controller: _capacityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Total capacity'),
                  ),
                  const SizedBox(height: Spacing.sm),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final type in ShelterFacilityType.values)
                        FilterChip(
                          label: Text(type.label),
                          selected: _selectedFacilities.contains(type),
                          onSelected: (selected) => setState(() {
                            if (selected) {
                              _selectedFacilities.add(type);
                            } else {
                              _selectedFacilities.remove(type);
                            }
                          }),
                        ),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  FilledButton.icon(
                    onPressed: _location == null || _isSubmitting
                        ? null
                        : _submit,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check),
                    label: Text(
                      _location == null
                          ? 'Tap the map to mark the location'
                          : widget.existing == null
                          ? 'Add shelter'
                          : 'Save changes',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Spacing.lg),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final location = _location;
    final capacityTotal = int.tryParse(_capacityController.text.trim());
    final name = _nameController.text.trim();
    if (location == null || name.isEmpty || capacityTotal == null) return;

    final officialId = ref.read(currentUserProvider)?.id;
    if (officialId == null) return;

    setState(() => _isSubmitting = true);

    final result = await ref.read(shelterManagementServiceProvider).upsertShelter(
      id: widget.existing?.id,
      name: name,
      latitude: location.latitude,
      longitude: location.longitude,
      capacityTotal: capacityTotal,
      facilities: _selectedFacilities,
      officialId: officialId,
    );

    ref.invalidate(sheltersProvider);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.when(
      success: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existing == null ? 'Shelter added' : 'Shelter updated',
            ),
          ),
        );
        Navigator.of(context).pop();
      },
      failure: (failure) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message))),
    );
  }
}
