import 'package:flutter/material.dart';
import 'package:taarak/app/spacing.dart';
import 'package:taarak/core/gis/severity_palette.dart';
import 'package:taarak/features/risk/domain/risk_class.dart';
import 'package:taarak/features/risk/presentation/risk_class_color.dart';

/// Collapsed by default — the full legend has 13 rows across four
/// sections, and rendering it fully open on top of the map (its previous
/// behavior) covered nearly half the screen on a phone, a real bug the
/// UI audit's device QA pass caught. Tapping the chip expands it into a
/// height-capped, scrollable card instead.
class MapLegend extends StatefulWidget {
  const MapLegend({super.key});

  @override
  State<MapLegend> createState() => _MapLegendState();
}

class _MapLegendState extends State<MapLegend> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    if (!_expanded) {
      return Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => setState(() => _expanded = true),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline, size: 18),
                SizedBox(width: Spacing.xs),
                Text('Legend'),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 220,
          maxHeight: MediaQuery.sizeOf(context).height * 0.5,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Spacing.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Legend', style: Theme.of(context).textTheme.labelLarge),
                  InkWell(
                    onTap: () => setState(() => _expanded = false),
                    child: const Icon(Icons.close, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.xs),
              _swatchRow(severityColor('critical'), 'Critical hazard'),
              _swatchRow(severityColor('high'), 'High hazard'),
              _swatchRow(severityColor('medium'), 'Medium hazard'),
              _swatchRow(severityColor('low'), 'Low hazard'),
              const Divider(height: Spacing.md),
              _iconRow(Icons.home_filled, Colors.blue, 'Shelter'),
              _iconRow(Icons.warning_amber, Colors.red, 'Incident'),
              _iconRow(Icons.block, Colors.red, 'Blocked road'),
              const Divider(height: Spacing.md),
              for (final riskClass in RiskClass.values)
                _iconRow(
                  Icons.location_city,
                  riskClassColor(riskClass),
                  riskClassLabel(riskClass),
                ),
              const Divider(height: Spacing.md),
              _lineRow(Colors.green.shade700, 'Safe route'),
              _lineRow(Colors.orange.shade900, 'Route detours around a hazard'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _swatchRow(Color color, String label) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        Container(width: 14, height: 14, color: color),
        const SizedBox(width: Spacing.xs),
        Expanded(child: Text(label, style: Theme.of(context).textTheme.bodySmall)),
      ],
    ),
  );

  Widget _lineRow(Color color, String label) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        Container(width: 14, height: 3, color: color),
        const SizedBox(width: Spacing.xs),
        Expanded(child: Text(label, style: Theme.of(context).textTheme.bodySmall)),
      ],
    ),
  );

  Widget _iconRow(IconData icon, Color color, String label) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: Spacing.xs),
        Expanded(child: Text(label, style: Theme.of(context).textTheme.bodySmall)),
      ],
    ),
  );
}
