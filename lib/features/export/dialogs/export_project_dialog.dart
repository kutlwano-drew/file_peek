import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../core/models/file_node.dart';
import '../../../core/models/export_options.dart';
import '../../../core/services/export_service.dart';
import '../../../core/services/clipboard_service.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../widgets/export_progress_dialog.dart';

class ExportProjectDialog extends StatefulWidget {
  final FileNode rootNode;

  const ExportProjectDialog({
    super.key,
    required this.rootNode,
  });

  @override
  State<ExportProjectDialog> createState() => _ExportProjectDialogState();
}

class _ExportProjectDialogState extends State<ExportProjectDialog> {
  int _exportMode = 1;
  int _contentsLayout = 1;

  String _format = 'clipboard';

  bool _isProcessing = false;

  String? _selectedTargetDirectory;

  String _statusMessage = '';

  Future<void> _showErrorDialog(String message) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: Colors.redAccent,
              ),
              SizedBox(width: 10),
              Text(
                'Export failed',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.45,
            ),
          ),
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showSuccessDialog({
    required String filePath,
    required String format,
  }) async {
    if (!mounted) return;

    final String fileName = filePath.split(Platform.pathSeparator).last;
    final String directory =
        File(filePath).parent.path;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceDark,
          elevation: 16,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          titlePadding: const EdgeInsets.fromLTRB(26, 24, 26, 8),
          contentPadding: const EdgeInsets.fromLTRB(26, 8, 26, 8),
          actionsPadding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          title: const Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: Colors.greenAccent,
                size: 28,
              ),
              SizedBox(width: 12),
              Text(
                'Export complete',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 430,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your export was successfully created.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.borderDark,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        format == 'pdf'
                            ? Icons.picture_as_pdf_rounded
                            : Icons.description_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              fileName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              directory,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Expanded(
              child: SizedBox(
                height: 44,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 44,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(
                    Icons.folder_open_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'View item location',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onPressed: () async {
                    await _openDirectory(directory);

                    if (dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                    }
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openDirectory(String directory) async {
    try {
      if (Platform.isLinux) {
        await Process.run(
          'xdg-open',
          [directory],
        );
      } else if (Platform.isMacOS) {
        await Process.run(
          'open',
          [directory],
        );
      } else if (Platform.isWindows) {
        await Process.run(
          'explorer',
          [directory],
        );
      } else {
        throw UnsupportedError(
          'Opening folders is not supported on this platform.',
        );
      }
    } catch (e) {
      if (!mounted) return;

      await _showErrorDialog(
        'The export was successful, but File Peek could not open the destination folder.\n\n$e',
      );
    }
  }

  Future<String?> _askForFileName({
    required String extension,
    required String suggestedName,
    required String title,
  }) async {
    final controller = TextEditingController(
      text: suggestedName,
    );

    String? result;

    try {
      result = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          String? validationError;

          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                backgroundColor: AppColors.surfaceDark,
                elevation: 16,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                titlePadding:
                    const EdgeInsets.fromLTRB(26, 24, 26, 8),
                contentPadding:
                    const EdgeInsets.fromLTRB(26, 8, 26, 8),
                actionsPadding:
                    const EdgeInsets.fromLTRB(20, 12, 20, 20),
                title: Row(
                  children: [
                    Icon(
                      extension == 'pdf'
                          ? Icons.picture_as_pdf_rounded
                          : Icons.description_rounded,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                content: SizedBox(
                  width: 440,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Choose a name for your exported file.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: controller,
                        autofocus: true,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                        ),
                        onSubmitted: (_) {
                          final name =
                              _sanitizeFileName(
                            controller.text,
                            extension,
                          );

                          if (name == null) {
                            setDialogState(() {
                              validationError =
                                  'Please enter a valid file name.';
                            });
                            return;
                          }

                          Navigator.of(dialogContext).pop(name);
                        },
                        decoration: InputDecoration(
                          labelText: 'File name',
                          hintText: 'Enter a name',
                          suffixText: '.$extension',
                          labelStyle: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                          hintStyle: const TextStyle(
                            color: AppColors.textMuted,
                          ),
                          suffixStyle: const TextStyle(
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                          filled: true,
                          fillColor:
                              AppColors.backgroundDark,
                          errorText: validationError,
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 15,
                            color: AppColors.textMuted,
                          ),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'You do not need to type the file extension.',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () =>
                        Navigator.of(dialogContext).pop(),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      final name =
                          _sanitizeFileName(
                        controller.text,
                        extension,
                      );

                      if (name == null) {
                        setDialogState(() {
                          validationError =
                              'Please enter a valid file name.';
                        });
                        return;
                      }

                      Navigator.of(dialogContext)
                          .pop(name);
                    },
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      controller.dispose();
    }

    return result;
  }

  String? _sanitizeFileName(
    String value,
    String extension,
  ) {
    String name = value.trim();

    if (name.isEmpty) {
      return null;
    }

    if (name.toLowerCase().endsWith('.$extension')) {
      name = name.substring(
        0,
        name.length - extension.length - 1,
      );
    }

    name = name.trim();

    if (name.isEmpty) {
      return null;
    }

    if (name.contains('/') ||
        name.contains('\\') ||
        name.contains(':') ||
        name.contains('*') ||
        name.contains('?') ||
        name.contains('"') ||
        name.contains('<') ||
        name.contains('>') ||
        name.contains('|')) {
      return null;
    }

    return '$name.$extension';
  }

  Future<void> _showProgressDialog(
    ValueNotifier<String> progressMessage,
  ) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return ExportProgressDialog(
message: progressMessage.value,        );
      },
    );
  }

Future<void> _saveAsPdf(
  String directory,
  String fileName,
  String content,
  ValueNotifier<String> progressMessage,
) async {
  progressMessage.value = 'Preparing your PDF...';

  final regularData = await rootBundle.load(
    'assets/fonts/GoogleSans-Regular.ttf',
  );

  final mediumData = await rootBundle.load(
    'assets/fonts/GoogleSans-Medium.ttf',
  );

  final boldData = await rootBundle.load(
    'assets/fonts/GoogleSans-Bold.ttf',
  );

  final monoData = await rootBundle.load(
    'assets/fonts/DejaVuSansMono.ttf',
  );

  progressMessage.value = 'Building the PDF document...';

  final regularFont = PdfTrueTypeFont(
    regularData.buffer.asUint8List(),
    9.5,
  );

  final mediumFont = PdfTrueTypeFont(
    mediumData.buffer.asUint8List(),
    9.5,
  );

  final boldFont = PdfTrueTypeFont(
    boldData.buffer.asUint8List(),
    16,
  );

  final smallBoldFont = PdfTrueTypeFont(
    boldData.buffer.asUint8List(),
    9,
  );

  final treeFont = PdfTrueTypeFont(
    monoData.buffer.asUint8List(),
    8.5,
  );

  final document = PdfDocument();

  document.pageSettings.size = PdfPageSize.a4;

  const double marginLeft = 42;
  const double marginRight = 42;
  const double marginTop = 40;
  const double marginBottom = 42;

  final double pageWidth = PdfPageSize.a4.width;
  final double pageHeight = PdfPageSize.a4.height;

  final double contentWidth =
      pageWidth - marginLeft - marginRight;

  final List<String> lines = content.split('\n');

  const double lineHeight = 12;
  const double headerHeight = 82;

  // Space reserved for the footer.
  const double footerHeight = 30;

  // Extra space between the content and footer.
  const double footerGap = 14;

  final double contentStartY =
      marginTop + headerHeight;

  // Reserve the footer and a gap above it so the file
  // structure cannot run into the footer.
  final double availableHeight =
      pageHeight -
      contentStartY -
      marginBottom -
      footerHeight -
      footerGap;

  final int linesPerPage =
      math.max(
        1,
        (availableHeight / lineHeight).floor(),
      );

  final List<List<String>> pages = [];

  for (
    int i = 0;
    i < lines.length;
    i += linesPerPage
  ) {
    final int end = math.min(
      i + linesPerPage,
      lines.length,
    );

    pages.add(
      lines.sublist(i, end),
    );
  }

  if (pages.isEmpty) {
    pages.add([]);
  }

  for (
    int pageIndex = 0;
    pageIndex < pages.length;
    pageIndex++
  ) {
    progressMessage.value =
        'Building PDF page ${pageIndex + 1} of ${pages.length}...';

    final page = document.pages.add();

    // Header background.
    page.graphics.drawRectangle(
      brush: PdfSolidBrush(
        PdfColor(247, 249, 252),
      ),
      bounds: Rect.fromLTWH(
        0,
        0,
        pageWidth,
        92,
      ),
    );

    // Small accent line.
    page.graphics.drawRectangle(
      brush: PdfSolidBrush(
        PdfColor(42, 110, 210),
      ),
      bounds: Rect.fromLTWH(
        0,
        0,
        pageWidth,
        4,
      ),
    );

    // Document title.
    page.graphics.drawString(
      fileName.replaceFirst(
        RegExp(r'\.pdf$', caseSensitive: false),
        '',
      ),
      boldFont,
      bounds: Rect.fromLTWH(
        marginLeft,
        marginTop - 4,
        contentWidth,
        24,
      ),
    );

    // Subtitle.
    page.graphics.drawString(
      'Project documentation export',
      mediumFont,
      bounds: Rect.fromLTWH(
        marginLeft,
        marginTop + 24,
        contentWidth,
        16,
      ),
      brush: PdfSolidBrush(
        PdfColor(95, 105, 120),
      ),
    );

    // Header metadata.
    page.graphics.drawString(
      'FILE PEEK',
      smallBoldFont,
      bounds: Rect.fromLTWH(
        marginLeft,
        marginTop + 48,
        100,
        15,
      ),
      brush: PdfSolidBrush(
        PdfColor(42, 110, 210),
      ),
    );

    // Page number intentionally removed from the header.
    // It is now displayed in the footer.

    // Section label.
    page.graphics.drawString(
      'PROJECT CONTENT',
      smallBoldFont,
      bounds: Rect.fromLTWH(
        marginLeft,
        contentStartY - 22,
        contentWidth,
        15,
      ),
      brush: PdfSolidBrush(
        PdfColor(95, 105, 120),
      ),
    );

    // Content card.
    page.graphics.drawRectangle(
      pen: PdfPen(
        PdfColor(224, 228, 234),
        width: 0.8,
      ),
      brush: PdfSolidBrush(
        PdfColor(255, 255, 255),
      ),
      bounds: Rect.fromLTWH(
        marginLeft - 8,
        contentStartY - 4,
        contentWidth + 16,
        availableHeight + 8,
      ),
    );

    final pageContent =
        pages[pageIndex].join('\n');

    if (pageContent.isNotEmpty) {
      final treeElement = PdfTextElement(
        text: pageContent,
        font: treeFont,
        brush: PdfSolidBrush(
          PdfColor(38, 43, 50),
        ),
        format: PdfStringFormat(
          lineSpacing: 1.5,
        ),
      );

      treeElement.draw(
        page: page,
        bounds: Rect.fromLTWH(
          marginLeft,
          contentStartY + 6,
          contentWidth,
          availableHeight - 4,
        ),
      );
    }


// FOOTER

// ----------------------------------------------------------

// Position the footer inside the bottom margin area.
final double footerY =
    pageHeight - marginBottom - footerHeight + 4;

// Footer divider.
page.graphics.drawLine(
  PdfPen(
    PdfColor(224, 228, 234),
    width: 0.8,
  ),
  Offset(
    marginLeft,
    footerY,
  ),
  Offset(
    pageWidth - marginRight,
    footerY,
  ),
);

// Page number centered in the footer.
page.graphics.drawString(
  'Page ${pageIndex + 1} / ${pages.length}',
  regularFont,
  bounds: Rect.fromLTWH(
    marginLeft,
    footerY + 6,
    contentWidth,
    14,
  ),
  format: PdfStringFormat(
    alignment: PdfTextAlignment.center,
  ),
  brush: PdfSolidBrush(
    PdfColor(80, 88, 100),
  ),
);
  }

  progressMessage.value = 'Saving your PDF...';

  final List<int> bytes = await document.save();

  document.dispose();

  final String finalPath =
      '$directory${Platform.pathSeparator}$fileName';

  await File(finalPath).writeAsBytes(bytes);

  progressMessage.value = 'PDF export complete.';
}

  Future<void> _handleStartGeneration() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _statusMessage = 'Preparing export...';
    });

    String? targetDirectory = _selectedTargetDirectory;

    try {
      if (_format != 'clipboard') {
        targetDirectory ??=
            await FilePicker.getDirectoryPath();

        if (targetDirectory == null) {
          if (mounted) {
            setState(() {
              _isProcessing = false;
            });
          }
          return;
        }

        _selectedTargetDirectory =
            targetDirectory;
      }

      String? fileName;

      if (_format == 'txt' || _format == 'pdf') {
        final String suggestedName =
            widget.rootNode.name.trim().isEmpty
                ? 'project_export'
                : widget.rootNode.name.trim();

        fileName = await _askForFileName(
          extension: _format,
          suggestedName: suggestedName,
          title: _format == 'pdf'
              ? 'Name your PDF'
              : 'Name your text file',
        );

        if (fileName == null) {
          if (mounted) {
            setState(() {
              _isProcessing = false;
            });
          }
          return;
        }
      }

      final progressMessage =
          ValueNotifier<String>(
        'Preparing export...',
      );

      if (_format == 'clipboard') {
        progressMessage.value =
            'Generating project export...';

        final content =
            await _generateContent(
          progressMessage,
        );

        progressMessage.value =
            'Copying export to clipboard...';

        final success =
            await ClipboardService.copyToClipboard(
          content,
        );

        progressMessage.dispose();

        if (!success) {
          throw Exception(
            'The export could not be copied to the clipboard.',
          );
        }

        if (mounted) {
          Navigator.of(context).pop();
          _showCustomSnackBar(
            context,
            'Project export copied to clipboard!',
          );
        }

        return;
      }

      if (!mounted) {
        progressMessage.dispose();
        return;
      }

      final progressDialogFuture =
          _showProgressDialog(
        progressMessage,
      );

      await Future<void>.delayed(
        const Duration(milliseconds: 80),
      );

      final content =
          await _generateContent(
        progressMessage,
      );

      if (_format == 'pdf') {
        progressMessage.value =
            'Creating your PDF...';

        await _saveAsPdf(
          targetDirectory!,
          fileName!,
          content,
          progressMessage,
        );
      } else {
        progressMessage.value =
            'Saving your text file...';

        final finalPath =
            '$targetDirectory${Platform.pathSeparator}$fileName';

        await File(finalPath).writeAsString(
          content,
        );

        progressMessage.value =
            'Text export complete.';
      }

      if (mounted) {
        Navigator.of(context).pop();
      }

      await progressDialogFuture;

      progressMessage.dispose();

      if (_format == 'pdf' || _format == 'txt') {
        final finalPath =
            '$targetDirectory${Platform.pathSeparator}$fileName';

        await _showSuccessDialog(
          filePath: finalPath,
          format: _format,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });

        await _showErrorDialog(
          e.toString(),
        );
      }
    }
  }

  Future<String> _generateContent(
    ValueNotifier<String> progressMessage,
  ) async {
    progressMessage.value =
        'Generating project structure...';

    final options = ExportOptions(
      includeMetadata: true,
      skipBinaryFiles: true,
      skipHiddenFiles: true,
    );

    if (_exportMode == 2) {
      return ExportService.exportProjectContent(
        widget.rootNode,
        options,
        layoutStyle: _contentsLayout,
        onProgress: (path) {
          final fileName =
              path.split(Platform.pathSeparator).last;

          progressMessage.value =
              'Reading: $fileName';
        },
      );
    }

    return ExportService.exportTreeContent(
      widget.rootNode,
      options,
    );
  }

  void _showCustomSnackBar(
    BuildContext context,
    String message, {
    Color backgroundColor = Colors.green,
  }) {
    final screenWidth =
        MediaQuery.of(context).size.width;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: 20,
          left: screenWidth * 0.275,
          right: screenWidth * 0.275,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppSpacing.radiusSmall,
          ),
        ),
      ),
    );
  }

  Widget _buildTooltip({
    required String message,
  }) {
    return Tooltip(
      message: message,
      waitDuration:
          const Duration(milliseconds: 350),
      showDuration:
          const Duration(seconds: 5),
      child: const Icon(
        Icons.help_outline_rounded,
        size: 15,
        color: AppColors.textMuted,
      ),
    );
  }

  Widget _buildFormatChip({
    required String value,
    required IconData icon,
    required String label,
    required String tooltip,
  }) {
    final selected = _format == value;

    return Tooltip(
      message: tooltip,
      waitDuration:
          const Duration(milliseconds: 350),
      child: ChoiceChip(
        avatar: Icon(
          icon,
          size: 16,
          color: selected
              ? Colors.white
              : AppColors.textSecondary,
        ),
        label: Text(
          label,
          style: TextStyle(
            color: selected
                ? Colors.white
                : AppColors.textPrimary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        selected: selected,
        selectedColor: AppColors.primary,
        backgroundColor:
            AppColors.backgroundDark,
        side: BorderSide(
          color: selected
              ? AppColors.primary
              : AppColors.borderDark,
        ),
        onSelected: (_) {
          setState(() {
            _format = value;
          });
        },
      ),
    );
  }

  Widget _buildModeCard({
    required int value,
    required IconData icon,
    required String title,
    required String description,
  }) {
    final selected = _exportMode == value;

    return Expanded(
      child: Tooltip(
        message: description,
        waitDuration:
            const Duration(milliseconds: 350),
        child: InkWell(
          borderRadius: BorderRadius.circular(
            14,
          ),
          onTap: () {
            setState(() {
              _exportMode = value;
            });
          },
          child: AnimatedContainer(
            duration:
                const Duration(milliseconds: 160),
            padding:
                const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primary
                      .withOpacity(0.10)
                  : AppColors.backgroundDark,
              border: Border.all(
                color: selected
                    ? AppColors.primary
                    : AppColors.borderDark,
                width: selected ? 1.5 : 1,
              ),
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary
                        : AppColors.surfaceDark,
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color:
                              AppColors.textPrimary,
                          fontSize: 12,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        description,
                        style: const TextStyle(
                          color:
                              AppColors.textSecondary,
                          fontSize: 10,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLayoutCard({
    required int value,
    required String title,
    required String description,
  }) {
    final selected =
        _contentsLayout == value;

    return Expanded(
      child: Tooltip(
        message: description,
        waitDuration:
            const Duration(milliseconds: 350),
        child: InkWell(
          borderRadius:
              BorderRadius.circular(14),
          onTap: () {
            setState(() {
              _contentsLayout = value;
            });
          },
          child: AnimatedContainer(
            duration:
                const Duration(milliseconds: 160),
            padding:
                const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: selected
                  ? Colors.white
                  : Colors.white
                      .withOpacity(0.96),
              border: Border.all(
                color: selected
                    ? AppColors.primary
                    : Colors.grey.shade300,
                width: selected ? 1.5 : 1,
              ),
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Radio<int>(
                  value: value,
                  groupValue:
                      _contentsLayout,
                  activeColor:
                      AppColors.primary,
                  onChanged: (val) {
                    setState(() {
                      _contentsLayout =
                          val ?? value;
                    });
                  },
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 12,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        description,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 10,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceDark,
      elevation: 16,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      titlePadding:
          const EdgeInsets.fromLTRB(24, 22, 24, 8),
      contentPadding:
          const EdgeInsets.fromLTRB(24, 8, 24, 8),
      actionsPadding:
          const EdgeInsets.fromLTRB(20, 10, 20, 18),
      title: const Row(
        children: [
          Icon(
            Icons.file_download_rounded,
            color: AppColors.primary,
            size: 23,
          ),
          SizedBox(width: 10),
          Text(
            'Export Project Documentation',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 660,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose how you want your project exported.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 18),

              Row(
                children: [
                  const Text(
                    'Export format',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 7),
                  _buildTooltip(
                    message:
                        'Clipboard copies the export directly. TXT creates a plain-text file. PDF creates a polished document.',
                  ),
                ],
              ),
              const SizedBox(height: 9),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildFormatChip(
                    value: 'clipboard',
                    icon: Icons.content_copy_rounded,
                    label: 'Clipboard',
                    tooltip:
                        'Copy the generated export directly to your clipboard.',
                  ),
                  _buildFormatChip(
                    value: 'txt',
                    icon: Icons.description_outlined,
                    label: 'TXT',
                    tooltip:
                        'Save the export as a normal plain-text file.',
                  ),
                  _buildFormatChip(
                    value: 'pdf',
                    icon: Icons.picture_as_pdf_outlined,
                    label: 'PDF',
                    tooltip:
                        'Create a polished, easy-to-read PDF document.',
                  ),
                ],
              ),

              const SizedBox(height: 22),

              Row(
                children: [
                  const Text(
                    'What should be exported?',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 7),
                  _buildTooltip(
                    message:
                        'Choose whether you want only the folder structure or the structure plus the contents of the files.',
                  ),
                ],
              ),
              const SizedBox(height: 9),

              Row(
                children: [
                  _buildModeCard(
                    value: 1,
                    icon: Icons.account_tree_outlined,
                    title: 'Tree Export',
                    description:
                        'Exports the folder and file structure without the contents of the files.',
                  ),
                  const SizedBox(width: 12),
                  _buildModeCard(
                    value: 2,
                    icon: Icons.folder_copy_outlined,
                    title: 'Tree + Contents',
                    description:
                        'Includes the directory structure and the readable contents of your files.',
                  ),
                ],
              ),

              if (_exportMode == 2) ...[
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text(
                      'Contents layout',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 7),
                    _buildTooltip(
                      message:
                          'Inline keeps each file beneath its name. Bottom Blocks puts the structure first and the file contents afterwards.',
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                Row(
                  children: [
                    _buildLayoutCard(
                      value: 1,
                      title: 'Inline Contents',
                      description:
                          'Places each file\'s contents directly beneath that file in the structure.',
                    ),
                    const SizedBox(width: 12),
                    _buildLayoutCard(
                      value: 2,
                      title: 'Bottom Blocks',
                      description:
                          'Shows the complete structure first, followed by separate file content sections.',
                    ),
                  ],
                ),
              ],

              if (_format != 'clipboard') ...[
                const SizedBox(height: 20),

                Row(
                  children: [
                    const Text(
                      'Save location',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 7),
                    _buildTooltip(
                      message:
                          'Choose the folder where File Peek should save your exported file.',
                    ),
                  ],
                ),
                const SizedBox(height: 9),

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color:
                        AppColors.backgroundDark,
                    borderRadius:
                        BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.borderDark,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.folder_outlined,
                        color:
                            AppColors.primary,
                        size: 19,
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          _selectedTargetDirectory ??
                              'No folder selected yet',
                          maxLines: 2,
                          overflow:
                              TextOverflow.ellipsis,
                          style:
                              const TextStyle(
                            color: AppColors
                                .textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed:
                            _isProcessing
                                ? null
                                : () async {
                                    final dir =
                                        await FilePicker
                                            .getDirectoryPath();

                                    if (dir !=
                                            null &&
                                        mounted) {
                                      setState(() {
                                        _selectedTargetDirectory =
                                            dir;
                                      });
                                    }
                                  },
                        child: const Text(
                          'Choose folder',
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              if (_isProcessing) ...[
                const SizedBox(height: 18),
                Container(
                  padding:
                      const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color:
                        AppColors.primary
                            .withOpacity(0.08),
                    borderRadius:
                        BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          AppColors.primary
                              .withOpacity(0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color:
                              AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _statusMessage,
                          style:
                              const TextStyle(
                            color:
                                AppColors
                                    .textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isProcessing
              ? null
              : () =>
                  Navigator.of(context).pop(),
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding:
                const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(10),
            ),
          ),
          onPressed: _isProcessing
              ? null
              : _handleStartGeneration,
          icon: const Icon(
            Icons.rocket_launch_rounded,
            size: 17,
          ),
          label: const Text(
            'Start Generation',
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
