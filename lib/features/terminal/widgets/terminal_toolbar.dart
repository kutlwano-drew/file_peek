import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';

class TerminalToolbar extends StatelessWidget {
  final VoidCallback onClear;
  final VoidCallback onClose;

  const TerminalToolbar({
    super.key,
    required this.onClear,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      color: AppColors.surfaceLightDark,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(Icons.terminal, size: AppSpacing.iconSizeSmall, color: AppColors.primary),
              SizedBox(width: AppSpacing.xs),
              Text('Terminal', style: TextStyle(color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.cleaning_services, size: AppSpacing.iconSizeSmall),
                tooltip: 'Clear Terminal',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onClear,
              ),
              const SizedBox(width: AppSpacing.md),
              IconButton(
                icon: const Icon(Icons.close, size: AppSpacing.iconSizeSmall),
                tooltip: 'Close Terminal',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onClose,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
