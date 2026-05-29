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

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      width: double.infinity,
      child: direction == 'row'
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: elements.map((e) => _buildElement(context, e)).toList(),
            )
          : Column(
              children: elements.map((e) => _buildElement(context, e)).toList(),
            ),
    );
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
