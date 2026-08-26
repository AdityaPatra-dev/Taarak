import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taarak/core/error/failure.dart';
import 'package:taarak/core/repository/result.dart';
import 'package:taarak/features/state_admin/domain/app_policy.dart';

const _docPath = 'config/policy';

/// Same "talk to Firestore directly" pattern as
/// [[UserAdminDataSource]]/[[FirestoreSyncTransport]]'s account data —
/// app-wide configuration is small, always-online, read-by-everyone data,
/// not an offline-cacheable entity worth routing through M17's sync
/// pipeline.
class AppPolicyDataSource {
  final FirebaseFirestore _firestore;

  AppPolicyDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<Result<AppPolicy>> read() async {
    try {
      final snapshot = await _firestore.doc(_docPath).get();
      if (!snapshot.exists) return const Result.success(AppPolicy.defaults);
      return Result.success(AppPolicy.fromFirestore(snapshot.data()!));
    } catch (_) {
      // A missing/unreachable policy doc shouldn't ever block the
      // screens that read it — they fall back to sane defaults.
      return const Result.success(AppPolicy.defaults);
    }
  }

  Future<Result<void>> write(AppPolicy policy) async {
    try {
      await _firestore
          .doc(_docPath)
          .set(policy.toFirestore(), SetOptions(merge: true));
      return const Result.success(null);
    } catch (_) {
      return const Result.failure(NetworkFailure('Unable to save policy'));
    }
  }
}
