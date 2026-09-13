import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';

class CodePreview extends StatefulWidget {
  final String content;
  final String language;
  final double fontSize;
  final bool lineNumbers;

  const CodePreview({
    super.key,
    required this.content,
    required this.language,
    this.fontSize = 14, // Increased default font size for better readability
    this.lineNumbers = true,
  });

  @override
  State<CodePreview> createState() => _CodePreviewState();
}

class _CodePreviewState extends State<CodePreview> {
  late final ScrollController _verticalController;
  late final ScrollController _horizontalController;

  @override
  void initState() {
    super.initState();
    _verticalController = ScrollController();
    _horizontalController = ScrollController();
  }

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  String _normalizeLanguage(String langOrPath) {
    String ext = langOrPath.trim().toLowerCase();
    if (ext.contains('.')) {
      ext = ext.split('.').last;
    }

    switch (ext) {
      case 'py':
        return 'python';
      case 'js':
        return 'javascript';
      case 'ts':
        return 'typescript';
      case 'sh':
      case 'bash':
        return 'bash';
      case 'yml':
        return 'yaml';
      case 'md':
        return 'markdown';
      case 'kt':
        return 'kotlin';
      case 'rb':
        return 'ruby';
      case 'rs':
        return 'rust';
      case 'cs':
        return 'csharp';
      case 'cpp':
      case 'hpp':
      case 'cxx':
        return 'cpp';
      case 'c':
      case 'h':
        return 'c';
      case 'html':
      case 'htm':
        return 'xml';
      case 'json':
        return 'json';
      case 'dart':
        return 'dart';
      default:
        return ext.isEmpty ? 'plaintext' : ext;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lines = widget.content.split('\n');
    final String resolvedLanguage = _normalizeLanguage(widget.language);
    final double lineHeight = widget.fontSize * 1.6;

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFF282C34), // Standard Atom One Dark background
      child: Scrollbar(
        controller: _verticalController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _verticalController,
          scrollDirection: Axis.vertical,
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Line Numbers Column
                  if (widget.lineNumbers)
                    SizedBox(
                      width: 56,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          for (var i = 0; i < lines.length; i++)
                            SizedBox(
                              height: lineHeight,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: Text(
                                  '${i + 1}',
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: widget.fontSize - 1,
                                    height: 1.6,
                                    color: const Color(0xFF5C6370),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                  // Horizontal Code View
                  Expanded(
                    child: Scrollbar(
                      controller: _horizontalController,
                      thumbVisibility: true,
                      notificationPredicate: (notification) {
                        return notification.metrics.axis == Axis.horizontal;
                      },
                      child: SingleChildScrollView(
                        controller: _horizontalController,
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            // Guarantees code view stretches to at least 100% of the screen width
                            minWidth: constraints.maxWidth -
                                (widget.lineNumbers ? 56 : 0),
                          ),
                          child: HighlightView(
                            widget.content,
                            language: resolvedLanguage,
                            theme: atomOneDarkTheme,
                            padding: const EdgeInsets.only(
                              left: 12,
                              right: 32,
                              bottom: 24,
                            ),
                            textStyle: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: widget.fontSize,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}