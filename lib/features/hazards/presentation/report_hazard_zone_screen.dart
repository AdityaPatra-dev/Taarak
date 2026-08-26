import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';
import 'package:taarak/app/spacing.dart';
import 'package:taarak/core/gis/circle_geometry.dart';
import 'package:taarak/core/gis/default_map_center.dart';
import 'package:taarak/core/gis/severity_palette.dart';
import 'package:taarak/features/auth/application/auth_controller.dart';
import 'package:taarak/features/hazards/application/hazard_providers.dart';
import 'package:taarak/features/hazards/domain/hazard_severity.dart';
import 'package:taarak/features/hazards/domain/hazard_type.dart';
import 'package:taarak/features/hazards/domain/raw_hazard_observation.dart';
import 'package:taarak/features/map/application/map_data_providers.dart';
import 'package:taarak/features/map/presentation/widgets/taarak_map_view.dart';
import 'package:taarak/features/profile/application/location_status_controller.dart';
import 'package:taarak/shared/widgets/responsive.dart';
import 'package:taarak/shared/widgets/section_header.dart';
import 'package:taarak/shared/widgets/taarak_app_bar.dart';

const _uuid = Uuid();
const _radiusOptions = {
  '200 m': 200.0,
  '500 m': 500.0,
  '1 km': 1000.0,
  '2 km': 2000.0,
  '5 km': 5000.0,
};

/// Lets a Local Official ([Permission.manageLocalIncidents]) mark a hazard's
/// epicenter and affected radius on the map — the front door M06's
/// ingestion pipeline never had: without this, [HazardIngestionService]
/// is only ever exercised by tests, and the map's hazard-zone layer has
/// nothing to show. The zone is captured as "epicenter + radius" rather
/// than a freehand boundary — faster for an official to enter under
/// pressure, and geometrically a real polygon either way (see
/// [circlePolygonPoints]).
class ReportHazardZoneScreen extends ConsumerStatefulWidget {
  const ReportHazardZoneScreen({super.key});

  @override
  ConsumerState<ReportHazardZoneScreen> createState() =>
      _ReportHazardZoneScreenState();
}

class _ReportHazardZoneScreenState
    extends ConsumerState<ReportHazardZoneScreen> {
  LatLng? _center;
  HazardType _hazardType = HazardType.flood;
  HazardSeverity _severity = HazardSeverity.medium;
  String _radiusLabel = '500 m';
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final userPoint = ref.watch(locationStatusProvider).valueOrNull?.geoTag;
    final fallbackCenter = userPoint == null
        ? defaultMapCenter
        : LatLng(userPoint.fix.latitude, userPoint.fix.longitude);
    final radiusMeters = _radiusOptions[_radiusLabel]!;

    return Scaffold(
      appBar: const TaarakAppBar(title: 'Report Hazard Zone'),
      body: ListView(
        children: [
          ContentWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  title: 'Mark the affected area',
                  icon: Icons.warning_amber_outlined,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                  child: Text(
                    'Tap the map at the hazard\'s epicenter, then set how far '
                    'it reaches.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                SizedBox(
                  height: 320,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.md,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: TaarakMapView(
                        initialCenter: fallbackCenter,
                        initialZoom: userPoint != null ? 13 : defaultMapZoom,
                        onTap: (point) => setState(() => _center = point),
                        overlayLayers: [
                          if (_center != null)
                            PolygonLayer(
                              polygons: [
                                Polygon(
                                  points: circlePolygonPoints(
                                    _center!,
                                    radiusMeters,
                                  ),
                                  color: severityColor(
                                    _severity.storageValue,
                                  ).withValues(alpha: 0.35),
                                  borderColor: severityColor(
                                    _severity.storageValue,
                                  ),
                                  borderStrokeWidth: 2,
                                ),
                              ],
                            ),
                          if (_center != null)
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: _center!,
                                  width: 28,
                                  height: 28,
                                  child: const Icon(
                                    Icons.location_pin,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                        ],
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
                        DropdownButtonFormField<HazardType>(
                          initialValue: _hazardType,
                          decoration: const InputDecoration(
                            labelText: 'Hazard type',
                          ),
                          items: [
                            for (final type in HazardType.values)
                              DropdownMenuItem(
                                value: type,
                                child: Text(type.storageValue),
                              ),
                          ],
                          onChanged: (value) =>
                              setState(() => _hazardType = value ?? _hazardType),
                        ),
                        const SizedBox(height: Spacing.sm),
                        DropdownButtonFormField<HazardSeverity>(
                          initialValue: _severity,
                          decoration: const InputDecoration(
                            labelText: 'Severity',
                          ),
                          items: [
                            for (final severity in HazardSeverity.values)
                              DropdownMenuItem(
                                value: severity,
                                child: Text(severity.storageValue),
                              ),
                          ],
                          onChanged: (value) =>
                              setState(() => _severity = value ?? _severity),
                        ),
                        const SizedBox(height: Spacing.sm),
                        DropdownButtonFormField<String>(
                          initialValue: _radiusLabel,
                          decoration: const InputDecoration(
                            labelText: 'Affected radius',
                          ),
                          items: [
                            for (final label in _radiusOptions.keys)
                              DropdownMenuItem(value: label, child: Text(label)),
                          ],
                          onChanged: (value) => setState(
                            () => _radiusLabel = value ?? _radiusLabel,
                          ),
                        ),
                        const SizedBox(height: Spacing.md),
                        FilledButton.icon(
                          onPressed: _center == null || _isSubmitting
                              ? null
                              : _submit,
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
                                ? 'Tap the map to mark the epicenter'
                                : 'Report hazard zone',
                          ),
                        ),
                      ],
                    ),
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

  Future<void> _submit() async {
    final center = _center;
    final officialId = ref.read(currentUserProvider)?.id;
    if (center == null || officialId == null) return;

    setState(() => _isSubmitting = true);

    final result = await ref.read(hazardIngestionServiceProvider).ingest(
      id: _uuid.v4(),
      observation: RawHazardObservation(
        hazardType: _hazardType.storageValue,
        severityScore: _severity.intensity,
        boundaryPoints: circlePolygonPoints(
          center,
          _radiusOptions[_radiusLabel]!,
        ),
        source: 'official:$officialId',
        observedAt: DateTime.now(),
      ),
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.when(
      success: (_) {
        ref.invalidate(hazardZonesProvider);
        setState(() => _center = null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hazard zone reported')),
        );
      },
      failure: (failure) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message))),
    );
  }
}
