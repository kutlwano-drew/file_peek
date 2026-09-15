import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: const BoxDecoration(
        color: backgroundColor,
        border: Border(bottom: BorderSide(color: Colors.white24)),
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
              style: const TextStyle(color: Colors.white70, fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            tooltip: 'Copy file content',
            color: foregroundColor,
            onPressed: fileContent == null
                ? null
                : () async {
                    final ok = await ClipboardService.copyToClipboard(
                      fileContent!,
                    );

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          width: MediaQuery.sizeOf(context).width * 0.5,
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: ok ? Colors.green : Colors.redAccent,
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          content: Row(
                            children: [
                              HeroIcon(
                                ok
                                    ? HeroIcons.checkCircle
                                    : HeroIcons.exclamationCircle,
                                size: 21,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  ok ? 'Copied' : 'Copy failed',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
            icon: const Icon(Icons.copy, size: 18),
          ),
        ],
      ),
    );
  }
}
