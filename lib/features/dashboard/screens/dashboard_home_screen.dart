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
// Removed sl/AuthService imports to maintain architectural boundary
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

    cubit.updateSettings(
      subdomain: _subdomainController.text.trim().toLowerCase(),
      customDomain: _customDomainController.text.trim().isEmpty ? '' : _customDomainController.text.trim().toLowerCase(),
      isPublished: _isPublished,
    );

    cubit.saveForCurrentUser();
  }

  void _previewPage() {
    if (_subdomainController.text.isEmpty) return;

    final subdomain = _subdomainController.text.trim().toLowerCase();
    // In mock mode or dev we append ?subdomain=xxx
    final baseUrl = Uri.base.origin;
    final testUrl = "$baseUrl/?tenant=$subdomain";

    launchUrl(Uri.parse(testUrl));
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
    final successMessage = loadedState.successMessage;
    final errorMessage = loadedState.errorMessage;

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
                    _buildDomainSettingsCard(loc, builderCubit, isSaving, successMessage, errorMessage),
                    const SizedBox(height: 24),
                    _buildQuickActionsCard(loc),
                  ],
                ),
                desktop: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _buildDomainSettingsCard(loc, builderCubit, isSaving, successMessage, errorMessage)),
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
    String? successMessage,
    String? errorMessage,
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

          // Subdomain field input
          FormGroup(
            label: loc.translate('subdomain'),
            helperText: "Format: subdomain.mylandy.com",
            child: CustomTextField(
              controller: _subdomainController,
              hintText: 'my-brand-name',
              prefixIcon: const Icon(Icons.link_rounded, color: AppColors.textSecondary),
              validator: (val) {
                if (val == null || val.isEmpty) return 'Subdomain is required';
                if (val.contains('.') || val.contains(' ')) return 'No dots or spaces allowed';
                return null;
              },
            ),
          ),
          const SizedBox(height: 20),

          // Custom Domain input
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

          // Toggle page publication status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Publish Page", style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text("Make this landing page accessible online.", style: AppTypography.caption),
                ],
              ),
              Switch(
                value: _isPublished,
                onChanged: (val) => setState(() => _isPublished = val),
                activeColor: AppColors.secondary,
                activeTrackColor: AppColors.secondary.withValues(alpha: 0.3),
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (errorMessage != null) ...[
            Text(errorMessage, style: AppTypography.bodyMedium.copyWith(color: AppColors.dangerRed)),
            const SizedBox(height: 16),
          ],
          if (successMessage != null) ...[
            Text(successMessage, style: AppTypography.bodyMedium.copyWith(color: AppColors.activeGreen)),
            const SizedBox(height: 16),
          ],

          PrimaryButton(
            text: loc.translate('save'),
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
