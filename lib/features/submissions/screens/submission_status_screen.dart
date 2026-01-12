import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controller/submission_controller.dart';
import '../../../core/sync/sync_engine.dart';
import '../models/submission_model.dart';

class SubmissionStatusScreen extends ConsumerStatefulWidget {
  const SubmissionStatusScreen({super.key});

  @override
  ConsumerState<SubmissionStatusScreen> createState() => _SubmissionStatusScreenState();
}

class _SubmissionStatusScreenState extends ConsumerState<SubmissionStatusScreen> {
  bool _isSyncing = false;

  Future<void> _handleSync() async {
    setState(() => _isSyncing = true);
    try {
      await ref.read(syncEngineProvider).syncData();
      ref.invalidate(submissionListProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sync completed successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sync failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final submissionsAsync = ref.watch(submissionListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Sync Status')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSyncing ? null : _handleSync,
        label: _isSyncing ? const Text('Syncing...') : const Text('Sync Now'),
        icon: _isSyncing 
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
            : const Icon(Icons.cloud_upload),
      ),
      body: submissionsAsync.when(
        data: (submissions) {
          if (submissions.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No submissions found.', style: TextStyle(color: Colors.grey, fontSize: 18)),
                ],
              ),
            );
          }
          final sorted = List.of(submissions)..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          
          return ListView.builder(
            itemCount: sorted.length,
            // Add padding at bottom for FAB
            padding: const EdgeInsets.only(bottom: 80), 
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
