import 'package:flutter/material.dart';
import '../../../core/theme/app_typography.dart';
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
  final String? backgroundColorHex;
  final double? verticalPadding;
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
    this.backgroundColorHex,
    this.verticalPadding,
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
    final primaryColor = widget.theme?.primary ?? Theme.of(context).colorScheme.primary;
    final secondaryColor = widget.theme?.secondary ?? Theme.of(context).colorScheme.secondary;
    final textColor = widget.theme?.textPrimary ?? Theme.of(context).colorScheme.onSurface;
    final subTextColor = widget.theme?.textSecondary ?? Theme.of(context).colorScheme.onSurfaceVariant;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 768;
        final double paddingValue = widget.verticalPadding ?? (isMobile ? 40 : 80);

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
          bgImageUrl: widget.bgImageUrl,
          bgOverlayColor: widget.bgOverlayColor,
          bgOverlayOpacity: widget.bgOverlayOpacity,
          backgroundColorHex: widget.backgroundColorHex,
          verticalPadding: widget.verticalPadding,
          bgBlur: widget.bgBlur,
        );

        return SectionBackground(
          bgImageUrl: widget.bgImageUrl,
          bgOverlayColor: widget.bgOverlayColor,
          bgOverlayOpacity: widget.bgOverlayOpacity,
          backgroundColorHex: widget.backgroundColorHex,
          verticalPaddingOverride: widget.verticalPadding,
          bgBlur: widget.bgBlur,
          theme: widget.theme,
          padding: EdgeInsetsDirectional.symmetric(vertical: paddingValue, horizontal: 24),
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
  final String? bgImageUrl;
  final String? bgOverlayColor;
  final double? bgOverlayOpacity;
  final String? backgroundColorHex;
  final double? verticalPadding;
  final double? bgBlur;

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
    this.bgImageUrl,
    this.bgOverlayColor,
    this.bgOverlayOpacity,
    this.backgroundColorHex,
    this.verticalPadding,
    this.bgBlur,
  });
}

class _DesktopPricingLayout extends StatelessWidget {
  final _PricingProps props;
  const _DesktopPricingLayout({required this.props});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PricingHeader(props: props),
        const SizedBox(height: 48),
        _buildPlansGrid(context),
      ],
    );
  }

  Widget _buildPlansGrid(BuildContext context) {
    final plans = props.model.items;
    if (props.layoutStyle == 'table') {
      return _PricingTable(props: props);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: plans.map((plan) => Expanded(
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 10),
          child: _PricingCard(plan: plan, props: props),
        ),
      )).toList(),
    );
  }
}

class _MobilePricingLayout extends StatelessWidget {
  final _PricingProps props;
  const _MobilePricingLayout({required this.props});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PricingHeader(props: props),
        const SizedBox(height: 32),
        ...props.model.items.map((plan) => Padding(
          padding: const EdgeInsetsDirectional.only(bottom: 20),
          child: props.layoutStyle == 'table'
              ? _PricingTableRow(plan: plan, props: props)
              : _PricingCard(plan: plan, props: props),
        )),
      ],
    );
  }
}

/// Comparison table layout for pricing plans.
class _PricingTable extends StatelessWidget {
  final _PricingProps props;
  const _PricingTable({required this.props});

  @override
  Widget build(BuildContext context) {
    final plans = props.model.items;
    if (plans.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        defaultColumnWidth: const IntrinsicColumnWidth(),
        border: TableBorder.all(color: props.subTextColor.withValues(alpha: 0.1)),
        children: [
          TableRow(
            children: [
              _PricingTableCell(child: Text('')),
              ...plans.map((plan) => _PricingTableCell(
                child: Text(plan.name, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: props.textColor)),
                isHeader: true,
              )),
            ],
          ),
          TableRow(
            children: [
              _PricingTableCell(child: Text('')),
              ...plans.map((plan) => _PricingTableCell(
                child: Column(
                  children: [
                    Text(PricingCalculator.formatPriceDisplay(
                      props.model.schemaVersion, plan, props.activePeriodKey, props.lang,
                    ), style: AppTypography.h2.copyWith(color: props.primaryColor, fontSize: 24)),
                  ],
                ),
                isHeader: true,
              )),
            ],
          ),
          ...plans.expand((plan) => plan.features.map((feature) {
            return TableRow(
              children: [
                _PricingTableCell(child: Text(feature, style: AppTypography.bodySmall.copyWith(color: props.textColor))),
                ...plans.map((p) => _PricingTableCell(
                  child: Icon(Icons.check_circle_rounded, color: props.primaryColor, size: 18),
                )),
              ],
            );
          })),
          TableRow(
            children: [
              _PricingTableCell(child: Text('')),
              ...plans.map((plan) => _PricingTableCell(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ActionHandlerService.executeAction(
                        context, actionType: plan.buttonActionType,
                        actionValue: plan.buttonActionValue,
                        pageId: props.pageId, buttonText: plan.buttonText,
                        blockType: 'pricing',
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: props.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(plan.buttonText, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                isHeader: true,
              )),
            ],
          ),
        ],
      ),
    );
  }
}

/// A single table row for mobile pricing table layout.
class _PricingTableRow extends StatelessWidget {
  final PricingItemModel plan;
  final _PricingProps props;
  const _PricingTableRow({required this.plan, required this.props});

  @override
  Widget build(BuildContext context) {
    final priceDisplay = PricingCalculator.formatPriceDisplay(
      props.model.schemaVersion, plan, props.activePeriodKey, props.lang,
    );
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: props.subTextColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: props.subTextColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Text(plan.name, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: props.textColor)),
          SizedBox(height: 8),
          Text(priceDisplay, style: AppTypography.h2.copyWith(color: props.primaryColor, fontSize: 24)),
          SizedBox(height: 16),
          ...plan.features.map((f) => Padding(
            padding: const EdgeInsetsDirectional.only(bottom: 8),
            child: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: props.primaryColor, size: 16),
                SizedBox(width: 8),
                Expanded(child: Text(f, style: AppTypography.bodySmall.copyWith(color: props.textColor))),
              ],
            ),
          )),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ActionHandlerService.executeAction(
                  context, actionType: plan.buttonActionType,
                  actionValue: plan.buttonActionValue,
                  pageId: props.pageId, buttonText: plan.buttonText,
                  blockType: 'pricing',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: props.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(plan.buttonText, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

/// A single cell in the pricing comparison table.
class _PricingTableCell extends StatelessWidget {
  final Widget child;
  final bool isHeader;

  const _PricingTableCell({required this.child, this.isHeader = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: isHeader ? Colors.white.withValues(alpha: 0.03) : null,
      child: child,
    );
  }
}

class _PricingHeader extends StatelessWidget {
  final _PricingProps props;
  const _PricingHeader({required this.props});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(props.model.title, style: AppTypography.h2.copyWith(color: props.textColor, fontSize: props.isMobile ? 24 : 36), textAlign: TextAlign.center),
        if (props.model.subtitle.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(props.model.subtitle, style: AppTypography.bodyMedium.copyWith(color: props.subTextColor), textAlign: TextAlign.center),
        ],
        if (props.model.hasToggle) ...[
          const SizedBox(height: 32),
          _PricingToggle(props: props),
        ],
      ],
    );
  }
}

class _PricingToggle extends StatelessWidget {
  final _PricingProps props;
  const _PricingToggle({required this.props});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: props.subTextColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: props.model.toggleLabels.entries.map((e) {
          final isSelected = props.activePeriodKey == e.key;
          return GestureDetector(
            onTap: () => props.onPeriodChanged(e.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? props.primaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(e.value, style: TextStyle(color: isSelected ? Colors.white : props.subTextColor, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PricingCard extends StatelessWidget {
  final PricingItemModel plan;
  final _PricingProps props;

  const _PricingCard({required this.plan, required this.props});

  @override
  Widget build(BuildContext context) {
    final priceDisplay = PricingCalculator.formatPriceDisplay(
      props.model.schemaVersion,
      plan,
      props.activePeriodKey,
      props.lang,
    );
    
    final discountBadge = PricingCalculator.resolveDiscountBadge(
      plan,
      props.activePeriodKey,
      props.lang,
    );

    final isPopular = plan.isPopular;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: props.subTextColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isPopular ? props.primaryColor : props.subTextColor.withValues(alpha: 0.1), width: isPopular ? 2 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isPopular || discountBadge != null) ...[
            Row(
              children: [
                if (isPopular)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: props.primaryColor, borderRadius: BorderRadius.circular(20)),
                    child: const Text('الأكثر طلباً', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                if (isPopular && discountBadge != null) const SizedBox(width: 8),
                if (discountBadge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(20)),
                    child: Text(discountBadge, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          Text(plan.name, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: props.textColor)),
          const SizedBox(height: 8),
          Text(priceDisplay, style: AppTypography.h2.copyWith(color: props.primaryColor, fontSize: 32)),
          const SizedBox(height: 24),
          ...plan.features.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: props.primaryColor, size: 18),
                const SizedBox(width: 10),
                Expanded(child: Text(f, style: AppTypography.bodySmall.copyWith(color: props.textColor))),
              ],
            ),
          )),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                EventAnalyticsService.recordCtaClick(
                  props.pageId,
                  buttonText: plan.buttonText,
                  blockType: 'pricing',
                );
                ActionHandlerService.executeAction(
                  context,
                  actionType: plan.buttonActionType,
                  actionValue: plan.buttonActionValue,
                  pageId: props.pageId,
                  buttonText: plan.buttonText,
                  blockType: 'pricing',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isPopular ? props.primaryColor : props.subTextColor.withValues(alpha: 0.1),
                foregroundColor: isPopular ? Colors.white : props.textColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Text(plan.buttonText, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
