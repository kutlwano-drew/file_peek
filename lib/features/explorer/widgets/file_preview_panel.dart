import 'package:file_peek/features/explorer/widgets/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/models/file_node.dart';
import '../../../core/services/app_preferences.dart';
import '../../../core/services/file_reader.dart';
import '../../../core/widgets/empty_state.dart';
import 'preview_toolbar.dart';

import 'preview/archive_preview.dart';
import 'preview/code_preview.dart';
import 'preview/database_preview.dart';
import 'preview/document_preview.dart';
import 'preview/image_preview.dart';
import 'preview/markdown_preview.dart';
import 'preview/media_preview.dart';
import 'preview/pdf_preview.dart';
import 'preview/preview_type.dart';
import 'preview/spreadsheet_preview.dart';
import 'preview/svg_preview.dart';
import 'preview/text_preview.dart';
import 'preview/unsupported_preview.dart';

class FilePreviewPanel extends StatefulWidget {
  final FileNode? selectedNode;
  final FileReaderResult? previewResult;

  const FilePreviewPanel({
    super.key,
    required this.selectedNode,
    required this.previewResult,
  });

  @override
  State<FilePreviewPanel> createState() => _FilePreviewPanelState();
}

class _FilePreviewPanelState extends State<FilePreviewPanel> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    if (widget.selectedNode == null) {
      return const EmptyState(
        icon: Icons.visibility_outlined,
        message: 'No file selected',
        subMessage:
            'Select a file from the directory tree to inspect its contents.',
      );
    }

    final node = widget.selectedNode!;
    final type = previewTypeFor(node.name);

    return Container(
      color: AppColors.backgroundDark,
      child: Column(
        children: [
          _PreviewHeader(
            node: node,
            type: type,
            content: widget.previewResult?.content,
          ),
      
          Expanded(
            child: _PreviewContent(
              node: node,
              result: widget.previewResult,
              type: type,
              searchQuery: _searchQuery,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// PREVIEW HEADER
// =============================================================================

class _PreviewHeader extends StatelessWidget {
  final FileNode node;
  final PreviewType type;
  final String? content;

  const _PreviewHeader({
    required this.node,
    required this.type,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 11, 12, 11),
      decoration: const BoxDecoration(
        color: Colors.black,
        border: Border(
          bottom: BorderSide(
            color: Colors.white24,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _iconForType(type),
              size: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        node.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 7),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Text(
                        '',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  node.path,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (content != null && content!.isNotEmpty)
            _CopyButton(content: content!),
        ],
      ),
    );
  }

  IconData _iconForType(PreviewType type) {
    switch (type.kind) {
      case 'image':
        return Icons.image_outlined;
      case 'pdf':
        return Icons.picture_as_pdf_outlined;
      case 'video':
        return Icons.video_file_outlined;
      case 'audio':
        return Icons.audio_file_outlined;
      case 'spreadsheet':
        return Icons.table_chart_outlined;
      case 'database':
        return Icons.storage_outlined;
      case 'archive':
        return Icons.archive_outlined;
      case 'document':
        return Icons.description_outlined;
      case 'markdown':
        return Icons.article_outlined;
      case 'code':
        return Icons.code_outlined;
      default:
        return Icons.text_snippet_outlined;
    }
  }
}
// =============================================================================
// COPY BUTTON
// =============================================================================

class _CopyButton extends StatelessWidget {
  final String content;

  const _CopyButton({
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Copy file content',
      onPressed: () async {
        final messenger = ScaffoldMessenger.of(context);

        final clipboardData = ClipboardData(text: content);
        await Clipboard.setData(clipboardData);

        if (!context.mounted) {
          return;
        }

        messenger.hideCurrentSnackBar();

        messenger.showSnackBar(
          const SnackBar(
            content: Text('File content copied to clipboard.'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      icon: const Icon(
        Icons.copy_outlined,
        size: 18,
      ),
    );
  }
}

// =============================================================================
// PREVIEW CONTENT DISPATCHER
// =============================================================================

class _PreviewContent extends StatelessWidget {
  final FileNode node;
  final FileReaderResult? result;
  final PreviewType type;
  final String searchQuery;

  const _PreviewContent({
    required this.node,
    required this.result,
    required this.type,
    required this.searchQuery,
  });

  bool _isCodeFile(String name) {
    final lower = name.toLowerCase();
    final ext = lower.contains('.') ? lower.split('.').last : '';
    const codeExtensions = {
      'dart', 'py', 'js', 'jsx', 'ts', 'tsx', 'java', 'kt', 'kts',
      'swift', 'rb', 'go', 'rs', 'php', 'c', 'h', 'hpp', 'cpp',
      'cc', 'cs', 'html', 'htm', 'xml', 'css', 'scss', 'json',
      'yaml', 'yml', 'sql', 'sh', 'bash', 'toml', 'env'
    };
    return codeExtensions.contains(ext);
  }

  String _filterContent(String input) {
    if (searchQuery.isEmpty) return input;

    final query = searchQuery.toLowerCase();
    final lines = input.split('\n');
    final matchingLines = lines
        .where((line) => line.toLowerCase().contains(query))
        .toList();

    if (matchingLines.isEmpty) {
      return 'No lines found matching "$searchQuery".';
    }

    return matchingLines.join('\n');
  }

  @override
  Widget build(BuildContext context) {
      final preferences = context.read<AppPreferences>();

  switch (type.kind) {
    case 'document':
      return DocumentPreview(
        path: node.path,
      );

      case 'image':
        if (node.name.toLowerCase().endsWith('.svg')) {
          return SvgPreview(path: node.path);
        }
        return ImagePreview(path: node.path);

      case 'pdf':
        return PdfPreview(path: node.path);

      case 'video':
        return MediaPreview(path: node.path, video: true);

      case 'audio':
        return MediaPreview(path: node.path, video: false);

      case 'spreadsheet':
        return SpreadsheetPreview(path: node.path);

      case 'database':
        return DatabasePreview(path: node.path);

      case 'archive':
        return ArchivePreview(path: node.path);
    }

    final bool isCode = type.kind == 'code' || _isCodeFile(node.name);

    if (result == null) {
      return FutureBuilder<FileReaderResult>(
        future: FileReader.readFile(node.path),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return _PreviewError(
              message: 'Failed to read file.',
              details: snapshot.error?.toString() ?? 'Unknown error',
            );
          }
          return _renderTextContent(
            context,
            snapshot.data!,
            isCode,
            preferences,
          );
        },
      );
    }

    return _renderTextContent(context, result!, isCode, preferences);
  }

  Widget _renderTextContent(
    BuildContext context,
    FileReaderResult fileResult,
    bool isCode,
    AppPreferences preferences,
  ) {
    if (fileResult.isLargeFile) {
      return const UnsupportedPreview(
        label: 'This file exceeds the configured preview size limit.',
      );
    }

    if (fileResult.isBinary) {
      return UnsupportedPreview(
        label: '${type.label} preview is not available.',
      );
    }

    final displayContent = _filterContent(fileResult.content);

    try {
      if (isCode) {
        return CodePreview(
          content: displayContent,
          language: _languageFor(node.name),
          fontSize: 23,
          lineNumbers: preferences.showLineNumbers,
        );
      }

      switch (type.kind) {
        case 'markdown':
          return MarkdownPreview(content: displayContent);

        case 'text':
        default:
          return TextPreview(
            content: displayContent,
            fontSize: preferences.previewFontSize,
            lineNumbers: preferences.showLineNumbers,
          );
      }
    } catch (error) {
      return _PreviewError(
        message: 'Preview failed safely.',
        details: error.toString(),
      );
    }
  }

  String _languageFor(String name) {
    final lower = name.toLowerCase();

    final extension = lower.contains('.')
        ? lower.substring(lower.lastIndexOf('.') + 1)
        : lower;

    const languages = {
      'dart': 'dart',
      'js': 'javascript',
      'jsx': 'javascript',
      'ts': 'typescript',
      'tsx': 'typescript',
      'java': 'java',
      'kt': 'kotlin',
      'kts': 'kotlin',
      'swift': 'swift',
      'py': 'python',
      'rb': 'ruby',
      'go': 'go',
      'rs': 'rust',
      'php': 'php',
      'c': 'c',
      'h': 'cpp',
      'hpp': 'cpp',
      'cpp': 'cpp',
      'cc': 'cpp',
      'cs': 'cs',
      'html': 'xml',
      'htm': 'xml',
      'xml': 'xml',
      'css': 'css',
      'scss': 'scss',
      'json': 'json',
      'yaml': 'yaml',
      'yml': 'yaml',
      'sql': 'sql',
      'sh': 'shell',
      'bash': 'shell',
    };

    return languages[extension] ?? 'plaintext';
  }
}

// =============================================================================
// SAFE PREVIEW ERROR
// =============================================================================

class _PreviewError extends StatelessWidget {
  final String message;
  final String details;

  const _PreviewError({
    required this.message,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 52,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            SelectableText(
              details,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}