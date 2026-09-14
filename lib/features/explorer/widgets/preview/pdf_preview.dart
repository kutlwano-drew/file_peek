import 'dart:io';
import 'dart:typed_data';

import 'package:dart_pdf_engine/dart_pdf_engine_viewer.dart';
import 'package:flutter/material.dart';

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
  PdfViewerController? _controller;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  @override
  void didUpdateWidget(covariant PdfPreview oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.path != widget.path) {
      _controller?.dispose();
      _controller = null;
      _error = null;
      _loading = true;

      _loadPdf();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _loadPdf() async {
    try {
      final file = File(widget.path);

      if (!await file.exists()) {
        throw Exception(
          'The PDF could not be found.\n\n${widget.path}',
        );
      }

      final bytes = await file.readAsBytes();

      if (bytes.isEmpty) {
        throw Exception('The PDF file is empty.');
      }

      final controller = PdfViewerController.fromBytes(
        Uint8List.fromList(bytes),
      );

      if (!mounted) {
        controller.dispose();
        return;
      }

      setState(() {
        _controller = controller;
        _error = null;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _controller = null;
        _error = _cleanError(error);
        _loading = false;
      });
    }
  }

  String _cleanError(Object error) {
    final text = error.toString();

    if (text.startsWith('Exception: ')) {
      return text.substring('Exception: '.length);
    }

    return text;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const _PdfLoading();
    }

    if (_error != null) {
      return _PdfError(
        message: _error!,
        onRetry: () {
          setState(() {
            _loading = true;
            _error = null;
          });

          _loadPdf();
        },
      );
    }

    final controller = _controller;

    if (controller == null) {
      return const _PdfError(
        message: 'No PDF document was loaded.',
      );
    }

    return ColoredBox(
      color: const Color(0xFFE5E7EB),
      child: PdfViewer(
        controller: controller,
        continuousScroll: true,
        enableZoom: true,
        minScale: 0.5,
        maxScale: 4.0,
        backgroundColor: const Color(0xFFE5E7EB),
        pageSpacing: 18,
        showNavigationControls: true,
        showPageIndicator: true,
      ),
    );
  }
}

class _PdfLoading extends StatelessWidget {
  const _PdfLoading();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFFE5E7EB),
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
            border: Border.fromBorderSide(
              BorderSide(
                color: Color(0xFFD1D5DB),
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x18000000),
                blurRadius: 14,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 28,
              vertical: 22,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  'Loading PDF…',
                  style: TextStyle(
                    color: Color(0xFF202124),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
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

class _PdfError extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _PdfError({
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFE5E7EB),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 560,
          ),
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFFD1D5DB),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x18000000),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.picture_as_pdf_outlined,
                size: 48,
                color: Color(0xFF5F6368),
              ),
              const SizedBox(height: 16),
              const Text(
                'Unable to load PDF',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF202124),
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              SelectableText(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF5F6368),
                  fontSize: 12,
                  height: 1.45,
                ),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 22),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try again'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}