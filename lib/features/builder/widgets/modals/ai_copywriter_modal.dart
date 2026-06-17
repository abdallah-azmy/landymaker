import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/atoms/primary_button.dart';
import '../../controllers/ai_copywriter_cubit.dart';

class AiCopywriterModal extends StatefulWidget {
  final String fieldType;
  final Function(String) onApply;
  final Map<String, dynamic> contextData;

  const AiCopywriterModal({
    super.key,
    required this.fieldType,
    required this.onApply,
    required this.contextData,
  });

  @override
  State<AiCopywriterModal> createState() => _AiCopywriterModalState();
}

class _AiCopywriterModalState extends State<AiCopywriterModal> {
  String _tone = 'Sales-focused';
  String _length = 'Short';

  @override
  void initState() {
    super.initState();
    _generate();
  }

  void _generate() {
    context.read<AICopywriterCubit>().generateCopy(
      fieldType: widget.fieldType,
      context: widget.contextData,
      tone: _tone,
      length: _length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("كاتب المحتوى الذكي", style: AppTypography.h3),
              IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.close)),
            ],
          ),
          SizedBox(height: 16),
          _buildSettings(),
          Divider(height: 32),
          Expanded(
            child: BlocBuilder<AICopywriterCubit, AICopywriterState>(
              builder: (context, state) {
                if (state is AICopywriterLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is AICopywriterFailure) {
                  return Center(child: Text("خطأ: ${state.error}"));
                }
                if (state is AICopywriterSuccess) {
                  return ListView.builder(
                    itemCount: state.variations.length,
                    itemBuilder: (context, index) {
                      final text = state.variations[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(text),
                          trailing: IconButton(
                            icon: const Icon(Icons.check_circle_rounded, color: Colors.green),
                            onPressed: () {
                              widget.onApply(text);
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      );
                    },
                  );
                }
                return SizedBox.shrink();
              },
            ),
          ),
          SizedBox(height: 16),
          PrimaryButton(
            text: "إعادة التوليد",
            icon: Icons.refresh_rounded,
            onPressed: _generate,
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  Widget _buildSettings() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _tone,
            decoration: const InputDecoration(labelText: 'نبرة الصوت'),
            items: ['Professional', 'Friendly', 'Sales-focused', 'Minimalist']
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (val) => setState(() => _tone = val!),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _length,
            decoration: const InputDecoration(labelText: 'الطول'),
            items: ['Short', 'Medium', 'Detailed']
                .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                .toList(),
            onChanged: (val) => setState(() => _length = val!),
          ),
        ),
      ],
    );
  }
}
