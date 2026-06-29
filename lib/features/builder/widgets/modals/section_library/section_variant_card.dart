part of '../section_library_modal.dart';

class _SectionVariantCard extends StatefulWidget {
  final _SectionDefinition section;
  final LandingPageBuilderCubit cubit;
  final int index;

  const _SectionVariantCard({
    super.key,
    required this.section,
    required this.cubit,
    required this.index,
  });

  @override
  State<_SectionVariantCard> createState() => _SectionVariantCardState();
}

class _SectionVariantCardState extends State<_SectionVariantCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacityAnimation;
  late final Animation<Offset> _slideAnimation;
  int _selectedVariantIndex = 0;
  bool _isHovered = false;

  _SectionVariant get _selectedVariant =>
      widget.section.variants[_selectedVariantIndex];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
        );
    Future.delayed(Duration(milliseconds: widget.index * 24), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Opacity(
        opacity: _opacityAnimation.value,
        child: Transform.translate(
          offset: _slideAnimation.value * 40,
          child: child,
        ),
      ),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _isHovered ? Theme.of(context).colorScheme.surface.withValues(alpha: 0.8) : Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _isHovered
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.65)
                  : Theme.of(context).colorScheme.outlineVariant,
              width: _isHovered ? 1.6 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.08),
                blurRadius: _isHovered ? 18 : 10,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.section.icon,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.section.name,
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          widget.section.desc,
                          style: AppTypography.caption.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: _DualMiniPreview(
                  variant: _selectedVariant,
                  accent: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: 10),
              Text(
                _selectedVariant.description,
                style: AppTypography.caption.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.25,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: List.generate(widget.section.variants.length, (index) {
                  final variant = widget.section.variants[index];
                  final isSelected = index == _selectedVariantIndex;
                  return InkWell(
                    onTap: () => setState(() => _selectedVariantIndex = index),
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : Theme.of(context).colorScheme.primary.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Text(
                        variant.name,
                        style: AppTypography.caption.copyWith(
                          color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 38,
                child: ElevatedButton.icon(
                  onPressed: () {
                    widget.cubit.addBlock(
                      widget.section.type,
                      presetOverrides: _selectedVariant.overrides,
                    );
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.add_rounded, size: 18),
                  label: Text("إضافة ${_selectedVariant.name}"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
