import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';

class TerminalSettings extends StatelessWidget {
  final String defaultShell;
  final ValueChanged<String?> onShellChanged;

  const TerminalSettings({
    super.key,
    required this.defaultShell,
    required this.onShellChanged,
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
              'Terminal Preferences',
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Default Shell / Runtime', style: TextStyle(fontSize: 12, color: AppColors.textPrimary)),
                DropdownButton<String>(
                  value: defaultShell,
                  dropdownColor: AppColors.surfaceDark,
                  style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                  items: const [
                    DropdownMenuItem(value: 'bash', child: Text('Bash')),
                    DropdownMenuItem(value: 'sh', child: Text('SH')),
                    DropdownMenuItem(value: 'zsh', child: Text('Zsh')),
                  ],
                  onChanged: onShellChanged,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
