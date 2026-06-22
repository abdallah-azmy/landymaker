import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' as intl;
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/particles/loading_logo.dart';
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BlogEditorScreen()),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        icon: Icon(Icons.edit_document, color: Theme.of(context).colorScheme.surface),
        label: Text(
          "كتابة مقال",
          style: TextStyle(color: Theme.of(context).colorScheme.surface, fontWeight: FontWeight.bold),
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
                backgroundColor: Theme.of(context).colorScheme.surface,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
                  title: Text(
                    "إدارة المقالات",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
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
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: .1),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (state is BlogLoading)
                SliverFillRemaining(
                  child: const Center(child: LoadingLogo(size: 48, initialState: LoadingLogoState.loading)),
                )
              else if (state is BlogError)
                SliverFillRemaining(
                  child: Center(
                    child: Text(
                      "Error: ${state.message}",
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                )
              else if (state is BlogLoaded && state.posts.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.article_outlined, size: 80, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5).withValues(alpha: .5)),
                        SizedBox(height: 16),
                        Text(
                          "لا توجد مقالات حتى الآن",
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 18),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "ابدأ بكتابة مقالك الأول لإلهام عملائك",
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 14),
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
                            color: Theme.of(context).colorScheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
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
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.onSurface,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              height: 1.3,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: post.isPublished 
                                              ? Colors.green.withValues(alpha: .1) 
                                              : Colors.orange.withValues(alpha: .1),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(
                                              color: post.isPublished 
                                                ? Colors.green.withValues(alpha: .5) 
                                                : Colors.orange.withValues(alpha: .5),
                                            ),
                                          ),
                                          child: Text(
                                            post.isPublished ? "منشور" : "مسودة",
                                            style: TextStyle(
                                              color: post.isPublished ? Colors.green : Colors.orange,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      "/${post.slug}",
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontSize: 13,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Divider(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: .5)),
                                    SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.calendar_today, size: 14, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                                            SizedBox(width: 6),
                                            Text(
                                              dateStr,
                                              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 13),
                                            ),
                                          ],
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error, size: 20),
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
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        title: Text("حذف المقال", style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        content: Text(
          "هل أنت متأكد من حذف مقال '$postTitle'؟ لا يمكن التراجع عن هذا الإجراء.",
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("إلغاء", style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
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
