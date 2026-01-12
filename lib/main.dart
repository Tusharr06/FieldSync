import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/database/local_database.dart';
import 'core/sync/sync_engine.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/forms/screens/form_list_screen.dart';
import 'features/submissions/screens/submission_screen.dart';
import 'features/sync_status/sync_status_screen.dart';

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
    return MaterialApp(
      title: 'FieldSync',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MainNavigationWrapper(),
    );
  }
}

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const LoginScreen(),
    const FormListScreen(),
    const SubmissionScreen(),
    const SyncStatusScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.login), label: 'Auth'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Forms'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Submissions'),
          BottomNavigationBarItem(icon: Icon(Icons.sync), label: 'Sync'),
        ],
      ),
    );
  }
}
