import 'package:flutter/material.dart';

class StructureImportToolbar extends StatelessWidget {
  final String? targetPath;
  final VoidCallback onSelectTarget;
  final VoidCallback onGenerate;
  final bool isGenerating;

  const StructureImportToolbar({
    Key? key,
    required this.targetPath,
    required this.onSelectTarget,
    required this.onGenerate,
    required this.isGenerating,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Theme.of(context).cardColor,
      child: Row(
        children: [
          Expanded(
            child: Text(
              targetPath == null ? 'No target directory selected' : 'Target: $targetPath',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: targetPath == null ? Colors.grey : Colors.green),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: onSelectTarget,
            icon: const Icon(Icons.folder_open),
            label: const Text('Select Target Folder'),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: isGenerating ? null : onGenerate,
            icon: isGenerating 
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.create_new_folder),
            label: const Text('Generate on Disk'),
          ),
        ],
      ),
    );
  }
}
