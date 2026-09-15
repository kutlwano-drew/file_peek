import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart' as printing;

class PdfPreview extends StatefulWidget {
  const PdfPreview({
    super.key,
    required this.path,
  });

  final String path;

  @override
  State<PdfPreview> createState() => _PdfPreviewState();
}

class _PdfPreviewState extends State<PdfPreview> {
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _validatePdf();
  }

  @override
  void didUpdateWidget(covariant PdfPreview oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.path != widget.path) {
      setState(() {
        _error = null;
        _loading = true;
      });

      _validatePdf();
    }
  }

  Future<void> _validatePdf() async {
    try {
      final file = File(widget.path);

      if (!await file.exists()) {
        throw Exception('The PDF file does not exist.');
      }

      final length = await file.length();

      if (length == 0) {
        throw Exception('The PDF file is empty.');
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _error = null;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error = _cleanError(error);
        _loading = false;
      });
    }
  }

  Future<Uint8List> _loadPdf() async {
    final file = File(widget.path);

    if (!await file.exists()) {
      throw Exception('The PDF file does not exist.');
    }

    final bytes = await file.readAsBytes();

    if (bytes.isEmpty) {
      throw Exception('The PDF file is empty.');
    }

    return bytes;
  }

  String _cleanError(Object error) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length);
    }

    return message;
  }

  void _retry() {
    if (!mounted) {
      return;
    }

    setState(() {
      _error = null;
      _loading = true;
    });

    _validatePdf();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const _PdfLoading();
    }

    if (_error != null) {
      return _PdfError(
        message: _error!,
        onRetry: _retry,
      );
    }

    return ColoredBox(
      color: const Color(0xFFE5E7EB),
      child: printing.PdfPreview(
        build: (_) => _loadPdf(),
        allowPrinting: false,
        allowSharing: false,
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
      ),
    );
  }
}

class _PdfLoading extends StatelessWidget {
  const _PdfLoading();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFE5E7EB),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 420,
          ),
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.symmetric(
            horizontal: 28,
            vertical: 30,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE5E7EB),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                ),
              ),
              SizedBox(height: 18),
              Text(
                'Loading PDF…',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PdfError extends StatelessWidget {
  const _PdfError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFE5E7EB),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 480,
          ),
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE5E7EB),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.picture_as_pdf_outlined,
                size: 42,
                color: Color(0xFFDC2626),
              ),
              const SizedBox(height: 16),
              const Text(
                'Unable to load PDF',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 12),
              SelectableText(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(
                  Icons.refresh,
                  size: 18,
                ),
                label: const Text('Try again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}