import 'package:flutter/material.dart';

class UnsupportedPreview extends StatelessWidget {
  final String label;

  const UnsupportedPreview({
    super.key,
    required this.label,
  });

  @override
  Widget build(BuildContext c) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.preview_outlined,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              '$label preview is not available.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'The file remains safely accessible on disk.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
}