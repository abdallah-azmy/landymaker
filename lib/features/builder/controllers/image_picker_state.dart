import 'package:flutter/foundation.dart';
import '../models/selected_image_data.dart';

@immutable
abstract class ImagePickerState {
  const ImagePickerState();
}

class ImagePickerInitial extends ImagePickerState {
  const ImagePickerInitial();
}

class ImagePickerLoadingPixabay extends ImagePickerState {
  const ImagePickerLoadingPixabay();
}

class ImagePickerPixabayLoaded extends ImagePickerState {
  final List<dynamic> images; // List<PixabayImageModel>
  final bool hasReachedMax;
  final int page;
  final String query;
  final String imageType;
  final bool isFetchingMore;

  const ImagePickerPixabayLoaded(
    this.images, {
    this.hasReachedMax = false,
    this.page = 1,
    this.query = '',
    this.imageType = 'all',
    this.isFetchingMore = false,
  });

  ImagePickerPixabayLoaded copyWith({
    List<dynamic>? images,
    bool? hasReachedMax,
    int? page,
    String? query,
    String? imageType,
    bool? isFetchingMore,
  }) {
    return ImagePickerPixabayLoaded(
      images ?? this.images,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      page: page ?? this.page,
      query: query ?? this.query,
      imageType: imageType ?? this.imageType,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
    );
  }
}

class ImagePickerPixabayError extends ImagePickerState {
  final String message;
  const ImagePickerPixabayError(this.message);
}

class ImagePickerUploading extends ImagePickerState {
  final double progress; // 0.0 to 1.0
  const ImagePickerUploading(this.progress);
}

class ImagePickerSuccess extends ImagePickerState {
  final SelectedImageData selectedData;
  const ImagePickerSuccess(this.selectedData);
}

class ImagePickerUploadError extends ImagePickerState {
  final String message;
  const ImagePickerUploadError(this.message);
}
