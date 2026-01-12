import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controller/submission_controller.dart';
import '../../forms/screens/form_fill_screen.dart';
import '../../forms/controller/form_controller.dart';
import '../../../core/sync/sync_engine.dart';
import '../models/submission_model.dart';
import 'submission_detail_screen.dart';

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
  
  void _onSubmissionTap(SubmissionModel submission) {
    if (submission.syncStatus == SyncStatus.draft) {
      final forms = ref.read(formListProvider);
      try {
        final form = forms.firstWhere((f) => f.id == submission.formId);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => FormFillScreen(form: form)), 
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Form definition not found for ${submission.formId}')),
        );
      }
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SubmissionDetailScreen(submission: submission)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final submissionsAsync = ref.watch(submissionListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Submissions')),
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
            return const Center(child: Text('No submissions found.'));
          }

          final drafts = submissions.where((s) => s.syncStatus == SyncStatus.draft).toList();
          final pending = submissions.where((s) => s.syncStatus == SyncStatus.pending).toList();
          final synced = submissions.where((s) => s.syncStatus == SyncStatus.synced).toList();
          final failed = submissions.where((s) => s.syncStatus == SyncStatus.failed).toList();

          return ListView(
            padding: const EdgeInsets.only(bottom: 80),
            children: [
              if (drafts.isNotEmpty) _buildSection('Drafts', drafts, Colors.grey),
              if (pending.isNotEmpty) _buildSection('Pending Upload', pending, Colors.orange),
              if (failed.isNotEmpty) _buildSection('Failed', failed, Colors.red),
              if (synced.isNotEmpty) _buildSection('Synced', synced, Colors.green),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildSection(String title, List<SubmissionModel> items, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        ...items.map((sub) => Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            title: Text('Form: ${sub.formId}'),
            subtitle: Text(sub.createdAt.toString().split('.')[0]),
            trailing: _StatusBadge(status: sub.syncStatus),
            onTap: () => _onSubmissionTap(sub),
          ),
        )),
      ],
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
      case SyncStatus.draft:
        color = Colors.grey;
        icon = Icons.edit_note;
        break;
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
