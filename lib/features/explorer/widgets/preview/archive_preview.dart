
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:archive/archive.dart';

class ArchivePreview extends StatefulWidget {
  final String path;

  const ArchivePreview({
    super.key,
    required this.path,
  });

  @override
  State<ArchivePreview> createState() => _ArchivePreviewState();
}

class _ArchivePreviewState extends State<ArchivePreview> {
  List<String>? entries;
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    try {
      final b = File(widget.path).readAsBytesSync();

      Archive a;

      if (widget.path.toLowerCase().endsWith('.tar')) {
        a = TarDecoder().decodeBytes(
          b,
          storeData: false,
        );
      } else if (widget.path.toLowerCase().endsWith('.gz') ||
          widget.path.toLowerCase().endsWith('.tgz')) {
        final raw = GZipDecoder().decodeBytes(b);

        a = widget.path.toLowerCase().endsWith('.tar.gz') ||
                widget.path.toLowerCase().endsWith('.tgz')
            ? TarDecoder().decodeBytes(
                raw,
                storeData: false,
              )
            : Archive();
      } else {
        a = ZipDecoder().decodeBytes(b);
      }

      entries = a.map((e) => e.name).toList();
    } catch (e) {
      error = 'Archive format could not be displayed safely.\n$e';
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext c) {
    final isDark =
        Theme.of(c).brightness == Brightness.dark;

    final backgroundColor =
        isDark ? const Color(0xFF121212) : Colors.white;

    final foregroundColor =
        isDark ? Colors.white : Colors.black;

    if (error != null) {
      return Container(
        color: backgroundColor,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: foregroundColor,
              ),
            ),
          ),
        ),
      );
    }

    if (entries == null) {
      return Container(
        color: backgroundColor,
        child: Center(
          child: CircularProgressIndicator(
            color: foregroundColor,
          ),
        ),
      );
    }

    return Container(
      color: backgroundColor,
      child: ListView.builder(
        itemCount: entries!.length,
        itemBuilder: (_, i) => ListTile(
          leading: Icon(
            entries![i].endsWith('/')
                ? Icons.folder
                : Icons.insert_drive_file_outlined,
            color: foregroundColor,
          ),
          title: Text(
            entries![i],
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: foregroundColor,
            ),
          ),
        ),
      ),
    );
  }
}
