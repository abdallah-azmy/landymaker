import 'package:landymaker/features/blog_admin/data/models/blog_category_model.dart';
import 'package:landymaker/features/blog_admin/data/models/blog_post_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BlogRepository {
  final SupabaseClient _supabase;

  BlogRepository(this._supabase);

  // --- Categories ---
  Future<List<BlogCategoryModel>> getCategories() async {
    final response = await _supabase
        .from('blog_categories')
        .select()
        .order('name', ascending: true);
    return (response as List)
        .map((e) => BlogCategoryModel.fromJson(e))
        .toList();
  }

  Future<BlogCategoryModel> createCategory(String name, String slug) async {
    final response = await _supabase
        .from('blog_categories')
        .insert({'name': name, 'slug': slug})
        .select()
        .single();
    return BlogCategoryModel.fromJson(response);
  }

  // --- Posts ---
  Future<List<BlogPostModel>> getAdminPosts() async {
    final response = await _supabase
        .from('blog_posts')
        .select('*, blog_categories(*)')
        .order('created_at', ascending: false);
    return (response as List).map((e) => BlogPostModel.fromJson(e)).toList();
  }

  Future<BlogPostModel> getPostById(String id) async {
    final response = await _supabase
        .from('blog_posts')
        .select('*, blog_categories(*)')
        .eq('id', id)
        .single();
    return BlogPostModel.fromJson(response);
  }

  Future<BlogPostModel> savePost(BlogPostModel post) async {
    final data = post.toJson();
    if (post.id.isEmpty) {
      // Insert
      data['author_id'] = _supabase.auth.currentUser?.id;
      final response = await _supabase
          .from('blog_posts')
          .insert(data)
          .select('*, blog_categories(*)')
          .single();
      return BlogPostModel.fromJson(response);
    } else {
      // Update
      data['updated_at'] = DateTime.now().toIso8601String();
      final response = await _supabase
          .from('blog_posts')
          .update(data)
          .eq('id', post.id)
          .select('*, blog_categories(*)')
          .single();
      return BlogPostModel.fromJson(response);
    }
  }

  Future<void> deletePost(String id) async {
    await _supabase.from('blog_posts').delete().eq('id', id);
  }
}
