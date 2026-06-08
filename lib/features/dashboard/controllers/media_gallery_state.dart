import 'package:equatable/equatable.dart';

abstract class MediaGalleryState extends Equatable {
  const MediaGalleryState();

  @override
  List<Object?> get props => [];
}

class MediaGalleryInitial extends MediaGalleryState {}

class MediaGalleryLoading extends MediaGalleryState {}

class MediaGalleryLoaded extends MediaGalleryState {
  final List<Map<String, dynamic>> images;
  final String? successMessage;
  final String? errorMessage;

  const MediaGalleryLoaded({
    required this.images,
    this.successMessage,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [images, successMessage, errorMessage];

  MediaGalleryLoaded copyWith({
    List<Map<String, dynamic>>? images,
    String? successMessage,
    String? errorMessage,
  }) {
    return MediaGalleryLoaded(
      images: images ?? this.images,
      successMessage: successMessage,
      errorMessage: errorMessage,
    );
  }
}

class MediaGalleryFailure extends MediaGalleryState {
  final String message;

  const MediaGalleryFailure(this.message);

  @override
  List<Object?> get props => [message];
}
