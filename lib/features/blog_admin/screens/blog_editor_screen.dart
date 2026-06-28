import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill_delta_from_html/flutter_quill_delta_from_html.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';
import 'package:markdown/markdown.dart' as md;
import '../../../core/widgets/atoms/cube_spinner.dart';
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
  late TextEditingController _metaDescController;
  late quill.QuillController _quillController;
  final ScrollController _scrollController = ScrollController();
  bool _isPublished = false;

  final String _aiPrompt = 
      "اكتب المقال بحيث يكون متوافقاً مع قواعد السيو (SEO). استخدم عناوين رئيسية وفرعية واضحة، استخدم الخط العريض (Bold) للكلمات المفتاحية المهمة، واكتب بعض النقاط في شكل قوائم (Bullet points).";

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.post?.title ?? '');
    _slugController = TextEditingController(text: widget.post?.slug ?? '');
    _metaDescController = TextEditingController(text: widget.post?.metaDescription ?? '');
    _isPublished = widget.post?.isPublished ?? false;

    // Load HTML to Delta for Quill
    final htmlContent = widget.post?.content ?? '';
    if (htmlContent.isNotEmpty) {
      try {
        final delta = HtmlToDelta().convert(htmlContent);
        _quillController = quill.QuillController(
          document: quill.Document.fromDelta(delta),
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (e) {
        // Fallback if parsing fails
        _quillController = quill.QuillController.basic();
      }
    } else {
      _quillController = quill.QuillController.basic();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _slugController.dispose();
    _metaDescController.dispose();
    _quillController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool _isLoading = false;

  Future<void> _importAiContentFromClipboard() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      final text = clipboardData?.text ?? '';
      
      if (text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الحافظة (Clipboard) فارغة! انسخ المقال من ChatGPT أولاً.'), backgroundColor: Colors.orange),
        );
        return;
      }

      // 1. Convert the plain Markdown text from ChatGPT to HTML
      final htmlContent = md.markdownToHtml(text, extensionSet: md.ExtensionSet.gitHubFlavored);

      // 2. Convert the HTML to Quill Delta
      final delta = HtmlToDelta().convert(htmlContent);
      
      setState(() {
        _quillController.document = quill.Document.fromDelta(delta);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم استيراد وتنسيق المقال بنجاح! ✨', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء استيراد النص: $e'), backgroundColor: Theme.of(context).colorScheme.error),
      );
    }
  }

  Future<void> _savePost() async {
    if (_titleController.text.isEmpty || _slugController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء إدخال عنوان المقال ورابط الـ Slug', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Convert Delta back to HTML
    final deltaJson = _quillController.document.toDelta().toJson();
    final converter = QuillDeltaToHtmlConverter(
      deltaJson.map((e) => Map<String, dynamic>.from(e as Map)).toList(),
      ConverterOptions(
        multiLineBlockquote: true,
        multiLineHeader: false,
        multiLineCodeblock: true,
        multiLineParagraph: true,
        multiLineCustomBlock: true,
      ),
    );
    final htmlContent = converter.convert();

    final post = BlogPostModel(
      id: widget.post?.id ?? '',
      title: _titleController.text,
      slug: _slugController.text,
      metaDescription: _metaDescController.text,
      content: htmlContent,
      isPublished: _isPublished,
      createdAt: widget.post?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      publishedAt: _isPublished && (widget.post?.publishedAt == null) ? DateTime.now() : widget.post?.publishedAt,
    );

    try {
      await context.read<BlogCubit>().savePost(post);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم الحفظ بنجاح! 🚀', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء الحفظ: $e', style: const TextStyle(color: Colors.white)),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _copyAiPrompt() {
    Clipboard.setData(ClipboardData(text: _aiPrompt));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('تم نسخ رسالة التوجيه (Prompt) بنجاح!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    // Determine screen width for responsiveness
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
        title: Text(
          widget.post == null ? "مقال جديد" : "تعديل المقال",
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Toolbar (Quill) & Import Button
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Theme(
                      data: ThemeData.dark().copyWith(
                        canvasColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                      ),
                      child: quill.QuillSimpleToolbar(
                        controller: _quillController,
                        config: quill.QuillSimpleToolbarConfig(
                          multiRowsDisplay: false, // Force single row, let horizontal scroll handle overflow
                          buttonOptions: quill.QuillSimpleToolbarButtonOptions(
                            base: quill.QuillToolbarBaseButtonOptions(
                              iconTheme: quill.QuillIconTheme(
                                iconButtonUnselectedData: quill.IconButtonData(
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                iconButtonSelectedData: quill.IconButtonData(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  // Import HTML Button
                  ElevatedButton.icon(
                    onPressed: _importAiContentFromClipboard,
                    icon: Icon(Icons.auto_awesome, size: 18),
                    label: const Text("استيراد الذكاء الاصطناعي", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: .1),
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Input
                    TextField(
                      controller: _titleController,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: "عنوان المقال الرهيب...",
                        hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5).withValues(alpha: .5),
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    SizedBox(height: 8),
                    
                    // Slug Input
                    TextField(
                      controller: _slugController,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 14,
                        fontFamily: 'monospace',
                      ),
                      decoration: InputDecoration(
                        prefixText: "landymaker.com/blog/ ",
                        prefixStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                          fontSize: 14,
                          fontFamily: 'monospace',
                        ),
                        hintText: "your-awesome-slug",
                        hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: .3),
                          fontSize: 14,
                          fontFamily: 'monospace',
                        ),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    SizedBox(height: 24),
                    
                    // Meta Description Input
                    TextField(
                      controller: _metaDescController,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 14,
                        height: 1.5,
                      ),
                      maxLines: 3,
                      maxLength: 160,
                      decoration: InputDecoration(
                        hintText: "وصف قصير للمقال (يظهر في كروت المدونة ومحركات البحث)...",
                        hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5).withValues(alpha: .5),
                          fontSize: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: .5)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: .5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        contentPadding: const EdgeInsets.all(16),
                        counterStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 12),
                      ),
                    ),
                    SizedBox(height: 24),
                    Divider(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: .5)),
                    SizedBox(height: 24),
                    
                    // Content Input (Quill Editor)
                    Container(
                      constraints: const BoxConstraints(minHeight: 200),
                      child: DefaultTextStyle(
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 16,
                          height: 1.8,
                        ),
                        child: quill.QuillEditor.basic(
                          controller: _quillController,
                          config: const quill.QuillEditorConfig(
                            scrollable: false, // Critical to prevent nested scrolling issues
                            autoFocus: false,
                            placeholder: "قم بلصق محتوى الذكاء الاصطناعي هنا، أو اكتب مقالك مباشرة...",
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 40),
                    
                    // AI Hint Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: .05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: .3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.auto_awesome, color: Theme.of(context).colorScheme.primary, size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "نصيحة الذكاء الاصطناعي (SEO)",
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Text(
                            "انسخ هذه الجملة والصقها في نهاية أي طلب لـ ChatGPT للحصول على نتيجة مثالية للنسخ واللصق هنا:",
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13),
                          ),
                          SizedBox(height: 12),
                          Material(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: _copyAiPrompt,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _aiPrompt,
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                                          fontSize: 13,
                                          height: 1.5,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primary.withValues(alpha: .1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(Icons.copy_rounded, color: Theme.of(context).colorScheme.primary, size: 20),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Extra padding at bottom to ensure scrolling past the keyboard and bottom bar
                    SizedBox(height: 100), 
                  ],
                ),
              ),
            ),
            
            // Sticky Bottom Bar
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 24, 
                vertical: 16
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .2),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Publish Toggle
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: _isPublished ? Colors.green.withValues(alpha: .1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: _isPublished ? Colors.green.withValues(alpha: .5) : Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                      padding: const EdgeInsetsDirectional.only(end: 4, start: 12, top: 4, bottom: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Switch(
                            value: _isPublished,
                            onChanged: (val) {
                              setState(() => _isPublished = val);
                            },
                            activeThumbColor: Colors.green,
                            activeTrackColor: Colors.green.withValues(alpha: .3),
                            inactiveThumbColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                            inactiveTrackColor: Theme.of(context).colorScheme.surface,
                          ),
                          Expanded(
                            child: Text(
                              _isPublished ? "منشور" : "مسودة",
                              style: TextStyle(
                                color: _isPublished ? Colors.green : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  
                  // Save Button
                  SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _savePost,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.surface,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: _isLoading 
                        ? CubeSpinner(size: 20, color: Theme.of(context).colorScheme.surface)
                        : Icon(Icons.cloud_upload_rounded),
                      label: Text(
                        _isLoading ? "جاري الحفظ..." : (isMobile ? "حفظ" : "حفظ المقال"),
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
