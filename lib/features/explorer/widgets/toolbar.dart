import 'package:flutter/material.dart';
import '../../../core/widgets/app_button.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';

class Toolbar extends StatelessWidget {
  final VoidCallback onSelectFolder;
  final VoidCallback onRefresh;
  final VoidCallback onToggleTerminal;
  final VoidCallback onOpenSettings;
  final VoidCallback onExportTree;
  final VoidCallback onExportProject;
  final VoidCallback onOpenStructureImport;
  final bool hasActiveFolder;

  const Toolbar({
    super.key,
    required this.onSelectFolder,
    required this.onRefresh,
    required this.onToggleTerminal,
    required this.onOpenSettings,
    required this.onExportTree,
    required this.onExportProject,
    required this.onOpenStructureImport,
    required this.hasActiveFolder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      color: AppColors.surfaceDark,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side: Folder operations & exports
          Row(
            children: [
              AppButton(
                label: 'Select Folder',
                icon: Icons.folder_open,
                onPressed: onSelectFolder,
              ),

              const SizedBox(width: AppSpacing.sm),

              IconButton(
                icon: const Icon(
                  Icons.refresh,
                  size: AppSpacing.iconSizeMedium,
                  color: Colors.white,
                ),
                tooltip: 'Refresh Folder (F5)',
                onPressed: hasActiveFolder ? onRefresh : null,
                color: Colors.white,
                disabledColor: Colors.white38,
              ),

              const VerticalDivider(
                indent: 10,
                endIndent: 10,
                color: AppColors.borderDark,
              ),

              // Export Tree
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: hasActiveFolder
                      ? Colors.lightBlue
                      : Colors.transparent,
                  side: BorderSide(
                    color: hasActiveFolder
                        ? Colors.lightBlue
                        : Colors.transparent,
                  ),
                ),
                onPressed: hasActiveFolder ? onExportTree : null,
                icon: const Icon(
                  Icons.account_tree_outlined,
                  size: 16,
                  color: Colors.white,
                ),
                label: const Text(
                  'Export Tree',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(width: AppSpacing.xs),

              // Export Project
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: hasActiveFolder
                      ? Colors.lightBlue
                      : Colors.transparent,
                  side: BorderSide(
                    color: hasActiveFolder
                        ? Colors.lightBlue
                        : Colors.transparent,
                  ),
                ),
                onPressed: hasActiveFolder ? onExportProject : null,
                icon: const Icon(
                  Icons.import_export,
                  size: 16,
                  color: Colors.white,
                ),
                label: const Text(
                  'Export Project',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          // Right side: Structure Import
          Row(
            children: [
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.lightBlue,
                ),
                onPressed: onOpenStructureImport,
                icon: const Icon(
                  Icons.create_new_folder_outlined,
                  size: 18,
                  color: Colors.white,
                ),
                label: const Text(
                  'Import Structure',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(width: AppSpacing.sm),
            ],
          ),
        ],
      ),
    );
  }
}

