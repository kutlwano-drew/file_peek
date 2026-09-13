enum ExportFormat { txt, markdown, pdf }

class ExportOptions {
  final ExportFormat format;
  final bool includeRootFolder;
  final bool includeMetadata;
  final bool includeTimestamps;
  final bool includeLineNumbers;
  final bool skipBinaryFiles;
  final bool skipHiddenFiles;
  final int maxFileSizeKB;
  final bool useUnicodeTree;

  const ExportOptions({
    this.format = ExportFormat.markdown,
    this.includeRootFolder = true,
    this.includeMetadata = true,
    this.includeTimestamps = true,
    this.includeLineNumbers = false,
    this.skipBinaryFiles = true,
    this.skipHiddenFiles = true,
    this.maxFileSizeKB = 2048,
    this.useUnicodeTree = true,
  });
}
