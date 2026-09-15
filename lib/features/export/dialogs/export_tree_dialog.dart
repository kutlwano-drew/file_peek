import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heroicons/heroicons.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../../../core/models/file_node.dart';
import '../../../core/models/export_options.dart';
import '../../../core/services/export_service.dart';
import '../../../core/services/clipboard_service.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../widgets/export_progress_dialog.dart';

class ExportTreeDialog extends StatefulWidget {
  final FileNode rootNode;

  const ExportTreeDialog({super.key, required this.rootNode});

  @override
  State<ExportTreeDialog> createState() => _ExportTreeDialogState();
}

class _ExportTreeDialogState extends State<ExportTreeDialog> {
  bool _useUnicode = true;
  bool _includeRoot = true;
  bool _isExporting = false;

  String _previewText = '';

  @override
  void initState() {
    super.initState();
    _updatePreview();
  }

  Future<void> _updatePreview() async {
    final options = ExportOptions(
      useUnicodeTree: _useUnicode,
      includeRootFolder: _includeRoot,
    );

    final result = await ExportService.exportTreeContent(
      widget.rootNode,
      options,
    );

    if (mounted) {
      setState(() {
        _previewText = result;
      });
    }
  }

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
              Icon(Icons.error_outline_rounded, color: Colors.redAccent),
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
          content: SizedBox(
            width: 400,
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.45,
              ),
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

    final String directory = File(filePath).parent.path;

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
                  'Your directory tree was successfully exported.',
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
                    border: Border.all(color: AppColors.borderDark),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
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
            Row(
              children: [
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
            ),
          ],
        );
      },
    );
  }

  Future<void> _openDirectory(String directory) async {
    try {
      if (Platform.isLinux) {
        await Process.run('xdg-open', [directory]);
      } else if (Platform.isMacOS) {
        await Process.run('open', [directory]);
      } else if (Platform.isWindows) {
        await Process.run('explorer', [directory]);
      } else {
        throw UnsupportedError(
          'Opening folders is not supported on this platform.',
        );
      }
    } catch (e) {
      await _showErrorDialog(
        'The export was successful, but File Peek could not open the destination folder.\n\n$e',
      );
    }
  }

  String? _sanitizeFileName(String value, String extension) {
    String name = value.trim();

    if (name.isEmpty) {
      return null;
    }

    if (name.toLowerCase().endsWith('.$extension')) {
      name = name.substring(0, name.length - extension.length - 1);
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

  Future<String?> _askForFileName({
    required String extension,
    required String suggestedName,
  }) async {
    final controller = TextEditingController(text: suggestedName);

    try {
      return await showDialog<String>(
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
                titlePadding: const EdgeInsets.fromLTRB(26, 24, 26, 8),
                contentPadding: const EdgeInsets.fromLTRB(26, 8, 26, 8),
                actionsPadding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
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
                      'Name your ${extension.toUpperCase()}',
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Choose a name for the exported file.',
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
                          fillColor: AppColors.backgroundDark,
                          errorText: validationError,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                        onSubmitted: (_) {
                          final name = _sanitizeFileName(
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
                              'The file extension is added automatically.',
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
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      final name = _sanitizeFileName(
                        controller.text,
                        extension,
                      );

                      if (name == null) {
                        setDialogState(() {
                          validationError = 'Please enter a valid file name.';
                        });
                        return;
                      }

                      Navigator.of(dialogContext).pop(name);
                    },
                    child: const Text(
                      'Continue',
                      style: TextStyle(fontWeight: FontWeight.w700),
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
  }

  Future<void> _handleCopyToClipboard() async {
    setState(() {
      _isExporting = true;
    });

    try {
      final success = await ClipboardService.copyToClipboard(_previewText);

      if (!success) {
        throw Exception('The tree could not be copied to the clipboard.');
      }

      if (mounted) {
        Navigator.of(context).pop();

        _showCustomSnackBar(context, 'Tree structure copied to clipboard.');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });

        await _showErrorDialog(e.toString());
      }
    }
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

    final boldData = await rootBundle.load('assets/fonts/GoogleSans-Bold.ttf');

    final monoData = await rootBundle.load('assets/fonts/DejaVuSansMono.ttf');

    progressMessage.value = 'Building the PDF document...';

    final regularFont = PdfTrueTypeFont(regularData.buffer.asUint8List(), 9.5);

    final mediumFont = PdfTrueTypeFont(mediumData.buffer.asUint8List(), 9.5);

    final boldFont = PdfTrueTypeFont(boldData.buffer.asUint8List(), 16);

    final smallBoldFont = PdfTrueTypeFont(boldData.buffer.asUint8List(), 9);

    final treeFont = PdfTrueTypeFont(monoData.buffer.asUint8List(), 8.5);

    final document = PdfDocument();

    document.pageSettings.size = PdfPageSize.a4;

    const double marginLeft = 42;
    const double marginRight = 42;
    const double marginTop = 40;
    const double marginBottom = 42;

    final double pageWidth = PdfPageSize.a4.width;

    final double pageHeight = PdfPageSize.a4.height;

    final double contentWidth = pageWidth - marginLeft - marginRight;

    final lines = content.split('\n');

    const double lineHeight = 12;
    const double headerHeight = 82;
    const double footerHeight = 24;

    final double contentStartY = marginTop + headerHeight;

    final double availableHeight =
        pageHeight - contentStartY - marginBottom - footerHeight;

    final int linesPerPage = (availableHeight / lineHeight).floor().clamp(
      1,
      100000,
    );

    final List<List<String>> pages = [];

    for (int i = 0; i < lines.length; i += linesPerPage) {
      final end = (i + linesPerPage).clamp(0, lines.length);

      pages.add(lines.sublist(i, end));
    }

    if (pages.isEmpty) {
      pages.add([]);
    }

    for (int pageIndex = 0; pageIndex < pages.length; pageIndex++) {
      progressMessage.value =
          'Building PDF page ${pageIndex + 1} of ${pages.length}...';

      final page = document.pages.add();

      final Size pageSize = page.getClientSize();

      page.graphics.drawRectangle(
        brush: PdfSolidBrush(PdfColor(247, 249, 252)),
        bounds: Rect.fromLTWH(0, 0, pageWidth, 92),
      );

      page.graphics.drawRectangle(
        brush: PdfSolidBrush(PdfColor(42, 110, 210)),
        bounds: Rect.fromLTWH(0, 0, pageWidth, 4),
      );

      page.graphics.drawString(
        fileName.replaceFirst(RegExp(r'\.pdf$', caseSensitive: false), ''),
        boldFont,
        bounds: Rect.fromLTWH(marginLeft, marginTop - 4, contentWidth, 24),
      );

      page.graphics.drawString(
        'Directory structure export',
        mediumFont,
        bounds: Rect.fromLTWH(marginLeft, marginTop + 24, contentWidth, 16),
        brush: PdfSolidBrush(PdfColor(95, 105, 120)),
      );

      page.graphics.drawString(
        'FILE PEEK',
        smallBoldFont,
        bounds: Rect.fromLTWH(marginLeft, marginTop + 48, 100, 15),
        brush: PdfSolidBrush(PdfColor(42, 110, 210)),
      );

      page.graphics.drawString(
        'Page ${pageIndex + 1} / ${pages.length}',
        regularFont,
        bounds: Rect.fromLTWH(
          pageWidth - marginRight - 100,
          marginTop + 48,
          100,
          15,
        ),
        format: PdfStringFormat(alignment: PdfTextAlignment.right),
        brush: PdfSolidBrush(PdfColor(95, 105, 120)),
      );

      page.graphics.drawString(
        'DIRECTORY TREE',
        smallBoldFont,
        bounds: Rect.fromLTWH(marginLeft, contentStartY - 22, contentWidth, 15),
        brush: PdfSolidBrush(PdfColor(95, 105, 120)),
      );

      page.graphics.drawRectangle(
        pen: PdfPen(PdfColor(224, 228, 234), width: 0.8),
        brush: PdfSolidBrush(PdfColor(255, 255, 255)),
        bounds: Rect.fromLTWH(
          marginLeft - 8,
          contentStartY - 4,
          contentWidth + 16,
          availableHeight + 8,
        ),
      );

      final pageContent = pages[pageIndex].join('\n');

      if (pageContent.isNotEmpty) {
        final treeElement = PdfTextElement(
          text: pageContent,
          font: treeFont,
          brush: PdfSolidBrush(PdfColor(38, 43, 50)),
          format: PdfStringFormat(lineSpacing: 1.5),
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

      final double footerY = pageSize.height - marginBottom + 4;

      page.graphics.drawLine(
        PdfPen(PdfColor(224, 228, 234), width: 0.8),
        Offset(marginLeft, footerY - 6),
        Offset(pageWidth - marginRight, footerY - 6),
      );

      page.graphics.drawString(
        'Generated by File Peek',
        regularFont,
        bounds: Rect.fromLTWH(marginLeft, footerY, contentWidth / 2, 14),
        brush: PdfSolidBrush(PdfColor(120, 128, 140)),
      );

      page.graphics.drawString(
        'Directory tree export',
        regularFont,
        bounds: Rect.fromLTWH(pageWidth / 2, footerY, contentWidth / 2, 14),
        format: PdfStringFormat(alignment: PdfTextAlignment.right),
        brush: PdfSolidBrush(PdfColor(120, 128, 140)),
      );
    }

    progressMessage.value = 'Saving your PDF...';

    final bytes = await document.save();

    document.dispose();

    final finalPath = '$directory${Platform.pathSeparator}$fileName';

    await File(finalPath).writeAsBytes(bytes);

    progressMessage.value = 'PDF export complete.';
  }

  Future<void> _handleFileExport(String format) async {
    final selectedDirectory = await FilePicker.getDirectoryPath();

    if (selectedDirectory == null) {
      return;
    }

    final extension = format;

    final suggestedName = widget.rootNode.name.trim().isEmpty
        ? 'directory_tree'
        : '${widget.rootNode.name.trim()}_tree';

    final fileName = await _askForFileName(
      extension: extension,
      suggestedName: suggestedName,
    );

    if (fileName == null) {
      return;
    }

    if (!mounted) return;

    setState(() {
      _isExporting = true;
    });

    final progressMessage = ValueNotifier<String>('Preparing export...');

    try {
      final progressDialogFuture = showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return ExportProgressDialog(message: progressMessage.value);
        },
      );

      await Future<void>.delayed(const Duration(milliseconds: 80));

      if (format == 'pdf') {
        await _saveAsPdf(
          selectedDirectory,
          fileName,
          _previewText,
          progressMessage,
        );
      } else {
        progressMessage.value = 'Saving your text file...';

        final filePath = '$selectedDirectory${Platform.pathSeparator}$fileName';

        await File(filePath).writeAsString(_previewText);

        progressMessage.value = 'Text export complete.';
      }

      if (mounted) {
        Navigator.of(context).pop();
      }

      await progressDialogFuture;

      progressMessage.dispose();

      final finalPath = '$selectedDirectory${Platform.pathSeparator}$fileName';

      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showSuccessDialog(filePath: finalPath, format: format);
        });
      }
    } catch (e) {
      progressMessage.dispose();

      if (mounted) {
        setState(() {
          _isExporting = false;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showErrorDialog(e.toString());
        });
      }
    }
  }

  void _showCustomSnackBar(
    BuildContext context,
    String message, {
    Color backgroundColor = Colors.green,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            HeroIcon(
              backgroundColor == Colors.green
                  ? HeroIcons.checkCircle
                  : HeroIcons.exclamationCircle,
              size: 21,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        width: screenWidth * 0.5,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
        ),
      ),
    );
  }

  Widget _buildHelp(String message) {
    return Tooltip(
      message: message,
      waitDuration: const Duration(milliseconds: 350),
      showDuration: const Duration(seconds: 5),
      child: const Icon(
        Icons.help_outline_rounded,
        size: 15,
        color: AppColors.textMuted,
      ),
    );
  }

  Widget _buildOptionCard({
    required bool selected,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withOpacity(0.08)
              : AppColors.backgroundDark,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.borderDark,
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceDark,
      elevation: 16,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.fromLTRB(24, 22, 24, 8),
      contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      actionsPadding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
      title: const Row(
        children: [
          Icon(Icons.account_tree_rounded, color: AppColors.primary, size: 23),
          SizedBox(width: 10),
          Text(
            'Export Directory Tree',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 800,
        height: 520,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Preview the directory structure, adjust the options, then choose how you want to save it.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: _buildOptionCard(
                    selected: _useUnicode,
                    onTap: () {
                      setState(() {
                        _useUnicode = !_useUnicode;
                      });
                      _updatePreview();
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.account_tree_outlined,
                          size: 19,
                          color: _useUnicode
                              ? AppColors.primary
                              : AppColors.textMuted,
                        ),
                        const SizedBox(width: 9),
                        const Expanded(
                          child: Text(
                            'Use Unicode tree characters',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        _buildHelp(
                          'Uses characters such as ├── and └── to make the folder structure easier to read.',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildOptionCard(
                    selected: _includeRoot,
                    onTap: () {
                      setState(() {
                        _includeRoot = !_includeRoot;
                      });
                      _updatePreview();
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.folder_outlined,
                          size: 19,
                          color: _includeRoot
                              ? AppColors.primary
                              : AppColors.textMuted,
                        ),
                        const SizedBox(width: 9),
                        const Expanded(
                          child: Text(
                            'Include root folder',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        _buildHelp(
                          'Includes the top-level project folder as the first line of the exported tree.',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                const Text(
                  'Preview',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 7),
                _buildHelp(
                  'This is what the exported directory tree will contain.',
                ),
              ],
            ),

            const SizedBox(height: 8),

            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.backgroundDark,
                  border: Border.all(color: AppColors.borderDark),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Builder(
                  builder: (context) {
                    final horizontalController = ScrollController();
                    final verticalController = ScrollController();

                    return Scrollbar(
                      controller: horizontalController,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            controller: horizontalController,
                            scrollDirection: Axis.horizontal,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: constraints.maxWidth,
                              ),
                              child: SingleChildScrollView(
                                controller: verticalController,
                                child: SelectableText(
                                  _previewText,
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 11,
                                    height: 1.45,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isExporting ? null : () => Navigator.of(context).pop(),
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.primary),
            foregroundColor: Colors.white,
          ),
          onPressed: _isExporting ? null : () => _handleFileExport('txt'),
          icon: const Icon(Icons.description_outlined, size: 17),
          label: const Text(
            'Export TXT',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.primary),
            foregroundColor: Colors.white,
          ),
          onPressed: _isExporting ? null : () => _handleFileExport('pdf'),
          icon: const Icon(Icons.picture_as_pdf_outlined, size: 17),
          label: const Text(
            'Export PDF',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          onPressed: _isExporting ? null : _handleCopyToClipboard,
          icon: const Icon(Icons.content_copy_rounded, size: 17),
          label: const Text(
            'Copy to Clipboard',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
