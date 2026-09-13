class ParserService {
  static String parseCommandAlias(String command, String currentDir) {
    final trimmed = command.trim();
    if (trimmed == 'pwd') {
      return currentDir;
    }
    return trimmed;
  }
}
