import \u0027package:file_picker/file_picker.dart\u0027;

class FileUtils {
  /// Wrapper for FilePicker to prevent platform-specific syntax issues across environments.
  static Future\u003cFilePickerResult?\u003e pickImage() async {
    try {
      // Some versions of file_picker use .platform, others use static pickFiles.
      // Wrapping it here ensures a single point of failure and easier maintenance.
      return await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );
    } catch (e) {
      // Fallback for environments where .platform might not be defined or available
      // though typically in version 11+ it should be there.
      return null;
    }
  }
}
