import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../builder/models/landing_page_theme.dart';
import '../../builder/controllers/builder_cubit.dart';
import '../../builder/controllers/builder_state.dart';
import '../../builder/widgets/atoms/dynamic_styled_text.dart';
import '../../builder/widgets/atoms/dynamic_styled_image.dart';

class BasicSectionRenderer extends StatelessWidget {
  final Map<String, dynamic> sectionData;
  final LandingPageTheme theme;
  final int sectionIndex;

  const BasicSectionRenderer({
    super.key,
    required this.sectionData,
    required this.theme,
    required this.sectionIndex,
  });

  @override
  Widget build(BuildContext context) {
    final List elements = sectionData['elements'] ?? [];
    final String direction = sectionData['layout_direction'] ?? 'column';
    final String mainAlign = sectionData['main_axis_alignment'] ?? 'center';
    final String crossAlign = sectionData['cross_axis_alignment'] ?? 'center';
    final double spacing = (sectionData['spacing'] ?? 16.0).toDouble();

    final List<Widget> elementWidgets = elements.map((e) => _buildElement(context, e)).toList();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      width: double.infinity,
      child: direction == 'row'
          ? Row(
              mainAxisAlignment: _parseMainAlign(mainAlign),
              crossAxisAlignment: _parseCrossAlign(crossAlign),
              children: _addSpacing(elementWidgets, spacing, true),
            )
          : Column(
              mainAxisAlignment: _parseMainAlign(mainAlign),
              crossAxisAlignment: _parseCrossAlign(crossAlign),
              children: _addSpacing(elementWidgets, spacing, false),
            ),
    );
  }

  MainAxisAlignment _parseMainAlign(String value) {
    switch (value) {
      case 'start': return MainAxisAlignment.start;
      case 'end': return MainAxisAlignment.end;
      case 'spaceBetween': return MainAxisAlignment.spaceBetween;
      default: return MainAxisAlignment.center;
    }
  }

  CrossAxisAlignment _parseCrossAlign(String value) {
    switch (value) {
      case 'start': return CrossAxisAlignment.start;
      case 'end': return CrossAxisAlignment.end;
      case 'stretch': return CrossAxisAlignment.stretch;
      default: return CrossAxisAlignment.center;
    }
  }

  List<Widget> _addSpacing(List<Widget> widgets, double spacing, bool isRow) {
    if (widgets.isEmpty) return [];
    List<Widget> result = [];
    for (int i = 0; i < widgets.length; i++) {
      result.add(widgets[i]);
      if (i < widgets.length - 1) {
        result.add(isRow ? SizedBox(width: spacing) : SizedBox(height: spacing));
      }
    }
    return result;
  }

  Widget _buildElement(BuildContext context, Map<String, dynamic> element) {
    final String type = element['type'] ?? 'text';
    final String id = element['id'] ?? '';
    
    return GestureDetector(
      onLongPress: () {
        context.read<LandingPageBuilderCubit>().focusElement(sectionIndex, id);
      },
      child: BlocBuilder<LandingPageBuilderCubit, BuilderState>(
        buildWhen: (prev, curr) => curr is BuilderLoaded && curr.focusedElementId == id,
        builder: (context, state) {
          final isFocused = state is BuilderLoaded && state.focusedElementId == id;
          
          return Container(
            decoration: BoxDecoration(
              border: isFocused ? Border.all(color: Colors.blue, width: 2) : null,
            ),
            child: type == 'text'
                ? DynamicStyledText(
                    text: element['content'] ?? 'نص جديد',
                    styleOverrides: element['style_overrides'] ?? {},
                    theme: theme,
                  )
                : DynamicStyledImage(
                    imageUrl: element['content'] ?? '',
                    styleOverrides: element['style_overrides'] ?? {},
                  ),
          );
        },
      ),
    );
  }
}
