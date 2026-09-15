import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/services/structure_import_service.dart';

class StructureImportScreen extends StatefulWidget {
  const StructureImportScreen({super.key});

  @override
  State<StructureImportScreen> createState() => _StructureImportScreenState();
}

class _StructureImportScreenState extends State<StructureImportScreen> {
  final TextEditingController _textController = TextEditingController();

  bool _isProcessing = false;
  String _statusMessage = '';

  String? _selectedTargetDirectory;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------

  String _extractProjectName(String text) {
    final lines = text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    if (lines.isEmpty) {
      return 'Project';
    }

    String name = lines.first;

    name = name.replaceFirst(RegExp(r'^[│├└─\|+\-\s]+'), '').trim();

    if (name.endsWith('/')) {
      name = name.substring(0, name.length - 1);
    }

    if (name.isEmpty) {
      return 'Project';
    }

    return name;
  }

  String _generatedProjectPath() {
    final target = _selectedTargetDirectory;

    if (target == null) {
      return '';
    }

    final projectName = _extractProjectName(_textController.text);

    return '$target${Platform.pathSeparator}$projectName';
  }

  // ---------------------------------------------------------------------------
  // SNACKBAR
  // ---------------------------------------------------------------------------

  void _showCustomSnackBar(
    BuildContext context,
    String message, {
    Color backgroundColor = const Color(0xFF252832),
    IconData icon = Icons.info_outline,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, size: 21, color: Colors.white),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // IMPORT FILE
  // ---------------------------------------------------------------------------

  Future<void> _handleImportClick() async {
    final bool? proceed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.surfaceDark,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.file_upload_outlined,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Import structure file',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Choose a file containing only the folder and file hierarchy you want File Peek to create.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _GuidelineRow(
                    icon: Icons.check_circle_outline,
                    text: 'TXT and PDF files are supported',
                  ),
                  const SizedBox(height: 9),
                  _GuidelineRow(
                    icon: Icons.account_tree_outlined,
                    text: 'Use an ASCII or indented folder tree',
                  ),
                  const SizedBox(height: 9),
                  _GuidelineRow(
                    icon: Icons.warning_amber_outlined,
                    text: 'Avoid explanatory paragraphs or notes',
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 13,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11),
                          ),
                        ),
                        child: const Text(
                          'Choose File',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (proceed != true) return;

    try {
      final FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'pdf'],
        dialogTitle: 'Select structure file',
      );

      if (result == null || result.files.single.path == null) {
        return;
      }

      final filePath = result.files.single.path!;
      final extension = filePath.split('.').last.toLowerCase();

      String extractedText = '';

      if (extension == 'txt') {
        final file = File(filePath);
        extractedText = await file.readAsString();
      } else if (extension == 'pdf') {
        extractedText = await _extractTextFromPdf(filePath);
      }

      if (!mounted) return;

      setState(() {
        _textController.text = extractedText;

        // A new structure means the old target should not silently
        // remain attached to the new project.
        _selectedTargetDirectory = null;
      });

      _showCustomSnackBar(
        context,
        'Structure imported. Review it before creating the project folder.',
        backgroundColor: const Color(0xFF237A57),
        icon: Icons.check_circle_outline,
      );
    } catch (e) {
      if (!mounted) return;

      _showCustomSnackBar(
        context,
        'Unable to import file: $e',
        backgroundColor: const Color(0xFF9E3434),
        icon: Icons.error_outline,
      );
    }
  }

  Future<String> _extractTextFromPdf(String path) async {
    final File file = File(path);
    final List<int> bytes = await file.readAsBytes();

    final PdfDocument document = PdfDocument(inputBytes: bytes);

    final String text = PdfTextExtractor(document).extractText();

    document.dispose();

    return text;
  }

  // ---------------------------------------------------------------------------
  // TARGET DIRECTORY
  // ---------------------------------------------------------------------------

  Future<void> _handleSelectDirectory() async {
    final text = _textController.text.trim();

    if (text.isEmpty) {
      _showCustomSnackBar(
        context,
        'Add or import a project structure first.',
        backgroundColor: const Color(0xFF8B641E),
        icon: Icons.warning_amber_outlined,
      );
      return;
    }

    final String? selectedDirectory = await FilePicker.getDirectoryPath(
      dialogTitle: 'Please select project folder',
    );

    if (selectedDirectory == null) {
      return;
    }

    if (!mounted) return;

    setState(() {
      _selectedTargetDirectory = selectedDirectory;
    });

    _showCustomSnackBar(
      context,
      'Project location selected. You can now create the folder.',
      backgroundColor: const Color(0xFF245F9E),
      icon: Icons.folder_open_outlined,
    );
  }

  // ---------------------------------------------------------------------------
  // GENERATION
  // ---------------------------------------------------------------------------

  Future<void> _handleStartGeneration() async {
    final text = _textController.text.trim();
    final target = _selectedTargetDirectory;

    if (text.isEmpty) {
      return;
    }

    if (target == null) {
      await _handleSelectDirectory();
      return;
    }

    if (!mounted) return;

    setState(() {
      _isProcessing = true;
      _statusMessage = 'Preparing project folder...';
    });

    try {
      await StructureImportService.generateStructureOnDisk(
        targetDirectoryPath: target,
        structureText: text,
        onProgress: (status) {
          if (!mounted) return;

          setState(() {
            _statusMessage = status;
          });
        },
      );

      if (!mounted) return;

      final projectName = _extractProjectName(text);
      final generatedPath = _generatedProjectPath();

      setState(() {
        _isProcessing = false;
      });

      await _showCreationCompleteDialog(
        projectName: projectName,
        projectPath: generatedPath,
      );

      if (!mounted) return;

      setState(() {
        _selectedTargetDirectory = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isProcessing = false;
      });

      _showCustomSnackBar(
        context,
        'Unable to create project folder: $e',
        backgroundColor: const Color(0xFF9E3434),
        icon: Icons.error_outline,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // COMPLETION DIALOG
  // ---------------------------------------------------------------------------

  Future<void> _showCreationCompleteDialog({
    required String projectName,
    required String projectPath,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.surfaceDark,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 30, 28, 26),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E9B6B).withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Color(0xFF49C98D),
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    '$projectName project folder successfully created.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    projectPath,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textSecondary.withOpacity(0.75),
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 46,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC74343),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Dismiss',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 46,
                          child: ElevatedButton(
                            onPressed: () async {
                              await _openItemLocation(projectPath);

                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF327BC4),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Open Item Location',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openItemLocation(String path) async {
    try {
      if (Platform.isLinux) {
        await Process.run('xdg-open', [path]);
      } else if (Platform.isMacOS) {
        await Process.run('open', [path]);
      } else if (Platform.isWindows) {
        await Process.run('explorer.exe', [path]);
      }
    } catch (e) {
      if (!mounted) return;

      _showCustomSnackBar(
        context,
        'Could not open the project location.',
        backgroundColor: const Color(0xFF9E3434),
        icon: Icons.error_outline,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final bool hasStructure = _textController.text.trim().isNotEmpty;
    final bool hasTarget = _selectedTargetDirectory != null;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 24,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: IconButton(
            tooltip: 'Back',
            icon: const Icon(Icons.arrow_back_rounded, size: 20),
            color: AppColors.textSecondary,
            onPressed: _isProcessing ? null : () => context.go('/'),
          ),
        ),
        title: const Text(
          'Import Project Structure',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(hasStructure: hasStructure, hasTarget: hasTarget),

            const SizedBox(height: 18),

            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderDark),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: TextField(
                    controller: _textController,
                    maxLines: null,
                    expands: true,
                    enabled: !_isProcessing,
                    textAlignVertical: TextAlignVertical.top,
                    onChanged: (_) {
                      setState(() {});
                    },
                    style: const TextStyle(
                      fontFamily: 'DejaVu Sans Mono',
                      fontSize: 13,
                      height: 1.6,
                      color: Colors.black,
                    ),
                    cursorColor: AppColors.primary,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText:
                          'Paste your project structure here...\n\n'
                          'my_project/\n'
                          '├── lib/\n'
                          '│   └── main.dart\n'
                          '└── pubspec.yaml',
                      hintStyle: TextStyle(
                        fontFamily: 'DejaVu Sans Mono',
                        fontSize: 13,
                        height: 1.6,
                        color: Colors.grey,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.fromLTRB(22, 20, 22, 20),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            if (hasTarget)
              _TargetLocation(
                path: _selectedTargetDirectory!,
                onClear: _isProcessing
                    ? null
                    : () {
                        setState(() {
                          _selectedTargetDirectory = null;
                        });
                      },
              ),

            if (hasTarget) const SizedBox(height: 14),

            if (_isProcessing) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  minHeight: 3,
                  color: AppColors.primary,
                  backgroundColor: AppColors.borderDark,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                _statusMessage,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 14),
            ],

            _ActionBar(
              isProcessing: _isProcessing,
              hasStructure: hasStructure,
              hasTarget: hasTarget,
              onCancel: () => context.go('/'),
              onImport: _handleImportClick,
              onGenerate: hasTarget
                  ? _handleStartGeneration
                  : _handleSelectDirectory,
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// HEADER
// =============================================================================

class _Header extends StatelessWidget {
  final bool hasStructure;
  final bool hasTarget;

  const _Header({required this.hasStructure, required this.hasTarget});

  @override
  Widget build(BuildContext context) {
    String message;

    if (!hasStructure) {
      message =
          'Paste a folder structure or import a TXT/PDF file to create a project folder.';
    } else if (!hasTarget) {
      message =
          'Structure ready. Choose where you want File Peek to create the project.';
    } else {
      message = 'Everything is ready. Create the project folder on disk.';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Supports ASCII trees and indented folder structures.',
          style: TextStyle(color: Colors.white, fontSize: 11),
        ),
      ],
    );
  }
}

// =============================================================================
// TARGET LOCATION
// =============================================================================

class _TargetLocation extends StatelessWidget {
  final String path;
  final VoidCallback? onClear;

  const _TargetLocation({required this.path, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFF182433),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: const Color(0xFF2D5E8C)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.folder_open_rounded,
            size: 18,
            color: Color(0xFF63A8E8),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Project location',
                  style: TextStyle(
                    color: Color(0xFF72B5F2),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  path,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Change location',
            visualDensity: VisualDensity.compact,
            onPressed: onClear,
            icon: const Icon(
              Icons.edit_outlined,
              size: 17,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// ACTION BAR
// =============================================================================

class _ActionBar extends StatelessWidget {
  final bool isProcessing;
  final bool hasStructure;
  final bool hasTarget;

  final VoidCallback onCancel;
  final VoidCallback onImport;
  final VoidCallback onGenerate;

  const _ActionBar({
    required this.isProcessing,
    required this.hasStructure,
    required this.hasTarget,
    required this.onCancel,
    required this.onImport,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton(
          onPressed: isProcessing ? null : onCancel,
          style: TextButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          ),
          child: const Text('Cancel', style: TextStyle(color: Colors.white)),
        ),
        const Spacer(),
        OutlinedButton.icon(
          onPressed: isProcessing ? null : onImport,
          style: OutlinedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            side: BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(11),
            ),
          ),
          icon: const HeroIcon(
            HeroIcons.arrowUpTray,
            size: 18,
            color: Colors.white,
          ),
          label: const Text(
            'Import File',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton.icon(
          onPressed: isProcessing || !hasStructure ? null : onGenerate,
          style: ElevatedButton.styleFrom(
            backgroundColor: hasTarget
                ? const Color(0xFF327BC4)
                : AppColors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.borderDark,
            disabledForegroundColor: AppColors.textMuted,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(11),
            ),
          ),
          icon: isProcessing
              ? const SizedBox(
                  width: 17,
                  height: 17,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Icon(
                  hasTarget
                      ? Icons.create_new_folder_outlined
                      : Icons.folder_open_outlined,
                  size: 18,
                ),
          label: Text(
            isProcessing
                ? 'Creating Project Folder...'
                : hasTarget
                ? 'Create Project Folder'
                : 'Choose Project Location',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// GUIDELINE ROW
// =============================================================================

class _GuidelineRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _GuidelineRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
