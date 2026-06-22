import 'package:flutter/material.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/atoms/cube_spinner.dart';

class AIChatInput extends StatefulWidget {
  final Function(String) onSend;
  final bool isLoading;
  final Function(String type)? onImageUpload;

  const AIChatInput({
    super.key,
    required this.onSend,
    this.isLoading = false,
    this.onImageUpload,
  });

  @override
  State<AIChatInput> createState() => _AIChatInputState();
}

class _AIChatInputState extends State<AIChatInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final List<String> _examplePrompts = [
    "أنشئ صفحة هبوط احترافية لشركة برمجيات (SaaS) مع ثيم عصري وأقسام مميزات وأسعار",
    "صمم متجر إلكتروني مع قسم منتجات وسلة شراء وثيم جذاب للتجارة الإلكترونية",
    "ولّد صفحة هبوط عالية التحويل لوكالة عقارية فاخرة مع ثيم داكن بريميوم ومعرض صور",
    "حوّل صفحتي إلى تصميم مظلم (Dark Mode) مع ألوان ذهبية وأنيميشن انزلاق للأقسام",
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
        if (widget.onImageUpload != null) _buildUploadButtons(),
        SizedBox(height: 12),
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
                style: AppTypography.caption.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
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

  Widget _buildUploadButtons() {
    if (widget.onImageUpload == null) return SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 12, right: 12),
      child: Row(
        children: [
          _UploadChip(
            icon: Icons.badge_rounded,
            label: "شعار",
            onTap: () => widget.onImageUpload!('logo'),
          ),
          SizedBox(width: 8),
          _UploadChip(
            icon: Icons.image_rounded,
            label: "صور",
            onTap: () => widget.onImageUpload!('asset'),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
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
                hintStyle: AppTypography.bodySmall.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onSubmitted: (_) => _handleSend(),
            ),
          ),
          SizedBox(width: 8),
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
          color: widget.isLoading ? Theme.of(context).colorScheme.outlineVariant : Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: widget.isLoading
            ? const CubeSpinner(size: 20, color: Colors.white)
            : Icon(
                Icons.send_rounded,
                color: Colors.black,
                size: 20,
              ),
      ),
    );
  }
}

class _UploadChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _UploadChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
      label: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
      ),
      onPressed: onTap,
    );
  }
}
