import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/database/local_database.dart';
import 'core/sync/sync_engine.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ProviderScope(child: FieldSyncApp()));
}

class FieldSyncApp extends ConsumerStatefulWidget {
  const FieldSyncApp({super.key});

  @override
  ConsumerState<FieldSyncApp> createState() => _FieldSyncAppState();
}

class _FieldSyncAppState extends ConsumerState<FieldSyncApp> {

  @override
  void initState() {
    super.initState();
    ref.read(localDatabaseProvider).init();
    ref.read(syncEngineProvider).init();
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'FieldSync',
      home: Scaffold(
        body: Center(
          child: Text('FieldSync Core Logic - Headless Mode\nCheck console for logs.'),
        ),
      ),
    );
  }
}

