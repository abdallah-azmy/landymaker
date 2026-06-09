import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/responsive/responsive_utils.dart';
import '../../../core/widgets/section_background.dart';
import '../../../core/services/event_analytics_service.dart';
import '../../../core/services/action_handler_service.dart';
import '../../builder/models/landing_page_theme.dart';
import '../models/pricing_models.dart';
import '../utils/pricing_parser.dart';
import '../utils/pricing_calculator.dart';

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
  String _activePeriodKey = 'monthly'; // default active period

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
    
    // Ensure activePeriodKey is valid. If only 'yearly' is available, default to it.
    if (_model.hasToggle && _model.toggleLabels.isNotEmpty) {
      if (!_model.toggleLabels.containsKey(_activePeriodKey)) {
        _activePeriodKey = _model.toggleLabels.keys.first;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.theme?.primary ?? AppColors.primary;
    final secondaryColor = widget.theme?.secondary ?? AppColors.secondary;
    final textColor = widget.theme?.textPrimary ?? AppColors.textPrimary;
    final subTextColor = widget.theme?.textSecondary ?? AppColors.textSecondary;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;
        final double verticalPadding = isMobile ? 40 : 80;

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
              child: Column(
                children: [
                  Text(
                    _model.title,
                    style: AppTypography.h2.copyWith(color: textColor, fontSize: isMobile ? 24 : 32),
                    textAlign: TextAlign.center,
                  ),
                  if (_model.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      _model.subtitle,
                      style: AppTypography.bodyLarge.copyWith(color: subTextColor, fontSize: isMobile ? 16 : 18),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  if (_model.hasToggle && _model.toggleLabels.length > 1) ...[
                    const SizedBox(height: 32),
                    _buildToggle(primaryColor, textColor),
                  ],
                  SizedBox(height: isMobile ? 32 : 64),
                  _buildPricingContent(context, constraints, primaryColor, secondaryColor, textColor, subTextColor, isMobile),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPricingContent(BuildContext context, BoxConstraints constraints, Color primary, Color secondary, Color textColor, Color subTextColor, bool isMobile) {
    if (widget.variant == 2 && !isMobile) { // Table style
       return _buildTableStyle(primary, secondary, textColor, subTextColor);
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _model.items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.variant == 1 ? 2 : ResponsiveUtils.getGridCrossAxisCount(
          context,
          desktop: _model.items.length > 3 ? 3 : _model.items.length,
          tablet: 2,
          mobile: 1,
          width: constraints.maxWidth,
        ),
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: isMobile ? 1.0 : (widget.variant == 1 ? 1.2 : 0.65),
      ),
      itemBuilder: (context, index) {
        final item = _model.items[index];
        return _buildPricingCard(item, primary, secondary, textColor, subTextColor, isMobile);
      },
    );
  }

  Widget _buildTableStyle(Color primary, Color secondary, Color textColor, Color subTextColor) {
    return Column(
      children: _model.items.map((item) {
        final priceDisplay = PricingCalculator.formatPriceDisplay(_model.schemaVersion, item, _activePeriodKey, widget.lang);
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: subTextColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: item.isPopular ? secondary : subTextColor.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: textColor)),
                    Text(item.features.join(", "), maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.caption.copyWith(color: subTextColor)),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(priceDisplay, textAlign: TextAlign.center, style: AppTypography.h3.copyWith(color: secondary)),
              ),
              const SizedBox(width: 24),
              ElevatedButton(
                onPressed: () {}, // Handled similarly to cards
                style: ElevatedButton.styleFrom(backgroundColor: secondary, foregroundColor: Colors.white),
                child: Text(item.buttonText.isEmpty ? 'Select' : item.buttonText),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildToggle(Color primaryColor, Color textColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _model.toggleLabels.entries.map((entry) {
          final isSelected = entry.key == _activePeriodKey;
          return GestureDetector(
            onTap: () {
              setState(() {
                _activePeriodKey = entry.key;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(26),
              ),
              child: Text(
                entry.value,
                style: TextStyle(
                  color: isSelected ? Colors.white : textColor,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPricingCard(PricingItemModel item, Color primary, Color secondary, Color textColor, Color subTextColor, bool isMobile) {
    final priceDisplay = PricingCalculator.formatPriceDisplay(_model.schemaVersion, item, _activePeriodKey, widget.lang);
    final discountBadge = PricingCalculator.resolveDiscountBadge(item, _activePeriodKey, widget.lang);

    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      decoration: BoxDecoration(
        color: subTextColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: item.isPopular ? secondary : subTextColor.withValues(alpha: 0.1),
          width: item.isPopular ? 2 : 1,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item.isPopular)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: secondary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "الأكثر شيوعاً", // Hardcoded fallback, usually you'd localize this too, but MVP for now
                    style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
              Text(item.name, style: AppTypography.h3.copyWith(color: textColor, fontSize: isMobile ? 18 : 22)),
              const SizedBox(height: 8),
              
              // Animated price display
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Container(
                  key: ValueKey(priceDisplay),
                  alignment: AlignmentDirectional.centerEnd,
                  child: Text(
                    priceDisplay, 
                    style: AppTypography.h1.copyWith(color: secondary, fontSize: isMobile ? 28 : 36),
                  ),
                ),
              ),
              
              SizedBox(height: isMobile ? 16 : 24),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: isMobile ? (item.features.length > 2 ? 2 : item.features.length) : item.features.length,
                  itemBuilder: (context, i) {
                    final f = item.features[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_rounded, color: secondary, size: 16),
                          const SizedBox(width: 8),
                          Expanded(child: Text(f, style: TextStyle(color: subTextColor, fontSize: isMobile ? 12 : 14))),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    // 1. Emit Analytics Event
                    EventAnalyticsService.logEvent(
                      eventName: 'pricing_plan_selected',
                      parameters: {
                        'plan_id': item.planId,
                        'billing_period': _activePeriodKey,
                        'schema_version': _model.schemaVersion,
                        'currency': item.currency,
                        'price_value': item.prices[_activePeriodKey] ?? 0.0,
                      },
                    );

                    // 2. Delegate Action to Handler
                    await ActionHandlerService.executeAction(
                      context,
                      actionType: item.buttonActionType,
                      actionValue: item.buttonActionValue,
                      pageId: widget.pageId,
                      buttonText: item.buttonText,
                      blockType: 'pricing',
                      metadata: {
                        'billing_id': item.billingIds[_activePeriodKey],
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: item.isPopular ? secondary : Colors.transparent,
                    foregroundColor: item.isPopular ? Colors.white : secondary,
                    side: item.isPopular ? null : BorderSide(color: secondary),
                    padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(item.buttonText.isEmpty ? 'Get Started' : item.buttonText, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 12 : 14)),
                ),
              ),
            ],
          ),
          
          if (discountBadge != null)
            Positioned(
              top: -10,
              left: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green, // Can be themed later
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))
                  ],
                ),
                child: Text(
                  discountBadge,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
