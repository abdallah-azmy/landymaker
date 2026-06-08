import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:landymaker/features/builder/controllers/builder_cubit.dart';
import 'package:landymaker/features/builder/models/preview_mode.dart';
import '../../../../core/localization/localization_cubit.dart';
import '../../../public_viewer/widgets/section_renderer.dart';
import '../../../public_viewer/widgets/global/sticky_cta_bar.dart';
import '../../controllers/builder_state.dart';

class BuilderCanvas extends StatelessWidget {
  final bool isMobile;
  final PreviewMode previewMode;
  final BuilderLoaded state;
  final LocalizationCubit loc;
  final Function(int) onBlockTapped;

  const BuilderCanvas({
    super.key,
    required this.isMobile,
    required this.previewMode,
    required this.state,
    required this.loc,
    required this.onBlockTapped,
  });

  @override
  Widget build(BuildContext context) {
    final blocksList = (state.designMap['blocks'] as List? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        double canvasWidth;
        switch (previewMode) {
          case PreviewMode.mobile:
            canvasWidth = 375;
            break;
          case PreviewMode.tablet:
            canvasWidth = 768;
            break;
          case PreviewMode.desktop:
            canvasWidth = constraints.maxWidth.clamp(0.0, 1000.0);
            break;
          case PreviewMode.fullscreen:
            canvasWidth = constraints.maxWidth;
            break;
        }

        Color? globalBgColor;
        final globalBgColorHex = state.theme.globalBgColorHex;
        if (globalBgColorHex != null && globalBgColorHex.isNotEmpty) {
           try {
             final hexStr = globalBgColorHex.replaceAll('#', '');
             if (hexStr.length == 6) globalBgColor = Color(int.parse('FF$hexStr', radix: 16));
             else if (hexStr.length == 8) globalBgColor = Color(int.parse(hexStr, radix: 16));
           } catch (_) {}
        }
        final globalBgImage = state.theme.globalBgImageUrl;
        final globalFont = state.theme.defaultFont ?? 'Cairo';
        
        final bool isInteractiveBuilder = previewMode != PreviewMode.fullscreen;

        Widget content = Directionality(
          textDirection: loc.isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: SectionRenderer(
            key: ValueKey(blocksList.hashCode ^ state.theme.hashCode),
            blocks: blocksList,
            pageId: state.pageId ?? 'preview',
            theme: state.theme,
            onBlockTapped: isInteractiveBuilder ? (index) {
              context.read<LandingPageBuilderCubit>().selectSection(index);
              onBlockTapped(index);
            } : null,
            isBuilder: isInteractiveBuilder,
            selectedIndex: state.focusedSectionIndex,
          ),
        );

        try {
          content = DefaultTextStyle(
            style: GoogleFonts.getFont(globalFont).copyWith(color: state.theme.textPrimary),
            child: Theme(
              data: Theme.of(context).copyWith(
                textTheme: GoogleFonts.getTextTheme(globalFont, Theme.of(context).textTheme),
              ),
              child: content,
            ),
          );
        } catch (_) {}

        return Stack(
          children: [
            Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: isMobile ? constraints.maxWidth : canvasWidth,
                height: isMobile ? constraints.maxHeight : null,
                margin: isMobile
                    ? EdgeInsets.zero
                    : const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                decoration: BoxDecoration(
                  color: globalBgColor ?? state.theme.background,
                  image: (globalBgImage != null && globalBgImage.isNotEmpty)
                      ? DecorationImage(image: NetworkImage(globalBgImage), fit: BoxFit.cover)
                      : null,
                  borderRadius: isMobile ? BorderRadius.zero : BorderRadius.circular(12),
                  boxShadow: isMobile ? [] : [const BoxShadow(color: Colors.black26, blurRadius: 36)],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    if (!isMobile) _buildBrowserChrome(),
                    Expanded(
                      child: Stack(
                        children: [
                          SingleChildScrollView(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: isMobile ? constraints.maxHeight : (constraints.maxHeight - 36),
                              ),
                              child: content,
                            ),
                          ),
                          if (state.designMap['sticky_cta']?['is_enabled'] == true)
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: StickyCtaBar(
                                config: Map<String, dynamic>.from(state.designMap['sticky_cta']),
                                lang: loc.isRtl ? 'ar' : 'en',
                                primaryColor: state.theme.primary,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBrowserChrome() {
    return Container(
      height: 36,
      color: const Color(0xFFE2E8F0),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Row(
            children: List.generate(
              3,
              (i) => Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == 0
                      ? Colors.red
                      : (i == 1 ? Colors.orange : Colors.green),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                "https://landymaker.com/${state.subdomain.isEmpty ? 'your-brand' : state.subdomain}",
                style: const TextStyle(fontSize: 9, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
