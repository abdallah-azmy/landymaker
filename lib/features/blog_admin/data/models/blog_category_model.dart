class BlogCategoryModel {
  final String id;
  final String name;
  final String slug;
  final DateTime createdAt;

  BlogCategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.createdAt,
  });

  factory BlogCategoryModel.fromJson(Map<String, dynamic> json) {
    return BlogCategoryModel(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'name': name,
      'slug': slug,
    };
  }
}
