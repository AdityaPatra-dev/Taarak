import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/features/alerts/application/alert_providers.dart';
import 'package:taarak/features/map/application/map_data_providers.dart';
import 'package:taarak/features/notifications/data/platform_notifier.dart';

final platformNotifierProvider = Provider<PlatformNotifier>(
  (ref) => createPlatformNotifier(),
);

/// Watched once from the app root, alongside the sync triggers: diffs
/// each new [alertHistoryProvider]/[incidentsProvider] snapshot against
/// the previous one and fires a local notification for anything that
/// wasn't there before. The first emission of each just establishes the
/// baseline — nothing already on the map/alerts list when the app opens
/// should notify, only what shows up afterward.
final notificationWatcherProvider = Provider.autoDispose<void>((ref) {
  final notifier = ref.watch(platformNotifierProvider);
  notifier.requestPermission();

  Set<String>? knownAlertIds;
  ref.listen<AsyncValue<List<LocalAlert>>>(alertHistoryProvider, (
    previous,
    next,
  ) {
    final alerts = next.valueOrNull;
    if (alerts == null) return;
    final ids = <String>{for (final alert in alerts) alert.id};

    final seen = knownAlertIds;
    if (seen == null) {
      knownAlertIds = ids;
      return;
    }
    for (final alert in alerts) {
      if (seen.contains(alert.id) || alert.cancelledAt != null) continue;
      notifier.show(title: 'New alert: ${alert.title}', body: alert.message);
    }
    knownAlertIds = ids;
  });

  Set<String>? knownIncidentIds;
  ref.listen(incidentsProvider, (previous, next) {
    final incidents = next.valueOrNull;
    if (incidents == null) return;
    final ids = {for (final incident in incidents) incident.id};

    final seen = knownIncidentIds;
    if (seen == null) {
      knownIncidentIds = ids;
      return;
    }
    for (final incident in incidents) {
      if (seen.contains(incident.id)) continue;
      notifier.show(
        title: 'New incident',
        body: incident.description.isEmpty
            ? incident.type
            : incident.description,
      );
    }
    knownIncidentIds = ids;
  });
});
