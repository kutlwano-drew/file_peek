import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';

class PreviewSettings extends StatelessWidget {
  final double fontSize;
  final ValueChanged<double> onFontSizeChanged;
  final bool showLineNumbers;
  final ValueChanged<bool> onShowLineNumbersChanged;

  const PreviewSettings({
    super.key,
    required this.fontSize,
    required this.onFontSizeChanged,
    required this.showLineNumbers,
    required this.onShowLineNumbersChanged,
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
              'File Preview Settings',
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Font Size', style: TextStyle(fontSize: 12, color: AppColors.textPrimary)),
                Text('${fontSize.toStringAsFixed(0)} pt', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
            Slider(
              value: fontSize,
              min: 10,
              max: 20,
              divisions: 10,
              activeColor: AppColors.primary,
              inactiveColor: AppColors.borderDark,
              onChanged: onFontSizeChanged,
            ),
          ],
        ),
      ),
    );
  }
}
