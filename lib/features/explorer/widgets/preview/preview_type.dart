class PreviewType {
  final String label;
  final String kind;

  const PreviewType(this.label, this.kind);
}

PreviewType previewTypeFor(String name) {
  final n = name.toLowerCase();
  final e = n.contains('.') ? n.substring(n.lastIndexOf('.') + 1) : n;

  if ({
    'png',
    'jpg',
    'jpeg',
    'gif',
    'bmp',
    'webp',
    'ico',
    'svg',
  }.contains(e)) {
    return PreviewType('Image', 'image');
  }

  if (e == 'pdf') {
    return const PreviewType('PDF', 'pdf');
  }

  if ({
    'mp4',
    'mkv',
    'mov',
    'webm',
    'avi',
    'm4v',
  }.contains(e)) {
    return const PreviewType('Video', 'video');
  }

  if ({
    'mp3',
    'wav',
    'flac',
    'ogg',
    'm4a',
    'aac',
  }.contains(e)) {
    return const PreviewType('Audio', 'audio');
  }

  if ({
    'xlsx',
    'xlsm',
    'xls',
  }.contains(e)) {
    return const PreviewType('Spreadsheet', 'spreadsheet');
  }

  if ({
    'db',
    'sqlite',
    'sqlite3',
  }.contains(e)) {
    return const PreviewType('SQLite Database', 'database');
  }

  if ({
    'zip',
    'tar',
    'gz',
    'tgz',
    'bz2',
    'xz',
    '7z',
    'rar',
  }.contains(e)) {
    return const PreviewType('Archive', 'archive');
  }

  if (e == 'docx') {
    return const PreviewType('Word Document', 'document');
  }

  if (e == 'md' || e == 'markdown') {
    return const PreviewType('Markdown', 'markdown');
  }

  if ({
    'dart',
    'js',
    'jsx',
    'ts',
    'tsx',
    'java',
    'kt',
    'kts',
    'swift',
    'py',
    'rb',
    'go',
    'rs',
    'php',
    'c',
    'h',
    'hpp',
    'cpp',
    'cc',
    'cs',
    'html',
    'htm',
    'xml',
    'css',
    'scss',
    'json',
    'yaml',
    'yml',
    'sql',
    'sh',
    'bash',
  }.contains(e)) {
    return PreviewType(_languageName(e), 'code');
  }

  return const PreviewType('Text', 'text');
}

String _languageName(String e) {
  const m = {
    'dart': 'Dart',
    'js': 'JavaScript',
    'jsx': 'JavaScript',
    'ts': 'TypeScript',
    'tsx': 'TypeScript',
    'java': 'Java',
    'kt': 'Kotlin',
    'kts': 'Kotlin',
    'swift': 'Swift',
    'py': 'Python',
    'rb': 'Ruby',
    'go': 'Go',
    'rs': 'Rust',
    'php': 'PHP',
    'c': 'C',
    'h': 'C/C++',
    'hpp': 'C/C++',
    'cpp': 'C++',
    'cc': 'C++',
    'cs': 'C#',
    'html': 'HTML',
    'htm': 'HTML',
    'xml': 'XML',
    'css': 'CSS',
    'scss': 'SCSS',
    'json': 'JSON',
    'yaml': 'YAML',
    'yml': 'YAML',
    'sql': 'SQL',
    'sh': 'Shell',
    'bash': 'Shell',
  };

  return m[e] ?? 'Code';
}