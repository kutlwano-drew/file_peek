import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';

class ExportSettings extends StatelessWidget {
  final bool defaultUnicodeTree;
  final ValueChanged<bool> onDefaultUnicodeChanged;

  const ExportSettings({
    super.key,
    required this.defaultUnicodeTree,
    required this.onDefaultUnicodeChanged,
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
              'Export Defaults',
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: AppSpacing.sm),
            SwitchListTile(
              title: const Text('Use Unicode by Default in Tree Export', style: TextStyle(fontSize: 12, color: AppColors.textPrimary)),
              value: defaultUnicodeTree,
              activeColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
              onChanged: onDefaultUnicodeChanged,
            ),
          ],
        ),
      ),
    );
  }
}
