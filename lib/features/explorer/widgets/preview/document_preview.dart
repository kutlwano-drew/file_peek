import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class DocumentPreview extends StatefulWidget {
  final String path;

  const DocumentPreview({
    super.key,
    required this.path,
  });

  @override
  State<DocumentPreview> createState() => _DocumentPreviewState();
}

class _DocumentPreviewState extends State<DocumentPreview> {
  String? _pdfPath;
  String? _error;
  bool _loading = true;

  Directory? _workingDirectory;

  @override
  void initState() {
    super.initState();
    _convertDocument();
  }

  @override
  void didUpdateWidget(covariant DocumentPreview oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.path != widget.path) {
      _cleanupWorkingDirectory();

      _pdfPath = null;
      _error = null;
      _loading = true;

      _convertDocument();
    }
  }

  @override
  void dispose() {
    _cleanupWorkingDirectory();
    super.dispose();
  }

  Future<void> _convertDocument() async {
    final source = File(widget.path);

    if (!await source.exists()) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = 'The document could not be found.\n\n${widget.path}';
      });

      return;
    }

    final extension = _extension(widget.path);

    if (extension != 'doc' && extension != 'docx') {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error =
            'Unsupported document format.\n\n'
            'Supported formats: .doc and .docx';
      });

      return;
    }

    try {
      final tempRoot = await getTemporaryDirectory();

      final timestamp = DateTime.now().microsecondsSinceEpoch;

      final workDir = Directory(
        '${tempRoot.path}${Platform.pathSeparator}'
        'file_peek_document_$timestamp',
      );

      await workDir.create(recursive: true);

      _workingDirectory = workDir;

      final outputDirectory = Directory(
        '${workDir.path}${Platform.pathSeparator}output',
      );

      final profileDirectory = Directory(
        '${workDir.path}${Platform.pathSeparator}libreoffice_profile',
      );

      await outputDirectory.create(recursive: true);
      await profileDirectory.create(recursive: true);

      final soffice = await _findLibreOffice();

      if (soffice == null) {
        throw Exception(
          'LibreOffice was not found.\n\n'
          'Please install LibreOffice and make sure it is available '
          'on your system.',
        );
      }

      final outputPdfName = '${_fileStem(widget.path)}.pdf';

      final expectedPdf = File(
        '${outputDirectory.path}${Platform.pathSeparator}'
        '$outputPdfName',
      );

      final profileUri = profileDirectory.uri.toString();

      final arguments = <String>[
        '--headless',
        '--nologo',
        '--nodefault',
        '--nofirststartwizard',
        '-env:UserInstallation=$profileUri',
        '--convert-to',
        'pdf:writer_pdf_Export',
        '--outdir',
        outputDirectory.path,
        source.path,
      ];

      final result = await Process.run(
        soffice,
        arguments,
        runInShell: false,
      );

      if (result.exitCode != 0) {
        final stdout = result.stdout.toString().trim();
        final stderr = result.stderr.toString().trim();

        throw Exception(
          'LibreOffice failed to render the document.\n\n'
          '${stderr.isNotEmpty ? stderr : stdout}',
        );
      }

      var attempts = 0;

      while (!await expectedPdf.exists() && attempts < 50) {
        attempts++;

        await Future<void>.delayed(
          const Duration(milliseconds: 100),
        );
      }

      if (!await expectedPdf.exists()) {
        final stdout = result.stdout.toString().trim();
        final stderr = result.stderr.toString().trim();

        throw Exception(
          'LibreOffice did not produce a PDF.\n\n'
          '${stderr.isNotEmpty ? stderr : stdout}',
        );
      }

      final pdfLength = await expectedPdf.length();

      if (pdfLength == 0) {
        throw Exception(
          'LibreOffice produced an empty PDF.',
        );
      }

      if (!mounted) return;

      setState(() {
        _pdfPath = expectedPdf.path;
        _loading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = _cleanError(error);
      });
    }
  }

  Future<String?> _findLibreOffice() async {
    if (Platform.isWindows) {
      return _findLibreOfficeWindows();
    }

    if (Platform.isMacOS) {
      return _findLibreOfficeMacOS();
    }

    if (Platform.isLinux) {
      return _findLibreOfficeLinux();
    }

    return null;
  }

  Future<String?> _findLibreOfficeLinux() async {
    const candidates = <String>[
      'soffice',
      'libreoffice',
    ];

    for (final executable in candidates) {
      final found = await _findExecutableInPath(executable);

      if (found != null) {
        return found;
      }
    }

    const locations = <String>[
      '/usr/bin/soffice',
      '/usr/local/bin/soffice',
      '/usr/bin/libreoffice',
      '/usr/local/bin/libreoffice',
      '/snap/bin/libreoffice',
    ];

    for (final path in locations) {
      if (await File(path).exists()) {
        return path;
      }
    }

    return null;
  }

  Future<String?> _findLibreOfficeWindows() async {
    const candidates = <String>[
      'soffice.exe',
      'libreoffice.exe',
    ];

    for (final executable in candidates) {
      final found = await _findExecutableInPath(executable);

      if (found != null) {
        return found;
      }
    }

    final programFiles = Platform.environment['PROGRAMFILES'];
    final programFilesX86 = Platform.environment['PROGRAMFILES(X86)'];
    final localAppData = Platform.environment['LOCALAPPDATA'];

    final locations = <String>[
      if (programFiles != null)
        '$programFiles\\LibreOffice\\program\\soffice.exe',
      if (programFilesX86 != null)
        '$programFilesX86\\LibreOffice\\program\\soffice.exe',
      if (localAppData != null)
        '$localAppData\\Programs\\LibreOffice\\program\\soffice.exe',
    ];

    for (final path in locations) {
      if (await File(path).exists()) {
        return path;
      }
    }

    return null;
  }

  Future<String?> _findLibreOfficeMacOS() async {
    const candidates = <String>[
      'soffice',
      'libreoffice',
    ];

    for (final executable in candidates) {
      final found = await _findExecutableInPath(executable);

      if (found != null) {
        return found;
      }
    }

    const locations = <String>[
      '/Applications/LibreOffice.app/Contents/MacOS/soffice',
      '/Applications/LibreOffice.app/Contents/MacOS/python',
    ];

    for (final path in locations) {
      if (await File(path).exists()) {
        return path;
      }
    }

    final home = Platform.environment['HOME'];

    if (home != null) {
      final userPath =
          '$home/Applications/LibreOffice.app/Contents/MacOS/soffice';

      if (await File(userPath).exists()) {
        return userPath;
      }
    }

    return null;
  }

  Future<String?> _findExecutableInPath(
    String executable,
  ) async {
    try {
      final command = Platform.isWindows ? 'where' : 'which';

      final result = await Process.run(
        command,
        [executable],
        runInShell: false,
      );

      if (result.exitCode == 0) {
        final output = result.stdout.toString().trim();

        if (output.isNotEmpty) {
          final firstLine = output
              .split(RegExp(r'[\r\n]+'))
              .first
              .trim();

          if (firstLine.isNotEmpty) {
            return firstLine;
          }
        }
      }
    } catch (_) {}

    try {
      final result = await Process.run(
        executable,
        const ['--version'],
        runInShell: false,
      );

      if (result.exitCode == 0) {
        return executable;
      }
    } catch (_) {}

    return null;
  }

  String _extension(String path) {
    final name = path.split(Platform.pathSeparator).last;

    final dot = name.lastIndexOf('.');

    if (dot == -1 || dot == name.length - 1) {
      return '';
    }

    return name.substring(dot + 1).toLowerCase();
  }

  String _fileStem(String path) {
    final name = path.split(Platform.pathSeparator).last;

    final dot = name.lastIndexOf('.');

    if (dot <= 0) {
      return name;
    }

    return name.substring(0, dot);
  }

  String _cleanError(Object error) {
    final text = error.toString();

    if (text.startsWith('Exception: ')) {
      return text.substring('Exception: '.length);
    }

    return text;
  }

  void _cleanupWorkingDirectory() {
    final directory = _workingDirectory;

    _workingDirectory = null;

    if (directory == null) {
      return;
    }

    unawaited(
      directory.delete(recursive: true).catchError(
        (_) {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const _DocumentLoading();
    }

    if (_error != null) {
      return _DocumentError(
        message: 'Unable to render document',
        details: _error!,
        onRetry: () {
          setState(() {
            _loading = true;
            _error = null;
            _pdfPath = null;
          });

          _convertDocument();
        },
      );
    }

    final pdfPath = _pdfPath;

    if (pdfPath == null) {
      return const _DocumentError(
        message: 'Unable to render document',
        details: 'No rendered document was produced.',
      );
    }

    return Theme(
      data: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF185ABD),
          surface: Color(0xFFE5E7EB),
          onSurface: Colors.black,
        ),
      ),
      child: ColoredBox(
        color: const Color(0xFFE5E7EB),
        child: _PdfViewer(
          pdfPath: pdfPath,
        ),
      ),
    );
  }
}

class _PdfViewer extends StatefulWidget {
  final String pdfPath;

  const _PdfViewer({
    required this.pdfPath,
  });

  @override
  State<_PdfViewer> createState() => _PdfViewerState();
}

class _PdfViewerState extends State<_PdfViewer> {
  final PdfViewerController _controller = PdfViewerController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: SfPdfViewer.file(
        File(widget.pdfPath),
        controller: _controller,
        pageLayoutMode: PdfPageLayoutMode.continuous,
        scrollDirection: PdfScrollDirection.vertical,
        canShowScrollHead: true,
        canShowScrollStatus: true,
        enableDoubleTapZooming: true,
        enableTextSelection: true,
        interactionMode: PdfInteractionMode.selection,
        pageSpacing: 18,
        onDocumentLoadFailed: (details) {
          debugPrint(
            'PDF viewer failed to load document: '
            '${details.error}',
          );
        },
      ),
    );
  }
}

class _DocumentLoading extends StatelessWidget {
  const _DocumentLoading();

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
                  'Rendering document…',
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

class _DocumentError extends StatelessWidget {
  final String message;
  final String details;
  final VoidCallback? onRetry;

  const _DocumentError({
    required this.message,
    required this.details,
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
                Icons.description_outlined,
                size: 48,
                color: Color(0xFF5F6368),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF202124),
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              SelectableText(
                details,
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