import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/explorer/screens/explorer_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/structure_import/screens/structure_import_screen.dart';

class AppRoutes {
  static const String explorer = '/';
  static const String settings = '/settings';
  static const String structureImport = '/structure-import';

  static final GoRouter router = GoRouter(
    initialLocation: explorer,
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Route not found: ${state.uri}',
              style: const TextStyle(color: Colors.red, fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(explorer),
              child: const Text('Back to Explorer'),
            ),
          ],
        ),
      ),
    ),
    routes: [
      GoRoute(
        path: explorer,
        name: 'explorer',
        builder: (context, state) => const ExplorerScreen(),
      ),
      GoRoute(
        path: settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: structureImport,
        name: 'structure-import',
        builder: (context, state) => const StructureImportScreen(),
      ),
    ],
  );
}
