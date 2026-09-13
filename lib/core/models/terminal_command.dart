class TerminalCommand {
  final String command;
  final DateTime timestamp;
  final bool isSuccess;

  TerminalCommand({
    required this.command,
    required this.timestamp,
    this.isSuccess = true,
  });
}
