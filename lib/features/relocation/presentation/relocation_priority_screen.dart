import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/app/spacing.dart';
import 'package:taarak/features/relocation/application/relocation_priority_providers.dart';
import 'package:taarak/features/relocation/domain/relocation_priority_result.dart';
import 'package:taarak/features/relocation/domain/relocation_priority_tier.dart';
import 'package:taarak/shared/widgets/async_state_views.dart';
import 'package:taarak/shared/widgets/responsive.dart';
import 'package:taarak/shared/widgets/severity_chip.dart';
import 'package:taarak/shared/widgets/taarak_app_bar.dart';

/// The PS's own question, answered directly: not "how risky is this
/// habitation" but "which habitations should be prioritized for
/// relocation, first." A ranked queue over [RelocationPriorityResult] —
/// see [RelocationPriorityEngine] for how each entry's score and tier are
/// actually computed, and why.
class RelocationPriorityScreen extends ConsumerWidget {
  const RelocationPriorityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueAsync = ref.watch(relocationPriorityQueueProvider);

    return Scaffold(
      appBar: TaarakAppBar(
        title: 'Relocation Priority',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recompute',
            onPressed: () => ref.invalidate(relocationPriorityQueueProvider),
          ),
        ],
      ),
      body: queueAsync.when(
        loading: () => const LoadingView(
          message: 'Assessing risk, capacity and relocation options…',
        ),
        error: (error, _) => ErrorView(
          message: 'Could not build the priority queue: $error',
          onRetry: () => ref.invalidate(relocationPriorityQueueProvider),
        ),
        data: (queue) => queue.isEmpty
            ? const EmptyView(
                icon: Icons.holiday_village_outlined,
                title: 'No habitations to prioritize',
                message: 'Register a habitation first.',
              )
            : RefreshIndicator(
                onRefresh: () async =>
                    ref.invalidate(relocationPriorityQueueProvider),
                child: ListView(
                  padding: const EdgeInsets.all(Spacing.md),
                  children: [
                    ContentWidth(
                      child: Column(
                        children: [
                          for (var i = 0; i < queue.length; i++)
                            _PriorityCard(rank: i + 1, result: queue[i]),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

Color _tierColor(RelocationPriorityTier tier) => switch (tier) {
  RelocationPriorityTier.immediate => const Color(0xFFB3261E),
  RelocationPriorityTier.shortTerm => const Color(0xFFB4540A),
  RelocationPriorityTier.mediumTerm => const Color(0xFF8C7A1A),
  RelocationPriorityTier.monitor => const Color(0xFF3F7A4D),
};

class _PriorityCard extends StatelessWidget {
  final int rank;
  final RelocationPriorityResult result;

  const _PriorityCard({required this.rank, required this.result});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tierColor = _tierColor(result.priorityTier);

    return Card(
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      child: InkWell(
        onTap: () => _showReasoning(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(Spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: scheme.primaryContainer,
                    child: Text(
                      '$rank',
                      style: TextStyle(
                        color: scheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Text(
                      result.habitationName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  StatusPill(label: result.priorityTier.label, color: tierColor),
                ],
              ),
              const SizedBox(height: Spacing.sm),
              Wrap(
                spacing: Spacing.md,
                runSpacing: 4,
                children: [
                  _Stat(
                    label: 'Risk',
                    value: '${(result.riskScore * 100).round()}',
                  ),
                  _Stat(
                    label: 'Population exposed',
                    value: '${result.populationExposed}',
                  ),
                  _Stat(
                    label: 'Shelter deficit',
                    value: result.capacityGap > 0
                        ? '${result.capacityGap}'
                        : 'None',
                  ),
                  _Stat(
                    label: 'Nearest safe shelter',
                    value: result.distanceToShelterMeters == null
                        ? 'None found'
                        : '${(result.distanceToShelterMeters! / 1000).toStringAsFixed(1)} km',
                  ),
                ],
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                'Recommended: ${result.recommendedAction}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 2),
              Text(
                'Tap to see why this habitation is prioritized',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReasoning(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(result.habitationName),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final reason in result.reasoning)
                Padding(
                  padding: const EdgeInsets.only(bottom: Spacing.xs),
                  child: Text('• $reason'),
                ),
              const SizedBox(height: Spacing.sm),
              Text(
                'Priority score ${(result.priorityScore * 100).round()}/100 · '
                'model ${result.modelVersion}',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;

  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodySmall,
        children: [
          TextSpan(
            text: '$label: ',
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
