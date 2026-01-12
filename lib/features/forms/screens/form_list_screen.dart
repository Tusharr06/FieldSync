import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../../core/network/connectivity_service.dart';
import '../controller/form_controller.dart';
import 'form_fill_screen.dart';
import '../../submissions/screens/submission_status_screen.dart';

class FormListScreen extends ConsumerWidget {
  const FormListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forms = ref.watch(formListProvider);
    final connectivityAsync = ref.watch(connectivityStatusProvider);
    
    final isOffline = connectivityAsync.maybeWhen(
      data: (results) => results.every((r) => r == ConnectivityResult.none),
      orElse: () => false,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('FieldSync: Forms'),
        actions: [
          if (isOffline)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Chip(
                label: Text('Offline', style: TextStyle(color: Colors.white)),
                backgroundColor: Colors.grey,
                side: BorderSide.none,
              ),
            ),
          IconButton(
            icon: const Icon(Icons.bug_report),
            tooltip: 'Seed Sample Data',
            onPressed: () {
               ref.read(formControllerProvider).submitForm('debug_form', {
                 'sample_field': 'Hello Firestore',
                 'timestamp': DateTime.now().toIso8601String(),
               });
               ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(content: Text('Sample data seeded! Go to Status -> Sync.')),
               );
            },
          ),
          IconButton(
            icon: const Icon(Icons.sync_alt),
            tooltip: 'Sync Status',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SubmissionStatusScreen()),
              );
            },
          )
        ],
      ),
      body: forms.isEmpty 
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.description_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No forms available', style: TextStyle(color: Colors.grey, fontSize: 18)),
              ],
            ),
          )
        : ListView.builder(
        itemCount: forms.length,
        itemBuilder: (context, index) {
          final form = forms[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(form.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(form.description),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FormFillScreen(form: form),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
