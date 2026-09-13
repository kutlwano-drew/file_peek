import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';

class TreeSettings extends StatelessWidget {
  final bool includeHidden;
  final ValueChanged<bool> onIncludeHiddenChanged;
  final int maxDepth;
  final ValueChanged<int> onMaxDepthChanged;

  const TreeSettings({
    super.key,
    required this.includeHidden,
    required this.onIncludeHiddenChanged,
    required this.maxDepth,
    required this.onMaxDepthChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surfaceDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
        side: const BorderSide(color: AppColors.borderDark),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Directory Tree Preferences',
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: AppSpacing.sm),
            SwitchListTile(
              title: const Text('Show Hidden Files (.git, .env)', style: TextStyle(fontSize: 12, color: AppColors.textPrimary)),
              subtitle: const Text('Include files and folders starting with a dot', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              value: includeHidden,
              activeColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
              onChanged: onIncludeHiddenChanged,
            ),
          ],
        ),
      ),
    );
  }
}
