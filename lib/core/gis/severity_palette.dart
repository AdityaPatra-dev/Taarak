import 'package:flutter/material.dart';

/// Consistent hazard/incident severity → color mapping, shared by the map
/// legend/layers here and, later, M07's risk engine displays and M18's
/// command dashboard — one place to keep them visually in sync.
Color severityColor(String severity) => switch (severity.toLowerCase()) {
  'critical' => Colors.purple.shade700,
  'high' => Colors.red.shade600,
  'medium' => Colors.orange.shade600,
  'low' => Colors.amber.shade600,
  _ => Colors.grey.shade600,
};
