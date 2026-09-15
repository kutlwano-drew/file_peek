import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heroicons/heroicons.dart';
import 'package:provider/provider.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/services/app_preferences.dart';
import '../../../core/widgets/app_dialogs.dart';

class FilePeekAppBar extends StatefulWidget implements PreferredSizeWidget {
  final VoidCallback? onSelectFolder;
  final VoidCallback? onRefresh;
  final VoidCallback? onExportTree;
  final VoidCallback? onExportProject;
  final VoidCallback? onImportStructure;
  final VoidCallback? onCreateDesktopEntry;
  final bool canRefresh;
  final bool hasActiveFolder;

  const FilePeekAppBar({
    super.key,
    this.onSelectFolder,
    this.onRefresh,
    this.onExportTree,
    this.onExportProject,
    this.onImportStructure,
    this.onCreateDesktopEntry,
    this.canRefresh = false,
    this.hasActiveFolder = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  State<FilePeekAppBar> createState() => _FilePeekAppBarState();
}

class _FilePeekAppBarState extends State<FilePeekAppBar> {
  static const String _emailAddress = 'kutlwanodrew.dev@gmail.com';

  static const String _githubUrl = 'https://github.com/kutlwano-drew';

  static const String _xUrl = 'https://x.com/kutlwano_drew';

  static const String _tutorialUrl =
      'https://www.youtube.com/playlist?list=PLQtZdlx2Zcog';

  final LayerLink _fileLink = LayerLink();
  final LayerLink _viewLink = LayerLink();
  final LayerLink _toolsLink = LayerLink();
  final LayerLink _settingsLink = LayerLink();
  final LayerLink _tutorialsLink = LayerLink();
  final LayerLink _developerLink = LayerLink();
  final LayerLink _exitLink = LayerLink();

  OverlayEntry? _menuEntry;
  String? _activeMenu;
  Timer? _closeTimer;

  @override
  void dispose() {
    _closeTimer?.cancel();
    _closeTimer = null;

    final entry = _menuEntry;
    _menuEntry = null;
    _activeMenu = null;

    if (entry != null && entry.mounted) {
      entry.remove();
    }

    super.dispose();
  }

  void _cancelClose() {
    _closeTimer?.cancel();
    _closeTimer = null;
  }

  void _scheduleClose() {
    _cancelClose();

    _closeTimer = Timer(const Duration(milliseconds: 180), () {
      if (!mounted) {
        return;
      }

      _removeMenu();
    });
  }

  void _removeMenu() {
    _cancelClose();

    final entry = _menuEntry;

    _menuEntry = null;
    _activeMenu = null;

    if (entry != null && entry.mounted) {
      entry.remove();
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _showMenu({
    required String menu,
    required LayerLink link,
    required List<_DesktopMenuItem> items,
  }) {
    if (!mounted) {
      return;
    }

    _cancelClose();

    if (_activeMenu == menu && _menuEntry != null) {
      return;
    }

    _removeMenu();

    if (!mounted) {
      return;
    }

    final overlay = Overlay.maybeOf(context);

    if (overlay == null) {
      return;
    }

    late final OverlayEntry entry;

    entry = OverlayEntry(
      builder: (overlayContext) {
        return Positioned.fill(
          child: Stack(
            children: [
              CompositedTransformFollower(
                link: link,
                showWhenUnlinked: false,
                targetAnchor: Alignment.bottomLeft,
                followerAnchor: Alignment.topLeft,
                offset: const Offset(0, 2),
                child: MouseRegion(
                  onEnter: (_) {
                    if (!mounted) {
                      return;
                    }

                    _cancelClose();
                  },
                  onExit: (_) {
                    if (!mounted) {
                      return;
                    }

                    _scheduleClose();
                  },
                  child: _DesktopDropdown(
                    items: items,
                    onClose: _removeMenu,
                    onKeepOpen: _cancelClose,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    _menuEntry = entry;
    _activeMenu = menu;

    overlay.insert(entry);

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _openExternal(String target) async {
    try {
      if (Platform.isWindows) {
        await Process.run('cmd', ['/c', 'start', '', target], runInShell: true);
      } else if (Platform.isMacOS) {
        await Process.run('open', [target]);
      } else if (Platform.isLinux) {
        await Process.run('xdg-open', [target]);
      }
    } catch (_) {}
  }

  Future<void> _copyEmailAddress() async {
    await Clipboard.setData(const ClipboardData(text: _emailAddress));

    _removeMenu();
  }

  Future<void> _openEmailClient() async {
    final mailto = Uri(scheme: 'mailto', path: _emailAddress).toString();

    _removeMenu();

    await _openExternal(mailto);
  }

  List<_DesktopMenuItem> _fileItems(AppLocalizations l) {
    return [
      _DesktopMenuItem(
        icon: HeroIcons.folderOpen,
        label: l.t('selectFolder'),
        onTap: () {
          _removeMenu();
          widget.onSelectFolder?.call();
        },
      ),
      _DesktopMenuItem(
        icon: HeroIcons.arrowPath,
        label: l.t('refresh'),
        enabled: widget.canRefresh,
        onTap: () {
          _removeMenu();
          widget.onRefresh?.call();
        },
      ),
      const _DesktopMenuItem.separator(),
      _DesktopMenuItem(
        icon: HeroIcons.arrowDownTray,
        label: l.t('exportTree'),
        enabled: widget.hasActiveFolder,
        onTap: () {
          _removeMenu();
          widget.onExportTree?.call();
        },
      ),
      _DesktopMenuItem(
        icon: HeroIcons.documentArrowDown,
        label: l.t('exportProject'),
        enabled: widget.hasActiveFolder,
        onTap: () {
          _removeMenu();
          widget.onExportProject?.call();
        },
      ),
      const _DesktopMenuItem.separator(),
      _DesktopMenuItem(
        icon: HeroIcons.folderPlus,
        label: l.t('importStructure'),
        onTap: () {
          _removeMenu();
          widget.onImportStructure?.call();
        },
      ),
    ];
  }

  List<_DesktopMenuItem> _viewItems(AppLocalizations l) {
    return [
      _DesktopMenuItem(
        icon: HeroIcons.arrowPath,
        label: l.t('refresh'),
        enabled: widget.canRefresh,
        onTap: () {
          _removeMenu();

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) {
              return;
            }

            widget.onRefresh?.call();
          });
        },
      ),
    ];
  }

  List<_DesktopMenuItem> _toolsItems(AppLocalizations l) {
    return [
      _DesktopMenuItem(
        icon: HeroIcons.folderPlus,
        label: l.t('importStructure'),
        onTap: () {
          _removeMenu();
          widget.onImportStructure?.call();
        },
      ),
      _DesktopMenuItem(
        icon: HeroIcons.computerDesktop,
        label: l.t('createDesktopEntry'),
        onTap: () async {
          _removeMenu();

          if (!mounted) {
            return;
          }

          await AppDialogs.desktopEntry(context);
        },
      ),
    ];
  }

  List<_DesktopMenuItem> _settingsItems(
    AppLocalizations l,
    AppPreferences preferences,
  ) {
    final isLight = preferences.themeMode == 'light';

    return [
      _DesktopMenuItem(
        icon: isLight ? HeroIcons.sun : HeroIcons.moon,
        label: isLight ? l.t('light') : l.t('dark'),
        onTap: () {
          preferences.setTheme(isLight ? 'dark' : 'light');

          _removeMenu();
        },
      ),
    ];
  }

  List<_DesktopMenuItem> _tutorialItems() {
    return [
      _DesktopMenuItem(
        icon: HeroIcons.play,
        label: 'Watch on YouTube',
        youtube: true,
        onTap: () {
          _removeMenu();

          _openExternal(_tutorialUrl);
        },
      ),
    ];
  }

  List<_DesktopMenuItem> _developerItems() {
    return [
      _DesktopMenuItem(
        icon: HeroIcons.heart,
        label: 'Support',
        onTap: () {
          _removeMenu();

          _openExternal('https://ko-fi.com/kutlwanodrew');
        },
      ),
      _DesktopMenuItem(
        icon: HeroIcons.share,
        label: 'Socials',
        children: [
          _DesktopMenuItem(
            icon: HeroIcons.codeBracket,
            label: 'View GitHub Profile',
            onTap: () {
              _removeMenu();

              _openExternal(_githubUrl);
            },
          ),
          _DesktopMenuItem(
            icon: HeroIcons.xMark,
            label: 'View X Profile',
            onTap: () {
              _removeMenu();

              _openExternal(_xUrl);
            },
          ),
          _DesktopMenuItem(
            icon: HeroIcons.envelope,
            label: 'Email',
            children: [
              _DesktopMenuItem(
                icon: HeroIcons.clipboardDocument,
                label: 'Copy Email Address',
                onTap: _copyEmailAddress,
              ),
              _DesktopMenuItem(
                icon: HeroIcons.envelopeOpen,
                label: 'Open Email App',
                onTap: _openEmailClient,
              ),
            ],
          ),
        ],
      ),
    ];
  }

  List<_DesktopMenuItem> _exitItems(AppLocalizations l) {
    return [
      _DesktopMenuItem(
        icon: HeroIcons.power,
        label: l.t('exit'),
        destructive: true,
        onTap: () async {
          _removeMenu();

          if (!mounted) {
            return;
          }

          await AppDialogs.confirmExit(context);
        },
      ),
    ];
  }

  void _openMenu({
    required String menu,
    required LayerLink link,
    required List<_DesktopMenuItem> items,
  }) {
    if (!mounted) {
      return;
    }

    _showMenu(menu: menu, link: link, items: items);
  }

  Widget _menuLabel({
    required String menu,
    required String label,
    required LayerLink link,
    required List<_DesktopMenuItem> items,
  }) {
    final selected = _activeMenu == menu;

    return CompositedTransformTarget(
      link: link,
      child: MouseRegion(
        onEnter: (_) {
          if (!mounted) {
            return;
          }

          _cancelClose();

          _openMenu(menu: menu, link: link, items: items);
        },
        onExit: (_) {
          if (!mounted) {
            return;
          }

          _scheduleClose();
        },
        child: InkWell(
          onTap: () {
            if (!mounted) {
              return;
            }

            if (selected) {
              _removeMenu();
            } else {
              _openMenu(menu: menu, link: link, items: items);
            }
          },
          hoverColor: Colors.lightBlue,
          borderRadius: BorderRadius.circular(7),
          child: Container(
            height: 40,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 11),
            decoration: BoxDecoration(
              color: selected
                  ? Colors.lightBlue
                  : Theme.of(context).brightness == Brightness.light
                  ? Colors.white
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: selected
                    ? Colors.white
                    : Theme.of(context).brightness == Brightness.light
                    ? Colors.black
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Consumer<AppPreferences>(
      builder: (context, preferences, _) {
        return AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 56,
          titleSpacing: 12,
          title: Row(
            children: [
              _menuLabel(
                menu: 'file',
                label: l.t('file'),
                link: _fileLink,
                items: _fileItems(l),
              ),
              _menuLabel(
                menu: 'view',
                label: l.t('view'),
                link: _viewLink,
                items: _viewItems(l),
              ),
              _menuLabel(
                menu: 'tools',
                label: l.t('tools'),
                link: _toolsLink,
                items: _toolsItems(l),
              ),
              _menuLabel(
                menu: 'settings',
                label: l.t('settings'),
                link: _settingsLink,
                items: _settingsItems(l, preferences),
              ),
              _menuLabel(
                menu: 'tutorials',
                label: 'Tutorials',
                link: _tutorialsLink,
                items: _tutorialItems(),
              ),
              _menuLabel(
                menu: 'developer',
                label: l.t('developer'),
                link: _developerLink,
                items: _developerItems(),
              ),
              _menuLabel(
                menu: 'exit',
                label: l.t('exit'),
                link: _exitLink,
                items: _exitItems(l),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DesktopDropdown extends StatelessWidget {
  final List<_DesktopMenuItem> items;
  final VoidCallback onClose;
  final VoidCallback onKeepOpen;

  const _DesktopDropdown({
    required this.items,
    required this.onClose,
    required this.onKeepOpen,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Material(
      elevation: 12,
      color: isLight ? Colors.white : AppColors.surfaceDark.withOpacity(0.97),
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 210, maxWidth: 310),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: items.map((item) {
              if (item.isSeparator) {
                return Divider(
                  height: 9,
                  thickness: 0.4,
                  color: isLight ? Colors.black : Colors.white24,
                  indent: 10,
                  endIndent: 10,
                );
              }

              if (item.children != null) {
                return _DesktopSubmenuRow(
                  item: item,
                  onClose: onClose,
                  onKeepOpen: onKeepOpen,
                );
              }

              return _DesktopMenuRow(item: item, onClose: onClose);
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _DesktopMenuRow extends StatefulWidget {
  final _DesktopMenuItem item;
  final VoidCallback onClose;

  const _DesktopMenuRow({required this.item, required this.onClose});

  @override
  State<_DesktopMenuRow> createState() => _DesktopMenuRowState();
}

class _DesktopMenuRowState extends State<_DesktopMenuRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    final enabled = widget.item.enabled;
    final hovered = enabled && _hovered;
    final isYoutube = widget.item.youtube;

    final normalTextColor = !enabled
        ? (isLight ? Colors.black38 : Colors.white38)
        : widget.item.destructive
        ? Colors.red
        : isYoutube
        ? Colors.white
        : isLight
        ? Colors.black
        : Colors.white;

    final normalIconColor = !enabled
        ? (isLight ? Colors.black38 : Colors.white38)
        : widget.item.destructive
        ? Colors.red
        : isYoutube
        ? Colors.white
        : isLight
        ? Colors.black
        : Colors.white;

    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) {
        if (enabled) {
          setState(() {
            _hovered = true;
          });
        }
      },
      onExit: (_) {
        setState(() {
          _hovered = false;
        });
      },
      child: GestureDetector(
        onTap: enabled
            ? () {
                widget.item.onTap?.call();
              }
            : null,
        child: Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 13),
          decoration: BoxDecoration(
            color: hovered
                ? Colors.lightBlue
                : isYoutube
                ? Colors.redAccent
                : Colors.transparent,
          ),
          child: Row(
            children: [
              HeroIcon(
                widget.item.icon,
                size: 18,
                color: hovered ? Colors.white : normalIconColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.item.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: hovered ? Colors.white : normalTextColor,
                  ),
                ),
              ),
              if (widget.item.trailingText != null)
                Text(
                  widget.item.trailingText!,
                  style: TextStyle(
                    fontSize: 11,
                    color: hovered
                        ? Colors.white70
                        : isLight
                        ? Colors.black38
                        : Colors.white38,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DesktopSubmenuRow extends StatefulWidget {
  final _DesktopMenuItem item;
  final VoidCallback onClose;
  final VoidCallback onKeepOpen;

  const _DesktopSubmenuRow({
    required this.item,
    required this.onClose,
    required this.onKeepOpen,
  });

  @override
  State<_DesktopSubmenuRow> createState() => _DesktopSubmenuRowState();
}

class _DesktopSubmenuRowState extends State<_DesktopSubmenuRow> {
  OverlayEntry? _submenuEntry;
  Timer? _closeTimer;
  bool _hovered = false;

  void _cancelClose() {
    _closeTimer?.cancel();
    _closeTimer = null;
  }

  void _scheduleClose() {
    _cancelClose();

    _closeTimer = Timer(const Duration(milliseconds: 180), _removeSubmenu);
  }

  void _removeSubmenu() {
    _cancelClose();

    final entry = _submenuEntry;
    _submenuEntry = null;

    if (entry != null && entry.mounted) {
      entry.remove();
    }
  }

  void _showSubmenu() {
    _cancelClose();
    widget.onKeepOpen();

    if (_submenuEntry != null) {
      return;
    }

    final renderBox = context.findRenderObject() as RenderBox?;

    final overlay = Overlay.maybeOf(context);

    if (renderBox == null || overlay == null) {
      return;
    }

    final overlayRenderObject = overlay.context.findRenderObject();

    if (overlayRenderObject == null) {
      return;
    }

    final topLeft = renderBox.localToGlobal(
      Offset.zero,
      ancestor: overlayRenderObject,
    );

    final submenuTop = topLeft.dy;

    final submenuLeft = topLeft.dx + renderBox.size.width + 4;

    final children = widget.item.children ?? const <_DesktopMenuItem>[];

    late final OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) {
        final isLight = Theme.of(context).brightness == Brightness.light;

        return Positioned(
          left: submenuLeft,
          top: submenuTop,
          child: MouseRegion(
            onEnter: (_) {
              _cancelClose();
              widget.onKeepOpen();
            },
            onExit: (_) {
              _scheduleClose();
              widget.onKeepOpen();
            },
            child: Material(
              elevation: 12,
              color: isLight
                  ? Colors.white
                  : AppColors.surfaceDark.withOpacity(0.97),
              borderRadius: BorderRadius.circular(8),
              clipBehavior: Clip.antiAlias,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 210, maxWidth: 310),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final child in children)
                        if (child.isSeparator)
                          Divider(
                            height: 9,
                            thickness: 0.4,
                            color: isLight ? Colors.black : Colors.white24,
                            indent: 10,
                            endIndent: 10,
                          )
                        else if (child.children != null)
                          _DesktopSubmenuRow(
                            item: child,
                            onClose: () {
                              _removeSubmenu();
                              widget.onClose();
                            },
                            onKeepOpen: _cancelClose,
                          )
                        else
                          _DesktopMenuRow(
                            item: child,
                            onClose: () {
                              _removeSubmenu();
                              widget.onClose();
                            },
                          ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    _submenuEntry = entry;

    overlay.insert(entry);
  }

  @override
  void dispose() {
    _closeTimer?.cancel();
    _removeSubmenu();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          _hovered = true;
        });

        _showSubmenu();
      },
      onExit: (_) {
        setState(() {
          _hovered = false;
        });

        _scheduleClose();
      },
      child: GestureDetector(
        onTap: _showSubmenu,
        child: Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 13),
          decoration: BoxDecoration(
            color: _hovered ? Colors.lightBlue : Colors.transparent,
          ),
          child: Row(
            children: [
              HeroIcon(
                widget.item.icon,
                size: 18,
                color: _hovered
                    ? Colors.white
                    : isLight
                    ? Colors.black
                    : Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.item.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _hovered
                        ? Colors.white
                        : isLight
                        ? Colors.black
                        : Colors.white,
                  ),
                ),
              ),
              HeroIcon(
                HeroIcons.chevronRight,
                size: 16,
                color: _hovered
                    ? Colors.white
                    : isLight
                    ? Colors.black
                    : Colors.white70,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DesktopMenuItem {
  final HeroIcons icon;
  final String label;
  final VoidCallback? onTap;
  final bool enabled;
  final bool destructive;
  final String? trailingText;
  final bool isSeparator;
  final bool youtube;
  final List<_DesktopMenuItem>? children;

  const _DesktopMenuItem({
    required this.icon,
    required this.label,
    this.onTap,
    this.enabled = true,
    this.destructive = false,
    this.trailingText,
    this.youtube = false,
    this.children,
    this.isSeparator = false,
  });

  const _DesktopMenuItem.separator()
    : icon = HeroIcons.minus,
      label = '',
      onTap = null,
      enabled = false,
      destructive = false,
      trailingText = null,
      youtube = false,
      isSeparator = true,
      children = null;
}
