import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const _channelId = 'taarak_alerts';

/// Client-only local notifications — shown while the app is
/// open/backgrounded, not when fully closed (no server push, no Cloud
/// Functions/billing needed). `flutter_local_notifications` covers both
/// Android and web through one API despite that pairing looking unusual —
/// its web companion package wraps the browser's own Notification API
/// behind the same `show`/`requestNotificationsPermission` calls Android
/// uses, so this class doesn't need to special-case platforms itself.
class PlatformNotifier {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  var _nextId = 0;

  Future<bool> _ensureInitialized() async {
    if (_initialized) return true;
    try {
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/launcher_icon'),
          web: WebInitializationSettings(),
        ),
      );
      _initialized = true;
      return true;
    } catch (_) {
      // No platform channel available (e.g. running under flutter_test,
      // or a platform this plugin doesn't cover) — notifications are a
      // best-effort convenience, never worth crashing over.
      return false;
    }
  }

  Future<void> requestPermission() async {
    if (!await _ensureInitialized()) return;
    try {
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
      await _plugin
          .resolvePlatformSpecificImplementation<
            WebFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    } catch (_) {
      // Ignored — see _ensureInitialized.
    }
  }

  Future<void> show({required String title, required String body}) async {
    if (!await _ensureInitialized()) return;
    try {
      await _plugin.show(
        id: _nextId++,
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            'TAARAK Alerts',
            channelDescription: 'New broadcast alerts and incidents',
            importance: Importance.high,
            priority: Priority.high,
          ),
          web: WebNotificationDetails(),
        ),
      );
    } catch (_) {
      // Ignored — see _ensureInitialized.
    }
  }
}

PlatformNotifier createPlatformNotifier() => PlatformNotifier();
