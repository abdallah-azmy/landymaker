import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/localization/localization_cubit.dart';
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
    {'type': 'hero', 'name': 'القسم الرئيسي (Hero)', 'icon': Icons.auto_awesome_rounded, 'category': 'basic', 'desc': 'واجهة الموقع مع عنوان وزر جذاب.'},
    {'type': 'features', 'name': 'المميزات', 'icon': Icons.list_alt_rounded, 'category': 'content', 'desc': 'عرض مميزات خدمتك أو منتجك.'},
    {'type': 'whatsapp', 'name': 'تواصل واتساب', 'icon': Icons.chat_bubble_outline_rounded, 'category': 'contact', 'desc': 'زر سريع للتواصل عبر الواتساب.'},
    {'type': 'products', 'name': 'المنتجات', 'icon': Icons.shopping_bag_outlined, 'category': 'ecommerce', 'desc': 'عرض منتجاتك مع الأسعار وصور.'},
    {'type': 'pricing', 'name': 'خطط الأسعار', 'icon': Icons.payments_rounded, 'category': 'ecommerce', 'desc': 'جداول الأسعار والاشتراكات.'},
    {'type': 'faq', 'name': 'الأسئلة الشائعة', 'icon': Icons.question_answer_rounded, 'category': 'content', 'desc': 'إجابات على استفسارات العملاء.'},
    {'type': 'testimonials', 'name': 'آراء العملاء', 'icon': Icons.reviews_rounded, 'category': 'content', 'desc': 'عرض تجارب عملائك الإيجابية.'},
    {'type': 'contact_info', 'name': 'معلومات الاتصال', 'icon': Icons.contact_mail_rounded, 'category': 'contact', 'desc': 'العنوان، الهاتف، والبريد.'},
    {'type': 'gallery', 'name': 'معرض الصور', 'icon': Icons.collections_rounded, 'category': 'content', 'desc': 'مجموعة صور لمنتجاتك أو عملك.'},
    {'type': 'qr_code', 'name': 'QR كود', 'icon': Icons.qr_code_2_rounded, 'category': 'basic', 'desc': 'كود سريع لزيارة الرابط.'},
    {'type': 'social_qr', 'name': 'روابط التواصل', 'icon': Icons.share_rounded, 'category': 'contact', 'desc': 'أيقونات التواصل الاجتماعي.'},
  ];

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationCubit>();
    final cubit = context.read<LandingPageBuilderCubit>();

    final categories = {
      'all': 'الكل',
      'basic': 'أساسي',
      'content': 'محتوى',
      'ecommerce': 'تجارة',
      'contact': 'تواصل',
    };

    final filteredSections = _sections.where((s) {
      final matchesSearch = s['name'].toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'all' || s['category'] == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
          ),
          
          Text("إضافة قسم جديد", style: AppTypography.h2),
          const SizedBox(height: 20),
          
          // Search
          TextField(
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: "بحث عن قسم...",
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: AppColors.cardBg,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
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
                    label: Text(cat.value),
                    selected: isSelected,
                    onSelected: (s) => setState(() => _selectedCategory = cat.key),
                    selectedColor: AppColors.secondary,
                    backgroundColor: AppColors.cardBg,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textSecondary),
                  ),
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Grid
          Expanded(
            child: filteredSections.isEmpty 
              ? _buildEmptyState()
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: filteredSections.length,
                  itemBuilder: (context, index) {
                    final section = filteredSections[index];
                    return _buildSectionCard(section, cubit);
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
    );
  }

  Widget _buildSectionCard(Map<String, dynamic> section, LandingPageBuilderCubit cubit) {
    return InkWell(
      onTap: () {
        cubit.addBlock(section['type']);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.secondary.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(section['icon'], color: AppColors.secondary, size: 28),
            ),
            const SizedBox(height: 12),
            Text(section['name'], style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(section['desc'], style: AppTypography.caption, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
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
