import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/core/providers/core_providers.dart';
import 'package:taarak/features/risk/application/risk_assessment_service.dart';
import 'package:taarak/features/risk/domain/vulnerability_provider.dart';

final vulnerabilityProviderProvider = Provider<VulnerabilityProvider>(
  (ref) => const DefaultVulnerabilityProvider(),
);

final riskAssessmentServiceProvider = Provider<RiskAssessmentService>(
  (ref) => RiskAssessmentService(
    habitationRepository: ref.watch(localHabitationRepositoryProvider),
    hazardZoneRepository: ref.watch(localHazardZoneRepositoryProvider),
    assessmentRepository: ref.watch(localRiskAssessmentRepositoryProvider),
    vulnerabilityProvider: ref.watch(vulnerabilityProviderProvider),
  ),
);
