import 'package:flutter/material.dart';

class TextPreview extends StatelessWidget {
  final String content;
  final double fontSize;
  final bool lineNumbers;

  const TextPreview({
    super.key,
    required this.content,
    this.fontSize = 13,
    this.lineNumbers = true,
  });

  @override
  Widget build(BuildContext c) {
    final lines = content.split('\n');

    return Container(
      color: Theme.of(c).colorScheme.surface,
      child: Scrollbar(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 20, 24, 40),
          child: SelectableText.rich(
            TextSpan(
              children: [
                for (var i = 0; i < lines.length; i++)
                  TextSpan(
                    text:
                        '${lineNumbers ? '${(i + 1).toString().padLeft(5)}  ' : ''}'
                        '${lines[i]}'
                        '${i < lines.length - 1 ? '\n' : ''}',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: fontSize,
                      height: 1.6,
                      color: Theme.of(c).colorScheme.onSurface,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}