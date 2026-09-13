import '../models/file_node.dart';

class TreeGenerator {
  static String generateAsciiTree(FileNode node, {bool useUnicode = true, String prefix = ''}) {
    final buffer = StringBuffer();
    final children = node.children ?? [];

    for (int i = 0; i < children.length; i++) {
      final child = children[i];
      final isLast = i == children.length - 1;

      final pointer = useUnicode
          ? (isLast ? '└── ' : '├── ')
          : (isLast ? '\\-- ' : '|-- ');

      buffer.writeln('$prefix$pointer${child.name}');

      if (child.isDirectory && child.children != null && child.children!.isNotEmpty) {
        final extensionPrefix = useUnicode
            ? (isLast ? '    ' : '│   ')
            : (isLast ? '    ' : '|   ');
        buffer.write(generateAsciiTree(child, useUnicode: useUnicode, prefix: prefix + extensionPrefix));
      }
    }

    return buffer.toString();
  }
}
