import 'package:flutter/material.dart';
import '../../../core/models/terminal_command.dart';
import '../../../core/services/terminal_service.dart';

class TerminalController extends ChangeNotifier {
  final List<TerminalCommand> _history = [];
  final List<String> _outputLog = [];
  bool _isRunning = false;

  List<TerminalCommand> get history => _history;
  List<String> get outputLog => _outputLog;
  bool get isRunning => _isRunning;

  Future<void> executeCommand(String command, String currentDirectory) async {
    final trimmed = command.trim();
    if (trimmed.isEmpty) return;

    _history.add(TerminalCommand(command: trimmed, timestamp: DateTime.now()));
    _outputLog.add('\$ $trimmed');
    _isRunning = true;
    notifyListeners();

    try {
      final result = await TerminalService.executeQuickCommand(trimmed, currentDirectory);
      _outputLog.add(result);
    } catch (e) {
      _outputLog.add('Error executing command: ${e.toString()}');
    }

    _isRunning = false;
    notifyListeners();
  }

  void clearLog() {
    _outputLog.clear();
    notifyListeners();
  }
}
