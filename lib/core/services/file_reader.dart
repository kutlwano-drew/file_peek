import 'dart:io';

import '../../app/constants/app_constants.dart';
import '../../app/constants/file_types.dart';

class FileReaderResult {
  final String content;
  final bool isBinary;
  final bool isLargeFile;
  final int lineCount;
  final int wordCount;
  final int charCount;

  const FileReaderResult({
    required this.content,
    required this.isBinary,
    required this.isLargeFile,
    required this.lineCount,
    required this.wordCount,
    required this.charCount,
  });
}

class FileReader {
  static Future<FileReaderResult> readFile(
    String filePath,
  ) async {
    try {
      final file = File(filePath);

      if (!await file.exists()) {
        return const FileReaderResult(
          content: 'Error: File does not exist.',
          isBinary: false,
          isLargeFile: false,
          lineCount: 1,
          wordCount: 5,
          charCount: 27,
        );
      }

      final length = await file.length();

      final extension = filePath.contains('.')
          ? filePath
              .substring(filePath.lastIndexOf('.') + 1)
              .toLowerCase()
          : '';

      // ---------------------------------------------------------------
      // Binary files
      //
      // These are handled by the dedicated preview renderers.
      // FileReader should not attempt to read them as strings.
      // ---------------------------------------------------------------
      if (FileTypes.isBinary(extension)) {
        return const FileReaderResult(
          content: '',
          isBinary: true,
          isLargeFile: false,
          lineCount: 0,
          wordCount: 0,
          charCount: 0,
        );
      }

      // ---------------------------------------------------------------
      // Text preview size limit
      // ---------------------------------------------------------------
      final maxBytes =
          AppConstants.maxPreviewSizeMB * 1024 * 1024;

      if (length > maxBytes) {
        return FileReaderResult(
          content:
              '[File exceeds maximum preview size of '
              '${AppConstants.maxPreviewSizeMB} MB]',
          isBinary: false,
          isLargeFile: true,
          lineCount: 1,
          wordCount: 1,
          charCount: 0,
        );
      }

      // ---------------------------------------------------------------
      // Read text
      // ---------------------------------------------------------------
      final content = await file.readAsString();

      final lines = content.split('\n');

      final words = content
          .split(RegExp(r'\s+'))
          .where((word) => word.isNotEmpty)
          .length;

      return FileReaderResult(
        content: content,
        isBinary: false,
        isLargeFile: false,
        lineCount: lines.length,
        wordCount: words,
        charCount: content.length,
      );
    } catch (error) {
      return FileReaderResult(
        content: 'Error reading file: $error',
        isBinary: false,
        isLargeFile: false,
        lineCount: 1,
        wordCount: 1,
        charCount: 0,
      );
    }
  }
}