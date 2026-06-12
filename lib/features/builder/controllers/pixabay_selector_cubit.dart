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
  final String? orientation;

  PixabaySelectorLoaded({
    required this.images,
    required this.currentPage,
    required this.query,
    required this.type,
    this.orientation,
  });
}

class PixabaySelectorFailure extends PixabaySelectorState {
  final String error;
  PixabaySelectorFailure(this.error);
}

class PixabaySelectorCubit extends Cubit<PixabaySelectorState> {
  final ImageMediaService _mediaService;

  PixabaySelectorCubit(this._mediaService) : super(PixabaySelectorInitial());

  Future<void> searchImages(String query, {int page = 1, String type = 'photo', String? orientation}) async {
    emit(PixabaySelectorLoading());
    try {
      final images = await _mediaService.fetchPixabayImages(
        query, page: page, imageType: type, orientation: orientation,
      );
      emit(PixabaySelectorLoaded(
        images: images,
        currentPage: page,
        query: query,
        type: type,
        orientation: orientation,
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
        orientation: currentState.orientation,
      );
      
      emit(PixabaySelectorLoaded(
        images: [...currentState.images, ...moreImages],
        currentPage: nextPage,
        query: currentState.query,
        type: currentState.type,
        orientation: currentState.orientation,
      ));
    } catch (e) {
      emit(PixabaySelectorFailure(e.toString()));
    }
  }
}
