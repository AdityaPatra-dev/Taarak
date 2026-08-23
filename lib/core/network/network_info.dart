import 'package:connectivity_plus/connectivity_plus.dart';

/// Tells the rest of the app whether it currently has connectivity, so
/// features can decide between connected and offline-mode behavior
/// (see blueprint section 2).
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity;

  NetworkInfoImpl({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  @override
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return results.any((result) => result != ConnectivityResult.none);
  }
}
