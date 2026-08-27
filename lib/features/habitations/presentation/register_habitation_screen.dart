import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:latlong2/latlong.dart';
import 'package:taarak/app/spacing.dart';
import 'package:taarak/core/gis/default_map_center.dart';
import 'package:taarak/features/auth/application/auth_controller.dart';
import 'package:taarak/features/habitations/application/habitation_providers.dart';
import 'package:taarak/features/map/presentation/widgets/taarak_map_controller.dart';
import 'package:taarak/features/map/presentation/widgets/taarak_map_view.dart';
import 'package:taarak/features/profile/application/location_status_controller.dart';
import 'package:taarak/shared/widgets/async_state_views.dart';
import 'package:taarak/shared/widgets/responsive.dart';
import 'package:taarak/shared/widgets/section_header.dart';
import 'package:taarak/shared/widgets/taarak_app_bar.dart';

/// The registration screen M07/M09/M10's engines never had a front door
/// for: until this existed, a [LocalHabitation] only ever came from a
/// demo seeder, so the risk/carrying-capacity/relocation pipeline had
/// nothing real to run against. Mirrors ReportHazardZoneScreen's
/// map-tap-then-form shape.
class RegisterHabitationScreen extends ConsumerStatefulWidget {
  const RegisterHabitationScreen({super.key});

  @override
  ConsumerState<RegisterHabitationScreen> createState() =>
      _RegisterHabitationScreenState();
}

final _accessOptions = {0.2: 'Easy access', 0.5: 'Moderate access', 0.8: 'Difficult access'};
final _infraOptions = {0.2: 'Robust infrastructure', 0.5: 'Average infrastructure', 0.8: 'Fragile infrastructure'};

class _RegisterHabitationScreenState
    extends ConsumerState<RegisterHabitationScreen> {
  final _mapController = TaarakMapController();
  final _nameController = TextEditingController();
  final _populationController = TextEditingController();
  final _regionController = TextEditingController();
  LatLng? _center;
  double _accessQuality = 0.5;
  double _infrastructureQuality = 0.5;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _populationController.dispose();
    _regionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userPoint = ref.watch(locationStatusProvider).valueOrNull?.geoTag;
    final fallbackCenter = userPoint == null
        ? defaultMapCenter
        : LatLng(userPoint.fix.latitude, userPoint.fix.longitude);
    final habitationsAsync = ref.watch(habitationsProvider);

    return Scaffold(
      appBar: const TaarakAppBar(title: 'Register Habitation'),
      body: ListView(
        children: [
          ContentWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  title: 'Mark the habitation',
                  icon: Icons.holiday_village_outlined,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                  child: Text(
                    'Tap the map at the habitation\'s location, then fill in '
                    'its details.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                SizedBox(
                  height: 280,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.md,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: TaarakMapView(
                        initialCenter: fallbackCenter,
                        initialZoom: userPoint != null ? 13 : defaultMapZoom,
                        mapController: _mapController,
                        onTap: (point) {
                          setState(() => _center = point);
                          _mapController.move(point, 13);
                        },
                        markers: _center == null
                            ? const {}
                            : {
                                gmaps.Marker(
                                  markerId: const gmaps.MarkerId('habitation'),
                                  position: gmaps.LatLng(
                                    _center!.latitude,
                                    _center!.longitude,
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
                          decoration: const InputDecoration(
                            labelText: 'Habitation name',
                          ),
                        ),
                        const SizedBox(height: Spacing.sm),
                        TextField(
                          controller: _populationController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Population',
                          ),
                        ),
                        const SizedBox(height: Spacing.sm),
                        TextField(
                          controller: _regionController,
                          decoration: const InputDecoration(
                            labelText: 'Administrative region (optional)',
                          ),
                        ),
                        const SizedBox(height: Spacing.sm),
                        DropdownButtonFormField<double>(
                          initialValue: _accessQuality,
                          decoration: const InputDecoration(
                            labelText: 'Access to the habitation',
                          ),
                          items: [
                            for (final entry in _accessOptions.entries)
                              DropdownMenuItem(
                                value: entry.key,
                                child: Text(entry.value),
                              ),
                          ],
                          onChanged: (value) => setState(
                            () => _accessQuality = value ?? _accessQuality,
                          ),
                        ),
                        const SizedBox(height: Spacing.sm),
                        DropdownButtonFormField<double>(
                          initialValue: _infrastructureQuality,
                          decoration: const InputDecoration(
                            labelText: 'Infrastructure quality',
                          ),
                          items: [
                            for (final entry in _infraOptions.entries)
                              DropdownMenuItem(
                                value: entry.key,
                                child: Text(entry.value),
                              ),
                          ],
                          onChanged: (value) => setState(
                            () => _infrastructureQuality =
                                value ?? _infrastructureQuality,
                          ),
                        ),
                        const SizedBox(height: Spacing.md),
                        FilledButton.icon(
                          onPressed: _canSubmit() && !_isSubmitting
                              ? _submit
                              : null,
                          icon: _isSubmitting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.add_location_alt_outlined),
                          label: Text(
                            _center == null
                                ? 'Tap the map to mark the habitation'
                                : 'Register habitation',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.lg),
                const SectionHeader(
                  title: 'Registered habitations',
                  icon: Icons.list_alt_outlined,
                ),
                habitationsAsync.when(
                  loading: () => const LoadingView(),
                  error: (error, _) => ErrorView(
                    message: 'Could not load habitations: $error',
                  ),
                  data: (habitations) => habitations.isEmpty
                      ? const EmptyView(
                          icon: Icons.holiday_village_outlined,
                          title: 'No habitations registered yet',
                        )
                      : Column(
                          children: [
                            for (final habitation in habitations)
                              Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: Spacing.md,
                                  vertical: Spacing.xs,
                                ),
                                child: ListTile(
                                  title: Text(habitation.name),
                                  subtitle: Text(
                                    'Population ${habitation.population}'
                                    '${habitation.administrativeRegionName == null ? '' : ' · ${habitation.administrativeRegionName}'}',
                                  ),
                                ),
                              ),
                          ],
                        ),
                ),
                const SizedBox(height: Spacing.lg),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _canSubmit() =>
      _center != null &&
      _nameController.text.trim().isNotEmpty &&
      int.tryParse(_populationController.text.trim()) != null;

  Future<void> _submit() async {
    final center = _center;
    final officialId = ref.read(currentUserProvider)?.id;
    final population = int.tryParse(_populationController.text.trim());
    if (center == null || officialId == null || population == null) return;

    setState(() => _isSubmitting = true);

    final region = _regionController.text.trim();
    final result = await ref
        .read(habitationRegistrationServiceProvider)
        .register(
          name: _nameController.text.trim(),
          latitude: center.latitude,
          longitude: center.longitude,
          population: population,
          administrativeRegionName: region.isEmpty ? null : region,
          infrastructureQuality: _infrastructureQuality,
          accessQuality: _accessQuality,
          officialId: officialId,
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.when(
      success: (_) {
        ref.invalidate(habitationsProvider);
        setState(() {
          _center = null;
          _nameController.clear();
          _populationController.clear();
          _regionController.clear();
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Habitation registered')));
      },
      failure: (failure) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message))),
    );
  }
}
