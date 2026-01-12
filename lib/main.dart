import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/database/local_database.dart';
import 'core/sync/sync_engine.dart';
import 'core/routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final container = ProviderContainer();
  await container.read(localDatabaseProvider).init();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const FieldSyncApp(),
    ),
  );
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
    ref.read(syncEngineProvider).init();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FieldSync',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}
