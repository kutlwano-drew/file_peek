import 'package:flutter/material.dart';

class StructureInput extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const StructureInput({
    Key? key,
    required this.controller,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: null,
      expands: true,
      onChanged: onChanged,
      cursorColor: Colors.black,
      style: const TextStyle(
        fontFamily: 'monospace',
        fontSize: 13,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        hintText:
            'Paste your folder structure here (e.g. ASCII tree or indented paths)...\n\n'
            'my_project/\n'
            '├── lib/\n'
            '│   └── main.dart\n'
            '└── pubspec.yaml',
        hintStyle: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
          color: Colors.grey,
        ),
        border: const OutlineInputBorder(),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey,
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey,
            width: 1.5,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
