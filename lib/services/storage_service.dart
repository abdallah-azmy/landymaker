import 'package:file_picker/file_picker.dart';
import 'supabase_service.dart';

class StorageService {
  final SupabaseService _supabase;

  StorageService(this._supabase);

  Future<String?> uploadImage(PlatformFile file) {
    return _supabase.uploadImage(file);
  }

  Future<List<Map<String, dynamic>>> listUserImages() {
    return _supabase.listUserImages();
  }

  Future<void> deleteImage(String fileName) {
    return _supabase.deleteImage(fileName);
  }
}
