import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/blog_repository.dart';
import '../data/models/blog_post_model.dart';
import 'blog_state.dart';

class BlogCubit extends Cubit<BlogState> {
  final BlogRepository _repository;

  BlogCubit(this._repository) : super(BlogInitial());

  Future<void> loadBlogData() async {
    emit(BlogLoading());
    try {
      final posts = await _repository.getAdminPosts();
      final categories = await _repository.getCategories();
      emit(BlogLoaded(posts: posts, categories: categories));
    } catch (e) {
      emit(BlogError(e.toString()));
    }
  }

  Future<void> savePost(BlogPostModel post) async {
    try {
      await _repository.savePost(post);
      await loadBlogData(); // Reload data to get updated list
    } catch (e) {
      emit(BlogError(e.toString()));
    }
  }

  Future<void> deletePost(String id) async {
    try {
      await _repository.deletePost(id);
      await loadBlogData();
    } catch (e) {
      emit(BlogError(e.toString()));
    }
  }

  Future<void> createCategory(String name, String slug) async {
    try {
      await _repository.createCategory(name, slug);
      await loadBlogData();
    } catch (e) {
      emit(BlogError(e.toString()));
    }
  }
}
