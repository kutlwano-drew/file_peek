import 'dart:io';

class PathUtils {
  static String getBaseName(String path) {
    try {
      if (path.isEmpty) return '';
      return path.split(Platform.pathSeparator).where((s) => s.isNotEmpty).last;
    } catch (_) {
      return path;
    }
  }

  static String getParentPath(String path) {
    try {
      final dir = Directory(path);
      return dir.parent.path;
    } catch (_) {
      return path;
    }
  }
}
