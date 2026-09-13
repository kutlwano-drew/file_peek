import 'package:flutter/material.dart';
import '../../../core/models/file_node.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';

class TreeNodeTile extends StatelessWidget {
  final FileNode node;
  final FileNode? selectedNode;
  final Function(FileNode) onTap;
  final int depth;
  final bool isSearching;
  final List<FileNode> searchResults;

  const TreeNodeTile({
    super.key,
    required this.node,
    required this.selectedNode,
    required this.onTap,
    this.depth = 0,
    this.isSearching = false,
    this.searchResults = const [],
  });

  bool _isDirectMatch(FileNode target) {
    return searchResults.any((result) => result.path == target.path);
  }

  bool _hasMatchingChild(FileNode parent) {
    if (parent.children == null || parent.children!.isEmpty) return false;
    for (final child in parent.children!) {
      if (_isDirectMatch(child) || _hasMatchingChild(child)) {
        return true;
      }
    }
    return false;
  }

  bool _shouldShowChild(FileNode child) {
    if (!isSearching) return true;
    return _isDirectMatch(child) || _hasMatchingChild(child);
  }

  IconData _getFileIcon(String ext) {
    switch (ext.toLowerCase()) {
      case 'dart':
        return Icons.code;
      case 'md':
      case 'txt':
        return Icons.text_snippet;
      case 'json':
      case 'yaml':
      case 'yml':
        return Icons.settings_applications;
      case 'png':
      case 'jpg':
      case 'jpeg':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedNode?.path == node.path;
    final isMatch = isSearching && _isDirectMatch(node);
    final shouldExpand = (isSearching && _hasMatchingChild(node)) || node.isExpanded;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => onTap(node),
          child: Container(
            padding: EdgeInsets.only(
              left: (depth * 16.0) + AppSpacing.sm,
              right: AppSpacing.sm,
              top: 4,
              bottom: 4,
            ),
            color: isSelected
                ? AppColors.surfaceLightDark
                : (isMatch ? AppColors.primary.withOpacity(0.15) : Colors.transparent),
            child: Row(
              children: [
                if (node.isDirectory)
                  Icon(
                    shouldExpand ? Icons.arrow_drop_down : Icons.arrow_right,
                    size: AppSpacing.iconSizeMedium,
                    color: AppColors.textSecondary,
                  )
                else
                  const SizedBox(width: AppSpacing.iconSizeMedium),
                const SizedBox(width: AppSpacing.xs),
                Icon(
                  node.isDirectory ? Icons.folder : _getFileIcon(node.extension),
                  size: AppSpacing.iconSizeSmall,
                  color: node.isDirectory ? AppColors.accentYellow : AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    node.name,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.primary
                          : (isMatch ? AppColors.primary : AppColors.textPrimary),
                      fontSize: 12,
                      fontWeight: (isSelected || isMatch) ? FontWeight.bold : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!node.isDirectory)
                  Text(
                    node.formattedSize,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                  ),
              ],
            ),
          ),
        ),
        if (node.isDirectory && shouldExpand && node.children != null)
          ...node.children!
              .where(_shouldShowChild)
              .map((child) => TreeNodeTile(
                    node: child,
                    selectedNode: selectedNode,
                    onTap: onTap,
                    depth: depth + 1,
                    isSearching: isSearching,
                    searchResults: searchResults,
                  )),
      ],
    );
  }
}