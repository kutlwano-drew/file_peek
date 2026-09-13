import 'dart:ffi' hide Size;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:media_kit/media_kit.dart';

import 'app/routes.dart';
import 'app/theme/app_theme.dart';
import 'app/localization/app_localizations.dart';
import 'core/services/app_preferences.dart';
import 'core/widgets/app_dialogs.dart';

void _applyLinuxLocaleFix() {
  if (Platform.isLinux) {
    try {
      final ffi = DynamicLibrary.process();
      final setlocale = ffi.lookupFunction<
          Pointer Function(Int32 category, Pointer locale),
          Pointer Function(int category, Pointer locale)>('setlocale');
      setlocale(15, nullptr);
    } catch (_) {}
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _applyLinuxLocaleFix();

  MediaKit.ensureInitialized();

  await windowManager.ensureInitialized();

  final prefs = AppPreferences();
  await prefs.load();

  const options = WindowOptions(
    center: true,
    minimumSize: Size(720, 480),
  );

  await windowManager.waitUntilReadyToShow(
    options,
    () async {
      await windowManager.setPreventClose(true);
      await windowManager.show();
      await windowManager.focus();

      // Normal maximized desktop window.
      await windowManager.maximize();
    },
  );

  runApp(
    ChangeNotifierProvider.value(
      value: prefs,
      child: const FilePeekApp(),
    ),
  );
}

class FilePeekApp extends StatefulWidget {
  const FilePeekApp({
    super.key,
  });

  @override
  State<FilePeekApp> createState() => _FilePeekAppState();
}

class _FilePeekAppState extends State<FilePeekApp>
    with WindowListener {
  @override
  void initState() {
    super.initState();

    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);

    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // WINDOW CLOSE
  // ---------------------------------------------------------------------------

  @override
  void onWindowClose() async {
    if (!mounted) {
      return;
    }

    final shouldClose = await AppDialogs.confirmExit(
      context,
    );

    if (shouldClose) {
      await windowManager.destroy();
    }
  }

  // ---------------------------------------------------------------------------
  // APP
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Consumer<AppPreferences>(
      builder: (
        context,
        preferences,
        _,
      ) {
        // ---------------------------------------------------------------------
        // FILE PEEK LANGUAGE
        //
        // File Peek owns its language selection.
        //
        // Supported:
        //   en = English
        //   tn = Setswana
        //   hi = Hindi
        //   ar = Arabic
        //   zh = Mandarin Chinese
        //
        // This value is NOT passed to MaterialApp.locale.
        //
        // That is intentional.
        //
        // Flutter's built-in Material/Cupertino localization delegates do not
        // need to know about Setswana. They remain on English internally,
        // while AppLocalizations handles the actual File Peek language.
        // ---------------------------------------------------------------------

        final languageCode = switch (preferences.languageCode) {
          'en' => 'en',
          'tn' => 'tn',
          'hi' => 'hi',
          'ar' => 'ar',
          'zh' => 'zh',
          _ => 'en',
        };

        // ---------------------------------------------------------------------
        // RTL
        // ---------------------------------------------------------------------

        final isArabic = languageCode == 'ar';

        // ---------------------------------------------------------------------
        // MATERIAL APP
        // ---------------------------------------------------------------------

        return MaterialApp.router(
          title: 'File Peek',

          debugShowCheckedModeBanner: false,

          // -------------------------------------------------------------------
          // THEME
          // -------------------------------------------------------------------

          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,

          themeMode: preferences.themeMode == 'light'
              ? ThemeMode.light
              : ThemeMode.dark,

          // -------------------------------------------------------------------
          // IMPORTANT
          //
          // Do NOT pass tn/ar/hi/zh here.
          //
          // Flutter's built-in localization delegates are being kept on
          // English. File Peek's own localization is handled by
          // AppLocalizations using AppPreferences.languageCode.
          // -------------------------------------------------------------------

          locale: const Locale('en'),

          // -------------------------------------------------------------------
          // NO AppLocalizations.supportedLocales
          //
          // We deliberately do not use the application's language list as
          // Flutter's Material localization list.
          // -------------------------------------------------------------------

          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          // -------------------------------------------------------------------
          // RTL
          //
          // Arabic is handled by File Peek independently of Flutter's locale.
          // -------------------------------------------------------------------

          builder: (context, child) {
            return Directionality(
              textDirection: isArabic
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: child ?? const SizedBox.shrink(),
            );
          },

          // -------------------------------------------------------------------
          // ROUTING
          // -------------------------------------------------------------------

          routerConfig: AppRoutes.router,
        );
      },
    );
  }
}