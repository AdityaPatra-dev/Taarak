import 'package:flutter/material.dart';
import 'package:taarak/core/gis/severity_palette.dart';
import 'package:taarak/features/risk/domain/risk_class.dart';
import 'package:taarak/features/risk/presentation/risk_class_color.dart';

class MapLegend extends StatelessWidget {
  const MapLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Legend', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            _swatchRow(severityColor('critical'), 'Critical hazard'),
            _swatchRow(severityColor('high'), 'High hazard'),
            _swatchRow(severityColor('medium'), 'Medium hazard'),
            _swatchRow(severityColor('low'), 'Low hazard'),
            const Divider(height: 12),
            _iconRow(Icons.home_filled, Colors.blue, 'Shelter'),
            _iconRow(Icons.warning_amber, Colors.red, 'Incident'),
            _iconRow(Icons.block, Colors.red, 'Blocked road'),
            const Divider(height: 12),
            for (final riskClass in RiskClass.values)
              _iconRow(
                Icons.location_city,
                riskClassColor(riskClass),
                riskClassLabel(riskClass),
              ),
            const Divider(height: 12),
            _lineRow(Colors.green.shade700, 'Safe route'),
            _lineRow(Colors.orange.shade900, 'Route detours around a hazard'),
          ],
        ),
      ),
    );
  }

  Widget _swatchRow(Color color, String label) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        Container(width: 14, height: 14, color: color),
        const SizedBox(width: 8),
        Text(label),
      ],
    ),
  );

  Widget _lineRow(Color color, String label) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        Container(width: 14, height: 3, color: color),
        const SizedBox(width: 8),
        Text(label),
      ],
    ),
  );

  Widget _iconRow(IconData icon, Color color, String label) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(label),
      ],
    ),
  );
}
