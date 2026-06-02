import 'blog_category_model.dart';

class BlogPostModel {
  final String id;
  final String title;
  final String slug;
  final String content;
  final String? featuredImageUrl;
  final String? authorId;
  final String? categoryId;
  final String? metaTitle;
  final String? metaDescription;
  final bool isPublished;
  final DateTime? publishedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  final BlogCategoryModel? category; // Joined data

  BlogPostModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.content,
    this.featuredImageUrl,
    this.authorId,
    this.categoryId,
    this.metaTitle,
    this.metaDescription,
    this.isPublished = false,
    this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
    this.category,
  });

  factory BlogPostModel.fromJson(Map<String, dynamic> json) {
    return BlogPostModel(
      id: json['id'],
      title: json['title'],
      slug: json['slug'],
      content: json['content'],
      featuredImageUrl: json['featured_image_url'],
      authorId: json['author_id'],
      categoryId: json['category_id'],
      metaTitle: json['meta_title'],
      metaDescription: json['meta_description'],
      isPublished: json['is_published'] ?? false,
      publishedAt: json['published_at'] != null ? DateTime.parse(json['published_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      category: json['blog_categories'] != null ? BlogCategoryModel.fromJson(json['blog_categories']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final map = {
      'title': title,
      'slug': slug,
      'content': content,
      'featured_image_url': featuredImageUrl,
      'category_id': categoryId,
      'meta_title': metaTitle,
      'meta_description': metaDescription,
      'is_published': isPublished,
    };
    if (id.isNotEmpty) map['id'] = id;
    if (isPublished && publishedAt != null) {
      map['published_at'] = publishedAt!.toIso8601String();
    }
    return map;
  }
}
