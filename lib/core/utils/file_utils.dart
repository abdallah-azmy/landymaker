import 'package:file_picker/file_picker.dart';

class FileUtils {
  /// Wrapper for FilePicker to prevent syntax issues across different environments and AI models.
  /// This centralized utility ensures that changes to the FilePicker API only need to be fixed in one place.
  static Future<PlatformFile?> pickImage() async {
    try {
      // In some versions/environments, FilePicker.platform is used.
      // In others, FilePicker.pickFiles is preferred.
      // We use .platform here as it's the standard for newer versions.
      final result = await FilePicker.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        return result.files.first;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
