import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/localization/localization_cubit.dart';
import '../../controllers/builder_cubit.dart';
import '../../controllers/builder_state.dart';
import '../tabs/builder_sidebar_tabs.dart';
import '../tabs/background_picker_tab.dart';
import 'seo_settings_modal.dart';

enum BuilderOptionView { main, templates, colors, fonts, background, seo }

class BuilderOptionsModal extends StatefulWidget {
  final LocalizationCubit loc;
  final LandingPageBuilderCubit cubit;
  final BuilderLoaded state;
  final BuilderOptionView initialView;
  final VoidCallback onAddBlock;
  final VoidCallback onPublish;

  const BuilderOptionsModal({
    super.key,
    required this.loc,
    required this.cubit,
    required this.state,
    this.initialView = BuilderOptionView.main,
    required this.onAddBlock,
    required this.onPublish,
  });

  @override
  State<BuilderOptionsModal> createState() => _BuilderOptionsModalState();
}

class _BuilderOptionsModalState extends State<BuilderOptionsModal> {
  late BuilderOptionView _currentView;

  @override
  void initState() {
    super.initState();
    _currentView = widget.initialView;
  }

  void _changeView(BuilderOptionView view) {
    setState(() {
      _currentView = view;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header with back button (if not in main view)
          if (_currentView != BuilderOptionView.main)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: () => _changeView(BuilderOptionView.main),
                  ),
                  Text(
                    _getTitleForView(_currentView),
                    style: AppTypography.h3.copyWith(fontSize: 16),
                  ),
                ],
              ),
            ),

          // Content Wrapper with AnimatedSize
          Flexible(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.05, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey<BuilderOptionView>(_currentView),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: _buildCurrentView(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTitleForView(BuilderOptionView view) {
    switch (view) {
      case BuilderOptionView.templates:
        return "تغيير القالب";
      case BuilderOptionView.colors:
        return "تغيير الألوان";
      case BuilderOptionView.fonts:
        return "تغيير الخطوط";
      case BuilderOptionView.background:
        return "خلفية الصفحة";
      case BuilderOptionView.seo:
        return "إعدادات السيو";
      default:
        return "";
    }
  }

  Widget _buildCurrentView() {
    switch (_currentView) {
      case BuilderOptionView.main:
        return _buildMainOptions();
      case BuilderOptionView.templates:
        return TemplatesTab(cubit: widget.cubit, state: widget.state);
      case BuilderOptionView.colors:
        return DesignColorsTab(
          loc: widget.loc,
          cubit: widget.cubit,
          state: widget.state,
        );
      case BuilderOptionView.fonts:
        return DesignFontsTab(
          loc: widget.loc,
          cubit: widget.cubit,
          state: widget.state,
        );
      case BuilderOptionView.background:
        return BackgroundPickerTab(
          cubit: widget.cubit,
          state: widget.state,
        );
      case BuilderOptionView.seo:
        return const SeoSettingsModal();
    }
  }

  Widget _buildMainOptions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildOptionTile(
          icon: Icons.auto_awesome_rounded,
          title: "تغيير القالب",
          subtitle: "تغيير الألوان والخطوط بالكامل",
          onTap: () => _changeView(BuilderOptionView.templates),
        ),
        _buildOptionTile(
          icon: Icons.color_lens_rounded,
          title: "تغيير ألوان الصفحة",
          onTap: () => _changeView(BuilderOptionView.colors),
        ),
        _buildOptionTile(
          icon: Icons.font_download_rounded,
          title: "تغيير نوع الخط",
          onTap: () => _changeView(BuilderOptionView.fonts),
        ),
        _buildOptionTile(
          icon: Icons.image_rounded,
          title: "خلفية الصفحة",
          onTap: () => _changeView(BuilderOptionView.background),
        ),
        _buildOptionTile(
          icon: Icons.search_rounded,
          title: "إعدادات السيو SEO",
          onTap: () => _changeView(BuilderOptionView.seo),
        ),
        _buildOptionTile(
          icon: Icons.add_circle_outline_rounded,
          title: "إضافة قسم",
          onTap: () {
            Navigator.pop(context);
            widget.onAddBlock();
          },
        ),
        const Divider(color: AppColors.border, height: 32),
        _buildOptionTile(
          icon: Icons.publish_rounded,
          title: "نشر الصفحة",
          color: AppColors.secondary,
          onTap: () {
            Navigator.pop(context);
            widget.onPublish();
          },
        ),
      ],
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: (color ?? AppColors.textPrimary).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color ?? AppColors.textPrimary, size: 24),
      ),
      title: Text(
        title,
        style: AppTypography.bodyMedium.copyWith(
          color: color ?? AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            )
          : null,
      onTap: onTap,
    );
  }
}
