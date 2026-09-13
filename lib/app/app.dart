import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'routes.dart';
import 'theme/app_theme.dart';
import 'localization/app_localizations.dart';
import '../core/services/app_preferences.dart';

class FilePeekApp extends StatelessWidget {
  const FilePeekApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppPreferences>(
      builder: (context, preferences, _) {
        final languageCode = preferences.languageCode;

        final locale = Locale(languageCode);

        return MaterialApp.router(
          title: 'File Peek',
          debugShowCheckedModeBanner: false,

          locale: locale,

          supportedLocales: AppLocalizations.supportedLocales,

          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          theme: AppTheme.darkTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,

          routerConfig: AppRoutes.router,

          builder: (context, child) {
            ErrorWidget.builder = (FlutterErrorDetails details) {
              return MaterialApp(
                home: Scaffold(
                  backgroundColor: const Color(0xFF1E1E1E),
                  body: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.redAccent,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'An unexpected UI error occurred',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            details.exception.toString(),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            };

            return child ?? const SizedBox.shrink();
          },
        );
      },
    );
  }
}
