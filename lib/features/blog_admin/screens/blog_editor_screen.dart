import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill_delta_from_html/flutter_quill_delta_from_html.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';
import '../../../core/theme/app_colors.dart';
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
    _quillController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool _isLoading = false;

  Future<void> _savePost() async {
    if (_titleController.text.isEmpty || _slugController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء إدخال عنوان المقال ورابط الـ Slug', style: TextStyle(color: Colors.white)),
          backgroundColor: AppColors.warningOrange,
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
            backgroundColor: AppColors.activeGreen,
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
            backgroundColor: AppColors.dangerRed,
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
      const SnackBar(
        content: Text('تم نسخ رسالة التوجيه (Prompt) بنجاح!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine screen width for responsiveness
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: Text(
          widget.post == null ? "مقال جديد" : "تعديل المقال",
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Toolbar (Quill) - Wrapped in SingleChildScrollView to prevent horizontal overflow on tiny screens
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                border: const Border(bottom: BorderSide(color: AppColors.border)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Theme(
                data: ThemeData.dark().copyWith(
                  canvasColor: AppColors.cardBg,
                ),
                child: quill.QuillSimpleToolbar(
                  controller: _quillController,
                  config: const quill.QuillSimpleToolbarConfig(
                    multiRowsDisplay: false, // Force single row, let horizontal scroll handle overflow
                    buttonOptions: quill.QuillSimpleToolbarButtonOptions(
                      base: quill.QuillToolbarBaseButtonOptions(
                        iconTheme: quill.QuillIconTheme(
                          iconButtonUnselectedData: quill.IconButtonData(
                            color: AppColors.textPrimary,
                          ),
                          iconButtonSelectedData: quill.IconButtonData(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
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
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: "عنوان المقال الرهيب...",
                        hintStyle: TextStyle(
                          color: AppColors.textMuted.withValues(alpha: .5),
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Slug Input
                    TextField(
                      controller: _slugController,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontFamily: 'monospace',
                      ),
                      decoration: InputDecoration(
                        prefixText: "landymaker.com/blog/ ",
                        prefixStyle: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 14,
                          fontFamily: 'monospace',
                        ),
                        hintText: "your-awesome-slug",
                        hintStyle: TextStyle(
                          color: AppColors.primary.withValues(alpha: .3),
                          fontSize: 14,
                          fontFamily: 'monospace',
                        ),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Divider(color: AppColors.border.withValues(alpha: .5)),
                    const SizedBox(height: 24),
                    
                    // Content Input (Quill Editor)
                    Container(
                      constraints: const BoxConstraints(minHeight: 200),
                      child: DefaultTextStyle(
                        style: const TextStyle(
                          color: AppColors.textSecondary,
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
                    
                    const SizedBox(height: 40),
                    
                    // AI Hint Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: .05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primary.withValues(alpha: .3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  "نصيحة الذكاء الاصطناعي (SEO)",
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "انسخ هذه الجملة والصقها في نهاية أي طلب لـ ChatGPT للحصول على نتيجة مثالية للنسخ واللصق هنا:",
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                          const SizedBox(height: 12),
                          Material(
                            color: AppColors.background,
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
                                        style: const TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 13,
                                          height: 1.5,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: .1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.copy_rounded, color: AppColors.primary, size: 20),
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
                    const SizedBox(height: 100), 
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
                color: AppColors.cardBg,
                border: const Border(top: BorderSide(color: AppColors.border)),
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
                        color: _isPublished ? AppColors.activeGreen.withValues(alpha: .1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: _isPublished ? AppColors.activeGreen.withValues(alpha: .5) : AppColors.border,
                        ),
                      ),
                      padding: const EdgeInsets.only(right: 4, left: 12, top: 4, bottom: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Switch(
                            value: _isPublished,
                            onChanged: (val) {
                              setState(() => _isPublished = val);
                            },
                            activeColor: AppColors.activeGreen,
                            activeTrackColor: AppColors.activeGreen.withValues(alpha: .3),
                            inactiveThumbColor: AppColors.textMuted,
                            inactiveTrackColor: AppColors.background,
                          ),
                          Expanded(
                            child: Text(
                              _isPublished ? "منشور" : "مسودة",
                              style: TextStyle(
                                color: _isPublished ? AppColors.activeGreen : AppColors.textMuted,
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
                  const SizedBox(width: 12),
                  
                  // Save Button
                  SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _savePost,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.background,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: _isLoading 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.background, strokeWidth: 2))
                        : const Icon(Icons.cloud_upload_rounded),
                      label: Text(
                        _isLoading ? "جاري الحفظ..." : (isMobile ? "حفظ" : "حفظ المقال"),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
