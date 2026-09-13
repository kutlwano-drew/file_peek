import 'dart:io';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SfPdfViewer.file(
      File(widget.path),
      controller: _controller,
      pageLayoutMode: PdfPageLayoutMode.continuous,
      scrollDirection: PdfScrollDirection.vertical,
      enableDoubleTapZooming: true,
      enableTextSelection: true,
      interactionMode: PdfInteractionMode.selection,
      canShowScrollHead: true,
      canShowScrollStatus: true,
      pageSpacing: 18,
    );
  }
}