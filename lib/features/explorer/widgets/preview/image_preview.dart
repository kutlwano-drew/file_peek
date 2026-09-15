import 'dart:io';

import 'package:flutter/material.dart';

class ImagePreview extends StatelessWidget {
  final String path;

  const ImagePreview({
    super.key,
    required this.path,
  });

  @override
  Widget build(BuildContext c) {
    return Center(
      child: InteractiveViewer(
        minScale: .5,
        maxScale: 8,
        child: Image.file(
          File(path),
          fit: BoxFit.contain,
          errorBuilder: (_, e, st) => const _Error(
            'Unable to render image',
          ),
        ),
      ),
    );
  }
}

class _Error extends StatelessWidget {
  final String text;

  const _Error(this.text);

  @override
  Widget build(BuildContext c) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            text,
            textAlign: TextAlign.center,
          ),
        ),
      );
}