import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';
import 'package:taarak/app/spacing.dart';
import 'package:taarak/core/gis/default_map_center.dart';
import 'package:taarak/features/auth/application/auth_controller.dart';
import 'package:taarak/features/disaster_events/application/disaster_event_providers.dart';
import 'package:taarak/features/disaster_events/application/disaster_event_processor.dart';
import 'package:taarak/features/disaster_events/application/government_alert_parser.dart';
import 'package:taarak/features/disaster_events/domain/disaster_event.dart';
import 'package:taarak/features/map/application/map_data_providers.dart';
import 'package:taarak/features/map/presentation/widgets/taarak_map_controller.dart';
import 'package:taarak/features/map/presentation/widgets/taarak_map_view.dart';
import 'package:taarak/features/profile/application/location_status_controller.dart';
import 'package:taarak/shared/widgets/responsive.dart';
import 'package:taarak/shared/widgets/section_header.dart';
import 'package:taarak/shared/widgets/taarak_app_bar.dart';

const _uuid = Uuid();

/// A safe stand-in for a real SMS/network alert intake: an official pastes
/// bulletin text exactly as they'd have received it, confirms where it
/// applies on the map, and this runs it through the same
/// [GovernmentAlertParser] → [DisasterEvent] → [DisasterEventProcessor]
/// pipeline a real feed would use later — without asking for SMS
/// permissions or standing up any receiving infrastructure this round.
/// Nothing here is faked: the parser only surfaces fields it actually
/// found in the text (Rule 7/8/9), and the outcome shown after submit is
/// the processor's real result, not an assumed success.
class SimulateAlertScreen extends ConsumerStatefulWidget {
  const SimulateAlertScreen({super.key});

  @override
  ConsumerState<SimulateAlertScreen> createState() =>
      _SimulateAlertScreenState();
}

class _SimulateAlertScreenState extends ConsumerState<SimulateAlertScreen> {
  final _mapController = TaarakMapController();
  final _textController = TextEditingController();
  LatLng? _center;
  ParsedGovernmentAlert? _parsed;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _onTextChanged(String text) {
    final parser = ref.read(governmentAlertParserProvider);
    setState(() => _parsed = text.trim().isEmpty ? null : parser.parse(text));
  }

  @override
  Widget build(BuildContext context) {
    final userPoint = ref.watch(locationStatusProvider).valueOrNull?.geoTag;
    final fallbackCenter = userPoint == null
        ? defaultMapCenter
        : LatLng(userPoint.fix.latitude, userPoint.fix.longitude);
    final parsed = _parsed;

    return Scaffold(
      appBar: const TaarakAppBar(title: 'Simulate Government Alert'),
      body: ListView(
        children: [
          ContentWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  title: 'Paste the bulletin text',
                  icon: Icons.campaign_outlined,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                  child: Text(
                    'This is a safe intake path for testing — it does not '
                    'read real SMS. Paste the alert text exactly as '
                    'received; fields are only used if they\'re actually '
                    'found in the text.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                  child: TextField(
                    controller: _textController,
                    maxLines: 5,
                    onChanged: _onTextChanged,
                    decoration: const InputDecoration(
                      labelText: 'Alert text',
                      hintText:
                          'e.g. "Heavy rainfall warning: 180mm expected in '
                          '24 hours. Teesta river rising. NH-10 vulnerable."',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                if (parsed != null) ...[
                  const SizedBox(height: Spacing.sm),
                  Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: Spacing.md,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(Spacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Detected',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: Spacing.xs),
                          if (!parsed.hasAnyStructuredData)
                            const Text('Nothing recognizable in this text.'),
                          if (parsed.hazardType != null)
                            Text('Hazard type: ${parsed.hazardType!.name}'),
                          if (parsed.rainfall24hMm != null)
                            Text(
                              'Rainfall (24h): ${parsed.rainfall24hMm} mm',
                            ),
                          if (parsed.riverMentions.isNotEmpty)
                            Text(
                              'Rivers mentioned: '
                              '${parsed.riverMentions.join(', ')}',
                            ),
                          if (parsed.roadMentions.isNotEmpty)
                            Text(
                              'Roads mentioned: '
                              '${parsed.roadMentions.join(', ')}',
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: Spacing.md),
                const SectionHeader(
                  title: 'Confirm the location',
                  icon: Icons.place_outlined,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                  child: Text(
                    'The text alone is not trusted to guess a location — '
                    'tap the map where this alert applies.',
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
                                  markerId: const gmaps.MarkerId('alert'),
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                  child: FilledButton.icon(
                    onPressed: _canSubmit() && !_isSubmitting
                        ? _submit
                        : null,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send_outlined),
                    label: Text(
                      _center == null
                          ? 'Tap the map to confirm a location'
                          : 'Process alert',
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

  bool _canSubmit() =>
      _center != null &&
      (_parsed?.hazardType == DisasterEventType.landslide ||
          _parsed?.hazardType == DisasterEventType.riverRise);

  Future<void> _submit() async {
    final center = _center;
    final parsed = _parsed;
    final officialId = ref.read(currentUserProvider)?.id;
    if (center == null || parsed?.hazardType == null || officialId == null) {
      return;
    }

    setState(() => _isSubmitting = true);

    final event = DisasterEvent(
      id: _uuid.v4(),
      type: parsed!.hazardType!,
      source: 'simulated-alert:$officialId',
      timestamp: DateTime.now(),
      latitude: center.latitude,
      longitude: center.longitude,
      confidence: 0.6,
      payload: {'rawText': parsed.rawText},
      provenanceNote:
          'Entered via the alert-simulation screen, not a live feed.',
    );

    final outcome = await ref
        .read(disasterEventProcessorProvider)
        .process(event);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    final message = switch (outcome.status) {
      DisasterEventProcessingStatus.ingestedAsHazardZone =>
        'Hazard zone created from this alert.',
      DisasterEventProcessingStatus.notActionable =>
        outcome.detail ?? 'Not actionable.',
      DisasterEventProcessingStatus.rejected =>
        'Rejected: ${outcome.detail}',
    };

    if (outcome.status == DisasterEventProcessingStatus.ingestedAsHazardZone) {
      ref.invalidate(hazardZonesProvider);
      setState(() {
        _center = null;
        _textController.clear();
        _parsed = null;
      });
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
