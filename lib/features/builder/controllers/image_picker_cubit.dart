import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../injection_container.dart';
import '../../../services/image_media_service.dart';
import '../models/selected_image_data.dart';
import 'image_picker_state.dart';

class ImagePickerCubit extends Cubit<ImagePickerState> {
  final ImageMediaService _mediaService;
  final ImagePicker _imagePicker = ImagePicker();

  ImagePickerCubit({ImageMediaService? mediaService}) 
    : _mediaService = mediaService ?? sl<ImageMediaService>(),
      super(const ImagePickerInitial()) {
    // Automatically load default/popular images so the user sees them immediately
    searchPixabay('');
  }

  /// Search Pixabay API and emit results with pagination and filtering.
  Future<void> searchPixabay(String query, {String? imageType, bool loadMore = false}) async {

    int page = 1;
    List<dynamic> existingImages = [];
    String type = imageType ?? 'photo';

    if (loadMore) {
      if (state is ImagePickerPixabayLoaded) {
        final currentState = state as ImagePickerPixabayLoaded;
        if (currentState.hasReachedMax || currentState.isFetchingMore) return;
        page = currentState.page + 1;
        existingImages = currentState.images;
        type = currentState.imageType; // inherit type when paginating
        emit(currentState.copyWith(isFetchingMore: true));
      } else {
        return;
      }
    } else {
      emit(const ImagePickerLoadingPixabay());
    }

    try {
      final newImages = await _mediaService.fetchPixabayImages(query, page: page, imageType: type);
      
      emit(ImagePickerPixabayLoaded(
        [...existingImages, ...newImages],
        hasReachedMax: newImages.length < 30, // Assuming 30 is the per_page limit
        page: page,
        query: query,
        imageType: type,
        isFetchingMore: false,
      ));
    } catch (e) {
      emit(ImagePickerPixabayError(e.toString()));
    }
  }

  /// Select from Pixabay and emit data immediately without uploading.
  void selectPixabayImage(String previewUrl, String webformatUrl) {
    emit(ImagePickerSuccess(SelectedImageData.pixabay(
      previewUrl: previewUrl,
      webformatUrl: webformatUrl,
    )));
  }

  /// Launch local file picker, read bytes, and emit immediately.
  Future<void> pickLocalImage() async {
    try {
      // Pick an image with built-in compression configurations for optimal performance
      final XFile? file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 88, // The performance sweet spot
      );

      if (file == null) return; // User canceled

      // Use readAsBytes() which works perfectly on both Web and Native
      final bytes = await file.readAsBytes();
      
      emit(ImagePickerSuccess(SelectedImageData.local(bytes)));
    } catch (e) {
      emit(ImagePickerUploadError(e.toString()));
    }
  }

  /// Direct URL input
  void submitDirectUrl(String url) {
    if (url.trim().isNotEmpty) {
      emit(ImagePickerSuccess(SelectedImageData.url(url.trim())));
    }
  }

  /// Reset to initial state
  void reset() {
    emit(const ImagePickerInitial());
  }
}
