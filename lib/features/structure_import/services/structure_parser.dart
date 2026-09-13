import 'dart:io';

class StructureParser {
  /// Parses text input representing a directory/file tree and generates it on disk.
  static Future<int> generateStructureOnDisk(String rawInput, String targetParentPath) async {
    final lines = rawInput.split('\n');
    int createdCount = 0;
    
    // Stack to track current directory paths at each indentation level
    final Map<int, String> directoryStack = {};
    directoryStack[0] = targetParentPath;

    for (var line in lines) {
      if (line.trim().isEmpty) continue;

      // Calculate indentation level based on leading spaces/tree characters
      final indentLevel = _calculateIndentLevel(line);
      final cleanName = _cleanNodeName(line);

      if (cleanName.isEmpty) continue;

      // Determine parent path based on indentation depth
      int parentIndent = indentLevel - 1;
      while (parentIndent >= 0 && !directoryStack.containsKey(parentIndent)) {
        parentIndent--;
      }
      final parentPath = directoryStack[parentIndent] ?? targetParentPath;

      final currentPath = '$parentPath${Platform.pathSeparator}$cleanName';

      if (_isLikelyFile(cleanName)) {
        // Create parent directories if missing, then create an empty file
        final file = File(currentPath);
        await file.parent.create(recursive: true);
        if (!await file.exists()) {
          await file.writeAsString('');
          createdCount++;
        }
      } else {
        // Create directory
        final dir = Directory(currentPath);
        await dir.create(recursive: true);
        directoryStack[indentLevel] = currentPath;
        createdCount++;
      }
    }

    return createdCount;
  }

  static int _calculateIndentLevel(String line) {
    int spaces = 0;
    for (int i = 0; i < line.length; i++) {
      if (line[i] == ' ' || line[i] == '│' || line[i] == '├' || line[i] == '└' || line[i] == '─') {
        spaces++;
      } else {
        break;
      }
    }
    return (spaces / 2).floor();
  }

  static String _cleanNodeName(String line) {
    return line
        .replaceAll(RegExp(r'[│├└─\|\s]+'), ' ')
        .trim();
  }

  static bool _isLikelyFile(String name) {
    // If it has a dot with an extension (and isn't just a hidden file like .gitignore or a trailing dot)
    if (name.contains('.') && !name.endsWith('.')) {
      final parts = name.split('.');
      if (parts.last.length <= 5 && parts.last.isNotEmpty) {
        return true;
      }
    }
    // Files without extensions or special file names
    if (name == 'pubspec.yaml' || name == 'Dockerfile' || name == 'Makefile' || name == 'README' || name == 'LICENSE') {
      return true;
    }
    return false;
  }
}
