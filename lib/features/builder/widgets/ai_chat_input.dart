import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class AIChatInput extends StatefulWidget {
  final Function(String) onSend;
  final bool isLoading;

  const AIChatInput({
    super.key,
    required this.onSend,
    this.isLoading = false,
  });

  @override
  State<AIChatInput> createState() => _AIChatInputState();
}

class _AIChatInputState extends State<AIChatInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final List<String> _examplePrompts = [
    "أنشئ صفحة لنادي رياضي",
    "أملك عيادة أسنان",
    "اجعل قسم الهيرو باللون الأسود",
    "استبدل الصور بصور أطباء",
  ];

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSend() {
    if (_controller.text.trim().isEmpty || widget.isLoading) return;
    widget.onSend(_controller.text.trim());
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_controller.text.isEmpty && !widget.isLoading) _buildExamplePrompts(),
        const SizedBox(height: 12),
        _buildInputField(),
      ],
    );
  }

  Widget _buildExamplePrompts() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: _examplePrompts.map((prompt) {
          return Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: ActionChip(
              label: Text(
                prompt,
                style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
              ),
              backgroundColor: AppColors.cardBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.border),
              ),
              onPressed: () {
                _controller.text = prompt;
                _focusNode.requestFocus();
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              maxLines: null,
              style: AppTypography.bodyMedium,
              decoration: InputDecoration(
                hintText: "كيف يمكنني مساعدتك في بناء صفحتك؟",
                hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onSubmitted: (_) => _handleSend(),
            ),
          ),
          const SizedBox(width: 8),
          _buildSendButton(),
        ],
      ),
    );
  }

  Widget _buildSendButton() {
    return InkWell(
      onTap: _handleSend,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: widget.isLoading ? AppColors.border : AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: widget.isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(
                Icons.send_rounded,
                color: Colors.black,
                size: 20,
              ),
      ),
    );
  }
}
