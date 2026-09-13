import 'dart:io';
import '../models/file_node.dart';
import '../models/project_statistics.dart';

class DirectoryScanner {
  /// Scans a directory recursively with full error handling and statistics collection.
  static Future<({FileNode? rootNode, ProjectStatistics stats})> scanDirectory(
    String path, {
    bool includeHidden = false,
    int maxDepth = 50,
    void Function(String currentPath)? onProgress,
  }) async {
    try {
      final dir = Directory(path);
      if (!await dir.exists()) {
        throw FileSystemException('Directory does not exist', path);
      }

      int folderCount = 0;
      int fileCount = 0;
      int totalSize = 0;
      final Map<String, int> extCounts = {};

      Future<FileNode?> scanRecursive(Directory currentDir, int depth) async {
        try {
          onProgress?.call(currentDir.path);
          folderCount++;
          
          final entities = await currentDir.list(followLinks: false).toList();
          final List<FileNode> children = [];

          for (final entity in entities) {
            try {
              final name = entity.uri.pathSegments.where((s) => s.isNotEmpty).last;
              if (!includeHidden && name.startsWith('.')) continue;

              if (entity is Directory) {
                final subNode = depth < maxDepth ? await scanRecursive(entity, depth + 1) : null;
                if (subNode != null) children.add(subNode);
              } else if (entity is File) {
                fileCount++;
                int size = 0;
                try {
                  size = await entity.length();
                } catch (_) {}
                
                totalSize += size;
                final node = FileNode.fromEntity(entity, isHidden: includeHidden);
                
                if (node.extension.isNotEmpty) {
                  extCounts[node.extension] = (extCounts[node.extension] ?? 0) + 1;
                }
                children.add(node);
              }
            } catch (_) {
              // Skip individual unreadable files/subfolders defensively
            }
          }

          // Sort: Folders first, then alphabetical
          children.sort((a, b) {
            if (a.isDirectory && !b.isDirectory) return -1;
            if (!a.isDirectory && b.isDirectory) return 1;
            return a.name.toLowerCase().compareTo(b.name.toLowerCase());
          });

          final rootStat = await currentDir.stat();
          return FileNode(
            path: currentDir.path,
            name: currentDir.uri.pathSegments.where((s) => s.isNotEmpty).last,
            isDirectory: true,
            sizeBytes: 0,
            lastModified: rootStat.modified,
            extension: '',
            children: children,
            isHidden: currentDir.uri.pathSegments.where((s) => s.isNotEmpty).last.startsWith('.'),
          );
        } catch (_) {
          return null;
        }
      }

      final rootNode = await scanRecursive(dir, 0);
      final stats = ProjectStatistics(
        totalFolders: folderCount,
        totalFiles: fileCount,
        totalSizeBytes: totalSize,
        extensionCounts: extCounts,
      );

      return (rootNode: rootNode, stats: stats);
    } catch (e) {
      throw FileSystemException('Failed to scan directory: ${e.toString()}', path);
    }
  }
}
