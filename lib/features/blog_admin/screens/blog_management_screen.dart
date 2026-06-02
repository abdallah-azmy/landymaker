import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      appBar: AppBar(
        title: const Text("إدارة المدونة (Headless CMS)"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BlogEditorScreen()),
              );
            },
          )
        ],
      ),
      body: BlocBuilder<BlogCubit, BlogState>(
        builder: (context, state) {
          if (state is BlogLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is BlogError) {
            return Center(child: Text("Error: ${state.message}", style: const TextStyle(color: Colors.red)));
          } else if (state is BlogLoaded) {
            if (state.posts.isEmpty) {
              return const Center(child: Text("لا توجد مقالات حتى الآن."));
            }
            return ListView.builder(
              itemCount: state.posts.length,
              itemBuilder: (context, index) {
                final post = state.posts[index];
                return ListTile(
                  title: Text(post.title),
                  subtitle: Text(post.isPublished ? "منشور" : "مسودة"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlogEditorScreen(post: post),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          context.read<BlogCubit>().deletePost(post.id);
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
