import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgPreview extends StatelessWidget {
  final String path;

  const SvgPreview({
    super.key,
    required this.path,
  });

  @override
  Widget build(BuildContext c) => Center(
        child: InteractiveViewer(
          minScale: .5,
          maxScale: 8,
          child: SvgPicture.file(
            File(path),
            fit: BoxFit.contain,
          ),
        ),
      );
}