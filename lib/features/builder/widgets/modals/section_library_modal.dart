import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/atoms/primary_button.dart';
import '../../controllers/builder_cubit.dart';

class SectionLibraryModal extends StatefulWidget {
  const SectionLibraryModal({super.key});

  @override
  State<SectionLibraryModal> createState() => _SectionLibraryModalState();
}

class _SectionLibraryModalState extends State<SectionLibraryModal> {
  String _searchQuery = "";
  String _selectedCategory = "all";
  final List<Map<String, dynamic>> _sections = [
    {'type': 'hero', 'name': 'القسم الرئيسي (Hero)', 'icon': Icons.auto_awesome_rounded, 'category': 'basic', 'desc': 'واجهة الموقع مع عنوان وزر جذاب.', 'popular': true},
    {'type': 'basic_section', 'name': 'قسم مرن متقدم', 'icon': Icons.view_quilt_rounded, 'category': 'basic', 'desc': 'صمم أي شكل بحرية كاملة.', 'popular': true},
    {'type': 'hero_saas', 'name': 'بطل تطبيقات (SaaS)', 'icon': Icons.dashboard_customize_rounded, 'category': 'basic', 'desc': 'قسم رئيسي مثالي للبرمجيات والتطبيقات.'},
    {'type': 'trust_logos', 'name': 'شركاء النجاح', 'icon': Icons.verified_user_rounded, 'category': 'trust', 'desc': 'عرض شعارات الشركات لزيادة الثقة.', 'popular': true},
    {'type': 'animated_counter', 'name': 'عداد أرقام', 'icon': Icons.onetwothree_rounded, 'category': 'conversion', 'desc': 'عداد متحرك للإحصائيات.'},
    {'type': 'multi_step_lead_form', 'name': 'نموذج متعدد الخطوات', 'icon': Icons.dynamic_form_rounded, 'category': 'conversion', 'desc': 'جمع بيانات العملاء باحترافية على مراحل.', 'popular': true},
    {'type': 'lead_magnet', 'name': 'التقاط العملاء', 'icon': Icons.person_add_rounded, 'category': 'conversion', 'desc': 'نموذج مغناطيس لجمع البيانات.', 'popular': true},
    {'type': 'features', 'name': 'المميزات', 'icon': Icons.list_alt_rounded, 'category': 'content', 'desc': 'عرض مميزات خدمتك أو منتجك.', 'popular': true},
    {'type': 'whatsapp', 'name': 'تواصل واتساب', 'icon': Icons.chat_bubble_outline_rounded, 'category': 'contact', 'desc': 'زر سريع للتواصل عبر الواتساب.'},
    {'type': 'products', 'name': 'المنتجات', 'icon': Icons.shopping_bag_outlined, 'category': 'ecommerce', 'desc': 'عرض منتجاتك مع الأسعار وصور.', 'popular': true},
    {'type': 'pricing', 'name': 'خطط الأسعار', 'icon': Icons.payments_rounded, 'category': 'ecommerce', 'desc': 'جداول الأسعار والاشتراكات.'},
    {'type': 'faq', 'name': 'الأسئلة الشائعة', 'icon': Icons.question_answer_rounded, 'category': 'content', 'desc': 'إجابات على استفسارات العملاء.'},
    {'type': 'testimonials', 'name': 'آراء العملاء', 'icon': Icons.reviews_rounded, 'category': 'content', 'desc': 'عرض تجارب عملائك الإيجابية.'},
    {'type': 'contact_info', 'name': 'معلومات الاتصال', 'icon': Icons.contact_mail_rounded, 'category': 'contact', 'desc': 'العنوان، الهاتف، والبريد.'},
    {'type': 'video_embed', 'name': 'فيديو (Video)', 'icon': Icons.video_library_rounded, 'category': 'basic', 'desc': 'تضمين فيديو يوتيوب أو فيميو.'},
    {'type': 'gallery', 'name': 'معرض الصور', 'icon': Icons.collections_rounded, 'category': 'content', 'desc': 'مجموعة صور لمنتجاتك أو عملك.'},
    {'type': 'qr_code', 'name': 'QR كود', 'icon': Icons.qr_code_2_rounded, 'category': 'basic', 'desc': 'كود سريع لزيارة الرابط.'},
    {'type': 'social_qr', 'name': 'روابط التواصل', 'icon': Icons.share_rounded, 'category': 'contact', 'desc': 'أيقونات التواصل الاجتماعي.'},
  ];

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LandingPageBuilderCubit>();

    final categories = {
      'all': 'الكل',
      'popular': 'شائع ومهم',
      'basic': 'أساسي',
      'conversion': 'مبيعات',
      'trust': 'ثقة',
      'content': 'محتوى',
      'ecommerce': 'تجارة',
      'contact': 'تواصل',
    };

    final filteredSections = _sections.where((s) {
      final matchesSearch = s['name'].toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'all' || 
                              s['category'] == _selectedCategory || 
                              (_selectedCategory == 'popular' && s['popular'] == true);
      return matchesSearch && matchesCategory;
    }).toList();

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.85,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: AppColors.background.withValues(alpha: 0.8),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: AppColors.border.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.border.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                )
              ),
              
              Text("إضافة قسم جديد", style: AppTypography.h2),
              const SizedBox(height: 20),
              
              // Search
              TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: "بحث عن قسم...",
                  hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.cardBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.border, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Categories
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categories.entries.map((cat) {
                    final isSelected = _selectedCategory == cat.key;
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: ChoiceChip(
                        label: Text(
                          cat.value,
                          style: AppTypography.caption.copyWith(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (s) => setState(() => _selectedCategory = cat.key),
                        selectedColor: AppColors.secondary,
                        backgroundColor: AppColors.cardBg,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? Colors.transparent : AppColors.border,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    );
                  }).toList(),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Grid with staggered item animations
              Expanded(
                child: filteredSections.isEmpty 
                  ? _buildEmptyState()
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 180,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: filteredSections.length,
                      itemBuilder: (context, index) {
                        final section = filteredSections[index];
                        // Recreate animate structure on search/category change using unique keys
                        return AnimatedSectionCard(
                          key: ValueKey("${section['type']}_${_selectedCategory}_${_searchQuery}_$index"),
                          section: section,
                          cubit: cubit,
                          index: index,
                        );
                      },
                    ),
              ),
              
              const SizedBox(height: 16),
              PrimaryButton(
                text: "إغلاق",
                isSecondary: true,
                width: double.infinity,
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off_rounded, size: 48, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text("لا توجد أقسام تطابق بحثك", style: AppTypography.bodyMedium),
        ],
      ),
    );
  }
}

class AnimatedSectionCard extends StatefulWidget {
  final Map<String, dynamic> section;
  final LandingPageBuilderCubit cubit;
  final int index;

  const AnimatedSectionCard({
    super.key,
    required this.section,
    required this.cubit,
    required this.index,
  });

  @override
  State<AnimatedSectionCard> createState() => _AnimatedSectionCardState();
}

class _AnimatedSectionCardState extends State<AnimatedSectionCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // Stagger load based on grid index
    Future.delayed(Duration(milliseconds: widget.index * 30), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.translate(
            offset: _slideAnimation.value * 50.0, // translate up 10px
            child: child,
          ),
        );
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedScale(
          scale: _isHovered ? 1.04 : 1.0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          child: InkWell(
            onTap: () {
              widget.cubit.addBlock(widget.section['type']);
              Navigator.pop(context);
            },
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                color: _isHovered ? AppColors.cardBgHover : AppColors.cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _isHovered ? AppColors.secondary.withValues(alpha: 0.7) : AppColors.border,
                  width: _isHovered ? 2 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _isHovered
                        ? AppColors.secondary.withValues(alpha: 0.12)
                        : Colors.black.withValues(alpha: 0.1),
                    blurRadius: _isHovered ? 16 : 8,
                    offset: Offset(0, _isHovered ? 6 : 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _isHovered
                          ? AppColors.secondary
                          : AppColors.secondary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.section['icon'],
                      color: _isHovered ? Colors.white : AppColors.secondary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.section['name'],
                    style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.section['desc'],
                    style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, height: 1.3),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
