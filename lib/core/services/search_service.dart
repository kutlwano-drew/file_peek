import '../models/file_node.dart';

class SearchService {
  static List<FileNode> searchNodes(FileNode root, String query, {bool caseSensitive = false}) {
    final results = <FileNode>[];
    if (query.trim().isEmpty) return results;

    final targetQuery = caseSensitive ? query : query.toLowerCase();

    void traverse(FileNode node) {
      final nodeName = caseSensitive ? node.name : node.name.toLowerCase();
      if (nodeName.contains(targetQuery)) {
        results.add(node);
      }
      if (node.isDirectory && node.children != null) {
        for (final child in node.children!) {
          traverse(child);
        }
      }
    }

    traverse(root);
    return results;
  }
}
