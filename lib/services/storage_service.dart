import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'supabase_service.dart';

class StorageService {
  final SupabaseService _supabase;

  StorageService(this._supabase);

  Future<String?> uploadImage(PlatformFile file) {
    return _supabase.uploadImage(file);
  }

  Future<String?> uploadImageBytes(Uint8List bytes, String fileName) {
    return _supabase.uploadImageBytes(bytes, fileName);
  }

  Future<List<Map<String, dynamic>>> listUserImages() {
    return _supabase.listUserImages();
  }

  Future<String?> findAssetByHash(String hash) {
    return _supabase.findAssetByHash(hash);
  }

  Future<void> registerExternalAsset(String url, String name, {String? hash}) {
    return _supabase.registerExternalAsset(url, name, hash: hash);
  }

  Future<void> deleteImage(String fileName, {String? source, String? assetId}) {
    return _supabase.deleteImage(fileName, source: source, assetId: assetId);
  }
}
