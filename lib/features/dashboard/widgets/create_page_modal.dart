import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import '../../builder/controllers/builder_cubit.dart';

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
    
    // Normalize: lowercase and remove spaces
    final normalized = value.toLowerCase().trim().replaceAll(' ', '-');
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
      
      Logger.info("Executing Supabase query for slug: $slug");
      final existingPage = await dbService.getLandingPageByDomain(slug);
      Logger.info("Supabase response: ${existingPage != null ? 'Found existing' : 'Not found'}");
      
      if (mounted) {
        setState(() {
          _isCheckingSlug = false;
          if (existingPage != null) {
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
    
    try {
      final builderCubit = context.read<LandingPageBuilderCubit>();
      final authService = sl<AuthService>();
      final bool isAdmin = authService.currentUserRole == 'super_admin';

      // The builder currently uses loadPageForUser("") for new pages.
      await builderCubit.loadPageForUser(""); 
      
      // Super Admins get published pages by default to avoid "Inactive" confusion
      // Regular users start as Draft (false)
      builderCubit.updateSettings(
        subdomain: _slugController.text, 
        isPublished: isAdmin, 
      );
      
      if (mounted) {
        Navigator.pop(context);
        widget.onPageCreated();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
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
            Text(
              loc.translate('create_new_page'),
              style: AppTypography.h3,
            ),
            const SizedBox(height: 24),
            Text(
              loc.translate('enter_page_slug'),
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _slugController,
              hintText: loc.translate('slug_hint'),
              onChanged: _onSlugChanged,
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
                      : null,
            ),
            if (_slugError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _slugError!,
                  style: AppTypography.caption.copyWith(color: AppColors.dangerRed),
                ),
              )
            else if (_isSlugAvailable)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  loc.translate('slug_available'),
                  style: AppTypography.caption.copyWith(color: AppColors.activeGreen),
                ),
              ),
            const SizedBox(height: 24),
            Text(
              loc.translate('live_url_preview'),
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                "landymaker.com/${_slugController.text.isEmpty ? '...' : _slugController.text}",
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
                textDirection: TextDirection.ltr,
                textAlign: loc.isRtl ? TextAlign.right : TextAlign.left,
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
                    onPressed: (_isSlugAvailable && !_isCheckingSlug) ? _handleCreate : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
