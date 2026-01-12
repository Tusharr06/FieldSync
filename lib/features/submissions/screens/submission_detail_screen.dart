import 'package:flutter/material.dart';
import '../models/submission_model.dart';

class SubmissionDetailScreen extends StatelessWidget {
  final SubmissionModel submission;

  const SubmissionDetailScreen({super.key, required this.submission});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submission Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const Divider(height: 32),
            Expanded(
              child: ListView(
                children: [
                  ...submission.data.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text(entry.value.toString(), style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    Color statusColor;
    switch (submission.syncStatus) {
      case SyncStatus.draft: statusColor = Colors.grey; break;
      case SyncStatus.pending: statusColor = Colors.orange; break;
      case SyncStatus.synced: statusColor = Colors.green; break;
      case SyncStatus.failed: statusColor = Colors.red; break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor),
              ),
              child: Text(
                submission.syncStatus.name.toUpperCase(),
                style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
              ),
            ),
            const Spacer(),
            Text(submission.createdAt.toString().split('.')[0], style: const TextStyle(color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 16),
        Text('Form ID: ${submission.formId}', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text('ID: ${submission.id}', style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
