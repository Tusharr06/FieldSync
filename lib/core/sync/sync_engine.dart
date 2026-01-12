import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart' as connectivity_plus;
import '../network/connectivity_service.dart';

class SyncEngine {
  final Ref _ref;

  SyncEngine(this._ref);

  void init() {
    print('SyncEngine initialized');
    _ref.listen(connectivityStatusProvider, (previous, next) {
        next.whenData((results) {
           final isConnected = !results.contains(connectivity_plus.ConnectivityResult.none);
           if (isConnected) {
             syncData();
           }
        });
    });
  }

  Future<void> syncData() async {
    print('Starting data synchronization...');
    await Future.delayed(const Duration(seconds: 2));
    print('Data synchronization complete.');
  }
}

final syncEngineProvider = Provider<SyncEngine>((ref) {
  return SyncEngine(ref);
});
