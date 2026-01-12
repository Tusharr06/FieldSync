import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart' as connectivity_plus;
import '../../core/network/connectivity_service.dart';

class SyncStatusScreen extends ConsumerWidget {
  const SyncStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityAsync = ref.watch(connectivityStatusProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Sync Status')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sync, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            const Text('Sync Status Dashboard', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 32),
            connectivityAsync.when(
              data: (results) {
                 final isConnected = !results.contains(connectivity_plus.ConnectivityResult.none);
                 return Text(
                  isConnected ? 'Online' : 'Offline',
                  style: TextStyle(
                    color: isConnected ? Colors.green : Colors.red,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (err, stack) => Text('Error: $err'),
            ),
             const SizedBox(height: 16),
             const Text('Last Sync: Never'),
             const SizedBox(height: 16),
             ElevatedButton(
               onPressed: () {
                 ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(content: Text('Manual sync triggered')),
                 );
               },
               child: const Text('Sync Now'),
             ),
          ],
        ),
      ),
    );
  }
}
