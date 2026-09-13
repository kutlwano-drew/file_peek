import 'package:flutter/material.dart';
import 'tree_node_tile.dart';
import '../../../core/models/file_node.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../app/theme/app_colors.dart';

class TreePanel extends StatelessWidget {
  final FileNode? rootNode;
  final FileNode? selectedNode;
  final Function(FileNode) onFileSelected;
  final String searchQuery;
  final List<FileNode> searchResults;

  const TreePanel({
    super.key,
    required this.rootNode,
    required this.selectedNode,
    required this.onFileSelected,
    this.searchQuery = '',
    this.searchResults = const [],
  });

  bool _isNodeVisible(FileNode node) {
    if (searchQuery.trim().isEmpty) return true;

    final isDirectMatch = searchResults.contains(node);
    final hasMatchingChild = _hasMatchingDescendant(node);

    return isDirectMatch || hasMatchingChild;
  }

  bool _hasMatchingDescendant(FileNode node) {
    if (node.children == null || node.children!.isEmpty) return false;
    for (final child in node.children!) {
      if (searchResults.contains(child) || _hasMatchingDescendant(child)) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (rootNode == null) {
      return const EmptyState(
        icon: Icons.folder_open,
        message: 'No folder selected',
        subMessage: 'Click "Select Folder" in the toolbar to inspect a project.',
      );
    }

    final isSearching = searchQuery.trim().isNotEmpty;
    final isRootVisible = _isNodeVisible(rootNode!);

    if (isSearching && !isRootVisible) {
      return Container(
        color: AppColors.surfaceDark,
        child: const EmptyState(
          icon: Icons.search_off,
          message: 'No matching files or directories',
          subMessage: 'Try adjusting your search term.',
        ),
      );
    }

    return Container(
      color: AppColors.surfaceDark,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          TreeNodeTile(
            node: rootNode!,
            selectedNode: selectedNode,
            onTap: onFileSelected,
            isSearching: isSearching,
            searchResults: searchResults,
          ),
        ],
      ),
    );
  }
}