import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/custom_network_image.dart';
import '../../../services/tenant_routing_service.dart';
import '../../auth/controllers/auth_cubit.dart';
import '../../auth/controllers/auth_state.dart';
import '../../builder/registries/template_registry.dart';

class TemplatePickerScreen extends StatelessWidget {
  const TemplatePickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isRtl = context.isRtl;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            isRtl ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => context.go('/'),
        ),
        title: Text(
          context.translate('choose_template'),
          style: AppTypography.h3.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isMobile = constraints.maxWidth < 600;
          final int crossAxisCount = constraints.maxWidth > 1200
              ? 4
              : (constraints.maxWidth > 800 ? 3 : (isMobile ? 1 : 2));

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  context.translate('template_warning'),
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 40,
                    vertical: 24,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: TemplateRegistry.availableTemplates.length,
                  itemBuilder: (context, index) {
                    final template = TemplateRegistry.availableTemplates[index];
                    return _TemplateCard(template: template);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TemplateCard extends StatefulWidget {
  final TemplateMetadata template;
  const _TemplateCard({required this.template});

  @override
  State<_TemplateCard> createState() => _TemplateCardState();
}

class _TemplateCardState extends State<_TemplateCard> {
  bool _isHovered = false;

  void _onTemplateSelected(BuildContext context) {
    final authState = context.read<AuthCubit>().state;

    // Store selected template ID globally
    TenantRoutingService.pendingTemplateId = widget.template.id;

    if (authState is Authenticated) {
      // If logged in, go to dashboard to create a new page with this template
      context.go('/dashboard');
    } else {
      // If not logged in, go to register/login
      context.go('/register');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered ? AppColors.secondary : AppColors.border,
            width: 2,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: AppColors.secondary.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                child: Stack(
                  children: [
                    CustomNetworkImage(
                      imageUrl: widget.template.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                    if (_isHovered)
                      Container(
                        color: Colors.black.withValues(alpha: 0.4),
                        child: Center(
                          child: ElevatedButton(
                            onPressed: () => _onTemplateSelected(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(context.translate('apply')),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.template.name,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.template.description,
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
