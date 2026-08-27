import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taarak/core/error/failure.dart';
import 'package:taarak/core/repository/result.dart';
import 'package:taarak/features/admin/domain/role_permission_overrides.dart';

const _docPath = 'config/role_permissions';

/// Same "talk to Firestore directly" pattern as [AppPolicyDataSource] —
/// small, always-online, read-by-everyone configuration, not an
/// offline-cacheable entity worth routing through M17's sync pipeline.
class RolePermissionOverridesDataSource {
  final FirebaseFirestore _firestore;

  RolePermissionOverridesDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<Result<RolePermissionOverrides>> read() async {
    try {
      final snapshot = await _firestore.doc(_docPath).get();
      if (!snapshot.exists) {
        return const Result.success(RolePermissionOverrides.empty);
      }
      return Result.success(
        RolePermissionOverrides.fromFirestore(snapshot.data()!),
      );
    } catch (_) {
      // A missing/unreachable override doc shouldn't ever block routing —
      // every screen that reads this falls back to each role's hardcoded
      // defaults, exactly as if no admin had ever touched this screen.
      return const Result.success(RolePermissionOverrides.empty);
    }
  }

  Future<Result<void>> write(RolePermissionOverrides overrides) async {
    try {
      await _firestore
          .doc(_docPath)
          .set(overrides.toFirestore());
      return const Result.success(null);
    } catch (_) {
      return const Result.failure(
        NetworkFailure('Unable to save permission overrides'),
      );
    }
  }
}
