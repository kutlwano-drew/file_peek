import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

class PdfPreview extends StatefulWidget {
  final String path;

  const PdfPreview({
    super.key,
    required this.path,
  });

  @override
  State<PdfPreview> createState() => _PdfPreviewState();
}

class _PdfPreviewState extends State<PdfPreview> {
  late final PdfViewerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PdfViewerController();
  }

  @override
  Widget build(BuildContext context) {
    return PdfViewer.file(
      widget.path,
      controller: _controller,
      params: const PdfViewerParams(
        maxScale: 4.0,
        minScale: 0.5,
      ),
    );
  }
}