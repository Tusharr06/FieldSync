import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controller/submission_controller.dart';
import '../../../core/sync/sync_engine.dart';
import '../models/submission_model.dart';

class SubmissionStatusScreen extends ConsumerWidget {
  const SubmissionStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submissionsAsync = ref.watch(submissionListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Sync Status')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Syncing...')));
            await ref.read(syncEngineProvider).syncData();
            ref.invalidate(submissionListProvider);
        },
        label: const Text('Sync Now'),
        icon: const Icon(Icons.cloud_upload),
      ),
      body: submissionsAsync.when(
        data: (submissions) {
          if (submissions.isEmpty) {
            return const Center(child: Text('No submissions found.'));
          }
          final sorted = List.of(submissions)..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          
          return ListView.builder(
            itemCount: sorted.length,
            itemBuilder: (context, index) {
              final sub = sorted[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  title: Text('Form: ${sub.formId}'),
                  subtitle: Text(sub.createdAt.toString().split('.')[0]),
                  trailing: _StatusBadge(status: sub.syncStatus),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error loading submissions: $e')),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final SyncStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    switch (status) {
      case SyncStatus.pending:
        color = Colors.orange;
        icon = Icons.hourglass_empty;
        break;
      case SyncStatus.synced:
        color = Colors.green;
        icon = Icons.check;
        break;
      case SyncStatus.failed:
        color = Colors.red;
        icon = Icons.error_outline;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            status.name.toUpperCase(), 
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)
          ),
        ],
      ),
    );
  }
}
