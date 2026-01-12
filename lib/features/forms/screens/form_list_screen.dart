import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../../core/network/connectivity_service.dart';
import '../controller/form_controller.dart';
import 'form_builder_screen.dart';
import 'form_detail_screen.dart';
import '../../submissions/screens/submission_status_screen.dart';

class FormListScreen extends ConsumerWidget {
  const FormListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formsAsync = ref.watch(formListProvider);
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
               ref.read(formControllerProvider).seedDebugForms();
               ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(content: Text('Sample data seeded! Refreshing...')),
               );
               ref.invalidate(formListProvider);
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const FormBuilderScreen()));
        },
        child: const Icon(Icons.add),
      ),
      body: formsAsync.when(
        data: (forms) {
          if (forms.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.description_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No forms available', style: TextStyle(color: Colors.grey, fontSize: 18)),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: forms.length,
            itemBuilder: (context, index) {
              final form = forms[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(form.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(form.description),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                       if (!form.isSynced)
                         const Padding(
                           padding: EdgeInsets.only(right: 8.0),
                           child: Icon(Icons.cloud_off, color: Colors.orange, size: 20),
                         ),
                       const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FormDetailScreen(form: form),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
