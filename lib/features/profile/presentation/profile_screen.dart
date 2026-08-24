import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/app/spacing.dart';
import 'package:taarak/core/location/location_permission_status.dart';
import 'package:taarak/features/auth/application/auth_controller.dart';
import 'package:taarak/features/auth/domain/user_role.dart';
import 'package:taarak/features/profile/application/location_status_controller.dart';
import 'package:taarak/shared/widgets/responsive.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isRefreshing = false;
  String? _errorMessage;

  Future<void> _refreshLocation() async {
    setState(() {
      _isRefreshing = true;
      _errorMessage = null;
    });
    final result = await ref.read(locationStatusProvider.notifier).refresh();
    if (!mounted) return;
    result.when(
      success: (_) {},
      failure: (failure) => setState(() => _errorMessage = failure.message),
    );
    setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final locationStatus = ref.watch(locationStatusProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        children: [
          ContentWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (user != null) ...[
                  Text(
                    user.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(user.email),
                  Text(user.role.label),
                  const SizedBox(height: Spacing.lg),
                ],
                Text(
                  'Location',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: Spacing.sm),
                locationStatus.when(
                  data: (status) => _LocationStatusView(status: status),
                  loading: () => const CircularProgressIndicator(),
                  error: (error, _) => Text('$error'),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: Spacing.sm),
                  Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: Spacing.md),
                FilledButton.icon(
                  onPressed: _isRefreshing ? null : _refreshLocation,
                  icon: _isRefreshing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location),
                  label: const Text('Refresh location'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationStatusView extends StatelessWidget {
  final LocationStatus status;

  const _LocationStatusView({required this.status});

  String get _permissionLabel => switch (status.permission) {
    LocationPermissionStatus.granted => 'Granted',
    LocationPermissionStatus.denied => 'Denied — tap Refresh to request',
    LocationPermissionStatus.deniedForever =>
      'Denied permanently — enable location for TAARAK in device settings',
    LocationPermissionStatus.serviceDisabled =>
      'Location services are turned off on this device',
  };

  @override
  Widget build(BuildContext context) {
    final geoTag = status.geoTag;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Permission: $_permissionLabel'),
        const SizedBox(height: 8),
        if (geoTag == null)
          const Text('No location captured yet.')
        else ...[
          Text(
            'Lat ${geoTag.fix.latitude.toStringAsFixed(5)}, '
            'Lng ${geoTag.fix.longitude.toStringAsFixed(5)} '
            '(±${geoTag.fix.accuracyMeters.toStringAsFixed(0)}m)',
          ),
          Text('Captured ${geoTag.fix.ageAsOf(DateTime.now()).inSeconds}s ago'),
          Text(
            geoTag.administrativeContext == null
                ? 'Administrative region: not available yet (needs GIS boundary data)'
                : 'Administrative region: ${geoTag.administrativeContext!.name}',
          ),
        ],
      ],
    );
  }
}
