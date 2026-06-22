import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/seo/app_seo.dart';
import '../../../core/router/router_extensions.dart';
import '../../../core/widgets/particles/loading_logo.dart';
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
      appBar: const HomeNavbar(),
      body: SelectionArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 700;
                  return Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: isMobile ? 60 : 100,
                      horizontal: 24,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
                    ),
                    child: Column(
                      children: [
                        TextButton.icon(
                          onPressed: () => context.safePop(fallbackPath: '/'),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                          label: Text(context.isRtl ? 'الرئيسية' : 'Home'),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: AppTypography.h1.copyWith(
                            fontSize: isMobile ? 28 : 44,
                          ),
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
                  );
                },
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 700;
                  return Container(
                    constraints: const BoxConstraints(maxWidth: 900),
                    padding: EdgeInsets.symmetric(
                      vertical: isMobile ? 24 : 60,
                      horizontal: isMobile ? 16 : 32,
                    ),
                    child: _isLoading 
                      ? const Center(child: LoadingLogo())
                      : _buildContent(context, isMobile),
                  );
                },
              ),
              const HomeFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isMobile) {
    final isRtl = context.isRtl;

    if (_dbContent != null) {
      return _buildSectionList(_dbContent!, isMobile);
    }

    final Map<String, List<Map<String, String>>> legalData = {
      'about_content': [
        {
          'title': isRtl ? 'من نحن' : 'Who We Are',
          'body': isRtl
              ? 'لاندي ميكر (LandyMaker) هي منصة عربية متخصصة في بناء صفحات الهبوط والمتاجر الإلكترونية دون الحاجة إلى خبرة برمجية. نقدم محرراً بصرياً يعمل بالسحب والإفلات، إلى جانب أدوات مدعومة بالذكاء الاصطناعي تساعدك على تصميم موقعك وإطلاقه بسرعة.'
              : 'LandyMaker is an Arabic platform specialized in building landing pages and e-commerce stores without coding. We provide a visual drag-and-drop editor, along with AI-powered tools to help you design and launch your site quickly.',
        },
        {
          'title': isRtl ? 'رسالتنا' : 'Our Mission',
          'body': isRtl
              ? 'نهدف إلى تمكين رواد الأعمال وأصحاب المشاريع الصغيرة والمتوسطة في المنطقة العربية من بناء حضور رقمي احترافي بأقل تكلفة وجهد ممكنين، دون الحاجة إلى خبرات تقنية متقدمة.'
              : 'Our goal is to empower entrepreneurs and small-to-medium businesses in the Arab region to build a professional digital presence with minimal cost and effort, without requiring advanced technical skills.',
        },
        {
          'title': isRtl ? 'ماذا نقدم؟' : 'What We Offer',
          'body': isRtl
              ? 'نقدم منصة متكاملة تتيح لك: بناء صفحات هبوط بمحرر سحب وإفلات. إنشاء متاجر إلكترونية مع إدارة المنتجات والطلبات عبر واتساب. الاستفادة من الذكاء الاصطناعي لإنشاء المحتوى والتصاميم. تتبع الأداء والتحليلات. ربط النطاقات المخصصة (في الباقات المدفوعة). إدارة العملاء المتوقعين عبر لوحة تحكم. إشعارات فورية عند وصول عملاء جدد.'
              : 'We offer a complete platform that lets you: Build landing pages with a drag-and-drop editor. Create e-commerce stores with product management and WhatsApp ordering. Use AI to generate content and designs. Track performance and analytics. Connect custom domains (on paid plans). Manage leads through a dashboard. Get instant notifications when new leads arrive.',
        },
        {
          'title': isRtl ? 'لماذا لاندي ميكر؟' : 'Why LandyMaker?',
          'body': isRtl
              ? 'صممت المنصة خصيصاً للسوق العربي، مع دعم كامل للغة العربية والكتابة من اليمين لليسار (RTL). نوفر أكثر من 20 قسماً احترافياً جاهزاً، وقوالب مصممة بعناية، وأدوات ذكاء اصطناعي لتوليد المحتوى والصور. خطتنا المجانية تتيح لك البدء فوراً دون أي تكلفة.'
              : 'The platform is purpose-built for the Arabic market, with full Arabic language support and native RTL. We provide over 20 professional sections, carefully designed templates, and AI tools for content and image generation. Our free plan lets you start immediately at no cost.',
        },
        {
          'title': isRtl ? 'قيمنا' : 'Our Values',
          'body': isRtl
              ? 'الابتكار: نستخدم أحدث التقنيات لتقديم أفضل تجربة مستخدم. التمكين: نمنحك الأدوات التي تحتاجها لتنمية أعمالك. الشفافية: نتعامل بوضوح وأمان مع بياناتك وخصوصيتك.'
              : 'Innovation: We use the latest technologies to deliver the best user experience. Empowerment: We give you the tools you need to grow your business. Transparency: We handle your data with clarity and security.',
        },
      ],
      'privacy_policy_content': [
        {
          'title': isRtl ? '١. مقدمة' : '1. Introduction',
          'body': isRtl
              ? 'توضح سياسة الخصوصية هذه كيفية جمع لاندي ميكر (LandyMaker) واستخدامها وحمايتها للمعلومات الشخصية عند استخدامك للمنصة وخدماتها. نحن ملتزمون بحماية خصوصيتك والامتثال للقوانين واللوائح المنظمة لحماية البيانات في جمهورية مصر العربية.'
              : 'This Privacy Policy explains how LandyMaker collects, uses, and protects your personal information when you use our platform and services. We are committed to protecting your privacy and complying with applicable data protection laws in the Arab Republic of Egypt.',
        },
        {
          'title': isRtl ? '٢. المعلومات التي نجمعها' : '2. Information We Collect',
          'body': isRtl
              ? 'نجمع الأنواع التالية من المعلومات حسب طريقة استخدامك للمنصة: عند التسجيل: الاسم الكامل والبريد الإلكتروني وكلمة المرور (يتم تشفيرها بواسطة Supabase Auth). عند تسجيل الدخول بحساب جوجل: الاسم والبريد الإلكتروني وصورة الملف الشخصي (يتم توفيرها من جوجل بعد موافقتك). معلومات الدفع: عند شراء باقة مدفوعة، نجمع اسم الباقة والمبلغ المدفوع وطريقة الدفع (مثل فودافون كاش، إنستاباي، وي كاش) وصورة إيصال الدفع. المعلومات التقنية: عنوان IP، نوع المتصفح، نظام التشغيل، بصمة المتصفح (SHA-256). معلومات الاستخدام: الصفحات التي تزورها، الإجراءات التي تتخذها داخل المنصة. محتوى المستخدم: التصاميم، الصور، النصوص، والبيانات التي تنشئها أو ترفعها إلى المنصة. بيانات الزوار: عند استقبال زوار لصفحاتك المنشورة، قد نجمع عناوين IP وبصمة المتصفح ونوع الحدث (مشاهدة، ضغط، تحويل) لأغراض التحليلات.'
              : 'We collect the following types of information depending on how you use the platform: During Registration: full name, email address, and password (encrypted by Supabase Auth). When signing in with Google: name, email, and profile picture (provided by Google after your consent). Payment Information: when purchasing a paid plan, we collect the plan name, amount paid, payment method (e.g., Vodafone Cash, InstaPay, We Cash), and a payment receipt screenshot. Technical Information: IP address, browser type, operating system, browser fingerprint (SHA-256). Usage Information: pages visited, actions taken within the platform. User Content: designs, images, text, and data you create or upload to the platform. Visitor Data: when visitors land on your published pages, we may collect IP addresses, browser fingerprints, and event types (view, click, conversion) for analytics purposes.',
        },
        {
          'title': isRtl ? '٣. بيانات خدمات جوجل والاستخدام المحدود' : '3. Google API Services & Limited Use',
          'body': isRtl
              ? 'إن استخدام منصة لاندي ميكر (LandyMaker) ونقلها للمعلومات المستلمة من واجهات برمجة تطبيقات جوجل (Google APIs) إلى أي تطبيق آخر سيلتزم تماماً بـ "سياسة بيانات مستخدم خدمات Google API" بما في ذلك متطلبات الاستخدام المحدود (Limited Use requirements). نحن لا نقوم ببيع أو مشاركة بيانات مستخدمي جوجل لأي أطراف ثالثة أو استخدامها لأغراض إعلانية.'
              : 'LandyMaker\'s use and transfer to any other app of information received from Google APIs will adhere to Google API Services User Data Policy, including the Limited Use requirements. We do not sell, share, or use Google user data for advertising or any other third-party purposes.',
        },
        {
          'title': isRtl ? '٤. كيفية استخدام معلوماتك' : '4. How We Use Your Information',
          'body': isRtl
              ? 'نستخدم معلوماتك للأغراض التالية: تقديم خدمات المنصة وإدارة حسابك وصفحاتك. معالجة طلبات الاشتراك في الباقات المدفوعة (يدوياً عبر طرق الدفع المصرية). تحسين وتطوير المنصة وتجربة المستخدم. إرسال الإشعارات الفورية والتنبيهات المتعلقة بحسابك (عند تفعيل الإذن). تحليل الأداء وإحصائيات الاستخدام. منع الاحتيال وسوء الاستخدام وحماية أمن المنصة.'
              : 'We use your information for the following purposes: Providing platform services and managing your account and pages. Processing paid plan subscription requests (manually via Egyptian payment methods). Improving and developing the platform and user experience. Sending push notifications and alerts related to your account (when permission is granted). Analyzing performance and usage statistics. Preventing fraud, abuse, and protecting platform security.',
        },
        {
          'title': isRtl ? '٥. مشاركة البيانات والإفصاح' : '5. Data Sharing and Disclosure',
          'body': isRtl
              ? 'لا نقوم ببيع معلوماتك الشخصية لأطراف ثالثة. قد نشارك معلوماتك مع: مزودي الخدمة الذين يساعدوننا في تشغيل المنصة، مثل Supabase (قواعد البيانات والمصادقة)، Cloudflare (شبكة توصيل المحتوى والحماية)، ImgBB (استضافة الصور)، Firebase Cloud Messaging (الإشعارات الفورية). السلطات القانونية إذا تطلب القانون ذلك أو لحماية حقوقنا القانونية. نضمن أن جميع الأطراف الثالثة تلتزم بمعايير أمان مناسبة.'
              : 'We do not sell your personal information to third parties. We may share your information with: Service providers who help us operate the platform, such as Supabase (database and authentication), Cloudflare (CDN and security), ImgBB (image hosting), and Firebase Cloud Messaging (push notifications). Legal authorities if required by law or to protect our legal rights. We ensure all third parties maintain appropriate security standards.',
        },
        {
          'title': isRtl ? '٦. ملفات تعريف الارتباط (Cookies)' : '6. Cookies',
          'body': isRtl
              ? 'نستخدم ملفات تعريف الارتباط وتقنيات التتبع المماثلة لتحسين تجربتك على المنصة. تشمل استخداماتنا: الكوكيز الأساسية: ضرورية لتشغيل المنصة بشكل صحيح. كوكيز الأداء: تساعدنا في تحسين أداء المنصة (بما في ذلك Google Analytics وMicrosoft Clarity). كوكيز التفضيلات: تذكر إعداداتك مثل اللغة والثيم. كوكيز التتبع: تُستخدم في صفحات الهبوط المنشورة فقط عند تفعيل صاحب الصفحة لأكواد التتبع (مثل Facebook Pixel). يمكنك التحكم في إعدادات الكوكيز من خلال إعدادات المتصفح في أي وقت. نوفر أيضاً خيار قبول أو رفض الكوكيز غير الأساسية عند زيارة صفحات الهبوط المنشورة.'
              : 'We use cookies and similar tracking technologies to enhance your experience on the platform. Our usage includes: Essential Cookies: necessary for the platform to function properly. Performance Cookies: help us improve platform performance (including Google Analytics and Microsoft Clarity). Preference Cookies: remember your settings such as language and theme. Tracking Cookies: used on published landing pages only when the page owner activates tracking codes (e.g., Facebook Pixel). You can control cookie settings through your browser at any time. We also provide an accept/reject option for non-essential cookies on published landing pages.',
        },
        {
          'title': isRtl ? '٧. تخزين البيانات والاحتفاظ بها' : '7. Data Storage and Retention',
          'body': isRtl
              ? 'يتم تخزين بياناتك على خوادم Supabase الآمنة في مراكز بيانات داخل الاتحاد الأوروبي. نحتفظ ببياناتك طالما كان حسابك نشطاً. عند إلغاء حسابك، يتم حذف صفحاتك المنشورة وبياناتك الشخصية تدريجياً خلال مدة لا تتجاوز ٩٠ يوماً. يمكنك طلب حذف بياناتك وحسابك بالكامل في أي وقت بالتواصل معنا.'
              : 'Your data is stored on secure Supabase servers hosted in the European Union. We retain your data as long as your account is active. Upon account cancellation, your published pages and personal data are gradually deleted within a period not exceeding 90 days. You may request full deletion of your data and account at any time by contacting us.',
        },
        {
          'title': isRtl ? '٨. حقوقك فيما يتعلق ببياناتك' : '8. Your Data Rights',
          'body': isRtl
              ? 'لديك الحقوق التالية فيما يتعلق ببياناتك الشخصية: الحق في الوصول: طلب نسخة من بياناتك الشخصية. الحق في التصحيح: تحديث أو تصحيح بياناتك غير الدقيقة. الحق في الحذف: طلب حذف بياناتك. الحق في الاعتراض: الاعتراض على معالجة بياناتك لأغراض التسويق. لممارسة هذه الحقوق، يرجى التواصل معنا عبر معلومات الاتصال في نهاية هذه السياسة.'
              : 'You have the following rights regarding your personal data: Right of Access: request a copy of your personal data. Right to Rectification: update or correct inaccurate data. Right to Deletion: request deletion of your data. Right to Object: object to processing of your data for marketing purposes. To exercise these rights, please contact us using the information at the end of this policy.',
        },
        {
          'title': isRtl ? '٩. أمان البيانات' : '9. Data Security',
          'body': isRtl
              ? 'نتخذ إجراءات أمنية لحماية بياناتك، تشمل: تشفير البيانات أثناء النقل (TLS/SSL). استخدام Cloudflare Turnstile للحماية من السبام والهجمات الآلية. صلاحيات وصول محدودة بناءً على مبدأ الضرورة. المراجعات الأمنية الدورية.'
              : 'We implement security measures to protect your data, including: Data encryption in transit (TLS/SSL). Cloudflare Turnstile for spam and automated attack protection. Access control based on the principle of least privilege. Regular security reviews.',
        },
        {
          'title': isRtl ? '١٠. خصوصية الأطفال' : '10. Children\'s Privacy',
          'body': isRtl
              ? 'منصتنا غير موجهة للأطفال دون سن ١٨ عاماً. لا نجمع عن قصد معلومات شخصية من الأطفال دون السن القانونية. إذا اكتشفنا أننا جمعنا معلومات من طفل دون ١٨ عاماً، سنقوم بحذف هذه المعلومات فوراً.'
              : 'Our platform is not directed to children under 18 years of age. We do not knowingly collect personal information from children under 18. If we discover that we have collected information from a child under 18, we will delete that information immediately.',
        },
        {
          'title': isRtl ? '١١. تحديثات سياسة الخصوصية' : '11. Changes to This Policy',
          'body': isRtl
              ? 'قد نقوم بتحديث سياسة الخصوصية هذه من وقت لآخر. سنقوم بإعلامك بأي تغييرات جوهرية عبر البريد الإلكتروني المسجل لدينا أو من خلال إشعار على المنصة. يُنصح بمراجعة هذه الصفحة بشكل دوري. تاريخ آخر تحديث: يونيو ٢٠٢٦.'
              : 'We may update this Privacy Policy from time to time. We will notify you of any material changes via your registered email or through a notice on the platform. We recommend reviewing this page periodically. Last updated: June 2026.',
        },
        {
          'title': isRtl ? '١٢. الاتصال بنا' : '12. Contact Us',
          'body': isRtl
              ? 'إذا كانت لديك أي أسئلة أو استفسارات حول سياسة الخصوصية، يرجى التواصل معنا عبر صفحة الاتصال في المنصة أو من خلال حسابنا على منصات التواصل الاجتماعي.'
              : 'If you have any questions or concerns about this Privacy Policy, please contact us through the contact page on the platform or via our social media channels.',
        },
      ],
      'terms_content': [
        {
          'title': isRtl ? '١. قبول الشروط' : '1. Acceptance of Terms',
          'body': isRtl
              ? 'باستخدامك لمنصة لاندي ميكر (LandyMaker)، فإنك توافق على الالتزام بشروط الاستخدام هذه وسياسة الخصوصية المنشورة على المنصة. إذا كنت لا توافق على هذه الشروط، يجب عليك التوقف عن استخدام المنصة. تحتفظ لاندي ميكر بالحق في تعديل هذه الشروط، وسيتم إعلامك بالتغييرات الجوهرية عبر البريد الإلكتروني المسجل لدينا.'
              : 'By using LandyMaker, you agree to be bound by these Terms of Service and the Privacy Policy published on the platform. If you do not agree with these terms, you must stop using the platform. LandyMaker reserves the right to modify these terms, and you will be notified of material changes via your registered email.',
        },
        {
          'title': isRtl ? '٢. التسجيل وإنشاء الحساب' : '2. Registration and Account',
          'body': isRtl
              ? 'للاستفادة من خدمات المنصة، يجب عليك إنشاء حساب باستخدام بريدك الإلكتروني وكلمة مرور، أو عبر حساب جوجل الخاص بك. أنت المسؤول الوحيد عن الحفاظ على سرية معلومات تسجيل الدخول الخاصة بك. يجب ألا يقل عمرك عن ١٨ عاماً لإنشاء حساب. يحظر إنشاء حسابات متعددة أو استخدام هويات مزيفة. نحتفظ بالحق في تعليق أو إنهاء أي حساب ينتهك هذه الشروط.'
              : 'To use the platform services, you must create an account using your email and password, or via your Google account. You are solely responsible for maintaining the confidentiality of your login credentials. You must be at least 18 years old to create an account. Creating multiple accounts or using fake identities is prohibited. We reserve the right to suspend or terminate any account that violates these terms.',
        },
        {
          'title': isRtl ? '٣. وصف الخدمات' : '3. Services Description',
          'body': isRtl
              ? 'توفر لاندي ميكر منصة إلكترونية لبناء وإدارة صفحات الهبوط والمتاجر الإلكترونية. تشمل الخدمات الأساسية: محرر بصري بالسحب والإفلات. أدوات توليد المحتوى بالذكاء الاصطناعي. استضافة الصفحات على نطاق فرعي مجاني (landymaker.com/صفحتك). إمكانية ربط النطاقات المخصصة (للباقات المدفوعة). إحصائيات أداء أساسية. نظام إدارة العملاء المتوقعين. إشعارات فورية عبر البريد الإلكتروني والإشعارات داخل المتصفح. قد تختلف الميزات المتاحة حسب الباقة المختارة.'
              : 'LandyMaker provides an online platform for building and managing landing pages and e-commerce stores. Core services include: Visual drag-and-drop editor. AI-powered content generation tools. Page hosting on a free subdomain (landymaker.com/yourpage). Custom domain support (for paid plans). Basic performance analytics. Lead management system. Instant email and in-browser notifications. Available features may vary depending on your chosen plan.',
        },
        {
          'title': isRtl ? '٤. التزامات المستخدم' : '4. User Obligations',
          'body': isRtl
              ? 'باستخدام المنصة، أنت تتعهد بعدم: استخدام الخدمة لأي غرض غير قانوني. نشر محتوى ينتهك حقوق الملكية الفكرية للآخرين. نشر محتوى مسيء أو مخالف للقوانين المصرية. محاولة اختراق أمن المنصة أو الوصول غير المصرح به إلى بيانات الآخرين. استخدام برامج آلية أو روبوتات لجمع البيانات. نشر صفحات تحتوي على برمجيات خبيثة أو روابط ضارة.'
              : 'By using the platform, you agree NOT to: Use the service for any illegal purpose. Publish content that infringes on others\' intellectual property rights. Publish abusive or content violating Egyptian laws. Attempt to breach platform security or gain unauthorized access to others\' data. Use bots or automated scripts to collect data. Publish pages containing malware or malicious links.',
        },
        {
          'title': isRtl ? '٥. ملكية المحتوى وحقوق الملكية الفكرية' : '5. Content Ownership and Intellectual Property',
          'body': isRtl
              ? 'أنت تمتلك جميع الحقوق في المحتوى الذي تنشئه عبر صفحاتك على لاندي ميكر، بما في ذلك النصوص والصور والتصاميم. بموجب هذه الشروط، تمنح لاندي ميكر ترخيصاً محدوداً لاستضافة هذا المحتوى وعرضه لغرض تقديم الخدمات لك. جميع حقوق الملكية الفكرية للمنصة نفسها (بما في ذلك البرمجيات والتصاميم والعلامات التجارية) هي ملك حصري لاندي ميكر.'
              : 'You retain all rights to the content you create on your LandyMaker pages, including text, images, and designs. Under these terms, you grant LandyMaker a limited license to host and display this content for the purpose of providing services to you. All intellectual property rights of the platform itself (including software, designs, and trademarks) are the exclusive property of LandyMaker.',
        },
        {
          'title': isRtl ? '٦. الباقات المدفوعة والدفع' : '6. Paid Plans and Payment',
          'body': isRtl
              ? 'الخدمات الأساسية في لاندي ميكر متاحة مجاناً مع حدود معينة (مثل عدد الصفحات والصور والتخزين). الباقات المدفوعة توفر ميزات إضافية مثل عدد صفحات أكبر، النطاقات المخصصة، وإزالة العلامة المائية. تتم عملية الدفع يدوياً عبر طرق الدفع المصرية المتاحة: فودافون كاش، إنستاباي، وي كاش. بعد الدفع، يتم مراجعة طلب الترقية من قبل فريقنا وتفعيل الباقة خلال ٢٤ ساعة. جميع المدفوعات غير قابلة للاسترداد. تحتفظ لاندي ميكر بالحق في تعديل أسعار الباقات مع إشعار مسبق.'
              : 'Basic LandyMaker services are available for free with certain limitations (e.g., number of pages, images, and storage). Paid plans provide additional features such as more pages, custom domains, and watermark removal. Payment is processed manually via available Egyptian payment methods: Vodafone Cash, InstaPay, and We Cash. After payment, your upgrade request is reviewed by our team and activated within 24 hours. All payments are non-refundable. LandyMaker reserves the right to modify plan prices with prior notice.',
        },
        {
          'title': isRtl ? '٧. سياسة الإلغاء والإنهاء' : '7. Cancellation and Termination',
          'body': isRtl
              ? 'يمكنك إلغاء تجديد اشتراكك المدفوع في أي وقت من خلال لوحة التحكم، ويستمر وصولك للخدمات المدفوعة حتى نهاية فترة الفوترة الحالية. يحق للاندي ميكر تعليق أو إنهاء حسابك إذا انتهكت هذه الشروط. سنقوم بإشعارك عبر البريد الإلكتروني قبل الإنهاء. بعد إنهاء الحساب، سيتم إيقاف صفحاتك المنشورة وحذف بياناتك وفقاً لسياسة الخصوصية.'
              : 'You may cancel your paid subscription renewal at any time through the dashboard; access to paid services continues until the end of the current billing period. LandyMaker may suspend or terminate your account if you violate these terms. We will notify you via email before termination. After account termination, your published pages will be taken down and your data will be deleted in accordance with our Privacy Policy.',
        },
        {
          'title': isRtl ? '٨. إخلاء المسؤولية' : '8. Disclaimer of Warranties',
          'body': isRtl
              ? 'تُقدم المنصة وخدماتها "كما هي" دون أي ضمانات صريحة أو ضمنية. لا نضمن أن المنصة ستكون خالية من الأخطاء أو الانقطاعات. لا نتحمل المسؤولية عن أي خسائر أو أضرار ناتجة عن استخدامك للمنصة، بما في ذلك فقدان البيانات.'
              : 'The platform and its services are provided "as is" without any warranties, express or implied. We do not guarantee that the platform will be error-free or uninterrupted. We are not liable for any losses or damages resulting from your use of the platform, including loss of data.',
        },
        {
          'title': isRtl ? '٩. تحديد المسؤولية' : '9. Limitation of Liability',
          'body': isRtl
              ? 'في أقصى حد يسمح به القانون المصري، لن تكون لاندي ميكر مسؤولة عن أي أضرار غير مباشرة أو تبعية، بما في ذلك فقدان الأرباح أو البيانات، الناشئة عن استخدامك للمنصة أو عدم قدرتك على استخدامها.'
              : 'To the maximum extent permitted by Egyptian law, LandyMaker shall not be liable for any indirect or consequential damages, including loss of profits or data, arising from your use or inability to use the platform.',
        },
        {
          'title': isRtl ? '١٠. القانون الواجب التطبيق' : '10. Governing Law',
          'body': isRtl
              ? 'تخضع هذه الشروط وأي نزاعات تنشأ عنها للقوانين السارية في جمهورية مصر العربية. في حالة وجود أي نزاع، يتم اللجوء أولاً إلى الحلول الودية، وفي حالة عدم الاتفاق، يتم عرض النزاع على المحاكم المختصة في مصر.'
              : 'These terms and any disputes arising from them are governed by the laws of the Arab Republic of Egypt. In case of any dispute, amicable solutions shall be sought first, and if no agreement is reached, the dispute shall be submitted to the competent courts in Egypt.',
        },
        {
          'title': isRtl ? '١١. أحكام عامة' : '11. General Provisions',
          'body': isRtl
              ? 'إذا تبين أن أي بند من هذه الشروط غير قابل للتنفيذ، فإن ذلك لا يؤثر على صحة البنود المتبقية. لا تشكل هذه الشروط علاقة شراكة أو وكالة بينك وبين لاندي ميكر. عدم ممارسة لاندي ميكر لأي حق لا يعتبر تنازلاً عنه.'
              : 'If any provision of these terms is found to be unenforceable, this does not affect the validity of the remaining provisions. These terms do not create a partnership or agency relationship between you and LandyMaker. LandyMaker\'s failure to exercise any right does not constitute a waiver.',
        },
        {
          'title': isRtl ? '١٢. الاتصال بنا' : '12. Contact Us',
          'body': isRtl
              ? 'للاستفسارات المتعلقة بهذه الشروط، يرجى التواصل معنا عبر صفحة الاتصال في المنصة.'
              : 'For inquiries regarding these terms, please contact us through the contact page on the platform.',
        },
      ],
    };

    final sections = legalData[widget.contentKey] ?? [];
    return _buildSectionList(sections, isMobile);
  }

  Widget _buildSectionList(List<Map<String, String>> sections, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sections.map((sec) {
        return Container(
          padding: EdgeInsetsDirectional.all(isMobile ? 20 : 28),
          margin: const EdgeInsetsDirectional.only(bottom: 20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.6),
            ),
          ),
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
              const SizedBox(height: 16),
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
