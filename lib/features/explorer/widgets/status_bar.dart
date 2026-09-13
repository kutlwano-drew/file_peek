import 'package:flutter/material.dart';
import '../../../core/models/project_statistics.dart';
import '../../../core/models/file_node.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';

class StatusBar extends StatelessWidget {
  final ProjectStatistics statistics;
  final FileNode? selectedFile;

  const StatusBar({
    super.key,
    required this.statistics,
    required this.selectedFile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      color: AppColors.surfaceLightDark,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text('Folders: ${statistics.totalFolders}', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              const SizedBox(width: AppSpacing.md),
              Text('Files: ${statistics.totalFiles}', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              const SizedBox(width: AppSpacing.md),
              Text('Size: ${statistics.formattedTotalSize}', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
            ],
          ),
          if (selectedFile != null)
            Text(
              'Selected: ${selectedFile!.name} (${selectedFile!.formattedSize})',
              style: const TextStyle(fontSize: 10, color: AppColors.primary),
            ),
        ],
      ),
    );
  }
}
