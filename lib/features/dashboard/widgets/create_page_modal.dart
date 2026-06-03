import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:landymaker/features/builder/controllers/builder_cubit.dart';
import 'package:landymaker/features/builder/controllers/builder_state.dart';
import 'package:landymaker/features/dashboard/controllers/landing_pages_cubit.dart';
import 'package:landymaker/features/dashboard/controllers/active_website_cubit.dart';
import 'package:landymaker/features/dashboard/controllers/landing_pages_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/localization/localization_cubit.dart';
import '../../../core/widgets/atoms/primary_button.dart';
import '../../../core/widgets/atoms/custom_text_field.dart';
import '../../../services/database_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/tenant_routing_service.dart';
import '../../../core/logger.dart';
import '../../../injection_container.dart';
import '../../../services/subscription_service.dart';
import '../widgets/upgrade_limit_modal.dart';
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

  @override
  void initState() {
    super.initState();
    _checkInitialLimit();
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

      // 2. Set subdomain (normalized in UI, re-normalized in Cubit save)
      builderCubit.updateSettings(
        subdomain: _slugController.text,
        isPublished: true,
      );

      // 3. Apply template if not empty
      if (_selectedTemplateId != 'empty') {
        builderCubit.applyTemplate(_selectedTemplateId);
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
      return const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_hasReachedLimit) {
      return UpgradeLimitModal(userId: sl<AuthService>().currentUserId!);
    }

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
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
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(loc.translate('create_new_page'), style: AppTypography.h3),
            const SizedBox(height: 24),
            Text(
              loc.translate('choose_template'),
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: TemplateRegistry.availableTemplates.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final template = TemplateRegistry.availableTemplates[index];
                  final isSelected = _selectedTemplateId == template.id;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedTemplateId = template.id),
                    child: Container(
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
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
                                color: AppColors.activeGreen,
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
            const SizedBox(height: 24),
            Text(
              loc.translate('enter_page_slug'),
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _slugController,
              hintText: loc.translate('slug_hint'),
              onChanged: _onSlugChanged,
              prefixIcon: const Icon(
                Icons.link,
                color: AppColors.textSecondary,
              ),
              suffixIcon: _isCheckingSlug
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : _isSlugAvailable
                  ? const Icon(Icons.check_circle, color: AppColors.activeGreen)
                  : _slugError != null
                  ? const Icon(Icons.error_outline, color: AppColors.dangerRed)
                  : null,
            ),
            if (_slugError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.dangerRed,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _slugError!,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.dangerRed,
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
                    const Icon(
                      Icons.check_circle_outline,
                      color: AppColors.activeGreen,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      loc.translate('slug_available'),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.activeGreen,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            Text(
              loc.translate('live_url_preview'),
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
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
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(11),
                      ),
                      border: Border(
                        bottom: BorderSide(color: AppColors.border),
                      ),
                    ),
                    child: Row(
                      children: [
                        _buildDot(Colors.red[300]!),
                        const SizedBox(width: 4),
                        _buildDot(Colors.orange[300]!),
                        const SizedBox(width: 4),
                        _buildDot(Colors.green[300]!),
                        const Expanded(child: SizedBox()),
                        const Icon(
                          Icons.add,
                          size: 14,
                          color: AppColors.textSecondary,
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
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.lock,
                            size: 12,
                            color: AppColors.activeGreen,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "landymaker.com/${_slugController.text.isEmpty ? '...' : _slugController.text}",
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.primary,
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
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(loc.translate('cancel')),
                  ),
                ),
                const SizedBox(width: 16),
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
