// ignore_for_file: unused_element
part of '../supabase_service.dart';


// ----------------------------------------------------
// STORAGE IMAGE UPLOADS & MANAGEMENT
// ----------------------------------------------------

mixin SupabaseServiceStorage on ChangeNotifier {
  SupabaseClient? get _client;
  set _client(SupabaseClient? val);

  String? get _currentUserId;

  String get _currentUserRole;

  String get _currentUserTier;

  int? get _cachedAssetsCount;
  set _cachedAssetsCount(int? val);

  DateTime? get _lastCountFetch;
  set _lastCountFetch(DateTime? val);
  Future<List<Map<String, dynamic>>> listUserImages() async {
    try {
      final userId = _currentUserId;
      if (userId == null) return [];

      final List<FileObject> files = await _client!.storage
          .from(DbConstants.landingAssetsBucket)
          .list(path: userId);

      final storageImages = files.map((f) {
        final publicUrl = _client!.storage
            .from(DbConstants.landingAssetsBucket)
            .getPublicUrl('$userId/${f.name}');

        return {
          'name': f.name,
          'id': f.id,
          'url': publicUrl,
          'size': f.metadata?['size'],
          'created_at': f.createdAt,
          'source': 'storage',
        };
      }).toList();

      final dbAssets = await _client!
          .from(DbConstants.userAssetsTable)
          .select()
          .eq('user_id', userId);

      final dbImages = List<Map<String, dynamic>>.from(dbAssets).map((a) {
        return {
          'name': a['name'] ?? 'ImgBB Asset',
          'id': a['id'],
          'url': a['url'],
          'created_at': a['created_at'],
          'source': 'imgbb',
          'hash': a['image_hash'],
        };
      }).toList();

      return [...storageImages, ...dbImages]
        ..sort((a, b) => b['created_at'].compareTo(a['created_at']));
    } catch (e) {
      debugPrint("Error listing user images: $e");
      return [];
    }
  }

  Future<String?> findAssetByHash(String hash) async {
    try {
      final res = await _client!
          .from(DbConstants.userAssetsTable)
          .select('url')
          .eq('image_hash', hash)
          .maybeSingle();
      return res?['url'] as String?;
    } catch (e) {
      return null;
    }
  }

  Future<void> registerExternalAsset(String url, String name, {String? hash}) async {
    try {
      final userId = _currentUserId;
      if (userId == null) return;

      await _client!.from(DbConstants.userAssetsTable).insert({
        'user_id': userId,
        'url': url,
        'name': name,
        'source': 'imgbb',
        'image_hash': hash,
      });
    } catch (e) {
      debugPrint("Error registering external asset: $e");
    }
  }

  Future<void> deleteImage(String fileName, {String? source, String? assetId}) async {
    try {
      final userId = _currentUserId;
      if (userId == null) return;

      if (source == 'imgbb' && assetId != null) {
        await _client!.from(DbConstants.userAssetsTable).delete().eq('id', assetId);
      } else {
        await _client!.storage
            .from(DbConstants.landingAssetsBucket)
            .remove(['$userId/$fileName']);
      }
    } catch (e) {
      debugPrint("Error deleting image: $e");
      rethrow;
    }
  }

  Future<String?> uploadImage(PlatformFile file) async {
    final bytes = file.bytes;
    if (bytes == null) {
      throw Exception("File data is missing. Unexpected null value.");
    }
    return uploadImageBytes(bytes, file.name);
  }

  Future<String?> uploadImageBytes(Uint8List bytes, String fileName) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        throw Exception("User session not found. Please login again.");
      }

      int quota = 50;
      if (_currentUserRole == 'super_admin') {
        quota = 999999;
      } else if (_currentUserTier == 'pro') {
        quota = 200;
      } else if (_currentUserTier == 'business') {
        quota = 500;
      } else if (_currentUserTier == 'agency') {
        quota = 1000;
      }

      if (_cachedAssetsCount == null ||
          _lastCountFetch == null ||
          DateTime.now().difference(_lastCountFetch!).inSeconds > 10) {
        final existingFiles = await _client!.storage
            .from(DbConstants.landingAssetsBucket)
            .list(path: userId);
        _cachedAssetsCount = existingFiles.length;
        _lastCountFetch = DateTime.now();
      }

      if (_cachedAssetsCount! >= quota && _currentUserRole != 'super_admin') {
        String msg = "لقد وصلت للحد الأقصى للرفع ($quota صورة).";
        if (_currentUserTier == 'free') {
          msg += " قم بالترقية للحصول على مساحة أكبر تصل إلى 1000 صورة.";
        } else {
          msg += " يرجى حذف بعض الصور القديمة لتتمكن من إضافة صور جديدة.";
        }
        throw Exception(msg);
      }

      final fileExtension = fileName.split('.').last;
      final filePath =
          '$userId/${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

      await _client!.storage
          .from(DbConstants.landingAssetsBucket)
          .uploadBinary(filePath, bytes);

      _cachedAssetsCount = (_cachedAssetsCount ?? 0) + 1;

      return _client!.storage
          .from(DbConstants.landingAssetsBucket)
          .getPublicUrl(filePath);
    } catch (e, stack) {
      ErrorHandler.logError("Error uploading image bytes", e, stack);
      rethrow;
    }
  }
}

