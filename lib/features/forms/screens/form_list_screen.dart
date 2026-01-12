import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controller/form_controller.dart';
import '../models/form_model.dart';

class FormListScreen extends ConsumerWidget {
  const FormListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formsAsyncValue = ref.watch(formsListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Available Forms')),
      body: formsAsyncValue.when(
        data: (forms) {
          if (forms.isEmpty) {
            return const Center(child: Text('No forms available.'));
          }
          return ListView.builder(
            itemCount: forms.length,
            itemBuilder: (context, index) {
              final form = forms[index];
              return _FormListItem(form: form);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _FormListItem extends StatelessWidget {
  final FormModel form;
  const _FormListItem({required this.form});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(form.title),
        subtitle: Text(form.description),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Selected form: ${form.title}')),
          );
        },
      ),
    );
  }
}
