import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../models/form_model.dart';
import '../controller/form_controller.dart';
import '../../submissions/controller/submission_controller.dart';
import '../../../core/export/excel_export_service.dart';
import 'form_fill_screen.dart';

class FormDetailScreen extends ConsumerStatefulWidget {
  final FormModel form;
  const FormDetailScreen({super.key, required this.form});

  @override
  ConsumerState<FormDetailScreen> createState() => _FormDetailScreenState();
}

class _FormDetailScreenState extends ConsumerState<FormDetailScreen> {
  bool _isExporting = false;

  Future<void> _exportData() async {
    setState(() => _isExporting = true);
    
    try {
      
      final allSubmissions = await ref.read(submissionListProvider.future);
      final formSubmissions = allSubmissions.where((s) => s.formId == widget.form.id).toList();

      if (formSubmissions.isEmpty) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('No submissions to export.')),
           );
        }
        return;
      }

      
      final filePath = await ref.read(excelExportServiceProvider).exportFormSubmissions(widget.form, formSubmissions);

      
      await Share.shareXFiles([XFile(filePath)], text: 'Export for ${widget.form.title}');
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    
    final submissionsAsync = ref.watch(submissionListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.form.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Delete Form',
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Confirm Delete'),
                    content: Text('Are you sure you want to delete "${widget.form.title}"? This will also delete all submissions for this form.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Delete'),
                      ),
                    ],
                  );
                },
              );
              
              if (confirmed == true && mounted) {
                await ref.read(formControllerProvider).deleteForm(widget.form.id);
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${widget.form.title} deleted')),
                  );
                }
              }
            },
          ),
          IconButton(
            icon: _isExporting 
             ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
             : const Icon(Icons.download),
            tooltip: 'Export to Excel',
            onPressed: _isExporting ? null : _exportData,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.form.description, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 24),
            
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Submissions', style: TextStyle(fontWeight: FontWeight.bold)),
                    submissionsAsync.when(
                      data: (list) {
                        final count = list.where((s) => s.formId == widget.form.id).length;
                        return Text(count.toString(), style: Theme.of(context).textTheme.headlineSmall);
                      },
                      loading: () => const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                      error: (_, __) => const Text('?'),
                    ),
                  ],
                ),
              ),
            ),
            
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => FormFillScreen(form: widget.form)),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Collect Data'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
