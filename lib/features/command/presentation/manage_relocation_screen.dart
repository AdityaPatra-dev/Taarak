import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taarak/app/spacing.dart';
import 'package:taarak/core/repository/result.dart';
import 'package:taarak/features/map/application/map_data_providers.dart';
import 'package:taarak/features/map/domain/habitation_overview.dart';
import 'package:taarak/features/routing/application/routing_providers.dart';
import 'package:taarak/features/routing/domain/route_candidate.dart';
import 'package:taarak/shared/widgets/async_state_views.dart';
import 'package:taarak/shared/widgets/responsive.dart';
import 'package:taarak/shared/widgets/taarak_app_bar.dart';

/// District/Command's ([Permission.manageRelocation]) trigger screen —
/// M10's `RelocationPlanningService` already computes ranked candidates
/// for every habitation that needs relocating; this is the missing "act
/// on it" step, generating a real routed evacuation path via the same
/// `RoutingService.planEvacuationRoute` a Field Responder's navigate
/// button uses.
class ManageRelocationScreen extends ConsumerWidget {
  const ManageRelocationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitationsAsync = ref.watch(habitationsOverviewProvider);

    return Scaffold(
      appBar: const TaarakAppBar(title: 'Manage Relocation'),
      body: habitationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const ErrorView(message: 'Unable to load habitations'),
        data: (habitations) {
          final needingRelocation = habitations
              .where((h) => (h.relocationPlan?.populationToRelocate ?? 0) > 0)
              .toList();
          if (needingRelocation.isEmpty) {
            return const EmptyView(
              icon: Icons.moving_outlined,
              title: 'No habitations currently need relocation',
            );
          }
          return ListView(
            padding: const EdgeInsets.all(Spacing.md),
            children: [
              ContentWidth(
                child: Column(
                  children: [
                    for (final item in needingRelocation)
                      _RelocationCard(item: item),
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

class _RelocationCard extends ConsumerWidget {
  final HabitationOverview item;

  const _RelocationCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = item.relocationPlan!;
    final candidates = jsonDecode(plan.rankedCandidatesJson) as List;
    final top = candidates.isEmpty
        ? null
        : candidates.first as Map<String, dynamic>;

    return Card(
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.habitation.name,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text('${plan.populationToRelocate} people to relocate'),
            if (top != null)
              Text(
                'Best candidate: ${top['shelterName']} '
                '(${((top['distanceMeters'] as num) / 1000).toStringAsFixed(1)} km)',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            const SizedBox(height: Spacing.sm),
            OutlinedButton.icon(
              onPressed: top == null
                  ? null
                  : () => _confirmRelocation(context, ref),
              icon: const Icon(Icons.alt_route_outlined),
              label: const Text('Confirm relocation & route'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmRelocation(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final result = await ref
        .read(routingServiceProvider)
        .planEvacuationRoute(item.habitation.id);

    switch (result) {
      case Success<RoutePlan>():
        ref.invalidate(routesProvider);
        if (context.mounted) context.push('/map');
      case Failed<RoutePlan>(:final failure):
        messenger.showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }
}
