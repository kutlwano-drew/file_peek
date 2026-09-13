import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/terminal_controller.dart';
import 'terminal_toolbar.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';

class TerminalPanel extends StatelessWidget {
  final String currentDirectory;
  final VoidCallback onClose;

  const TerminalPanel({
    super.key,
    required this.currentDirectory,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TerminalController(),
      child: Consumer<TerminalController>(
        builder: (context, controller, child) {
          final textController = TextEditingController();

          return Container(
            color: AppColors.terminalBackground,
            child: Column(
              children: [
                TerminalToolbar(
                  onClear: controller.clearLog,
                  onClose: onClose,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: ListView.builder(
                      itemCount: controller.outputLog.length,
                      itemBuilder: (context, index) {
                        return SelectableText(
                          controller.outputLog[index],
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            color: AppColors.textPrimary,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                  color: AppColors.surfaceDark,
                  child: Row(
                    children: [
                      const Text('\$', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: TextField(
                          controller: textController,
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: AppColors.textPrimary),
                          decoration: const InputDecoration(
                            hintText: 'Type command (e.g., git status, npm test)...',
                            hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 11),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          onSubmitted: (value) {
                            if (currentDirectory.isNotEmpty) {
                              controller.executeCommand(value, currentDirectory);
                              textController.clear();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please select a directory first'), backgroundColor: Colors.red),
                              );
                            }
                          },
                        ),
                      ),
                      if (controller.isRunning)
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
