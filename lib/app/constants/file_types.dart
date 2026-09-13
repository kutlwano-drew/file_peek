class FileTypes {
  static const Set<String> textExtensions = {
    'dart', 'txt', 'md', 'json', 'yaml', 'yml', 'xml', 'csv', 'log',
    'html', 'htm', 'css', 'js', 'ts', 'kt', 'java', 'c', 'cpp', 'h',
    'hpp', 'rs', 'py', 'sh', 'bat', 'conf', 'ini', 'properties', 'sql',
    'gitignore', 'dockerfile', 'lock', 'rb', 'go', 'php'
  };

  static const Set<String> binaryExtensions = {
    'png', 'jpg', 'jpeg', 'gif', 'bmp', 'webp', 'ico', 'pdf', 'zip',
    'tar', 'gz', '7z', 'rar', 'exe', 'dll', 'so', 'dylib', 'bin',
    'iso', 'mp3', 'wav', 'mp4', 'mkv', 'mov', 'class', 'db', 'sqlite'
  };

  static bool isBinary(String extension) {
    return binaryExtensions.contains(extension.toLowerCase());
  }

  static bool isText(String extension) {
    return textExtensions.contains(extension.toLowerCase());
  }
}
