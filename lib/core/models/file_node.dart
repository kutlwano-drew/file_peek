import 'dart:io';

class FileNode {
  final String path;
  final String name;
  final bool isDirectory;
  final int sizeBytes;
  final DateTime lastModified;
  final String extension;
  List<FileNode>? children;
  bool isExpanded;
  bool isHidden;

  FileNode({
    required this.path,
    required this.name,
    required this.isDirectory,
    required this.sizeBytes,
    required this.lastModified,
    required this.extension,
    this.children,
    this.isExpanded = false,
    this.isHidden = false,
  });

  factory FileNode.fromEntity(FileSystemEntity entity, {bool isHidden = false}) {
    final name = entity.uri.pathSegments.where((s) => s.isNotEmpty).last;
    final isDir = entity is Directory;
    int size = 0;
    DateTime modified = DateTime.now();

    try {
      if (!isDir && entity is File) {
        size = entity.lengthSync();
        modified = entity.statSync().modified;
      } else if (isDir && entity is Directory) {
        modified = entity.statSync().modified;
      }
    } catch (_) {
      // Defensive fallback if permissions or locks fail
    }

    final ext = isDir ? '' : (name.contains('.') ? name.split('.').last : '');

    return FileNode(
      path: entity.path,
      name: name,
      isDirectory: isDir,
      sizeBytes: size,
      lastModified: modified,
      extension: ext,
      children: isDir ? [] : null,
      isHidden: name.startsWith('.'),
    );
  }

  String get formattedSize {
    if (isDirectory) return '';
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    if (sizeBytes < 1024 * 1024 * 1024) return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(sizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
