import 'dart:io';
import 'package:path/path.dart' as p;

class StructureImportService {
  /// Generates the directory and file structure on disk based on the provided text.
  static Future<void> generateStructureOnDisk({
    required String targetDirectoryPath,
    required String structureText,
    required Function(String) onProgress,
  }) async {
    final lines = structureText.split('\n');
    
    // A stack to keep track of the current parent directory at a specific indentation level.
    // Key: Indentation length (number of spaces). Value: Absolute path to the directory.
    // We start with -1 representing the root target directory.
    final List<MapEntry<int, String>> directoryStack = [
      MapEntry(-1, targetDirectoryPath)
    ];

    for (String rawLine in lines) {
      if (rawLine.trim().isEmpty) continue;

      // 1. Strip comments (←, //, #) from the right side, but PRESERVE leading spaces!
      String line = _stripComments(rawLine);
      if (line.trim().isEmpty) continue;

      // 2. Normalize tree characters into spaces. 
      // This magically turns `├── ` into `    ` and `│   └── ` into `        `
      // allowing us to perfectly calculate the hierarchical depth.
      String spaceNormalizedLine = line.replaceAll(RegExp(r'[│├└─┌┬┐┴┘]'), ' ');

      // 3. Count exact indentation length
      int indent = 0;
      for (int i = 0; i < spaceNormalizedLine.length; i++) {
        String char = spaceNormalizedLine[i];
        // Check for normal space, non-breaking space (often in copy-paste), or tabs
        if (char == ' ' || char == '\u00A0') { 
          indent++;
        } else if (char == '\t') {
          indent += 4; // count tabs as 4 spaces
        } else {
          break;
        }
      }

      // 4. Extract the clean file/folder name
      String cleanName = spaceNormalizedLine.trim();
      if (cleanName.endsWith('/')) {
        cleanName = cleanName.substring(0, cleanName.length - 1).trim();
      }
      if (cleanName.endsWith(':')) {
        cleanName = cleanName.substring(0, cleanName.length - 1).trim();
      }
      if (cleanName.isEmpty) continue;

      // 5. Determine the correct parent directory
      // Pop items off the stack until we find a parent with a SMALLER indentation
      while (directoryStack.isNotEmpty && directoryStack.last.key >= indent) {
        directoryStack.removeLast();
      }

      // The last remaining item in the stack is our true parent directory
      String parentPath = directoryStack.last.value;
      String fullPath = p.join(parentPath, cleanName);

      onProgress('Creating: $cleanName');

      // 6. Create the File or Directory
      bool isFile = _isFileName(cleanName, rawLine);

      if (isFile) {
        final file = File(fullPath);
        await file.parent.create(recursive: true);
        if (!await file.exists()) {
          await file.writeAsString(''); // Create the empty file
        }
      } else {
        final directory = Directory(fullPath);
        await directory.create(recursive: true);
        
        // Because this is a directory, push it to the stack so children can nest inside it!
        directoryStack.add(MapEntry(indent, fullPath));
      }
    }
  }

  /// Removes trailing comments while strictly preserving all left-side indentation
  static String _stripComments(String line) {
    final commentMarkers = ['←', '//', '#'];
    for (final marker in commentMarkers) {
      if (line.contains(marker)) {
        line = line.substring(0, line.indexOf(marker));
      }
    }
    return line.trimRight(); // Only trim the right side to keep structural spaces
  }

  /// Checks if a line represents a file vs a directory
  static bool _isFileName(String cleanName, String rawLine) {
    // If the original string explicitly ended with a slash before the comment, it's a folder
    String beforeComment = _stripComments(rawLine).trimRight();
    if (beforeComment.endsWith('/')) return false;
    if (beforeComment.endsWith(':')) return false;

    // Otherwise, if it has a file extension (like .dart, .yaml), it is a file
    final extension = p.extension(cleanName);
    return extension.isNotEmpty;
  }
}
