import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controller/submission_controller.dart';
import '../models/submission_model.dart';

class SubmissionScreen extends ConsumerWidget {
  const SubmissionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submissionsAsyncValue = ref.watch(submissionsListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Submissions')),
      body: submissionsAsyncValue.when(
        data: (submissions) {
            if (submissions.isEmpty) return const Center(child: Text("No submissions found"));
            
            return ListView.builder(
            itemCount: submissions.length,
            itemBuilder: (context, index) {
              final submission = submissions[index];
              return ListTile(
                title: Text('Submission: ${submission.id}'),
                subtitle: Text('Status: ${submission.status}'),
                trailing: Text(submission.timestamp.toString().split(' ')[0]),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(submissionControllerProvider.notifier).createSubmission(
            '1',
            {'dummy': 'data'},
          );
          ref.invalidate(submissionsListProvider);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
