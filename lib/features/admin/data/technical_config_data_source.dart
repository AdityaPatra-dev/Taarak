import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taarak/core/error/failure.dart';
import 'package:taarak/core/repository/result.dart';
import 'package:taarak/features/admin/domain/technical_config.dart';

const _docPath = 'config/technical';

/// Same "talk to Firestore directly" pattern as [AppPolicyDataSource].
class TechnicalConfigDataSource {
  final FirebaseFirestore _firestore;

  TechnicalConfigDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<Result<TechnicalConfig>> read() async {
    try {
      final snapshot = await _firestore.doc(_docPath).get();
      if (!snapshot.exists) return const Result.success(TechnicalConfig.defaults);
      return Result.success(TechnicalConfig.fromFirestore(snapshot.data()!));
    } catch (_) {
      return const Result.success(TechnicalConfig.defaults);
    }
  }

  Future<Result<void>> write(TechnicalConfig config) async {
    try {
      await _firestore
          .doc(_docPath)
          .set(config.toFirestore(), SetOptions(merge: true));
      return const Result.success(null);
    } catch (_) {
      return const Result.failure(
        NetworkFailure('Unable to save technical configuration'),
      );
    }
  }
}
