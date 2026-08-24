import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taarak/core/providers/core_providers.dart';
import 'package:taarak/features/risk/application/risk_assessment_service.dart';
import 'package:taarak/features/risk/domain/vulnerability_provider.dart';
import 'package:taarak/features/vulnerability/application/real_vulnerability_provider.dart';
import 'package:taarak/features/vulnerability/application/vulnerability_providers.dart';

/// M08 (Vulnerability) now provides the real, factor-based index —
/// replacing the M07-era [[DefaultVulnerabilityProvider]] neutral stand-in.
final vulnerabilityProviderProvider = Provider<VulnerabilityProvider>(
  (ref) => RealVulnerabilityProvider(
    ref.watch(vulnerabilityAssessmentServiceProvider),
  ),
);

final riskAssessmentServiceProvider = Provider<RiskAssessmentService>(
  (ref) => RiskAssessmentService(
    habitationRepository: ref.watch(localHabitationRepositoryProvider),
    hazardZoneRepository: ref.watch(localHazardZoneRepositoryProvider),
    assessmentRepository: ref.watch(localRiskAssessmentRepositoryProvider),
    vulnerabilityProvider: ref.watch(vulnerabilityProviderProvider),
  ),
);
