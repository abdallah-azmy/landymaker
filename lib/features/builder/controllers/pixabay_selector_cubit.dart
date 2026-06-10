import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/image_media_service.dart';

abstract class PixabaySelectorState {}

class PixabaySelectorInitial extends PixabaySelectorState {}

class PixabaySelectorLoading extends PixabaySelectorState {}

class PixabaySelectorLoaded extends PixabaySelectorState {
  final List<PixabayImageModel> images;
  final int currentPage;
  final String query;
  final String type;

  PixabaySelectorLoaded({
    required this.images,
    required this.currentPage,
    required this.query,
    required this.type,
  });
}

class PixabaySelectorFailure extends PixabaySelectorState {
  final String error;
  PixabaySelectorFailure(this.error);
}

class PixabaySelectorCubit extends Cubit<PixabaySelectorState> {
  final ImageMediaService _mediaService;

  PixabaySelectorCubit(this._mediaService) : super(PixabaySelectorInitial());

  Future<void> searchImages(String query, {int page = 1, String type = 'photo'}) async {
    emit(PixabaySelectorLoading());
    try {
      final images = await _mediaService.fetchPixabayImages(query, page: page, imageType: type);
      emit(PixabaySelectorLoaded(
        images: images,
        currentPage: page,
        query: query,
        type: type,
      ));
    } catch (e) {
      emit(PixabaySelectorFailure(e.toString()));
    }
  }

  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is! PixabaySelectorLoaded) return;

    final nextPage = currentState.currentPage + 1;
    try {
      final moreImages = await _mediaService.fetchPixabayImages(
        currentState.query,
        page: nextPage,
        imageType: currentState.type,
      );
      
      emit(PixabaySelectorLoaded(
        images: [...currentState.images, ...moreImages],
        currentPage: nextPage,
        query: currentState.query,
        type: currentState.type,
      ));
    } catch (e) {
      // Keep existing data but show error? For now just fail.
      emit(PixabaySelectorFailure(e.toString()));
    }
  }
}
