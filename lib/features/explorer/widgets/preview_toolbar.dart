
import 'package:flutter/material.dart';

import '../../../core/models/file_node.dart';
import '../../../core/services/clipboard_service.dart';
import 'preview/preview_type.dart';

class PreviewToolbar extends StatelessWidget {
  final FileNode? selectedNode;
  final String? fileContent;

  const PreviewToolbar({
    super.key,
    required this.selectedNode,
    required this.fileContent,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedNode == null) {
      return const SizedBox.shrink();
    }

    final type = previewTypeFor(selectedNode!.name);

    const backgroundColor = Colors.black;
    const foregroundColor = Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      decoration: const BoxDecoration(
        color: backgroundColor,
        border: Border(
          bottom: BorderSide(
            color: Colors.white24,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${selectedNode!.name} — ${type.label}',
              style: const TextStyle(
                color: foregroundColor,
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              selectedNode!.path,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            tooltip: 'Copy file content',
            color: foregroundColor,
            onPressed: fileContent == null
                ? null
                : () async {
                    final ok =
                        await ClipboardService.copyToClipboard(
                      fileContent!,
                    );

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            ok ? 'Copied' : 'Copy failed',
                          ),
                          backgroundColor:
                              ok ? Colors.green : Colors.redAccent,
                        ),
                      );
                    }
                  },
            icon: const Icon(
              Icons.copy,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}
