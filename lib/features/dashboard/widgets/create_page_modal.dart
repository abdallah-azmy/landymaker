import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:landymaker/features/builder/controllers/builder_cubit.dart';
import 'package:landymaker/features/builder/controllers/builder_state.dart';
import 'package:landymaker/features/dashboard/controllers/landing_pages_cubit.dart';
import 'package:landymaker/features/dashboard/controllers/active_website_cubit.dart';
import 'package:landymaker/features/dashboard/controllers/landing_pages_state.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/atoms/cube_spinner.dart';
import 'package:landymaker/core/widgets/particles/loading_logo.dart';
import '../../../core/localization/localization_cubit.dart';
import '../../../core/widgets/atoms/primary_button.dart';
import '../../../core/widgets/atoms/custom_text_field.dart';
import '../../../services/database_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/tenant_routing_service.dart';
import '../../../core/logger.dart';
import '../../../injection_container.dart';
import '../../../services/subscription_service.dart';
import '../../subscription/widgets/mission_upgrade_modal.dart';
import '../../builder/registries/template_registry.dart';

class CreatePageModal extends StatefulWidget {
  final VoidCallback onPageCreated;

  const CreatePageModal({super.key, required this.onPageCreated});

  @override
  State<CreatePageModal> createState() => _CreatePageModalState();
}

class _CreatePageModalState extends State<CreatePageModal> {
  final _slugController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isCheckingSlug = false;
  bool _isCheckingLimit = true;
  String? _slugError;
  bool _isSlugAvailable = false;
  bool _hasReachedLimit = false;
  String _selectedTemplateId = 'empty';
  Timer? _debounce;

  String? _customTemplateName;
  bool _loadingCustomTemplate = false;

  static final Map<String, Map<String, dynamic>> _hardcodedTemplates = {
    'midnight_ocean': {
      'theme': {
        'primary': 0xFF3B82F6,
        'secondary': 0xFF60A5FA,
        'background': 0xFF030712,
        'textPrimary': 0xFFFFFFFF,
        'textSecondary': 0xFF9CA3AF,
        'buttonTextColor': 0xFFFFFFFF,
        'name': 'Midnight Ocean',
      },
      'blocks': [
        {
          'type': 'hero',
          'title': 'أناقة وفخامة تليق بك',
          'subtitle': 'نحن لا نقص الشعر فقط، بل نصنع الثقة والمظهر المثالي الذي تستحقه بأحدث القصات العالمية.',
          'button_text': 'احجز مقعدك الآن',
          'image_url': 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=400',
        },
        {
          'type': 'features',
          'title': 'خدماتنا المميزة',
          'items': [
            {
              'title': 'قص وتصفيف احترافي',
              'description': 'أحدث القصات والستايلات العالمية.',
            },
            {
              'title': 'حلاقة ذقن بالبخار',
              'description': 'جلسة تنظيف ذقن متكاملة بالبخار.',
            },
          ],
        },
      ],
    },
    'lux_earth': {
      'theme': {
        'primary': 0xFFD97706,
        'secondary': 0xFFF59E0B,
        'background': 0xFF0F172A,
        'textPrimary': 0xFFFFFFFF,
        'textSecondary': 0xFF94A3B8,
        'buttonTextColor': 0xFFFFFFFF,
        'name': 'Lux-Earth',
      },
      'blocks': [
        {
          'type': 'hero',
          'title': 'ساعات ذكية فاخرة',
          'subtitle': 'اكتشف مجموعتنا الحصرية من الساعات الذكية والأجهزة التقنية الراقية.',
          'button_text': 'تسوق الآن',
          'image_url': 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400',
        },
        {
          'type': 'products',
          'title': 'المنتجات الأكثر مبيعاً',
          'items': [
            {
              'name': 'ساعة ذكية فاخرة Pro',
              'price': '1200 EGP',
              'description': 'تتبع نشاطك وصحتك بكل سهولة مع تصميم عصري.',
              'image_url': 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400',
              'button_text': 'طلب مباشر',
            },
          ],
        },
      ],
    },
    'butter_sky': {
      'theme': {
        'primary': 0xFF0EA5E9,
        'secondary': 0xFF38BDF8,
        'background': 0xFF0F172A,
        'textPrimary': 0xFFFFFFFF,
        'textSecondary': 0xFF94A3B8,
        'buttonTextColor': 0xFF0F172A,
        'name': 'Butter & Sky',
      },
      'blocks': [
        {
          'type': 'hero',
          'title': 'تصميم هويات بصرية مذهلة',
          'subtitle': 'نساعد الشركات الناشئة على بناء هويات وتجارب مستخدم فريدة للويب والهاتف.',
          'button_text': 'شاهد أعمالي',
          'image_url': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
        },
        {
          'type': 'social_qr',
          'title': 'تابع منصاتي',
          'subtitle': 'تابعني على حساباتي الرسمية لمزيد من التصاميم اليومية',
          'links': [
            {'platform': 'instagram', 'url': 'https://instagram.com'},
            {'platform': 'linkedin', 'url': 'https://linkedin.com'},
          ],
        },
      ],
    },
  };

  @override
  void initState() {
    super.initState();
    _checkInitialLimit();

    final pendingId = TenantRoutingService.pendingTemplateId;
    if (pendingId != null) {
      _selectedTemplateId = pendingId;
      _resolveTemplateName(pendingId);
    }
  }

  Future<void> _resolveTemplateName(String id) async {
    // Check built-in templates first
    final builtIn = TemplateRegistry.availableTemplates.firstWhere(
      (t) => t.id == id,
      orElse: () => const TemplateMetadata(id: '', name: '', description: '', imageUrl: ''),
    );
    if (builtIn.id.isNotEmpty) {
      return; // It's standard built-in, ListView handles selection automatically
    }

    // Check hardcoded home preview page names
    if (id == 'midnight_ocean') {
      setState(() => _customTemplateName = 'Midnight Ocean');
      return;
    } else if (id == 'lux_earth') {
      setState(() => _customTemplateName = 'Lux-Earth');
      return;
    } else if (id == 'butter_sky') {
      setState(() => _customTemplateName = 'Butter & Sky');
      return;
    }

    // Otherwise, fetch from Supabase
    setState(() => _loadingCustomTemplate = true);
    try {
      final page = await sl<DatabaseService>().getLandingPageById(id);
      if (page != null && mounted) {
        setState(() {
          _customTemplateName = page['name'] as String? ?? page['subdomain'] as String? ?? 'تصميم مخصص';
        });
      }
    } catch (_) {
      // ignore
    } finally {
      if (mounted) {
        setState(() => _loadingCustomTemplate = false);
      }
    }
  }

  Future<void> _checkInitialLimit() async {
    try {
      final subService = sl<SubscriptionService>();
      final userId = sl<AuthService>().currentUserId!;

      final reachedLimit = await subService.hasReachedLimit(userId);
      if (mounted) {
        setState(() {
          _hasReachedLimit = reachedLimit;
          _isCheckingLimit = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isCheckingLimit = false);
    }
  }

  @override
  void dispose() {
    _slugController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSlugChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Strict normalization: lowercase, replace spaces/special with single dash
    String normalized = value.toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]+'),
      '-',
    );

    // Remove leading dash
    if (normalized.startsWith('-')) {
      normalized = normalized.replaceFirst('-', '');
    }

    Logger.info("Slug input changed: $value -> $normalized");

    if (normalized != value) {
      _slugController.value = _slugController.value.copyWith(
        text: normalized,
        selection: TextSelection.collapsed(offset: normalized.length),
      );
    }

    if (normalized.isEmpty) {
      setState(() {
        _slugError = null;
        _isSlugAvailable = false;
        _isCheckingSlug = false;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _checkSlugAvailability(normalized);
    });
  }

  Future<void> _checkSlugAvailability(String slug) async {
    if (slug.isEmpty) return;

    Logger.info("Starting slug availability check for: $slug");

    // 1. Basic length check
    if (slug.length < 3 || slug.length > 30) {
      Logger.warn("Validation failed: Slug length error (${slug.length})");
      setState(() {
        _slugError = context.translate('slug_length_error');
        _isSlugAvailable = false;
      });
      return;
    }

    // 2. Format validation (Regex)
    final slugRegex = RegExp(r'^[a-z0-9-]+$');
    if (!slugRegex.hasMatch(slug)) {
      Logger.warn("Validation failed: Slug invalid characters");
      setState(() {
        _slugError = context.translate('slug_invalid_error');
        _isSlugAvailable = false;
      });
      return;
    }

    // 3. Reserved system routes check
    if (TenantRoutingService.reservedPaths.contains(slug)) {
      Logger.warn("Validation failed: Slug is a reserved route");
      setState(() {
        _slugError = context.translate('slug_reserved_error');
        _isSlugAvailable = false;
      });
      return;
    }

    setState(() {
      _isCheckingSlug = true;
      _slugError = null;
    });

    try {
      // FIX: Use sl<DatabaseService>() instead of RepositoryProvider
      final dbService = sl<DatabaseService>();

      Logger.info("Checking route availability for slug: $slug");
      final isAvailable = await dbService.isRouteAvailable(slug);
      Logger.info(
        "Route availability response: $isAvailable",
      );

      if (mounted) {
        setState(() {
          _isCheckingSlug = false;
          if (!isAvailable) {
            _slugError = context.translate('slug_taken_error');
            _isSlugAvailable = false;
          } else {
            _slugError = null;
            _isSlugAvailable = true;
          }
        });
        Logger.info("State updated: isSlugAvailable = $_isSlugAvailable");
      }
    } catch (e, stack) {
      Logger.error("Exception during slug check", e, stack);
      if (mounted) {
        setState(() {
          _isCheckingSlug = false;
          _slugError = context.translate('slug_checking_error');
        });
      }
    }
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate() || !_isSlugAvailable) return;

    setState(() => _isLoading = true);

    final builderCubit = context.read<LandingPageBuilderCubit>();
    final landingPagesCubit = context.read<LandingPagesCubit>();

    // Backup current builder state if needed (though usually empty here)
    final prevState = builderCubit.state;

    try {
      final authService = sl<AuthService>();
      final userId = authService.currentUserId!;

      // 1. Initialize builder with clean state
      builderCubit.initializeNewPage();

      // 2. Set subdomain — start as draft
      builderCubit.updateSettings(
        subdomain: _slugController.text,
        isPublished: false,
      );

      // 3. Apply template if not empty
      if (_selectedTemplateId != 'empty') {
        if (_hardcodedTemplates.containsKey(_selectedTemplateId)) {
          final customDesign = _hardcodedTemplates[_selectedTemplateId]!;
          builderCubit.applyCustomDesign(customDesign);
        } else {
          final isBuiltIn = TemplateRegistry.availableTemplates.any((t) => t.id == _selectedTemplateId);
          if (isBuiltIn) {
            builderCubit.applyTemplate(_selectedTemplateId);
          } else {
            // Custom landing page UUID from DB
            final pageData = await sl<DatabaseService>().getLandingPageById(_selectedTemplateId);
            if (pageData != null) {
              Map<String, dynamic> designMap = {'blocks': []};
              final rawDesign = pageData['design_json'];
              if (rawDesign != null) {
                if (rawDesign is String) {
                  designMap = Map<String, dynamic>.from(jsonDecode(rawDesign));
                } else {
                  designMap = Map<String, dynamic>.from(rawDesign as Map);
                }
              }
              builderCubit.applyCustomDesign(designMap);
            }
          }
        }
      }

      // 4. Save to database immediately
      await builderCubit.savePage(userId);

      // Check if save was successful by inspecting state
      if (builderCubit.state is BuilderLoaded) {
        final state = builderCubit.state as BuilderLoaded;
        if (state.errorMessage != null) {
          throw Exception(state.errorMessage);
        }
      }

      // 5. Refresh Dashboard list
      await landingPagesCubit.loadPages();

      // Auto-select the newly created page (which will be first due to updated_at ordering)
      if (landingPagesCubit.state is LandingPagesLoaded) {
        final pages = (landingPagesCubit.state as LandingPagesLoaded).pages;
        if (pages.isNotEmpty) {
          if (context.mounted) {
            context.read<ActiveWebsiteCubit>().selectWebsite(pages.first);
          }
        }
      }

      if (mounted) {
        Navigator.pop(context);
        widget.onPageCreated();
      }
    } catch (e) {
      Logger.error("Failed to create page: $e");

      // Rollback logic: Clear builder to prevent "ghost" state
      if (prevState is BuilderLoaded) {
        // Restore previous or just reset to Initial to force a reload if they enter again
        builderCubit.loadForCurrentUser();
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          _slugError =
              "فشل إنشاء الصفحة: ${e.toString().replaceAll('Exception: ', '')}";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationCubit>();

    if (_isCheckingLimit) {
      return SizedBox(
        height: 300,
        child: Center(child: const LoadingLogo(size: 48)),
      );
    }

    if (_hasReachedLimit) {
      return MissionUpgradeModal(userId: sl<AuthService>().currentUserId!);
    }

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(loc.translate('create_new_page'), style: AppTypography.h3),
            SizedBox(height: 24),
            Text(
              loc.translate('choose_template'),
              style: AppTypography.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            if (_customTemplateName != null || _loadingCustomTemplate) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.dashboard_customize_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.isRtl ? 'التصميم المستهدف الحالي:' : 'Current target design:',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          if (_loadingCustomTemplate)
                            SizedBox(
                              height: 12,
                              width: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            )
                          else
                            Text(
                              _customTemplateName ?? '',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _selectedTemplateId = 'empty';
                          _customTemplateName = null;
                          TenantRoutingService.pendingTemplateId = null;
                        });
                      },
                      icon: Icon(
                        Icons.delete_forever_rounded,
                        color: Theme.of(context).colorScheme.error,
                        size: 18,
                      ),
                      tooltip: loc.isRtl ? 'إزالة الاختيار' : 'Remove template',
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: TemplateRegistry.availableTemplates.length,
                separatorBuilder: (_, __) => SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final template = TemplateRegistry.availableTemplates[index];
                  final isSelected = _selectedTemplateId == template.id;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTemplateId = template.id;
                        _customTemplateName = null;
                        TenantRoutingService.pendingTemplateId = null;
                      });
                    },
                    child: Container(
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outlineVariant,
                          width: isSelected ? 2 : 1,
                        ),
                        image: DecorationImage(
                          image: NetworkImage(template.imageUrl),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            Colors.black.withValues(alpha: isSelected ? 0.2 : 0.5),
                            BlendMode.darken,
                          ),
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            bottom: 8,
                            left: 8,
                            right: 8,
                            child: Text(
                              template.name,
                              style: AppTypography.caption.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isSelected)
                            const Positioned(
                              top: 4,
                              right: 4,
                              child: Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 20,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 24),
            Text(
              loc.translate('enter_page_slug'),
              style: AppTypography.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            CustomTextField(
              controller: _slugController,
              hintText: loc.translate('slug_hint'),
              onChanged: _onSlugChanged,
              prefixIcon: Icon(
                Icons.link,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              suffixIcon: _isCheckingSlug
                  ? Padding(
                      padding: EdgeInsets.all(12),
                      child: CubeSpinner(
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                  : _isSlugAvailable
                  ? Icon(Icons.check_circle, color: Colors.green)
                  : _slugError != null
                  ? Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error)
                  : null,
            ),
            if (_slugError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.error,
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      _slugError!,
                      style: AppTypography.caption.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
              )
            else if (_isSlugAvailable)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      loc.translate('slug_available'),
                      style: AppTypography.caption.copyWith(
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(height: 24),
            Text(
              loc.translate('live_url_preview'),
              style: AppTypography.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Browser Top Bar Mockup
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(11),
                      ),
                      border: Border(
                        bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                      ),
                    ),
                    child: Row(
                      children: [
                        _buildDot(Colors.red[300]!),
                        SizedBox(width: 4),
                        _buildDot(Colors.orange[300]!),
                        SizedBox(width: 4),
                        _buildDot(Colors.green[300]!),
                        const Expanded(child: SizedBox()),
                        Icon(
                          Icons.add,
                          size: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                  // Address Bar
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lock,
                            size: 12,
                            color: Colors.green,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "landymaker.com/${_slugController.text.isEmpty ? '...' : _slugController.text}",
                              style: AppTypography.bodyMedium.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              textDirection: TextDirection.ltr,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(loc.translate('cancel')),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: PrimaryButton(
                    text: loc.translate('confirm_and_create'),
                    isLoading: _isLoading,
                    onPressed: (_isSlugAvailable && !_isCheckingSlug)
                        ? _handleCreate
                        : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
