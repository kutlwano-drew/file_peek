class ExportUtils {
  static String sanitizeFileName(String name) {
    try {
      return name.replaceAll(RegExp(r'[^\w\s\.-]'), '_').replaceAll(RegExp(r'\s+'), '_');
    } catch (_) {
      return 'export_output';
    }
  }
}
