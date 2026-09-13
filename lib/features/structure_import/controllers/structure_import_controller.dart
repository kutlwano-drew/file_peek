import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../services/structure_parser.dart';

class StructureImportController extends ChangeNotifier {
  String _rawStructureInput = '';
  String? _targetDirectoryPath;
  bool _isGenerating = false;
  String? _statusMessage;

  String get rawStructureInput => _rawStructureInput;
  String? get targetDirectoryPath => _targetDirectoryPath;
  bool get isGenerating => _isGenerating;
  String? get statusMessage => _statusMessage;

  void updateInput(String input) {
    _rawStructureInput = input;
    notifyListeners();
  }

  Future<void> pickTargetDirectory() async {
    final String? dir = await FilePicker.getDirectoryPath();
    if (dir != null) {
      _targetDirectoryPath = dir;
      notifyListeners();
    }
  }

  Future<bool> generateStructure() async {
    if (_rawStructureInput.trim().isEmpty || _targetDirectoryPath == null) {
      return false;
    }

    _isGenerating = true;
    _statusMessage = 'Generating structure on disk...';
    notifyListeners();

    try {
      await StructureParser.generateStructureOnDisk(_rawStructureInput, _targetDirectoryPath!);
      _isGenerating = false;
      _statusMessage = 'Structure successfully generated!';
      notifyListeners();
      return true;
    } catch (e) {
      _isGenerating = false;
      _statusMessage = 'Failed to generate: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  void clear() {
    _rawStructureInput = '';
    _targetDirectoryPath = null;
    _statusMessage = null;
    notifyListeners();
  }
}
