abstract class BlogState {}

class BlogInitial extends BlogState {}

class BlogLoading extends BlogState {}

class BlogLoaded extends BlogState {
  final List<dynamic> posts;
  final List<dynamic> categories;

  BlogLoaded({required this.posts, required this.categories});
}

class BlogError extends BlogState {
  final String message;
  BlogError(this.message);
}
