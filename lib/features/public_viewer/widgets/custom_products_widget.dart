import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/section_background.dart';
import '../../../core/widgets/custom_network_image.dart';
import '../../../core/widgets/block_animation_wrapper.dart';
import '../../builder/models/landing_page_theme.dart';
import '../controllers/cart_cubit.dart';

/// ======================================================
/// FEATURE: Custom Products Widget
/// PURPOSE: Displays a searchable and filterable grid or list of products.
/// ARCHITECTURE:
/// - State Hoisting: Pagination, Sorting, and Category state is managed
///   in the [CustomProductsWidget] state object.
/// - Layout Delegation: Renders [_DesktopProductsLayout] or [_MobileProductsLayout]
///   based on screen width.
/// ======================================================
class CustomProductsWidget extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final String layoutStyle;
  final int mobileColumns;
  final LandingPageTheme? theme;
  final Map<String, GlobalKey>? productKeys;
  final String? bgImageUrl;
  final String? bgOverlayColor;
  final double? bgOverlayOpacity;
  final String? backgroundColorHex;
  final double? verticalPadding;
  final double? bgBlur;
  final String? whatsappNumber;
  final bool showCategoryFilter;
  final List<String>? customCategories;
  final String cardStyle;
  final bool staggerAnimations;
  final String hoverEffect;

  const CustomProductsWidget({
    super.key,
    required this.title,
    required this.items,
    this.layoutStyle = 'grid_2',
    this.mobileColumns = 2,
    this.theme,
    this.productKeys,
    this.bgImageUrl,
    this.bgOverlayColor,
    this.bgOverlayOpacity,
    this.backgroundColorHex,
    this.verticalPadding,
    this.bgBlur,
    this.whatsappNumber,
    this.showCategoryFilter = true,
    this.customCategories,
    this.cardStyle = 'classic',
    this.staggerAnimations = true,
    this.hoverEffect = 'scale',
  });

  @override
  State<CustomProductsWidget> createState() => _CustomProductsWidgetState();
}

class _CustomProductsWidgetState extends State<CustomProductsWidget>
    with TickerProviderStateMixin {
  int _currentPage = 1;
  static const int _itemsPerPage = 6;
  _SortMode _sortMode = _SortMode.defaultOrder;
  TabController? _tabController;
  List<String> _categories = [];
  String _selectedCategory = 'all';

  List<Map<String, dynamic>> get _sortedItems {
    final filtered = _selectedCategory == 'all'
        ? List<Map<String, dynamic>>.from(widget.items)
        : widget.items
              .where(
                (p) =>
                    _toSlug(p['category']?.toString() ?? '') ==
                    _toSlug(_selectedCategory),
              )
              .toList();

    if (_sortMode == _SortMode.priceLow) {
      filtered.sort(
        (a, b) => _parsePrice(a['price']).compareTo(_parsePrice(b['price'])),
      );
    } else if (_sortMode == _SortMode.priceHigh) {
      filtered.sort(
        (a, b) => _parsePrice(b['price']).compareTo(_parsePrice(a['price'])),
      );
    }
    return filtered;
  }

  List<Map<String, dynamic>> get _paginatedItems {
    final allSorted = _sortedItems;
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    if (startIndex >= allSorted.length) return [];
    final endIndex = (startIndex + _itemsPerPage).clamp(0, allSorted.length);
    return allSorted.sublist(startIndex, endIndex);
  }

  int get _totalPages => (_sortedItems.length / _itemsPerPage).ceil();

  double _parsePrice(dynamic raw) {
    if (raw == null) return 0;
    return double.tryParse(raw.toString().replaceAll(RegExp(r'[^0-9.]'), '')) ??
        0;
  }

  String _toSlug(String input) =>
      input.toLowerCase().trim().replaceAll(' ', '-');

  @override
  void initState() {
    super.initState();
    _initCategories();
  }

  @override
  void didUpdateWidget(covariant CustomProductsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items ||
        oldWidget.customCategories != widget.customCategories) {
      _initCategories();
    }
  }

  void _initCategories() {
    if (widget.customCategories != null &&
        widget.customCategories!.isNotEmpty) {
      _categories = widget.customCategories!;
    } else {
      final Set<String> cats = {'all'};
      for (final item in widget.items) {
        final c = item['category']?.toString();
        if (c != null && c.isNotEmpty) cats.add(c);
      }
      _categories = cats.toList();
    }

    _tabController?.dispose();
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController!.addListener(() {
      if (!_tabController!.indexIsChanging) {
        setState(() {
          _selectedCategory = _categories[_tabController!.index];
          _currentPage = 1;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final secondaryColor =
        widget.theme?.secondary ?? Theme.of(context).colorScheme.secondary;
    final textColor =
        widget.theme?.textPrimary ?? Theme.of(context).colorScheme.onSurface;
    final subTextColor =
        widget.theme?.textSecondary ??
        Theme.of(context).colorScheme.onSurfaceVariant;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 768;
        final double paddingValue =
            widget.verticalPadding ?? (isMobile ? 40 : 80);

        final props = _ProductsProps(
          title: widget.title,
          categories: _categories,
          selectedCategory: _selectedCategory,
          tabController: _tabController,
          currentPage: _currentPage,
          totalPages: _totalPages,
          items: _paginatedItems,
          sortMode: _sortMode,
          secondaryColor: secondaryColor,
          textColor: textColor,
          subTextColor: subTextColor,
          isMobile: isMobile,
          onPageChanged: (p) => setState(() => _currentPage = p),
          onSortChanged: (s) => setState(() {
            _sortMode = s;
            _currentPage = 1;
          }),
          productKeys: widget.productKeys,
          whatsappNumber: widget.whatsappNumber,
          showCategoryFilter: widget.showCategoryFilter,
          layoutStyle: widget.layoutStyle,
          mobileColumns: widget.mobileColumns,
          cardStyle: widget.cardStyle,
          staggerAnimations: widget.staggerAnimations,
          hoverEffect: widget.hoverEffect,
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
          padding: EdgeInsetsDirectional.symmetric(
            vertical: paddingValue,
            horizontal: 24,
          ),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: isMobile
                  ? _MobileProductsLayout(props: props)
                  : _DesktopProductsLayout(props: props),
            ),
          ),
        );
      },
    );
  }
}

enum _SortMode { defaultOrder, priceLow, priceHigh }

class _ProductsProps {
  final String title;
  final List<String> categories;
  final String selectedCategory;
  final TabController? tabController;
  final int currentPage;
  final int totalPages;
  final List<Map<String, dynamic>> items;
  final _SortMode sortMode;
  final Color secondaryColor;
  final Color textColor;
  final Color subTextColor;
  final bool isMobile;
  final Function(int) onPageChanged;
  final Function(_SortMode) onSortChanged;
  final Map<String, GlobalKey>? productKeys;
  final String? whatsappNumber;
  final bool showCategoryFilter;
  final String layoutStyle;
  final int mobileColumns;
  final String cardStyle;
  final bool staggerAnimations;
  final String hoverEffect;
  final LandingPageTheme? theme;
  final String? bgImageUrl;
  final String? bgOverlayColor;
  final double? bgOverlayOpacity;
  final String? backgroundColorHex;
  final double? verticalPadding;
  final double? bgBlur;

  const _ProductsProps({
    required this.title,
    required this.categories,
    required this.selectedCategory,
    this.tabController,
    required this.currentPage,
    required this.totalPages,
    required this.items,
    required this.sortMode,
    required this.secondaryColor,
    required this.textColor,
    required this.subTextColor,
    required this.isMobile,
    required this.onPageChanged,
    required this.onSortChanged,
    this.productKeys,
    this.whatsappNumber,
    required this.showCategoryFilter,
    required this.layoutStyle,
    required this.mobileColumns,
    required this.cardStyle,
    required this.staggerAnimations,
    required this.hoverEffect,
    this.theme,
    this.bgImageUrl,
    this.bgOverlayColor,
    this.bgOverlayOpacity,
    this.backgroundColorHex,
    this.verticalPadding,
    this.bgBlur,
  });
}

class _DesktopProductsLayout extends StatelessWidget {
  final _ProductsProps props;
  const _DesktopProductsLayout({required this.props});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ProductsHeader(props: props),
        const SizedBox(height: 48),
        if (props.showCategoryFilter) _CategoryFilter(props: props),
        const SizedBox(height: 32),
        _ProductsGrid(props: props),
        if (props.totalPages > 1) ...[
          const SizedBox(height: 48),
          _Pagination(props: props),
        ],
      ],
    );
  }
}

class _MobileProductsLayout extends StatelessWidget {
  final _ProductsProps props;
  const _MobileProductsLayout({required this.props});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ProductsHeader(props: props),
        const SizedBox(height: 24),
        if (props.showCategoryFilter) _CategoryFilter(props: props),
        const SizedBox(height: 24),
        _ProductsGrid(props: props),
        if (props.totalPages > 1) ...[
          const SizedBox(height: 32),
          _Pagination(props: props),
        ],
      ],
    );
  }
}

class _ProductsHeader extends StatelessWidget {
  final _ProductsProps props;
  const _ProductsHeader({required this.props});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            props.title,
            style: AppTypography.h2.copyWith(
              color: props.textColor,
              fontSize: props.isMobile ? 22 : 32,
            ),
          ),
        ),
        _SortDropdown(props: props),
      ],
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  final _ProductsProps props;
  const _CategoryFilter({required this.props});

  @override
  Widget build(BuildContext context) {
    if (props.tabController == null) return const SizedBox.shrink();
    return TabBar(
      controller: props.tabController,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      labelColor: props.secondaryColor,
      unselectedLabelColor: props.subTextColor,
      indicatorColor: props.secondaryColor,
      tabs: props.categories
          .map((c) => Tab(text: c == 'all' ? 'الكل' : c))
          .toList(),
    );
  }
}

class _SortDropdown extends StatelessWidget {
  final _ProductsProps props;
  const _SortDropdown({required this.props});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_SortMode>(
      initialValue: props.sortMode,
      onSelected: props.onSortChanged,
      icon: Icon(Icons.sort_rounded, color: props.secondaryColor),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: _SortMode.defaultOrder,
          child: Text('الترتيب الافتراضي'),
        ),
        const PopupMenuItem(
          value: _SortMode.priceLow,
          child: Text('السعر: من الأقل للأعلى'),
        ),
        const PopupMenuItem(
          value: _SortMode.priceHigh,
          child: Text('السعر: من الأعلى للأقل'),
        ),
      ],
    );
  }
}

class _ProductsGrid extends StatelessWidget {
  final _ProductsProps props;
  const _ProductsGrid({required this.props});

  @override
  Widget build(BuildContext context) {
    if (props.items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 64),
        child: Text(
          'لا توجد منتجات في هذا القسم',
          style: TextStyle(color: props.subTextColor),
        ),
      );
    }

    if (props.layoutStyle == 'carousel') {
      return _ProductsCarousel(props: props);
    }

    if (props.layoutStyle == 'list') {
      return _ProductsList(props: props);
    }

    final int columnCount = props.isMobile
        ? props.mobileColumns
        : (props.layoutStyle == 'grid_3' ? 3 : 2);

    final List<List<Map<String, dynamic>>> rows = [];
    for (var i = 0; i < props.items.length; i += columnCount) {
      rows.add(
        props.items.sublist(i, (i + columnCount).clamp(0, props.items.length)),
      );
    }

    final double spacing = props.isMobile ? 12 : 24;

    return Column(
      children: rows.asMap().entries.map((rowEntry) {
        final isLastRow = rowEntry.key == rows.length - 1;
        return Padding(
          padding: EdgeInsetsDirectional.only(bottom: isLastRow ? 0 : spacing),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                rowEntry.value.asMap().entries.map((itemEntry) {
                  final index = rowEntry.key * columnCount + itemEntry.key;
                  final item = itemEntry.value;
                  final isLastItem = itemEntry.key == rowEntry.value.length - 1;

                  Widget card = _ProductCard(item: item, props: props);

                  if (props.staggerAnimations) {
                    card = BlockAnimationWrapper(
                      settings: BlockAnimationSettings(
                        type: BlockAnimationType.fadeIn,
                        delay: Duration(milliseconds: index * 100),
                      ),
                      child: card,
                    );
                  }

                  return Expanded(
                    child: Padding(
                      padding: EdgeInsetsDirectional.only(
                        end: isLastItem ? 0 : spacing,
                      ),
                      child: card,
                    ),
                  );
                }).toList() +
                List.generate(
                  columnCount - rowEntry.value.length,
                  (_) => const Expanded(child: SizedBox.shrink()),
                ),
          ),
        );
      }).toList(),
    );
  }
}

class _ProductsCarousel extends StatelessWidget {
  final _ProductsProps props;
  const _ProductsCarousel({required this.props});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: props.isMobile ? 320 : 450,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: props.items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 20),
        itemBuilder: (context, index) => SizedBox(
          width: props.isMobile ? 220 : 300,
          child: _ProductCard(item: props.items[index], props: props),
        ),
      ),
    );
  }
}

/// Vertical list layout for products.
class _ProductsList extends StatelessWidget {
  final _ProductsProps props;
  const _ProductsList({required this.props});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: props.items.asMap().entries.map((entry) {
        return Padding(
          padding: EdgeInsetsDirectional.only(bottom: entry.key < props.items.length - 1 ? 16 : 0),
          child: _ProductCard(item: entry.value, props: props),
        );
      }).toList(),
    );
  }
}

class _ProductCard extends StatefulWidget {
  final Map<String, dynamic> item;
  final _ProductsProps props;

  const _ProductCard({required this.item, required this.props});

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _hovered = false;

  bool get _isMinimal => widget.props.cardStyle == 'minimal';
  bool get _isElevated => widget.props.cardStyle == 'elevated';

  @override
  Widget build(BuildContext context) {
    final String name = widget.item['name'] ?? 'Product';
    final String price = widget.item['price'] ?? '0 EGP';
    final String imageUrl = widget.item['image_url'] ?? '';
    final String? description = widget.item['description'];

    final bool isSmall =
        widget.props.isMobile && widget.props.mobileColumns > 1;
    final bool isTiny = widget.props.isMobile && widget.props.mobileColumns > 2;

    final bool applyScale = widget.props.hoverEffect == 'scale' && _hovered;
    final bool applyElevate = widget.props.hoverEffect == 'elevate' && _hovered;
    final bool applyGlow = widget.props.hoverEffect == 'glow' && _hovered;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: applyScale
            ? (Matrix4.identity()..scale(1.03))
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(isTiny ? 12 : 24),
          border: Border.all(
            color: applyGlow
                ? widget.props.secondaryColor
                : _isMinimal
                    ? Colors.transparent
                    : Theme.of(context).colorScheme.outlineVariant,
            width: applyGlow ? 2 : 0,
          ),
          boxShadow: _isMinimal
              ? []
              : (applyElevate || applyGlow || _isElevated)
                  ? [
                      BoxShadow(
                        color: (applyGlow ? widget.props.secondaryColor : Colors.black)
                            .withValues(alpha: _isElevated ? 0.15 : 0.1),
                        blurRadius: _isElevated ? 40 : (applyGlow ? 20 : 30),
                        spreadRadius: _isElevated ? 4 : (applyGlow ? 2 : 0),
                        offset: _isElevated ? const Offset(0, 15) : (applyGlow ? Offset.zero : const Offset(0, 10)),
                      ),
                    ]
                  : [],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 1.0,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                  PositionedDirectional(
                    top: isTiny ? 4 : 8,
                    end: isTiny ? 4 : 8,
                    child: Container(
                      padding: EdgeInsetsDirectional.symmetric(
                        horizontal: isTiny ? 6 : 8,
                        vertical: isTiny ? 2 : 4,
                      ),
                      decoration: BoxDecoration(
                        color: widget.props.secondaryColor,
                        borderRadius: BorderRadius.circular(isTiny ? 4 : 8),
                      ),
                      child: Text(
                        price,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: isTiny ? 8 : (isSmall ? 9 : 11),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(isTiny ? 6 : (isSmall ? 8 : 12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: widget.props.textColor,
                      fontSize: isTiny ? 10 : (isSmall ? 12 : 14),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (!isTiny && description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: AppTypography.caption.copyWith(
                        color: widget.props.subTextColor,
                        fontSize: isSmall ? 9 : 11,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  SizedBox(height: isTiny ? 8 : (isSmall ? 12 : 16)),
                  SizedBox(
                    width: double.infinity,
                    height: isTiny ? 28 : (isSmall ? 32 : 40),
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<CartCubit>().addItem(widget.item);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.props.secondaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(isTiny ? 6 : 10),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        isTiny ? 'شراء' : 'إضافة للسلة',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isTiny ? 8 : (isSmall ? 10 : 12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pagination extends StatelessWidget {
  final _ProductsProps props;
  const _Pagination({required this.props});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(props.totalPages, (index) {
        final pageNum = index + 1;
        final isActive = props.currentPage == pageNum;
        return GestureDetector(
          onTap: () => props.onPageChanged(pageNum),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isActive ? props.secondaryColor : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: props.secondaryColor.withValues(alpha: 0.3),
              ),
            ),
            child: Center(
              child: Text(
                pageNum.toString(),
                style: TextStyle(
                  color: isActive ? Colors.white : props.textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
