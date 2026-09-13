import 'dart:io';
import 'dart:math' as math;
import 'package:excel/excel.dart' hide Border;
import 'package:flutter/material.dart';

class SpreadsheetPreview extends StatefulWidget {
  final String path;

  const SpreadsheetPreview({
    super.key,
    required this.path,
  });

  @override
  State<SpreadsheetPreview> createState() => _SpreadsheetPreviewState();
}

class _SpreadsheetPreviewState extends State<SpreadsheetPreview> {
  String? _error;
  Excel? _book;
  bool _isLoading = true;

  String _activeSheetName = '';
  int _selectedRow = 0;
  int _selectedCol = 0;

  final TextEditingController _jumpController = TextEditingController();
  final ScrollController _horizontalScroll = ScrollController();
  final ScrollController _verticalScroll = ScrollController();

  static const double _cellWidth = 110.0;
  static const double _cellHeight = 32.0;
  static const double _headerRowHeight = 28.0;
  static const double _headerColWidth = 50.0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant SpreadsheetPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) {
      _load();
    }
  }

  @override
  void dispose() {
    _jumpController.dispose();
    _horizontalScroll.dispose();
    _verticalScroll.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _book = null;
    });

    try {
      final file = File(widget.path);
      if (!await file.exists()) {
        throw Exception('File does not exist at path: ${widget.path}');
      }

      final bytes = await file.readAsBytes();
      final excel = Excel.decodeBytes(bytes);

      if (!mounted) return;

      setState(() {
        _book = excel;
        _isLoading = false;
        if (excel.tables.isNotEmpty) {
          _activeSheetName = excel.tables.keys.first;
          _jumpToCell(0, 0);
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _getColumnLabel(int index) {
    String label = '';
    int col = index;
    while (col >= 0) {
      label = String.fromCharCode((col % 26) + 65) + label;
      col = (col ~/ 26) - 1;
    }
    return label;
  }

  (int row, int col)? _parseCellReference(String ref) {
    final cleaned = ref.trim().toUpperCase();
    final match = RegExp(r'^([A-Z]+)([0-9]+)$').firstMatch(cleaned);
    if (match == null) return null;

    final letters = match.group(1)!;
    final rowNum = int.tryParse(match.group(2)!);
    if (rowNum == null || rowNum <= 0) return null;

    int colIndex = 0;
    for (int i = 0; i < letters.length; i++) {
      colIndex = colIndex * 26 + (letters.codeUnitAt(i) - 64);
    }

    return (rowNum - 1, colIndex - 1);
  }

  void _jumpToCell(int row, int col) {
    setState(() {
      _selectedRow = row;
      _selectedCol = col;
      _jumpController.text = '${_getColumnLabel(col)}${row + 1}';
    });

    // If cells have stretched to full width, maxScrollExtent will be 0.
    // The clamp handles this gracefully without modifying the jump calculation.
    final targetX = col * _cellWidth; 
    final targetY = row * _cellHeight;

    if (_horizontalScroll.hasClients) {
      _horizontalScroll.animateTo(
        targetX.clamp(0.0, _horizontalScroll.position.maxScrollExtent),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
    if (_verticalScroll.hasClients) {
      _verticalScroll.animateTo(
        targetY.clamp(0.0, _verticalScroll.position.maxScrollExtent),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  void _handleJumpSubmit(String value) {
    final coords = _parseCellReference(value);
    if (coords != null) {
      _jumpToCell(coords.$1, coords.$2);
    } else {
      _jumpController.text =
          '${_getColumnLabel(_selectedCol)}${_selectedRow + 1}';
    }
  }

  Color? _extractColor(dynamic colorValue) {
    if (colorValue == null) return null;

    String hexStr = colorValue.toString();
    if (hexStr.contains('(') && hexStr.contains(')')) {
      final match = RegExp(r'\((.*?)\)').firstMatch(hexStr);
      if (match != null) {
        hexStr = match.group(1)!;
      }
    }

    hexStr = hexStr.replaceAll('#', '').trim();
    if (hexStr.isEmpty || hexStr == '00000000' || hexStr == 'null') return null;

    if (hexStr.length == 6) {
      hexStr = 'FF$hexStr';
    }

    final intValue = int.tryParse(hexStr, radix: 16);
    return intValue != null ? Color(intValue) : null;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Spreadsheet could not be displayed.\n$_error',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    if (_book == null || _book!.tables.isEmpty) {
      return const Center(child: Text('Spreadsheet contains no sheets.'));
    }

    final sheet = _book!.tables[_activeSheetName];
    final maxCols = (sheet?.maxColumns ?? 0).clamp(1, 16384);
    final maxRows = (sheet?.maxRows ?? 0).clamp(1, 1048576);

    final selectedCellData = sheet
        ?.cell(
          CellIndex.indexByColumnRow(
            columnIndex: _selectedCol,
            rowIndex: _selectedRow,
          ),
        )
        .value;

    return Theme(
      data: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.white,
      ),
      child: Container(
        color: const Color(0xFFF8F9FA),
        width: double.infinity, // Force container to fill available width
        child: Column(
          children: [
            // =================================================================
            // FORMULA BAR & CELL ADDRESS INPUT
            // =================================================================
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F3F4),
                border: Border(
                  bottom: BorderSide(color: Color(0xFFDCDCDC)),
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 70,
                    height: 28,
                    child: TextField(
                      controller: _jumpController,
                      onSubmitted: _handleJumpSubmit,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(vertical: 4),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFCCCCCC)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF107C41)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'fx',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF5F6368),
                      fontSize: 14,
                    ),
                  ),
                  const VerticalDivider(
                    width: 16,
                    thickness: 1,
                    color: Color(0xFFCCCCCC),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(color: const Color(0xFFCCCCCC)),
                      ),
                      child: Text(
                        selectedCellData != null ? '$selectedCellData' : '',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // =================================================================
            // GRID CONTENT
            // =================================================================
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Dynamically calculate cell width so small spreadsheets stretch to fill space
                  double actualCellWidth = _cellWidth;
                  if (maxCols > 0 && constraints.maxWidth != double.infinity) {
                    final double availableWidth =
                        constraints.maxWidth - _headerColWidth;
                    actualCellWidth =
                        math.max(_cellWidth, availableWidth / maxCols);
                  }

                  return Scrollbar(
                    controller: _horizontalScroll,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: _horizontalScroll,
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: _headerColWidth + (maxCols * actualCellWidth),
                        child: Column(
                          children: [
                            // Column Headers Row
                            Container(
                              height: _headerRowHeight,
                              color: const Color(0xFFE6E6E6),
                              child: Row(
                                children: [
                                  // Top-Left Corner Box
                                  Container(
                                    width: _headerColWidth,
                                    height: _headerRowHeight,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFD9D9D9),
                                      border: Border(
                                        right: BorderSide(
                                          color: Color(0xFFBFBFBF),
                                        ),
                                        bottom: BorderSide(
                                          color: Color(0xFFBFBFBF),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Column Letter Headers
                                  ...List.generate(
                                    maxCols,
                                    (col) => Container(
                                      width: actualCellWidth, // Use stretched width
                                      height: _headerRowHeight,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: col == _selectedCol
                                            ? const Color(0xFFD0E7D5)
                                            : const Color(0xFFE6E6E6),
                                        border: const Border(
                                          right: BorderSide(
                                            color: Color(0xFFBFBFBF),
                                          ),
                                          bottom: BorderSide(
                                            color: Color(0xFFBFBFBF),
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        _getColumnLabel(col),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: col == _selectedCol
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Rows and Cells
                            Expanded(
                              child: Scrollbar(
                                controller: _verticalScroll,
                                thumbVisibility: true,
                                child: SingleChildScrollView(
                                  controller: _verticalScroll,
                                  child: Column(
                                    children: List.generate(
                                      maxRows,
                                      (row) => SizedBox(
                                        height: _cellHeight,
                                        child: Row(
                                          children: [
                                            // Row Number Header
                                            Container(
                                              width: _headerColWidth,
                                              height: _cellHeight,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: row == _selectedRow
                                                    ? const Color(0xFFD0E7D5)
                                                    : const Color(0xFFE6E6E6),
                                                border: const Border(
                                                  right: BorderSide(
                                                    color: Color(0xFFBFBFBF),
                                                  ),
                                                  bottom: BorderSide(
                                                    color: Color(0xFFBFBFBF),
                                                  ),
                                                ),
                                              ),
                                              child: Text(
                                                '${row + 1}',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: row == _selectedRow
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ),

                                            // Grid Cells
                                            ...List.generate(
                                              maxCols,
                                              (col) {
                                                final cell = sheet?.cell(
                                                  CellIndex.indexByColumnRow(
                                                    columnIndex: col,
                                                    rowIndex: row,
                                                  ),
                                                );

                                                final isSelected =
                                                    row == _selectedRow &&
                                                        col == _selectedCol;

                                                final cellStyle = cell?.cellStyle;
                                                final bgColor = _extractColor(
                                                    cellStyle?.backgroundColor);
                                                final fontColor = _extractColor(
                                                    cellStyle?.fontColor);

                                                return GestureDetector(
                                                  onTap: () =>
                                                      _jumpToCell(row, col),
                                                  child: Container(
                                                    width: actualCellWidth, // Use stretched width
                                                    height: _cellHeight,
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                    ),
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    decoration: BoxDecoration(
                                                      color: isSelected
                                                          ? const Color(
                                                              0xFFE8F0FE)
                                                          : (bgColor ??
                                                              Colors.white),
                                                      border: isSelected
                                                          ? Border.all(
                                                              color: const Color(
                                                                  0xFF107C41),
                                                              width: 2,
                                                            )
                                                          : const Border(
                                                              right: BorderSide(
                                                                color: Color(
                                                                    0xFFE0E0E0),
                                                              ),
                                                              bottom: BorderSide(
                                                                color: Color(
                                                                    0xFFE0E0E0),
                                                              ),
                                                            ),
                                                    ),
                                                    child: Text(
                                                      cell?.value != null
                                                          ? '${cell!.value}'
                                                          : '',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: fontColor ??
                                                            Colors.black87,
                                                        fontWeight: cellStyle
                                                                    ?.isBold ==
                                                                true
                                                            ? FontWeight.bold
                                                            : FontWeight.normal,
                                                        fontStyle: cellStyle
                                                                    ?.isItalic ==
                                                                true
                                                            ? FontStyle.italic
                                                            : FontStyle.normal,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // =================================================================
            // BOTTOM SHEET TABS
            // =================================================================
            if (_book!.tables.length > 1)
              Container(
                height: 36,
                color: const Color(0xFFE6E6E6),
                child: Row(
                  children: [
                    Expanded(
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: _book!.tables.keys.map((sheetName) {
                          final isActive = sheetName == _activeSheetName;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _activeSheetName = sheetName;
                                _jumpToCell(0, 0);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              margin: const EdgeInsets.only(
                                left: 4,
                                top: 4,
                                right: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? Colors.white
                                    : const Color(0xFFD9D9D9),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4),
                                ),
                                border: Border(
                                  top: BorderSide(
                                    color: isActive
                                        ? const Color(0xFF107C41)
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Text(
                                sheetName,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isActive
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isActive
                                      ? const Color(0xFF107C41)
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}