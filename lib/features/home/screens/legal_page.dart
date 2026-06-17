import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/seo/app_seo.dart';
import '../../../services/supabase_service.dart';
import '../widgets/home_navbar.dart';
import '../widgets/home_footer.dart';

class LegalPage extends StatefulWidget {
  final String titleKey;
  final String contentKey;
  final String path;

  const LegalPage({
    super.key,
    required this.titleKey,
    required this.contentKey,
    required this.path,
  });

  @override
  State<LegalPage> createState() => _LegalPageState();
}

class _LegalPageState extends State<LegalPage> {
  List<Map<String, String>>? _dbContent;
  bool _isLoading = true;
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadContent();
    });
  }

  Future<void> _loadContent() async {
    if (_hasLoaded) return;
    _hasLoaded = true;

    try {
      final res = await SupabaseService.instance.client
          .from('platform_seo_settings')
          .select('page_content')
          .eq('route_path', widget.path)
          .maybeSingle()
          .timeout(const Duration(seconds: 8));

      if (res != null && res['page_content'] != null) {
        final List rawList = res['page_content'] as List;
        if (mounted) {
          setState(() {
            _dbContent = rawList
                .map((e) => Map<String, String>.from(e as Map))
                .toList();
            _isLoading = false;
          });
          return;
        }
      }
    } catch (e) {
      debugPrint("Error loading dynamic content for ${widget.path}: $e");
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _applySeo(BuildContext context, String title) {
    if (kIsWeb) {
      final isRtl = context.isRtl;
      final suffix = isRtl ? 'لاندي ميكر' : 'LandyMaker';
      AppSEO.updateMeta(
        title: '$title | $suffix',
        description: isRtl 
          ? 'اقرأ $title للتعرف على حقوقك وكيفية حمايتها في لاندي ميكر.'
          : 'Read our $title to understand how we protect your rights at LandyMaker.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = context.translate(widget.titleKey);
    _applySeo(context, title);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: HomeNavbar(
        onLoginPressed: () => context.go('/login'),
        onGetStartedPressed: () => context.go('/templates'),
      ),
      body: SelectionArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
                ),
                child: Column(
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: AppTypography.h1.copyWith(fontSize: 40),
                    ),
                    SizedBox(height: 16),
                    Text(
                      context.isRtl ? "لاندي ميكر 🚀" : "LandyMaker 🚀",
                      style: AppTypography.bodyLarge.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                constraints: const BoxConstraints(maxWidth: 900),
                padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
                child: _isLoading 
                  ? const Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.secondary))
                  : _buildContent(context),
              ),
              const HomeFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final isRtl = context.isRtl;

    if (_dbContent != null) {
      return _buildSectionList(_dbContent!);
    }

    final Map<String, List<Map<String, String>>> legalData = {
      'about_content': [
        {
          'title': isRtl ? 'من نحن' : 'About Us',
          'body': isRtl 
            ? 'لاندي ميكر هي المنصة العربية الأولى المتخصصة في بناء صفحات الهبوط الاحترافية بسهولة وسرعة.'
            : 'LandyMaker is the first Arabic platform specialized in building professional landing pages easily and quickly.',
        },
      ],
      'privacy_policy_content': [
        {
          'title': isRtl ? '1. البيانات التي نجمعها' : '1. Data Collection',
          'body': isRtl
              ? 'نجمع معلوماتك عند التسجيل، بما في ذلك الاسم والبريد الإلكتروني وتفاصيل الدفع. كما نجمع بيانات تقنية مثل عنوان IP وبصمة الجهاز لتحسين الأمان.'
              : 'We collect information during registration, including name, email, and payment details. We also collect technical data such as IP address and device fingerprint for security purposes.',
        },
        {
          'title': isRtl ? '2. كيف نستخدم بياناتك' : '2. How We Use Data',
          'body': isRtl
              ? 'تُستخدم بياناتك لتقديم خدماتنا، ومعالجة المدفوعات، وإرسال التنبيهات الفورية، ومنع السبام والاحتيال.'
              : 'Your data is used to provide our services, process payments, send push notifications, and prevent spam and fraud.',
        },
        {
          'title': isRtl ? '3. ملفات تعريف الارتباط' : '3. Cookies',
          'body': isRtl
              ? 'نستخدم الكوكيز لتخصيص تجربتك وحفظ تفضيلاتك وجمع إحصائيات حول أداء الصفحات التي تبنيها.'
              : 'We use cookies to personalize your experience, save preferences, and collect analytics on the pages you build.',
        },
      ],
      'terms_content': [
        {
          'title': isRtl ? '1. شروط الاستخدام' : '1. Terms of Use',
          'body': isRtl
              ? 'باستخدام لاندي ميكر، أنت توافق على الالتزام بهذه الشروط. يحظر استخدام المنصة لأي غرض غير قانوني أو لنشر محتوى ينتهك حقوق الآخرين.'
              : 'By using LandyMaker, you agree to these terms. It is forbidden to use the platform for any illegal purpose or to publish content that violates the rights of others.',
        },
        {
          'title': isRtl ? '2. ملكية المحتوى' : '2. Content Ownership',
          'body': isRtl
              ? 'أنت تمتلك كامل الحقوق في المحتوى الذي تنشره عبر صفحاتك، ولكنك تمنح لاندي ميكر رخصة لاستضافة هذا المحتوى وعرضه.'
              : 'You own all rights to the content you publish on your pages, but you grant LandyMaker a license to host and display this content.',
        },
        {
          'title': isRtl
              ? '3. الاشتراكات والدفع'
              : '3. Subscriptions & Payment',
          'body': isRtl
              ? 'تخضع الخطط المدفوعة لشروط الاشتراك المختارة. لاندي ميكر تحتفظ بالحق في تعديل الأسعار مع إشعار مسبق.'
              : 'Paid plans are subject to the chosen subscription terms. LandyMaker reserves the right to modify prices with prior notice.',
        },
      ],
    };

    final sections = legalData[widget.contentKey] ?? [];
    return _buildSectionList(sections);
  }

  Widget _buildSectionList(List<Map<String, String>> sections) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sections.map((sec) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sec['title']!,
                style: AppTypography.h3.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                sec['body']!,
                style: AppTypography.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.8,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
