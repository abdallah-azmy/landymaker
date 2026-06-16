import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class LayoutOptionCard extends StatelessWidget {
  final String name;
  final String description;
  final String layoutStyle;
  final bool isSelected;
  final VoidCallback onTap;

  const LayoutOptionCard({
    required this.name,
    required this.description,
    required this.layoutStyle,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.secondary.withValues(alpha: 0.1)
                  : AppColors.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.secondary : AppColors.border,
                width: isSelected ? 2 : 1,
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 80,
                  width: double.infinity,
                  child: _LayoutMiniPreview(layoutStyle: layoutStyle),
                ),
                const SizedBox(height: 8),
                Text(
                  name,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppColors.secondary : Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LayoutMiniPreview extends StatelessWidget {
  final String layoutStyle;

  const _LayoutMiniPreview({required this.layoutStyle});

  Color get _imageColor => AppColors.secondary.withValues(alpha: 0.6);
  Color get _textColor => AppColors.textSecondary.withValues(alpha: 0.5);
  Color get _buttonColor => const Color(0xFF22C55E).withValues(alpha: 0.6);
  Color get _headingColor => Colors.white.withValues(alpha: 0.5);
  Color get _bgColor => AppColors.background;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        color: _bgColor,
        child: _buildPreview(),
      ),
    );
  }

  Widget _buildPreview() {
    switch (layoutStyle) {
      case 'split':
        return Row(
          children: [
            Expanded(child: Container(color: _imageColor, margin: const EdgeInsets.all(2))),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _block(_headingColor, height: 8, width: 0.7),
                  const SizedBox(height: 4),
                  _block(_textColor, height: 6, width: 0.9),
                  const SizedBox(height: 4),
                  _block(_buttonColor, height: 6, width: 0.5),
                ],
              ),
            ),
          ],
        );

      case 'centered':
      case 'gradientOnly':
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _block(_headingColor, height: 8, width: 0.6),
            const SizedBox(height: 4),
            _block(_textColor, height: 6, width: 0.8),
            const SizedBox(height: 4),
            _block(_buttonColor, height: 6, width: 0.4),
          ],
        );

      case 'glass':
        return Stack(
          children: [
            Container(color: _imageColor.withValues(alpha: 0.3)),
            Center(
              child: Container(
                height: 50,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: AppColors.cardBg.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _block(_headingColor, height: 6, width: 0.6),
                    const SizedBox(height: 3),
                    _block(_buttonColor, height: 6, width: 0.4),
                  ],
                ),
              ),
            ),
          ],
        );

      case 'fullWidthBg':
      case 'fullWidthImage':
        return Stack(
          children: [
            Container(color: _imageColor),
            if (layoutStyle == 'fullWidthImage')
              Container(color: Colors.black.withValues(alpha: 0.35)),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _block(_headingColor, height: 8, width: 0.6),
                  const SizedBox(height: 4),
                  _block(_textColor, height: 6, width: 0.8),
                  const SizedBox(height: 4),
                  _block(_buttonColor, height: 6, width: 0.4),
                ],
              ),
            ),
          ],
        );

      case 'minimal':
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _block(_headingColor, height: 8, width: 0.5),
            const SizedBox(height: 4),
            _block(_textColor, height: 6, width: 0.7),
          ],
        );

      case 'grid':
      case 'threeCols':
        return Row(
          children: List.generate(
            3,
            (_) => Expanded(
              child: Container(
                margin: const EdgeInsets.all(2),
                color: _textColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _block(_headingColor, height: 6, width: 0.6),
                    const SizedBox(height: 3),
                    _block(_textColor, height: 4, width: 0.8),
                  ],
                ),
              ),
            ),
          ),
        );

      case 'bento':
        return Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(flex: 2, child: Container(margin: const EdgeInsets.all(2), color: _imageColor)),
                  Expanded(flex: 1, child: Container(margin: const EdgeInsets.all(2), color: _textColor)),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(flex: 1, child: Container(margin: const EdgeInsets.all(2), color: _textColor)),
                  Expanded(flex: 2, child: Container(margin: const EdgeInsets.all(2), color: _imageColor)),
                ],
              ),
            ),
          ],
        );

      case 'iconLeft':
        return Row(
          children: [
            Container(width: 24, height: 24, margin: const EdgeInsets.all(4), decoration: BoxDecoration(color: _imageColor, borderRadius: BorderRadius.circular(4))),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _block(_headingColor, height: 8, width: 0.8),
                  const SizedBox(height: 3),
                  _block(_textColor, height: 6, width: 0.9),
                ],
              ),
            ),
          ],
        );

      case 'tabs':
        return Column(
          children: [
            Row(
              children: List.generate(3, (i) => Expanded(child: Container(height: 8, margin: const EdgeInsets.all(1), decoration: BoxDecoration(color: i == 0 ? _buttonColor : _textColor, borderRadius: BorderRadius.circular(2))))),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(2),
                color: _textColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _block(_headingColor, height: 6, width: 0.6),
                    _block(_textColor, height: 4, width: 0.8),
                  ],
                ),
              ),
            ),
          ],
        );

      case 'carousel':
        return Row(
          children: [
            Expanded(flex: 3, child: Container(margin: const EdgeInsets.all(2), color: _imageColor)),
            Expanded(flex: 2, child: Container(margin: const EdgeInsets.all(2), color: _textColor)),
          ],
        );

      case 'masonry':
        return Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Expanded(flex: 2, child: Container(margin: const EdgeInsets.all(1), color: _imageColor)),
                  Expanded(flex: 1, child: Container(margin: const EdgeInsets.all(1), color: _textColor)),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Expanded(flex: 1, child: Container(margin: const EdgeInsets.all(1), color: _textColor)),
                  Expanded(flex: 2, child: Container(margin: const EdgeInsets.all(1), color: _imageColor)),
                ],
              ),
            ),
          ],
        );

      case 'list':
        return Column(
          children: List.generate(
            4,
            (i) => Container(
              height: 12,
              margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
              decoration: BoxDecoration(
                color: _textColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        );

      case 'cards':
        return Column(
          children: List.generate(
            2,
            (_) => Expanded(
              child: Container(
                margin: const EdgeInsets.all(3),
                color: _textColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _block(_headingColor, height: 6, width: 0.5),
                    _block(_textColor, height: 4, width: 0.7),
                  ],
                ),
              ),
            ),
          ),
        );

      case 'withIcons':
        return Row(
          children: List.generate(
            3,
            (_) => Expanded(
              child: Container(
                margin: const EdgeInsets.all(2),
                color: _textColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 12, height: 12, decoration: BoxDecoration(color: _imageColor, borderRadius: BorderRadius.circular(6))),
                    const SizedBox(height: 2),
                    _block(_headingColor, height: 4, width: 0.6),
                  ],
                ),
              ),
            ),
          ),
        );

      case 'progressBars':
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            3,
            (i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _block(_headingColor, height: 4, width: 0.3),
                  const SizedBox(height: 2),
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: _textColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: 0.4 + (i * 0.2),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _buttonColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

      case 'imageBackground':
        return Stack(
          children: [
            Container(color: _imageColor),
            Center(
              child: Container(
                height: 40,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                color: AppColors.cardBg.withValues(alpha: 0.7),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _block(_headingColor, height: 6, width: 0.5),
                    _block(_buttonColor, height: 6, width: 0.3),
                  ],
                ),
              ),
            ),
          ],
        );

      default:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _block(_headingColor, height: 8, width: 0.6),
            _block(_textColor, height: 6, width: 0.8),
          ],
        );
    }
  }

  Widget _block(Color color, {double height = 6, double width = 0.5}) {
    return FractionallySizedBox(
      widthFactor: width,
      child: Container(
        height: height,
        margin: const EdgeInsets.symmetric(vertical: 1),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
