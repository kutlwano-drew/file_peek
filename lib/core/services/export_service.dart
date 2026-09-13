import 'dart:io';
import '../models/file_node.dart';
import '../models/export_options.dart';
import 'tree_generator.dart';
import 'file_reader.dart';

class ExportService {
  static Future<String> exportTreeContent(FileNode root, ExportOptions options) async {
    try {
      final buffer = StringBuffer();
      if (options.includeRootFolder) {
        buffer.writeln(root.name);
      }
      buffer.write(TreeGenerator.generateAsciiTree(root, useUnicode: options.useUnicodeTree));
      return buffer.toString();
    } catch (e) {
      return 'Error generating tree export: ${e.toString()}';
    }
  }

  static Future<String> exportProjectContent(
    FileNode root,
    ExportOptions options, {
    int layoutStyle = 2, // 1 = Inline Layout, 2 = Bottom Blocks
    void Function(String)? onProgress,
  }) async {
    try {
      if (layoutStyle == 1) {
        return await _exportInlineContent(root, options, '', onProgress);
      } else {
        return await _exportBottomBlocksContent(root, options, onProgress);
      }
    } catch (e) {
      return 'Error generating project export: ${e.toString()}';
    }
  }

static Future<String> _exportBottomBlocksContent(
    FileNode root,
    ExportOptions options,
    void Function(String)? onProgress,
  ) async {
    final buffer = StringBuffer();
    buffer.writeln('=== PROJECT STRUCTURE ===\n');
    buffer.writeln(await exportTreeContent(root, options));
    buffer.writeln('=== FILE CONTENTS ===\n');

    Future<void> appendFiles(FileNode node) async {
      if (node.isDirectory) {
        for (final child in (node.children ?? [])) {
          await appendFiles(child);
        }
      } else {
        if (options.skipHiddenFiles && node.isHidden) return;
        if (options.skipBinaryFiles && node.sizeBytes > (options.maxFileSizeKB * 1024)) return;

        onProgress?.call(node.path);
        buffer.writeln('--------------------------------------------------');
        buffer.writeln('FILE: ${node.path}');
        if (options.includeMetadata) {
          final dt = node.lastModified;
          final modStr = '${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
          buffer.writeln('SIZE: ${node.formattedSize} | MODIFIED: $modStr');
        }
        buffer.writeln('--------------------------------------------------\n');

        final fileResult = await FileReader.readFile(node.path);
        if (!fileResult.isBinary) {
          final content = fileResult.content.trim();
          if (content.isNotEmpty) {
            buffer.writeln(content);
          } else {
            buffer.writeln('{no content}');
          }
        } else {
          buffer.writeln('[Binary file omitted]');
        }
        buffer.writeln('\n');
      }
    }

    await appendFiles(root);
    return buffer.toString();
  }
static Future<String> _exportInlineContent(
    FileNode root,
    ExportOptions options,
    String prefix,
    void Function(String)? onProgress,
  ) async {
    final buffer = StringBuffer();
    buffer.writeln(root.name);

    if (!root.isDirectory) {
      if (!(options.skipHiddenFiles && root.isHidden)) {
        if (!(options.skipBinaryFiles && root.sizeBytes > (options.maxFileSizeKB * 1024))) {
          onProgress?.call(root.path);
          buffer.writeln('$prefix    --- CONTENT ---');
          try {
            final fileResult = await FileReader.readFile(root.path);
            if (!fileResult.isBinary) {
              final content = fileResult.content.trim();
              if (content.isNotEmpty) {
                for (final line in content.split('\n')) {
                  buffer.writeln('$prefix    $line');
                }
              } else {
                buffer.writeln('$prefix    {no content available}');
              }
            } else {
              buffer.writeln('$prefix    [Binary file omitted]');
            }
          } catch (_) {
            buffer.writeln('$prefix    [Error reading file]');
          }
        }
      }
    }

    final children = (root.children ?? []).where((child) {
      if (options.skipHiddenFiles && child.isHidden) return false;
      return true;
    }).toList();

    for (int i = 0; i < children.length; i++) {
      final child = children[i];
      final isLast = i == children.length - 1;
      final pointer = isLast ? '└── ' : '├── ';

      buffer.write('$prefix$pointer');
      final subContent = await _exportInlineContent(
        child,
        options,
        prefix + (isLast ? '    ' : '│   '),
        onProgress,
      );
      buffer.write(subContent);
    }

    return buffer.toString();
  }

  static Future<bool> saveExportToFile(String content, String defaultFileName) async {
    try {
      final file = File(defaultFileName);
      await file.writeAsString(content);
      return true;
    } catch (_) {
      return false;
    }
  }
}
