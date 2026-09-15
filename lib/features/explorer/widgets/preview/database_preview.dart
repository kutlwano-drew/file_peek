import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sqlite3/sqlite3.dart';

class DatabasePreview extends StatefulWidget {
  final String path;

  const DatabasePreview({
    super.key,
    required this.path,
  });

  @override
  State<DatabasePreview> createState() => _DatabasePreviewState();
}

class _DatabasePreviewState extends State<DatabasePreview> {
  Database? db;
  List<String> tables = [];
  String? error;

  @override
  void initState() {
    super.initState();

    try {
      db = sqlite3.open(
        widget.path,
        mode: OpenMode.readOnly,
      );

      tables = (db!.select(
        "SELECT name FROM sqlite_master "
        "WHERE type='table' ORDER BY name",
      ))
          .map((r) => r['name'] as String)
          .toList();
    } catch (e) {
      error = e.toString();
    }
  }

  @override
  void dispose() {
    db?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) {
    if (error != null) {
      return Center(
        child: Text(
          'Database could not be opened.\n$error',
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Tables',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        for (final t in tables)
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.table_chart_outlined,
              ),
              title: Text(t),
              onTap: () => _showTable(t),
            ),
          ),
      ],
    );
  }

  void _showTable(String table) {
    final rows = db!.select(
      'SELECT * FROM "${table.replaceAll('"', '""')}" LIMIT 100',
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(table),
        content: SizedBox(
          width: 700,
          height: 450,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                for (final k in rows.columnNames)
                  DataColumn(
                    label: Text(k),
                  ),
              ],
              rows: [
                for (final r in rows)
                  DataRow(
                    cells: [
                      for (final k in rows.columnNames)
                        DataCell(
                          Text('${r[k] ?? ''}'),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}