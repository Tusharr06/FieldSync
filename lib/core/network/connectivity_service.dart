import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Service responsible for monitoring network connectivity status.
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  /// Stream of connectivity changes.
  /// Emits a list of [ConnectivityResult] whenever the connection state changes.
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;

  /// Checks the current connectivity status.
  Future<List<ConnectivityResult>> checkConnectivity() async {
    return await _connectivity.checkConnectivity();
  }

  /// Helper to determine if we are currently connected to any network.
  /// Returns the first result if multiple are present.
  /// Note: This does not guarantee internet access, only network connection.
  bool isConnected(List<ConnectivityResult> results) {
    return results.any((result) => result != ConnectivityResult.none);
  }
}

/// Provider for the ConnectivityService instance.
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

/// Stream provider for the current connectivity status.
final connectivityStatusProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.onConnectivityChanged;
});
