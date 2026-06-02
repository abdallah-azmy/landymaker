import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/blog_post_model.dart';
import '../controllers/blog_cubit.dart';

class BlogEditorScreen extends StatefulWidget {
  final BlogPostModel? post;
  
  const BlogEditorScreen({super.key, this.post});

  @override
  State<BlogEditorScreen> createState() => _BlogEditorScreenState();
}

class _BlogEditorScreenState extends State<BlogEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _slugController;
  late TextEditingController _contentController;
  bool _isPublished = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.post?.title ?? '');
    _slugController = TextEditingController(text: widget.post?.slug ?? '');
    _contentController = TextEditingController(text: widget.post?.content ?? '');
    _isPublished = widget.post?.isPublished ?? false;
  }

  void _savePost() {
    if (_titleController.text.isEmpty || _slugController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('العنوان والرابط (Slug) مطلوبان')),
      );
      return;
    }

    final post = BlogPostModel(
      id: widget.post?.id ?? '',
      title: _titleController.text,
      slug: _slugController.text,
      content: _contentController.text,
      isPublished: _isPublished,
      createdAt: widget.post?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      publishedAt: _isPublished && (widget.post?.publishedAt == null) ? DateTime.now() : widget.post?.publishedAt,
    );

    context.read<BlogCubit>().savePost(post);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post == null ? "كتابة مقال جديد" : "تعديل المقال"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _savePost,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "عنوان المقال"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _slugController,
              decoration: const InputDecoration(labelText: "الرابط (Slug) بالانجليزية"),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text("نشر المقال (عام)"),
              value: _isPublished,
              onChanged: (val) {
                setState(() {
                  _isPublished = val;
                });
              },
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerRight,
              child: Text("محتوى المقال (يدعم Markdown):", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "اكتب مقالك هنا...",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
