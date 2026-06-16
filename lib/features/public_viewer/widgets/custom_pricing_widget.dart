import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/responsive/responsive_utils.dart';
import '../../../core/widgets/section_background.dart';
import '../../../core/services/event_analytics_service.dart';
import '../../../core/services/action_handler_service.dart';
import '../../../core/responsive/card_layout_mode.dart';
import '../../builder/models/landing_page_theme.dart';
import '../models/pricing_models.dart';
import '../utils/pricing_parser.dart';
import '../utils/pricing_calculator.dart';

/// ======================================================
/// FEATURE: Custom Pricing Widget
/// PURPOSE: Displays pricing plans with a monthly/yearly toggle.
/// ARCHITECTURE: 
/// - State Hoisting: [_activePeriodKey] is managed in [CustomPricingWidget] state.
/// - Layout Delegation: Renders [_DesktopPricingLayout] or [_MobilePricingLayout]
///   based on screen width.
/// ======================================================
class CustomPricingWidget extends StatefulWidget {
  final Map<String, dynamic> block;
  final LandingPageTheme? theme;
  final String? bgImageUrl;
  final String? bgOverlayColor;
  final double? bgOverlayOpacity;
  final double? bgBlur;
  final String pageId;
  final String lang;
  final int variant;

  const CustomPricingWidget({
    super.key,
    required this.block,
    required this.pageId,
    this.theme,
    this.bgImageUrl,
    this.bgOverlayColor,
    this.bgOverlayOpacity,
    this.bgBlur,
    this.lang = 'ar',
    this.variant = 0,
  });

  @override
  State<CustomPricingWidget> createState() => _CustomPricingWidgetState();
}

class _CustomPricingWidgetState extends State<CustomPricingWidget> {
  late PricingBlockModel _model;
  String _activePeriodKey = 'monthly';

  @override
  void initState() {
    super.initState();
    _parseModel();
  }

  @override
  void didUpdateWidget(covariant CustomPricingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.block != widget.block || oldWidget.lang != widget.lang) {
      _parseModel();
    }
  }

  void _parseModel() {
    _model = PricingParser.parse(widget.block, widget.lang);
    if (_model.hasToggle && _model.toggleLabels.isNotEmpty) {
      if (!_model.toggleLabels.containsKey(_activePeriodKey)) {
        _activePeriodKey = _model.toggleLabels.keys.first;
      }
    }
  }

  CardLayoutMode get _layoutMode {
    final raw = widget.block['card_layout_mode'];
    if (raw == null) return CardLayoutMode.equal;
    return CardLayoutModeExt.fromString(raw);
  }

  String get _layoutStyle => widget.block['layout_style'] as String? ?? '';

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.theme?.primary ?? AppColors.primary;
    final secondaryColor = widget.theme?.secondary ?? AppColors.secondary;
    final textColor = widget.theme?.textPrimary ?? Theme.of(context).colorScheme.onSurface;
    final subTextColor = widget.theme?.textSecondary ?? Theme.of(context).colorScheme.onSurfaceVariant;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 768;
        final double verticalPadding = isMobile ? 40 : 80;

        final props = _PricingProps(
          model: _model,
          activePeriodKey: _activePeriodKey,
          onPeriodChanged: (key) => setState(() => _activePeriodKey = key),
          primaryColor: primaryColor,
          secondaryColor: secondaryColor,
          textColor: textColor,
          subTextColor: subTextColor,
          isMobile: isMobile,
          layoutStyle: _layoutStyle,
          layoutMode: _layoutMode,
          variant: widget.variant,
          pageId: widget.pageId,
          lang: widget.lang,
          theme: widget.theme,
        );

        return SectionBackground(
          bgImageUrl: widget.bgImageUrl,
          bgOverlayColor: widget.bgOverlayColor,
          bgOverlayOpacity: widget.bgOverlayOpacity,
          bgBlur: widget.bgBlur,
          theme: widget.theme,
          padding: EdgeInsetsDirectional.symmetric(vertical: verticalPadding, horizontal: 24),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: isMobile ? _MobilePricingLayout(props: props) : _DesktopPricingLayout(props: props),
            ),
          ),
        );
      },
    );
  }
}

/// Data class for Pricing properties.
class _PricingProps {
  final PricingBlockModel model;
  final String activePeriodKey;
  final Function(String) onPeriodChanged;
  final Color primaryColor;
  final Color secondaryColor;
  final Color textColor;
  final Color subTextColor;
  final bool isMobile;
  final String layoutStyle;
  final CardLayoutMode layoutMode;
  final int variant;
  final String pageId;
  final String lang;
  final LandingPageTheme? theme;

  const _PricingProps({
    required this.model,
    required this.activePeriodKey,
    required this.onPeriodChanged,
    required this.primaryColor,
    required this.secondaryColor,
    required this.textColor,
    required this.subTextColor,
    required this.isMobile,
    required this.layoutStyle,
    required this.layoutMode,
    required this.variant,
    required this.pageId,
    required this.lang,
    this.theme,
  });
}

/// Desktop version of the Pricing layout.
class _DesktopPricingLayout extends StatelessWidget {
  final _PricingProps props;
  const _DesktopPricingLayout({required this.props});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PricingHeader(props: props),
        if (props.model.hasToggle && props.model.toggleLabels.length > 1) ...[
          SizedBox(height: 32),
          _PricingToggle(props: props),
        ],
        SizedBox(height: 64),
        _PricingContent(props: props),
      ],
    );
  }
}

/// Mobile version of the Pricing layout.
class _MobilePricingLayout extends StatelessWidget {
  final _PricingProps props;
  const _MobilePricingLayout({required this.props});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PricingHeader(props: props),
        if (props.model.hasToggle && props.model.toggleLabels.length > 1) ...[
          SizedBox(height: 32),
          _PricingToggle(props: props),
        ],
        SizedBox(height: 32),
        _PricingContent(props: props),
      ],
    );
  }
}

/// Shared Pricing Header.
class _PricingHeader extends StatelessWidget {
  final _PricingProps props;
  const _PricingHeader({required this.props});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          props.model.title,
          style: AppTypography.h2.copyWith(color: props.textColor, fontSize: props.isMobile ? 24 : 32),
          textAlign: TextAlign.center,
        ),
        if (props.model.subtitle.isNotEmpty) ...[
          SizedBox(height: 16),
          Text(
            props.model.subtitle,
            style: AppTypography.bodyLarge.copyWith(color: props.subTextColor, fontSize: props.isMobile ? 16 : 18),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// Shared Pricing Toggle.
class _PricingToggle extends StatelessWidget {
  final _PricingProps props;
  const _PricingToggle({required this.props});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(30)),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: props.model.toggleLabels.entries.map((entry) {
          final isSelected = entry.key == props.activePeriodKey;
          return GestureDetector(
            onTap: () => props.onPeriodChanged(entry.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? props.primaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(26),
              ),
              child: Text(
                entry.value,
                style: TextStyle(
                  color: isSelected ? Colors.white : props.textColor,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Shared Pricing Content (Cards or Table).
class _PricingContent extends StatelessWidget {
  final _PricingProps props;
  const _PricingContent({required this.props});

  @override
  Widget build(BuildContext context) {
    if (props.layoutStyle == 'table' || (props.variant == 2 && !props.isMobile)) {
      return _PricingTableStyle(props: props);
    }
    return _PricingCardsLayout(props: props);
  }
}

/// Grid/Row layout for Pricing Cards.
class _PricingCardsLayout extends StatelessWidget {
  final _PricingProps props;
  const _PricingCardsLayout({required this.props});

  @override
  Widget build(BuildContext context) {
    final int columnCount = props.variant == 1 ? 2 : ResponsiveUtils.getContentColumns(
      MediaQuery.of(context).size.width,
      desktop: props.model.items.length >= 3 ? 3 : props.model.items.length,
      tablet: 2,
      mobile: 1,
    );

    final List<Widget> rows = [];
    for (int i = 0; i < props.model.items.length; i += columnCount) {
      final rowItems = props.model.items.sublist(i, (i + columnCount > props.model.items.length) ? props.model.items.length : i + columnCount);

      Widget rowWidget = Row(
        crossAxisAlignment: props.layoutMode == CardLayoutMode.equal ? CrossAxisAlignment.stretch : CrossAxisAlignment.start,
        children: List.generate(columnCount, (colIndex) {
          if (colIndex < rowItems.length) {
            final item = rowItems[colIndex];
            final isLastInRow = colIndex == columnCount - 1;
            return Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.only(end: isLastInRow ? 0 : 20.0),
                child: _PricingCard(item: item, props: props),
              ),
            );
          } else {
            return const Expanded(child: SizedBox.shrink());
          }
        }),
      );

      rows.add(props.layoutMode == CardLayoutMode.equal ? IntrinsicHeight(child: rowWidget) : rowWidget);

      if (i + columnCount < props.model.items.length) {
        rows.add(SizedBox(height: 20));
      }
    }
    return Column(children: rows);
  }
}

/// Table-like style for Pricing.
class _PricingTableStyle extends StatelessWidget {
  final _PricingProps props;
  const _PricingTableStyle({required this.props});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: props.model.items.map((item) {
        final priceDisplay = PricingCalculator.formatPriceDisplay(props.model.schemaVersion, item, props.activePeriodKey, props.lang);
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: props.subTextColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: item.isPopular ? props.secondaryColor : props.subTextColor.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: props.textColor)),
                    Text(item.features.join(", "), maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.caption.copyWith(color: props.subTextColor)),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(priceDisplay, textAlign: TextAlign.center, style: AppTypography.h3.copyWith(color: props.secondaryColor)),
              ),
              SizedBox(width: 24),
              ElevatedButton(
                onPressed: () => _handlePricingAction(context, item, props),
                style: ElevatedButton.styleFrom(
                  backgroundColor: props.secondaryColor,
                  foregroundColor: props.theme?.buttonTextColor ?? Colors.white,
                ),
                child: Text(item.buttonText.isEmpty ? 'Select' : item.buttonText),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// Modular Pricing Card.
class _PricingCard extends StatelessWidget {
  final PricingItemModel item;
  final _PricingProps props;

  const _PricingCard({required this.item, required this.props});

  @override
  Widget build(BuildContext context) {
    final priceDisplay = PricingCalculator.formatPriceDisplay(props.model.schemaVersion, item, props.activePeriodKey, props.lang);
    final discountBadge = PricingCalculator.resolveDiscountBadge(item, props.activePeriodKey, props.lang);

    return Container(
      padding: EdgeInsets.all(props.isMobile ? 20 : 32),
      decoration: BoxDecoration(
        color: props.subTextColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: item.isPopular ? props.secondaryColor : props.subTextColor.withValues(alpha: 0.1),
          width: item.isPopular ? 2 : 1,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.isPopular)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(color: props.secondaryColor, borderRadius: BorderRadius.circular(20)),
                      child: const Text("الأكثر شيوعاً", style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                  Text(item.name, style: AppTypography.h3.copyWith(color: props.textColor, fontSize: props.isMobile ? 18 : 22)),
                  SizedBox(height: 8),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      key: ValueKey(priceDisplay),
                      alignment: AlignmentDirectional.centerEnd,
                      child: Text(priceDisplay, style: AppTypography.h1.copyWith(color: props.secondaryColor, fontSize: props.isMobile ? 28 : 36)),
                    ),
                  ),
                  SizedBox(height: props.isMobile ? 16 : 24),
                  _PricingFeaturesList(item: item, props: props),
                  SizedBox(height: 16),
                ],
              ),
              _PricingActionButton(item: item, props: props),
            ],
          ),
          if (discountBadge != null)
            Positioned(
              top: -10,
              left: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))]),
                child: Text(discountBadge, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ),
        ],
      ),
    );
  }
}

/// Shared Pricing Features List.
class _PricingFeaturesList extends StatelessWidget {
  final PricingItemModel item;
  final _PricingProps props;

  const _PricingFeaturesList({required this.item, required this.props});

  @override
  Widget build(BuildContext context) {
    final displayItems = props.isMobile ? (item.features.length > 2 ? 2 : item.features.length) : item.features.length;
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: displayItems,
      itemBuilder: (context, i) {
        final f = item.features[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: props.secondaryColor, size: 16),
              SizedBox(width: 8),
              Expanded(child: Text(f, style: TextStyle(color: props.subTextColor, fontSize: props.isMobile ? 12 : 14))),
            ],
          ),
        );
      },
    );
  }
}

/// Shared Pricing Action Button.
class _PricingActionButton extends StatelessWidget {
  final PricingItemModel item;
  final _PricingProps props;

  const _PricingActionButton({required this.item, required this.props});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _handlePricingAction(context, item, props),
        style: ElevatedButton.styleFrom(
          backgroundColor: item.isPopular ? props.secondaryColor : Colors.transparent,
          foregroundColor: item.isPopular ? (props.theme?.buttonTextColor ?? Colors.white) : props.secondaryColor,
          side: item.isPopular ? null : BorderSide(color: props.secondaryColor),
          padding: EdgeInsets.symmetric(vertical: props.isMobile ? 12 : 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(item.buttonText.isEmpty ? 'Get Started' : item.buttonText, style: TextStyle(fontWeight: FontWeight.bold, fontSize: props.isMobile ? 12 : 14)),
      ),
    );
  }
}

Future<void> _handlePricingAction(BuildContext context, PricingItemModel item, _PricingProps props) async {
  EventAnalyticsService.logEvent(
    eventName: 'pricing_plan_selected',
    parameters: {
      'plan_id': item.planId,
      'billing_period': props.activePeriodKey,
      'schema_version': props.model.schemaVersion,
      'currency': item.currency,
      'price_value': item.prices[props.activePeriodKey] ?? 0.0,
    },
  );

  await ActionHandlerService.executeAction(
    context,
    actionType: item.buttonActionType,
    actionValue: item.buttonActionValue,
    pageId: props.pageId,
    buttonText: item.buttonText,
    blockType: 'pricing',
    metadata: {'billing_id': item.billingIds[props.activePeriodKey]},
  );
}
