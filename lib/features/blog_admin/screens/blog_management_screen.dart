import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' as intl;
import '../../../core/theme/app_colors.dart';
import '../controllers/blog_cubit.dart';
import '../controllers/blog_state.dart';
import 'blog_editor_screen.dart';

class BlogManagementScreen extends StatefulWidget {
  const BlogManagementScreen({super.key});

  @override
  State<BlogManagementScreen> createState() => _BlogManagementScreenState();
}

class _BlogManagementScreenState extends State<BlogManagementScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BlogCubit>().loadBlogData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BlogEditorScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.edit_document, color: AppColors.background),
        label: const Text(
          "كتابة مقال",
          style: TextStyle(color: AppColors.background, fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocBuilder<BlogCubit, BlogState>(
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 160.0,
                floating: false,
                pinned: true,
                backgroundColor: AppColors.background,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
                  title: const Text(
                    "إدارة المقالات",
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.darkGradient,
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -50,
                          top: -50,
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary.withValues(alpha: .1),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (state is BlogLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                )
              else if (state is BlogError)
                SliverFillRemaining(
                  child: Center(
                    child: Text(
                      "Error: ${state.message}",
                      style: const TextStyle(color: AppColors.dangerRed),
                    ),
                  ),
                )
              else if (state is BlogLoaded && state.posts.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.article_outlined, size: 80, color: AppColors.textMuted.withValues(alpha: .5)),
                        const SizedBox(height: 16),
                        const Text(
                          "لا توجد مقالات حتى الآن",
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "ابدأ بكتابة مقالك الأول لإلهام عملائك",
                          style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                )
              else if (state is BlogLoaded)
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final post = state.posts[index];
                        final dateStr = intl.DateFormat('yyyy/MM/dd').format(post.publishedAt ?? post.createdAt);
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: AppColors.cardBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: .2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BlogEditorScreen(post: post),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            post.title,
                                            style: const TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              height: 1.3,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: post.isPublished 
                                              ? AppColors.activeGreen.withValues(alpha: .1) 
                                              : AppColors.warningOrange.withValues(alpha: .1),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(
                                              color: post.isPublished 
                                                ? AppColors.activeGreen.withValues(alpha: .5) 
                                                : AppColors.warningOrange.withValues(alpha: .5),
                                            ),
                                          ),
                                          child: Text(
                                            post.isPublished ? "منشور" : "مسودة",
                                            style: TextStyle(
                                              color: post.isPublished ? AppColors.activeGreen : AppColors.warningOrange,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "/${post.slug}",
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 13,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Divider(color: AppColors.border.withValues(alpha: .5)),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.calendar_today, size: 14, color: AppColors.textMuted),
                                            const SizedBox(width: 6),
                                            Text(
                                              dateStr,
                                              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                                            ),
                                          ],
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, color: AppColors.dangerRed, size: 20),
                                          onPressed: () {
                                            _showDeleteDialog(context, post.id, post.title);
                                          },
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: state.posts.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String postId, String postTitle) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        title: const Text("حذف المقال", style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          "هل أنت متأكد من حذف مقال '$postTitle'؟ لا يمكن التراجع عن هذا الإجراء.",
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("إلغاء", style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.dangerRed),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<BlogCubit>().deletePost(postId);
            },
            child: const Text("حذف نهائي", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
