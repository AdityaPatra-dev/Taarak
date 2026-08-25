import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/app/spacing.dart';
import 'package:taarak/core/location/location_permission_status.dart';
import 'package:taarak/features/auth/application/auth_controller.dart';
import 'package:taarak/features/auth/domain/user_role.dart';
import 'package:taarak/features/profile/application/location_status_controller.dart';
import 'package:taarak/shared/widgets/responsive.dart';
import 'package:taarak/shared/widgets/section_header.dart';

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
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        children: [
          ContentWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (user != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(Spacing.md),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: scheme.primary,
                          child: Text(
                            user.name.isNotEmpty
                                ? user.name[0].toUpperCase()
                                : '?',
                            style: textTheme.headlineSmall?.copyWith(
                              color: scheme.onPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: Spacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                style: textTheme.titleLarge?.copyWith(
                                  color: scheme.onPrimaryContainer,
                                ),
                              ),
                              Text(
                                user.email,
                                style: textTheme.bodySmall?.copyWith(
                                  color: scheme.onPrimaryContainer,
                                ),
                              ),
                              const SizedBox(height: Spacing.xs),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: Spacing.sm,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: scheme.primary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  user.role.label,
                                  style: textTheme.labelMedium?.copyWith(
                                    color: scheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: Spacing.lg),
                const SectionHeader(
                  title: 'Location',
                  icon: Icons.my_location_outlined,
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(Spacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        locationStatus.when(
                          data: (status) => _LocationStatusView(status: status),
                          loading: () => const Padding(
                            padding: EdgeInsets.symmetric(vertical: Spacing.sm),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          error: (error, _) => Text('$error'),
                        ),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: Spacing.sm),
                          Text(
                            _errorMessage!,
                            style: TextStyle(color: scheme.error),
                          ),
                        ],
                        const SizedBox(height: Spacing.md),
                        FilledButton.icon(
                          onPressed: _isRefreshing ? null : _refreshLocation,
                          icon: _isRefreshing
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.my_location),
                          label: const Text('Refresh location'),
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

  IconData get _permissionIcon => switch (status.permission) {
    LocationPermissionStatus.granted => Icons.check_circle,
    _ => Icons.error_outline,
  };

  @override
  Widget build(BuildContext context) {
    final geoTag = status.geoTag;
    final scheme = Theme.of(context).colorScheme;
    final granted = status.permission == LocationPermissionStatus.granted;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              _permissionIcon,
              size: 18,
              color: granted ? Colors.green.shade600 : scheme.error,
            ),
            const SizedBox(width: Spacing.xs),
            Expanded(child: Text(_permissionLabel)),
          ],
        ),
        if (geoTag == null) ...[
          const SizedBox(height: Spacing.xs),
          Text(
            'No location captured yet.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ] else ...[
          const Divider(height: Spacing.lg),
          Text(
            'Lat ${geoTag.fix.latitude.toStringAsFixed(5)}, '
            'Lng ${geoTag.fix.longitude.toStringAsFixed(5)} '
            '(±${geoTag.fix.accuracyMeters.toStringAsFixed(0)}m)',
          ),
          const SizedBox(height: 4),
          Text('Captured ${geoTag.fix.ageAsOf(DateTime.now()).inSeconds}s ago'),
          const SizedBox(height: 4),
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
