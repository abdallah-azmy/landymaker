import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../../../services/storage_service.dart';
import 'media_gallery_state.dart';

class MediaGalleryCubit extends Cubit<MediaGalleryState> {
  final StorageService _storageService;

  MediaGalleryCubit({required StorageService storageService})
      : _storageService = storageService,
        super(MediaGalleryInitial());

  Future<void> loadImages() async {
    emit(MediaGalleryLoading());
    try {
      final images = await _storageService.listUserImages();
      emit(MediaGalleryLoaded(images: images));
    } catch (e) {
      emit(MediaGalleryFailure(e.toString()));
    }
  }

  Future<void> uploadImage(PlatformFile file) async {
    final currentState = state;
    if (currentState is MediaGalleryLoaded) {
      emit(MediaGalleryLoading());
    }
    
    try {
      final url = await _storageService.uploadImage(file);
      if (url != null) {
        await loadImages();
        if (state is MediaGalleryLoaded) {
          emit((state as MediaGalleryLoaded).copyWith(successMessage: "تم رفع الصورة بنجاح!"));
        }
      } else {
        if (state is MediaGalleryLoaded) {
          emit((state as MediaGalleryLoaded).copyWith(errorMessage: "فشل رفع الصورة."));
        } else {
          emit(const MediaGalleryFailure("فشل رفع الصورة."));
        }
      }
    } catch (e) {
      if (state is MediaGalleryLoaded) {
        emit((state as MediaGalleryLoaded).copyWith(errorMessage: e.toString()));
      } else {
        emit(MediaGalleryFailure(e.toString()));
      }
    }
  }

  Future<void> deleteImage(String fileName) async {
    final currentState = state;
    if (currentState is! MediaGalleryLoaded) return;

    try {
      await _storageService.deleteImage(fileName);
      await loadImages();
      if (state is MediaGalleryLoaded) {
        emit((state as MediaGalleryLoaded).copyWith(successMessage: "تم حذف الصورة بنجاح."));
      }
    } catch (e) {
      emit(currentState.copyWith(errorMessage: "فشل حذف الصورة: $e"));
    }
  }
}
