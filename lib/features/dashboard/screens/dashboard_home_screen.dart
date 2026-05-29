import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/localization/localization_cubit.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../core/responsive/responsive_utils.dart';
import '../../../core/widgets/atoms/primary_button.dart';
import '../../../core/widgets/atoms/custom_text_field.dart';
import '../../../core/widgets/molecules/form_group.dart';
import '../../../core/widgets/molecules/status_pill.dart';
import '../../../core/utils/toast_service.dart';
import '../../auth/controllers/auth_cubit.dart';
import '../../auth/controllers/auth_state.dart';
import '../../../services/tenant_routing_service.dart';
import '../../builder/controllers/builder_cubit.dart';
import '../../builder/controllers/builder_state.dart';

class DashboardHomeScreen extends StatefulWidget {
  final VoidCallback onOpenBuilder;

  const DashboardHomeScreen({super.key, required this.onOpenBuilder});

  @override
  State<DashboardHomeScreen> createState() => _DashboardHomeScreenState();
}

class _DashboardHomeScreenState extends State<DashboardHomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subdomainController = TextEditingController();
  final _customDomainController = TextEditingController();
  bool _isPublished = false;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<LandingPageBuilderCubit>();
    if (cubit.state is! BuilderLoaded) {
      cubit.loadForCurrentUser();
    }
    _populateControllers(cubit.state);
  }

  void _populateControllers(BuilderState state) {
    if (state is BuilderLoaded) {
      _subdomainController.text = state.subdomain;
      _customDomainController.text = state.customDomain ?? '';
      _isPublished = state.isPublished;
    }
  }

  void _saveConfig(LandingPageBuilderCubit cubit) {
    if (!_formKey.currentState!.validate()) return;

    final rawCustomDomain = _customDomainController.text.trim().toLowerCase();

    cubit.updateSettings(
      subdomain: _subdomainController.text.trim().toLowerCase(),
      // Pass null (not empty string '') so Postgres CHECK constraint is satisfied
      customDomain: rawCustomDomain.isEmpty ? '' : rawCustomDomain,
      isPublished: _isPublished,
    );

    cubit.saveForCurrentUser();
  }

  void _previewPage() {
    if (_subdomainController.text.isEmpty) return;

    final subdomain = _subdomainController.text.trim().toLowerCase();
    final baseUrl = Uri.base.origin;
    // Use path-based slug routing: mylandy.com/restaurant-x
    final liveUrl = '$baseUrl/$subdomain';

    launchUrl(Uri.parse(liveUrl), webOnlyWindowName: '_blank');
  }

  @override
  void dispose() {
    _subdomainController.dispose();
    _customDomainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationCubit>();
    final builderCubit = context.watch<LandingPageBuilderCubit>();
    final state = builderCubit.state;

    if (state is BuilderLoading || state is BuilderInitial) {
      return const Center(child: CircularProgressIndicator(color: AppColors.secondary));
    }

    if (state is BuilderFailure) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Failed to load page config", style: AppTypography.h2),
            const SizedBox(height: 8),
            Text(state.message, style: AppTypography.bodyMedium.copyWith(color: AppColors.dangerRed)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                builderCubit.loadForCurrentUser();
              },
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    final loadedState = state as BuilderLoaded;
    final isSaving = loadedState.isSaving;
    
    // Check if user is super admin to show/hide custom domain
    final authState = context.read<AuthCubit>().state;
    final bool isSuperAdmin = authState is Authenticated && authState.role == 'super_admin';

    return BlocListener<LandingPageBuilderCubit, BuilderState>(
      listener: (context, state) {
        if (state is BuilderLoaded) {
          if (_subdomainController.text.isEmpty && state.subdomain.isNotEmpty) {
            _subdomainController.text = state.subdomain;
          }
          if (_customDomainController.text.isEmpty && state.customDomain != null) {
            _customDomainController.text = state.customDomain!;
          }
          setState(() {
            _isPublished = state.isPublished;
          });
          // Show save feedback as Toast
          if (state.successMessage != null) {
            ToastService.showSuccess(context, message: state.successMessage!);
            builderCubit.clearMessages();
          } else if (state.errorMessage != null) {
            ToastService.showError(context, message: state.errorMessage!);
            builderCubit.clearMessages();
          }

          // Apply pending template if any
          if (TenantRoutingService.pendingTemplateId != null) {
            final templateId = TenantRoutingService.pendingTemplateId!;
            TenantRoutingService.pendingTemplateId = null; // Clear immediately
            
            // Wait until current frame is done to avoid nested state updates
            WidgetsBinding.instance.addPostFrameCallback((_) {
              builderCubit.applyTemplate(templateId);
              builderCubit.saveForCurrentUser(); // Automatically save the new template to DB
              ToastService.showSuccess(context, message: "تم تطبيق القالب بنجاح!");
            });
          }
        }
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.all(ResponsiveUtils.getPadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.translate('dashboard'),
                      style: AppTypography.h1.copyWith(fontSize: 28),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Manage your subdomain configurations and page properties.",
                      style: AppTypography.bodyMedium,
                    ),
                  ],
                ),
                _isPublished
                    ? StatusPill.published(label: loc.translate('published'))
                    : StatusPill.draft(label: loc.translate('draft')),
              ],
            ),
            const SizedBox(height: 32),

            // Main forms block
            Form(
              key: _formKey,
              child: ResponsiveLayout(
                mobile: Column(
                  children: [
                    _buildDomainSettingsCard(loc, builderCubit, isSaving, isSuperAdmin),
                    const SizedBox(height: 24),
                    _buildQuickActionsCard(loc),
                  ],
                ),
                desktop: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _buildDomainSettingsCard(loc, builderCubit, isSaving, isSuperAdmin)),
                    const SizedBox(width: 24),
                    Expanded(flex: 2, child: _buildQuickActionsCard(loc)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDomainSettingsCard(
    LocalizationCubit loc,
    LandingPageBuilderCubit cubit,
    bool isSaving,
    bool isSuperAdmin,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        border: Border.all(color: AppColors.border, width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(loc.translate('landing_page_url'), style: AppTypography.h3),
          const SizedBox(height: 20),

          // Subdomain field input (Renamed to Brand Name for users)
          FormGroup(
            label: "اسم البراند (Brand Name)",
            helperText: "هذا الاسم سيظهر في رابط صفحتك: brand.mylandy.com",
            child: CustomTextField(
              controller: _subdomainController,
              hintText: 'my-brand-name',
              prefixIcon: const Icon(Icons.stars_rounded, color: AppColors.secondary),
              validator: (val) {
                if (val == null || val.isEmpty) return 'Brand name is required';
                if (val.contains('.') || val.contains(' ')) return 'No dots or spaces allowed';
                return null;
              },
            ),
          ),
          const SizedBox(height: 20),

          // Custom Domain input - Only visible to Super Admin for now
          if (isSuperAdmin) ...[
            FormGroup(
              label: loc.translate('custom_domain'),
              helperText: "Configure custom CNAME pointer to your Vercel instance",
              child: CustomTextField(
                controller: _customDomainController,
                hintText: 'www.my-brand.com',
                prefixIcon: const Icon(Icons.language_rounded, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Toggle page publication status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "نشر الصفحة (Publish Page)",
                        style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "عند التفعيل، ستكون صفحتك متاحة للجميع عبر الرابط.",
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isPublished,
                  onChanged: (val) => setState(() => _isPublished = val),
                  activeThumbColor: AppColors.secondary,
                  activeTrackColor: AppColors.secondary.withValues(alpha: 0.3),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          PrimaryButton(
            text: "حفظ التغييرات (Save Changes)",
            icon: Icons.save_rounded,
            onPressed: () => _saveConfig(cubit),
            isLoading: isSaving,
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard(LocalizationCubit loc) {
    final bool hasSubdomain = _subdomainController.text.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        border: Border.all(color: AppColors.border, width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Quick Actions", style: AppTypography.h3),
          const SizedBox(height: 20),

          // Edit Builder Link Button
          PrimaryButton(
            text: "Open Section Builder",
            icon: Icons.construction_rounded,
            onPressed: widget.onOpenBuilder,
            width: double.infinity,
          ),
          const SizedBox(height: 16),

          // Live Preview Link Button
          PrimaryButton(
            text: "Open Live Site",
            icon: Icons.open_in_new_rounded,
            isSecondary: true,
            onPressed: hasSubdomain ? _previewPage : null,
            width: double.infinity,
          ),
          const SizedBox(height: 24),
          const Divider(color: AppColors.border, height: 1.2),
          const SizedBox(height: 24),

          // Short educational hint
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded, color: AppColors.secondary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Changes made inside the Section Builder will immediately update your dynamic state mapping ('design_json'). Set the publication switch to on for live site changes to reflect.",
                  style: AppTypography.caption,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
