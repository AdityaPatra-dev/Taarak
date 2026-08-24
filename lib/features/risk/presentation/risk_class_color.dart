import 'package:flutter/material.dart';
import 'package:taarak/features/risk/domain/risk_class.dart';

Color riskClassColor(RiskClass riskClass) => switch (riskClass) {
  RiskClass.low => Colors.green.shade600,
  RiskClass.moderate => Colors.yellow.shade800,
  RiskClass.high => Colors.orange.shade700,
  RiskClass.red => Colors.red.shade900,
};

String riskClassLabel(RiskClass riskClass) => switch (riskClass) {
  RiskClass.low => 'Low risk',
  RiskClass.moderate => 'Moderate risk',
  RiskClass.high => 'High risk',
  RiskClass.red => 'Red zone',
};
