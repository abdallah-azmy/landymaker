import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:landymaker/features/builder/controllers/builder_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/localization_cubit.dart';
import '../../../public_viewer/widgets/section_renderer.dart';
import '../../controllers/builder_state.dart';

class BuilderCanvas extends StatelessWidget {
  final bool isMobile;
  final bool isMobilePreview;
  final BuilderLoaded state;
  final LocalizationCubit loc;
  final Function(int) onBlockTapped;

  const BuilderCanvas({
    super.key,
    required this.isMobile,
    required this.isMobilePreview,
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
        return Stack(
          children: [
            Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: isMobile
                    ? constraints.maxWidth
                    : (isMobilePreview
                          ? 375
                          : constraints.maxWidth.clamp(0.0, 1000.0)),
                height: isMobile ? constraints.maxHeight : null,
                margin: isMobile
                    ? EdgeInsets.zero
                    : const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                decoration: BoxDecoration(
                  color: state.theme.background,
                  borderRadius: isMobile
                      ? BorderRadius.zero
                      : BorderRadius.circular(12),
                  boxShadow: isMobile
                      ? []
                      : [
                          const BoxShadow(
                            color: Colors.black26,
                            blurRadius: 36,
                          ),
                        ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    if (!isMobile) _buildBrowserChrome(),
                    Expanded(
                      child: Container(
                        color: state.theme.background,
                        child: SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: isMobile
                                  ? constraints.maxHeight
                                  : (constraints.maxHeight - 36),
                            ),
                            child: Directionality(
                              textDirection: loc.isRtl
                                  ? TextDirection.rtl
                                  : TextDirection.ltr,
                              child: SectionRenderer(
                                key: ValueKey(
                                  blocksList.hashCode ^ state.theme.hashCode,
                                ),
                                blocks: blocksList,
                                pageId: state.pageId ?? 'preview',
                                theme: state.theme,
                                onBlockTapped: (index) {
                                  context
                                      .read<LandingPageBuilderCubit>()
                                      .selectSection(index);
                                  onBlockTapped(index);
                                },
                                isBuilder: true,
                                selectedIndex: state.focusedSectionIndex,
                              ),
                            ),
                          ),
                        ),
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
