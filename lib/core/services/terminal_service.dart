import 'dart:io';

class TerminalService {
  static Future<String> executeQuickCommand(String command, String currentDirectory) async {
    try {
      final result = await Process.run(
        Platform.isWindows ? 'cmd' : 'sh',
        Platform.isWindows ? ['/c', command] : ['-c', command],
        workingDirectory: currentDirectory,
      );
      if (result.exitCode == 0) {
        return result.stdout.toString();
      } else {
        return result.stderr.toString().isNotEmpty ? result.stderr.toString() : 'Command failed with exit code ${result.exitCode}';
      }
    } catch (e) {
      return 'Execution error: ${e.toString()}';
    }
  }
}
