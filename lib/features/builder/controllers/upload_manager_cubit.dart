import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../models/selected_image_data.dart';
import '../../../services/image_media_service.dart';
import '../../../services/storage_service.dart';
import '../../../core/utils/crypto_utils.dart';
import '../../../injection_container.dart';

class UploadTask {
  final String id;
  final SelectedImageData data;
  final double progress;
  final CancelToken cancelToken;
  final String? error;
  final Function()? onCancel;

  UploadTask({
    required this.id,
    required this.data,
    this.progress = 0.0,
    required this.cancelToken,
    this.error,
    this.onCancel,
  });

  UploadTask copyWith({double? progress, String? error}) {
    return UploadTask(
      id: id,
      data: data,
      progress: progress ?? this.progress,
      cancelToken: cancelToken,
      error: error ?? this.error,
      onCancel: onCancel,
    );
  }
}

enum SavePhase { idle, uploadingImages, savingToDb, completed, error }

class SaveProcessState {
  final SavePhase phase;
  final String statusText;
  final String subdomain;
  final String? pageId;
  final String? errorMessage;

  const SaveProcessState({
    required this.phase,
    required this.statusText,
    required this.subdomain,
    this.pageId,
    this.errorMessage,
  });

  SaveProcessState copyWith({
    SavePhase? phase,
    String? statusText,
    String? subdomain,
    String? pageId,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SaveProcessState(
      phase: phase ?? this.phase,
      statusText: statusText ?? this.statusText,
      subdomain: subdomain ?? this.subdomain,
      pageId: pageId ?? this.pageId,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class UploadManagerState {
  final Map<String, UploadTask> uploads;
  final SaveProcessState? saveProcess;
  UploadManagerState(this.uploads, {this.saveProcess});
}

class UploadManagerCubit extends Cubit<UploadManagerState> {
  final ImageMediaService _mediaService;
  final StorageService _storageService;

  UploadManagerCubit({
    ImageMediaService? mediaService,
    StorageService? storageService,
  })  : _mediaService = mediaService ?? sl<ImageMediaService>(),
        _storageService = storageService ?? sl<StorageService>(),
        super(UploadManagerState({}, saveProcess: null));

  Future<void> upload({
    required String uploadId, // e.g. "upload://uuid"
    required SelectedImageData data,
    required Function(String finalUrl) onSuccess,
    Function()? onCancel,
  }) async {
    final cancelToken = CancelToken();
    
    final newTask = UploadTask(
      id: uploadId,
      data: data,
      cancelToken: cancelToken,
      onCancel: onCancel,
    );

    final currentUploads = Map<String, UploadTask>.from(state.uploads);
    currentUploads[uploadId] = newTask;
    emit(UploadManagerState(currentUploads, saveProcess: state.saveProcess));

    try {
       String finalUrl = '';
      Uint8List? imageBytes;

      if (data.source == SelectedImageSource.local && data.bytes != null) {
        imageBytes = data.bytes;
      } else if (data.source == SelectedImageSource.pixabay && data.webformatUrl != null) {
        // Pre-check by sourceUrl to avoid downloading image bytes entirely!
        final existingUrlBySource = await _storageService.findAssetBySourceUrl(data.webformatUrl!);
        if (existingUrlBySource != null) {
          onSuccess(existingUrlBySource);
          _removeTask(uploadId);
          return;
        }

        imageBytes = await _mediaService.downloadImageBytes(
          data.webformatUrl!,
          cancelToken: cancelToken,
        );
      } else if (data.source == SelectedImageSource.url && data.url != null) {
        // Direct URLs are already valid images, we don't upload them.
        onSuccess(data.url!);
        _removeTask(uploadId);
        return;
      }

      if (imageBytes != null) {
        // 0. Check for existing hash (Deduplication)
        final hash = CryptoUtils.calculateHash(imageBytes);
        final existingUrl = await _storageService.findAssetByHash(hash);
        if (existingUrl != null) {
          if (data.source == SelectedImageSource.pixabay && data.webformatUrl != null) {
            // Also map it to this source URL for future lookups
            await _storageService.registerExternalAsset(
              existingUrl,
              'img_${DateTime.now().millisecondsSinceEpoch}.jpg',
              hash: hash,
              sourceUrl: data.webformatUrl,
            );
          }
          onSuccess(existingUrl);
          _removeTask(uploadId);
          return;
        }

        // 1. Upload to ImgBB for the design URL
        finalUrl = await _mediaService.uploadImageBytesToImgBB(
          imageBytes,
          'image_upload.jpg',
          (sent, total) => _updateProgress(uploadId, sent / total),
          cancelToken: cancelToken,
        );

        // 2. Register with user_assets table in Supabase
        await _storageService.registerExternalAsset(
          finalUrl,
          'img_${DateTime.now().millisecondsSinceEpoch}.jpg',
          hash: hash,
          sourceUrl: data.source == SelectedImageSource.pixabay ? data.webformatUrl : null,
        );
      }

      if (!isClosed) {
        onSuccess(finalUrl);
        _removeTask(uploadId);
      }

    } catch (e) {
      if (isClosed) return;
      final currentUploads = Map<String, UploadTask>.from(state.uploads);
      if (currentUploads.containsKey(uploadId)) {
        // Strip exception prefix
        String errMsg = e.toString().replaceAll('Exception: ', '');
        currentUploads[uploadId] = currentUploads[uploadId]!.copyWith(error: errMsg);
        emit(UploadManagerState(currentUploads, saveProcess: state.saveProcess));
      }
    }
  }

  /// New: Persists an external URL (e.g. from Pixabay template) to the user's storage.
  Future<void> persistExternalImage({
    required String uploadId,
    required String externalUrl,
    required Function(String finalUrl) onSuccess,
  }) async {
    final cancelToken = CancelToken();
    
    // Create a dummy SelectedImageData for the task tracking
    final data = SelectedImageData(
      source: SelectedImageSource.url,
      url: externalUrl,
    );

    final newTask = UploadTask(
      id: uploadId,
      data: data,
      cancelToken: cancelToken,
    );

    final currentUploads = Map<String, UploadTask>.from(state.uploads);
    currentUploads[uploadId] = newTask;
    emit(UploadManagerState(currentUploads, saveProcess: state.saveProcess));

     try {
      // 0. Pre-check: has this exact external URL already been uploaded/registered?
      final existingUrlBySource = await _storageService.findAssetBySourceUrl(externalUrl);
      if (existingUrlBySource != null) {
        onSuccess(existingUrlBySource);
        _removeTask(uploadId);
        return;
      }

      // 1. Download image into bytes
      final Uint8List imageBytes = await _mediaService.downloadImageBytes(
        externalUrl,
        cancelToken: cancelToken,
      );

      // 1.5 Deduplication Check
      final hash = CryptoUtils.calculateHash(imageBytes);
      final existingUrl = await _storageService.findAssetByHash(hash);
      if (existingUrl != null) {
        // Also map it to this source URL for future lookups
        await _storageService.registerExternalAsset(
          existingUrl,
          'import_${DateTime.now().millisecondsSinceEpoch}.jpg',
          hash: hash,
          sourceUrl: externalUrl,
        );
        onSuccess(existingUrl);
        _removeTask(uploadId);
        return;
      }

      // 2. Upload to ImgBB (for the design JSON)
      final imgbbUrl = await _mediaService.uploadImageBytesToImgBB(
        imageBytes,
        'template_fixed.jpg',
        (sent, total) => _updateProgress(uploadId, sent / total),
        cancelToken: cancelToken,
      );

      // 3. Register with user_assets table
      await _storageService.registerExternalAsset(
        imgbbUrl,
        'import_${DateTime.now().millisecondsSinceEpoch}.jpg',
        hash: hash,
        sourceUrl: externalUrl,
      );

      if (!isClosed) {
        onSuccess(imgbbUrl);
        _removeTask(uploadId);
      }
    } catch (e) {
       if (isClosed) return;
      final currentUploads = Map<String, UploadTask>.from(state.uploads);
      if (currentUploads.containsKey(uploadId)) {
        String errMsg = e.toString().replaceAll('Exception: ', '');
        currentUploads[uploadId] = currentUploads[uploadId]!.copyWith(error: errMsg);
        emit(UploadManagerState(currentUploads, saveProcess: state.saveProcess));
      }
    }
  }

  void _updateProgress(String uploadId, double progress) {
    if (isClosed) return;
    final currentUploads = Map<String, UploadTask>.from(state.uploads);
    if (currentUploads.containsKey(uploadId)) {
      currentUploads[uploadId] = currentUploads[uploadId]!.copyWith(progress: progress);
      emit(UploadManagerState(currentUploads, saveProcess: state.saveProcess));
    }
  }

  void cancelUpload(String uploadId) {
    if (state.uploads.containsKey(uploadId)) {
      final task = state.uploads[uploadId]!;
      task.cancelToken.cancel('تم الإلغاء');
      if (task.onCancel != null) {
        task.onCancel!();
      }
      _removeTask(uploadId);
    }
  }

  void retryUpload(String uploadId, Function(String) onSuccess) {
    if (state.uploads.containsKey(uploadId)) {
      final task = state.uploads[uploadId]!;
      _removeTask(uploadId);
      upload(uploadId: task.id, data: task.data, onSuccess: onSuccess);
    }
  }

  void _removeTask(String uploadId) {
    if (isClosed) return;
    final currentUploads = Map<String, UploadTask>.from(state.uploads);
    currentUploads.remove(uploadId);
    emit(UploadManagerState(currentUploads, saveProcess: state.saveProcess));
  }

  // ──────────────────────────────────────────────
  // Save Process Management
  // ──────────────────────────────────────────────

  void startSaveProcess({
    required String subdomain,
    String? pageId,
  }) {
    if (isClosed) return;
    emit(UploadManagerState(
      Map<String, UploadTask>.from(state.uploads),
      saveProcess: SaveProcessState(
        phase: SavePhase.uploadingImages,
        statusText: '',
        subdomain: subdomain,
        pageId: pageId,
      ),
    ));
  }

  void updateSaveStatus(SavePhase phase, String statusText) {
    if (isClosed || state.saveProcess == null) return;
    emit(UploadManagerState(
      Map<String, UploadTask>.from(state.uploads),
      saveProcess: state.saveProcess!.copyWith(
        phase: phase,
        statusText: statusText,
        clearError: true,
      ),
    ));
  }

  void completeSaveProcess({String? errorMessage}) {
    if (isClosed || state.saveProcess == null) return;
    emit(UploadManagerState(
      Map<String, UploadTask>.from(state.uploads),
      saveProcess: state.saveProcess!.copyWith(
        phase: errorMessage != null ? SavePhase.error : SavePhase.completed,
        errorMessage: errorMessage,
      ),
    ));
  }

  void clearSaveProcess() {
    if (isClosed) return;
    emit(UploadManagerState(
      Map<String, UploadTask>.from(state.uploads),
      saveProcess: null,
    ));
  }

  @override
  Future<void> close() {
    for (var task in state.uploads.values) {
      task.cancelToken.cancel('تم الإغلاق');
    }
    return super.close();
  }
}
