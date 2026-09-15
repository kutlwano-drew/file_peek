import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:heroicons/heroicons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../services/desktop_entry_service.dart';

class AppDialogs {
  static Future<T?> choice<T>(
    BuildContext context, {
    required String title,
    required String message,
    required List<Widget> actions,
    HeroIcons icon = HeroIcons.questionMarkCircle,
  }) {
    return showDialog<T>(
      context: context,
      builder: (dialogContext) {
        return _Shell(
          title: title,
          message: message,
          icon: icon,
          loader: LoadingAnimationWidget.hexagonDots(
            color: Theme.of(dialogContext).colorScheme.primary,
            size: 34,
          ),
          actions: actions,
        );
      },
    );
  }

 static Future<bool> confirmExit(BuildContext context) async {
  final ok = await choice<bool>(
    context,
    title: 'Exit File Peek?',
    message: 'Are you sure you want to close the application?',
    icon: HeroIcons.exclamationTriangle,
    actions: [
      SizedBox(
        width: 120,
        height: 42,
        child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () => Navigator.pop(context, false),
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
      SizedBox(
        width: 120,
        height: 42,
        child: GlowButton(
          color: Colors.redAccent,
          glowColor: Colors.redAccent,
          blurRadius: 0,
          onPressed: () => Navigator.pop(context, true),
          child: const Text(
            'Yes, Exit',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    ],
  );

  if (ok == true) {
    await _countdown(context);
    return true;
  }

  return false;
}

static Future<void> _countdown(BuildContext context) async {
  var seconds = 3;
  Timer? timer;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (dialogContext, setState) {
          timer ??= Timer.periodic(
            const Duration(seconds: 1),
            (t) {
              if (seconds <= 1) {
                t.cancel();
                Navigator.pop(dialogContext);

                if (kIsWeb ||
                    Platform.isAndroid ||
                    Platform.isIOS) {
                  SystemNavigator.pop();
                } else {
                  exit(0);
                }
              } else {
                setState(() {
                  seconds--;
                });
              }
            },
          );

          return _Shell(
            title: 'Closing File Peek',
            message: 'Closing app in:\n$seconds seconds',
            icon: HeroIcons.power,
            actions: [
              SizedBox(
                width: 120,
                height: 42,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    timer?.cancel();
                    Navigator.pop(dialogContext);
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 120,
                height: 42,
                child: GlowButton(
                  color: Colors.redAccent,
                  glowColor: Colors.redAccent,
                  blurRadius: 0,
                  onPressed: () {
                    timer?.cancel();
                    Navigator.pop(dialogContext);

                    if (kIsWeb ||
                        Platform.isAndroid ||
                        Platform.isIOS) {
                      SystemNavigator.pop();
                    } else {
                      exit(0);
                    }
                  },
                  child: const Text(
                    'Close Now',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );

  timer?.cancel();
}

  static Future<void> desktopEntry(BuildContext context) async {
    if (kIsWeb || !Platform.isLinux) {
      if (context.mounted) {
        await choice(
          context,
          title: 'Desktop Entry',
          message:
              'Desktop launcher creation is available on Linux desktop only.',
          icon: HeroIcons.computerDesktop,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      }

      return;
    }

    if (!context.mounted) {
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return const _Shell(
          title: 'Creating Desktop Entry',
          message:
              'Registering File Peek with your desktop application launcher.',
          icon: HeroIcons.computerDesktop,
          loader: null,
          actions: [],
        );
      },
    );

    try {
      final ok = await DesktopEntryService().createDesktopEntry();

      if (context.mounted) {
        Navigator.pop(context);
      }

      if (context.mounted) {
        await choice(
          context,
          title: ok
              ? 'Desktop Entry Created'
              : 'Desktop Entry Failed',
          message: ok
              ? 'File Peek is now available from your desktop application launcher.'
              : 'The desktop launcher could not be created.',
          icon: ok
              ? HeroIcons.checkCircle
              : HeroIcons.exclamationTriangle,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
      }

      if (context.mounted) {
        await choice(
          context,
          title: 'Desktop Entry Failed',
          message: e.toString(),
          icon: HeroIcons.exclamationTriangle,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      }
    }
  }
}

class _Shell extends StatelessWidget {
  final String title;
  final String message;
  final HeroIcons icon;
  final Widget? loader;
  final List<Widget> actions;

  const _Shell({
    required this.title,
    required this.message,
    required this.icon,
    this.loader,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      backgroundColor: colorScheme.surface.withOpacity(0.96),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: colorScheme.primary.withOpacity(0.20),
        ),
      ),
      titlePadding: const EdgeInsets.fromLTRB(
        24,
        22,
        24,
        0,
      ),
      contentPadding: const EdgeInsets.fromLTRB(
        24,
        18,
        24,
        8,
      ),
      actionsPadding: const EdgeInsets.fromLTRB(
        20,
        8,
        20,
        18,
      ),
      title: Row(
        children: [
          HeroIcon(
            icon,
            color: colorScheme.primary,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GlowText(
              title,
              glowColor: colorScheme.primary,
              blurRadius: 0,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (loader != null)
            Padding(
              padding: const EdgeInsets.only(
                bottom: 16,
              ),
              child: loader,
            ),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorScheme.onSurface,
              height: 1.45,
            ),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actionsOverflowAlignment: OverflowBarAlignment.center,
      actions: [
        if (actions.isNotEmpty)
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 8,
            children: actions,
          ),
      ],
    );
  }
}
