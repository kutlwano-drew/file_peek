class ProjectStatistics {
  final int totalFolders;
  final int totalFiles;
  final int totalSizeBytes;
  final Map<String, int> extensionCounts;

  const ProjectStatistics({
    required this.totalFolders,
    required this.totalFiles,
    required this.totalSizeBytes,
    required this.extensionCounts,
  });

  factory ProjectStatistics.empty() {
    return const ProjectStatistics(
      totalFolders: 0,
      totalFiles: 0,
      totalSizeBytes: 0,
      extensionCounts: {},
    );
  }

  String get formattedTotalSize {
    if (totalSizeBytes < 1024 * 1024) {
      return '${(totalSizeBytes / 1024).toStringAsFixed(1)} KB';
    } else if (totalSizeBytes < 1024 * 1024 * 1024) {
      return '${(totalSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(totalSizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
