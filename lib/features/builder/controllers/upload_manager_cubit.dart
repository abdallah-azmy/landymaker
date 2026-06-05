import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../models/selected_image_data.dart';
import '../../../services/image_media_service.dart';
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

class UploadManagerState {
  final Map<String, UploadTask> uploads;
  UploadManagerState(this.uploads);
}

class UploadManagerCubit extends Cubit<UploadManagerState> {
  final ImageMediaService _mediaService;

  UploadManagerCubit({ImageMediaService? mediaService})
      : _mediaService = mediaService ?? sl<ImageMediaService>(),
        super(UploadManagerState({}));

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
    emit(UploadManagerState(currentUploads));

    try {
      String finalUrl = '';
      if (data.source == SelectedImageSource.local && data.bytes != null) {
        finalUrl = await _mediaService.uploadImageBytesToImgBB(
          data.bytes!,
          'local_upload.jpg',
          (sent, total) => _updateProgress(uploadId, sent / total),
          cancelToken: cancelToken,
        );
      } else if (data.source == SelectedImageSource.pixabay && data.webformatUrl != null) {
        finalUrl = await _mediaService.downloadAndUploadPixabayImage(
          data.webformatUrl!,
          (sent, total) => _updateProgress(uploadId, sent / total),
          cancelToken: cancelToken,
        );
      } else if (data.source == SelectedImageSource.url && data.url != null) {
        // Direct URLs are already valid images, we don't upload them.
        onSuccess(data.url!);
        _removeTask(uploadId);
        return;
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
        emit(UploadManagerState(currentUploads));
      }
    }
  }

  void _updateProgress(String uploadId, double progress) {
    if (isClosed) return;
    final currentUploads = Map<String, UploadTask>.from(state.uploads);
    if (currentUploads.containsKey(uploadId)) {
      currentUploads[uploadId] = currentUploads[uploadId]!.copyWith(progress: progress);
      emit(UploadManagerState(currentUploads));
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
    emit(UploadManagerState(currentUploads));
  }

  @override
  Future<void> close() {
    for (var task in state.uploads.values) {
      task.cancelToken.cancel('تم الإغلاق');
    }
    return super.close();
  }
}
