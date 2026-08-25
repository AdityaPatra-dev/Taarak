import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/app/spacing.dart';
import 'package:taarak/core/database/app_database.dart';
import 'package:taarak/features/audit/application/audit_log_filter.dart';
import 'package:taarak/features/audit/application/audit_providers.dart';
import 'package:taarak/shared/widgets/async_state_views.dart';
import 'package:taarak/shared/widgets/responsive.dart';
import 'package:taarak/shared/widgets/taarak_app_bar.dart';

/// M19: a System Admin's ([Permission.reviewAudit]) view into every
/// critical change recorded by [AuditLogDao] — actor, action, object,
/// time, old/new value and reason, exactly the fields the spec names,
/// shown per row rather than requiring a tap to reveal them. Every write
/// this app makes to it (M13 incident lifecycle, M15 shelter management,
/// M16 alert broadcasts, and whatever future module adds its own) shows
/// up here without this screen needing to know about that module.
class AuditLogScreen extends ConsumerStatefulWidget {
  const AuditLogScreen({super.key});

  @override
  ConsumerState<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends ConsumerState<AuditLogScreen> {
  String? _objectTypeFilter;
  final _queryController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(auditEventsProvider);

    return Scaffold(
      appBar: TaarakAppBar(
        title: 'Audit Log',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(auditEventsProvider),
          ),
        ],
      ),
      body: eventsAsync.when(
        loading: () => const LoadingView(message: 'Loading the audit log…'),
        error: (error, _) => ErrorView(
          message: 'Could not load the audit log: $error',
          onRetry: () => ref.invalidate(auditEventsProvider),
        ),
        data: (events) {
          final objectTypes = events.map((e) => e.objectType).toSet().toList()
            ..sort();
          final filtered = filterAuditEvents(
            events,
            objectType: _objectTypeFilter,
            query: _query,
          );

          return Column(
            children: [
              ContentWidth(
                maxWidth: 900,
                padding: const EdgeInsets.fromLTRB(
                  Spacing.md,
                  Spacing.md,
                  Spacing.md,
                  0,
                ),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(Spacing.sm),
                    child: Column(
                      children: [
                        TextField(
                          controller: _queryController,
                          decoration: const InputDecoration(
                            labelText: 'Search actor, action, object, reason',
                            prefixIcon: Icon(Icons.search),
                          ),
                          onChanged: (value) => setState(() => _query = value),
                        ),
                        const SizedBox(height: Spacing.sm),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Wrap(
                            spacing: Spacing.sm,
                            children: [
                              ChoiceChip(
                                label: const Text('All'),
                                selected: _objectTypeFilter == null,
                                onSelected: (_) =>
                                    setState(() => _objectTypeFilter = null),
                              ),
                              for (final type in objectTypes)
                                ChoiceChip(
                                  label: Text(type),
                                  selected: _objectTypeFilter == type,
                                  onSelected: (_) =>
                                      setState(() => _objectTypeFilter = type),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Spacing.sm),
              Expanded(
                child: filtered.isEmpty
                    ? const EmptyView(
                        icon: Icons.manage_search,
                        title: 'No matching audit events',
                        message: 'Try a different search term or filter.',
                      )
                    : ListView(
                        children: [
                          ContentWidth(
                            maxWidth: 900,
                            padding: const EdgeInsets.all(Spacing.md),
                            child: Column(
                              children: [
                                for (final event in filtered)
                                  _AuditEventCard(event: event),
                              ],
                            ),
                          ),
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

class _AuditEventCard extends StatelessWidget {
  final LocalAuditEvent event;

  const _AuditEventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bolt, size: 16, color: scheme.primary),
                const SizedBox(width: Spacing.xs),
                Expanded(
                  child: Text(event.action, style: textTheme.titleSmall),
                ),
                Text(
                  '${event.occurredAt.toLocal()}'.split('.').first,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.xs),
            Wrap(
              spacing: Spacing.xs,
              runSpacing: 4,
              children: [
                Chip(
                  visualDensity: VisualDensity.compact,
                  avatar: const Icon(Icons.person_outline, size: 14),
                  label: Text(event.actorId),
                ),
                Chip(
                  visualDensity: VisualDensity.compact,
                  avatar: const Icon(Icons.category_outlined, size: 14),
                  label: Text('${event.objectType} · ${event.objectId}'),
                ),
              ],
            ),
            if (event.reason != null) ...[
              const SizedBox(height: Spacing.xs),
              Text('Reason: ${event.reason}', style: textTheme.bodySmall),
            ],
            if (event.oldValue != null || event.newValue != null) ...[
              const SizedBox(height: Spacing.xs),
              Container(
                padding: const EdgeInsets.all(Spacing.sm),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (event.oldValue != null)
                      Text(
                        'Before: ${event.oldValue}',
                        style: textTheme.bodySmall,
                      ),
                    if (event.newValue != null)
                      Text(
                        'After: ${event.newValue}',
                        style: textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
