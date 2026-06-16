import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/responsive/responsive_utils.dart';
import '../../../core/widgets/section_background.dart';
import '../../../core/widgets/custom_network_image.dart';
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
  final double? bgBlur;
  final String? whatsappNumber;
  final bool showCategoryFilter;
  final List<String>? customCategories;

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
    this.bgBlur,
    this.whatsappNumber,
    this.showCategoryFilter = true,
    this.customCategories,
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
              .where((p) => _toSlug(p['category']?.toString() ?? '') == _toSlug(_selectedCategory))
              .toList();

    if (_sortMode == _SortMode.priceLow) {
      filtered.sort((a, b) => _parsePrice(a['price']).compareTo(_parsePrice(b['price'])));
    } else if (_sortMode == _SortMode.priceHigh) {
      filtered.sort((a, b) => _parsePrice(b['price']).compareTo(_parsePrice(a['price'])));
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
    return double.tryParse(raw.toString().replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
  }

  @override
  void initState() {
    super.initState();
    _initCategories();
  }

  @override
  void didUpdateWidget(CustomProductsWidget old) {
    super.didUpdateWidget(old);
    if (old.items != widget.items || old.customCategories != widget.customCategories) {
      _initCategories();
    }
  }

  void _initCategories() {
    List<String> newCats;
    if (widget.customCategories != null && widget.customCategories!.isNotEmpty) {
      newCats = ['all', ...widget.customCategories!];
    } else {
      final itemsCategories = <String>[];
      for (final e in widget.items) {
        final c = e['category']?.toString();
        if (c != null && c.isNotEmpty && !itemsCategories.contains(c)) {
          itemsCategories.add(c);
        }
      }
      newCats = ['all', ...itemsCategories];
    }

    _tabController?.dispose();
    TabController? newController;
    if (newCats.isNotEmpty) {
      newController = TabController(length: newCats.length, vsync: this);
      newController.addListener(() {
        if (!newController!.indexIsChanging) {
          setState(() {
            _selectedCategory = newCats[newController!.index];
            _currentPage = 1; // Reset to page 1 when category changes
          });
        }
      });
    }

    setState(() {
      _categories = newCats;
      _tabController = newController;
      _selectedCategory = 'all';
    });

    if (widget.productKeys != null) {
      for (final p in widget.items) {
        final id = p['id']?.toString() ?? '';
        final slug = _toSlug(p['name']?.toString() ?? '');
        if (id.isNotEmpty) widget.productKeys!["$id-${widget.hashCode}"] ??= GlobalKey();
        if (slug.isNotEmpty) widget.productKeys!["$slug-${widget.hashCode}"] ??= GlobalKey();
      }
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final secondaryColor = widget.theme?.secondary ?? AppColors.secondary;
    final textColor = widget.theme?.textPrimary ?? Theme.of(context).colorScheme.onSurface;
    final subTextColor = widget.theme?.textSecondary ?? Theme.of(context).colorScheme.onSurfaceVariant;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;
        
        final props = _ProductsProps(
          title: widget.title,
          theme: widget.theme,
          secondaryColor: secondaryColor,
          textColor: textColor,
          subTextColor: subTextColor,
          isMobile: isMobile,
          showCategoryFilter: widget.showCategoryFilter,
          categories: _categories,
          selectedCategory: _selectedCategory,
          sortMode: _sortMode,
          onSortChanged: (mode) => setState(() => _sortMode = mode),
          tabController: _tabController,
          paginatedItems: _paginatedItems,
          currentPage: _currentPage,
          totalPages: _totalPages,
          onPageChanged: (page) => setState(() => _currentPage = page),
          layoutStyle: widget.layoutStyle,
          mobileColumns: widget.mobileColumns,
          productKeys: widget.productKeys,
          whatsappNumber: widget.whatsappNumber,
          onShowDetail: (item) => _showProductDetail(context, item),
          parentHashCode: widget.hashCode,
        );

        return SectionBackground(
          bgImageUrl: widget.bgImageUrl,
          bgOverlayColor: widget.bgOverlayColor,
          bgOverlayOpacity: widget.bgOverlayOpacity,
          bgBlur: widget.bgBlur,
          theme: widget.theme,
          padding: EdgeInsetsDirectional.symmetric(vertical: isMobile ? 40 : 80, horizontal: 24),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: isMobile ? _MobileProductsLayout(props: props) : _DesktopProductsLayout(props: props),
            ),
          ),
        );
      },
    );
  }

  void _showProductDetail(BuildContext context, Map<String, dynamic> item) {
    final secondary = widget.theme?.secondary ?? AppColors.secondary;
    final bgColor = widget.theme?.background ?? Theme.of(context).colorScheme.surface;
    final textColor = widget.theme?.textPrimary ?? Theme.of(context).colorScheme.onSurface;
    final subTextColor = widget.theme?.textSecondary ?? Theme.of(context).colorScheme.onSurfaceVariant;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: _ProductDetailModal(
          item: item,
          secondary: secondary,
          bgColor: bgColor,
          textColor: textColor,
          subTextColor: subTextColor,
          whatsappNumber: widget.whatsappNumber,
          theme: widget.theme,
        ),
      ),
    );
  }
}

/// Data class for Products properties.
class _ProductsProps {
  final String title;
  final LandingPageTheme? theme;
  final Color secondaryColor;
  final Color textColor;
  final Color subTextColor;
  final bool isMobile;
  final bool showCategoryFilter;
  final List<String> categories;
  final String selectedCategory;
  final _SortMode sortMode;
  final Function(_SortMode) onSortChanged;
  final TabController? tabController;
  final List<Map<String, dynamic>> paginatedItems;
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;
  final String layoutStyle;
  final int mobileColumns;
  final Map<String, GlobalKey>? productKeys;
  final String? whatsappNumber;
  final Function(Map<String, dynamic>) onShowDetail;
  final int parentHashCode;

  const _ProductsProps({
    required this.title,
    this.theme,
    required this.secondaryColor,
    required this.textColor,
    required this.subTextColor,
    required this.isMobile,
    required this.showCategoryFilter,
    required this.categories,
    required this.selectedCategory,
    required this.sortMode,
    required this.onSortChanged,
    this.tabController,
    required this.paginatedItems,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    required this.layoutStyle,
    required this.mobileColumns,
    this.productKeys,
    this.whatsappNumber,
    required this.onShowDetail,
    required this.parentHashCode,
  });
}

/// Desktop version of the Products layout.
class _DesktopProductsLayout extends StatelessWidget {
  final _ProductsProps props;
  const _DesktopProductsLayout({required this.props});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _ProductsHeader(props: props),
        SizedBox(height: 32),
        _ProductsToolbar(props: props),
        SizedBox(height: 32),
        _ProductsContent(props: props),
      ],
    );
  }
}

/// Mobile version of the Products layout.
class _MobileProductsLayout extends StatelessWidget {
  final _ProductsProps props;
  const _MobileProductsLayout({required this.props});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _ProductsHeader(props: props),
        SizedBox(height: 32),
        _ProductsToolbar(props: props),
        SizedBox(height: 32),
        _ProductsContent(props: props),
      ],
    );
  }
}

/// Shared Products Header.
class _ProductsHeader extends StatelessWidget {
  final _ProductsProps props;
  const _ProductsHeader({required this.props});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          props.title,
          style: AppTypography.h2.copyWith(fontSize: 32, fontWeight: FontWeight.bold, color: props.textColor),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16),
        Container(
          width: 60,
          height: 4,
          decoration: BoxDecoration(color: props.secondaryColor, borderRadius: BorderRadius.circular(2)),
        ),
      ],
    );
  }
}

/// Shared Products Toolbar (Tabs & Sort).
class _ProductsToolbar extends StatelessWidget {
  final _ProductsProps props;
  const _ProductsToolbar({required this.props});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (props.showCategoryFilter && props.categories.length > 1 && props.tabController != null) ...[
          TabBar(
            controller: props.tabController,
            isScrollable: true,
            labelColor: props.secondaryColor,
            unselectedLabelColor: props.subTextColor,
            indicatorColor: props.secondaryColor,
            dividerColor: Colors.transparent,
            tabs: props.categories.map((c) => Tab(text: c == 'all' ? 'الكل' : c)).toList(),
          ),
          SizedBox(height: 24),
        ],
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _SortChip(label: 'الافتراضي', mode: _SortMode.defaultOrder, props: props),
              SizedBox(width: 8),
              _SortChip(label: 'السعر: الأقل أولاً', mode: _SortMode.priceLow, props: props),
              SizedBox(width: 8),
              _SortChip(label: 'السعر: الأعلى أولاً', mode: _SortMode.priceHigh, props: props),
            ],
          ),
        ),
      ],
    );
  }
}

/// Shared Products Content (Grid/List & Pagination).
class _ProductsContent extends StatelessWidget {
  final _ProductsProps props;
  const _ProductsContent({required this.props});

  @override
  Widget build(BuildContext context) {
    if (props.paginatedItems.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Text('لا توجد منتجات', style: AppTypography.caption.copyWith(color: props.subTextColor)),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final bool isMobileWidth = width < 768;

        Widget content;
        if (props.layoutStyle == 'list' || props.layoutStyle == 'list_large') {
          content = ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: props.paginatedItems.length,
            separatorBuilder: (_, __) => SizedBox(height: isMobileWidth ? 16 : 24),
            itemBuilder: (context, index) => _ProductListItem(item: props.paginatedItems[index], props: props),
          );
        } else {
          final int crossAxisCount = ResponsiveUtils.getContentColumns(
            width,
            desktop: props.layoutStyle == 'grid_3' ? 3 : 2,
            tablet: 2,
            mobile: props.mobileColumns,
          );
          final double spacing = isMobileWidth ? 12 : 20;
          final double cardWidth = (width - spacing * (crossAxisCount - 1)) / crossAxisCount;

          content = GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: spacing,
              crossAxisSpacing: spacing,
              childAspectRatio: cardWidth / (cardWidth + 100),
            ),
            itemCount: props.paginatedItems.length,
            itemBuilder: (context, index) => _ProductCard(item: props.paginatedItems[index], props: props, cardWidth: cardWidth),
          );
        }

        return Column(
          children: [
            content,
            SizedBox(height: 32),
            _Pagination(props: props),
          ],
        );
      },
    );
  }
}

/// Shared Sort Chip.
class _SortChip extends StatelessWidget {
  final String label;
  final _SortMode mode;
  final _ProductsProps props;

  const _SortChip({required this.label, required this.mode, required this.props});

  @override
  Widget build(BuildContext context) {
    final isActive = props.sortMode == mode;
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 12, color: isActive ? Colors.white : props.subTextColor)),
      selected: isActive,
      selectedColor: props.secondaryColor,
      backgroundColor: props.secondaryColor.withValues(alpha: 0.08),
      side: BorderSide(color: isActive ? props.secondaryColor : props.subTextColor.withValues(alpha: 0.3)),
      onSelected: (_) => props.onSortChanged(mode),
    );
  }
}

/// Shared Pagination control.
class _Pagination extends StatelessWidget {
  final _ProductsProps props;
  const _Pagination({required this.props});

  @override
  Widget build(BuildContext context) {
    if (props.totalPages <= 1) return SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(onPressed: props.currentPage > 1 ? () => props.onPageChanged(props.currentPage - 1) : null, icon: Icon(Icons.chevron_left_rounded), color: props.secondaryColor),
        SizedBox(width: 16),
        Text("${props.currentPage} / ${props.totalPages}", style: AppTypography.bodyMedium.copyWith(color: props.textColor)),
        SizedBox(width: 16),
        IconButton(onPressed: props.currentPage < props.totalPages ? () => props.onPageChanged(props.currentPage + 1) : null, icon: Icon(Icons.chevron_right_rounded), color: props.secondaryColor),
      ],
    );
  }
}

/// Modular Product Card (Grid).
class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final _ProductsProps props;
  final double cardWidth;

  const _ProductCard({required this.item, required this.props, required this.cardWidth});

  @override
  Widget build(BuildContext context) {
    final String id = item['id']?.toString() ?? '';
    final String name = item['name']?.toString() ?? 'Product';
    final String price = item['price']?.toString() ?? '';
    final String imageUrl = item['image_url']?.toString() ?? 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800';
    
    final bool isTiny = cardWidth < 160;
    final bool isSmall = cardWidth < 220;

    final GlobalKey? cardKey = props.productKeys != null ? (props.productKeys!["$id-${props.parentHashCode}"] ??= GlobalKey()) : null;

    return GestureDetector(
      onTap: () => props.onShowDetail(item),
      child: Container(
        key: cardKey,
        decoration: BoxDecoration(
          color: props.subTextColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(isTiny ? 8 : 16),
          border: Border.all(color: props.subTextColor.withValues(alpha: 0.1)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                children: [
                  Positioned.fill(child: CustomNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover)),
                  Positioned(
                    top: isTiny ? 4 : 8,
                    right: isTiny ? 4 : 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: isTiny ? 6 : 8, vertical: isTiny ? 2 : 4),
                      decoration: BoxDecoration(color: props.secondaryColor, borderRadius: BorderRadius.circular(isTiny ? 4 : 8)),
                      child: Text(price, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: isTiny ? 8 : (isSmall ? 9 : 11))),
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
                  Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isTiny ? 11 : (isSmall ? 13 : 15), color: props.textColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 8),
                  _ProductActionButton(item: item, props: props, isTiny: isTiny, isSmall: isSmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Modular Product List Item.
class _ProductListItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final _ProductsProps props;

  const _ProductListItem({required this.item, required this.props});

  @override
  Widget build(BuildContext context) {
    final String id = item['id']?.toString() ?? '';
    final String name = item['name']?.toString() ?? 'Product';
    final String price = item['price']?.toString() ?? '';
    final String imageUrl = item['image_url']?.toString() ?? 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800';

    final GlobalKey? listKey = props.productKeys != null ? (props.productKeys!["$id-${props.parentHashCode}"] ??= GlobalKey()) : null;

    return GestureDetector(
      onTap: () => props.onShowDetail(item),
      child: Container(
        key: listKey,
        height: props.isMobile ? 120 : 160,
        decoration: BoxDecoration(
          color: props.subTextColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(props.isMobile ? 12 : 20),
          border: Border.all(color: props.subTextColor.withValues(alpha: 0.1)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            SizedBox(width: props.isMobile ? 120 : 160, height: props.isMobile ? 120 : 160, child: CustomNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover)),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(props.isMobile ? 12 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(name, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold, fontSize: props.isMobile ? 15 : 18, color: props.textColor), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        SizedBox(width: 8),
                        Text(price, style: AppTypography.bodyLarge.copyWith(color: props.secondaryColor, fontWeight: FontWeight.bold, fontSize: props.isMobile ? 14 : 16)),
                      ],
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _ProductActionButton(item: item, props: props, isTiny: false, isSmall: props.isMobile),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shared Product Action Button.
class _ProductActionButton extends StatelessWidget {
  final Map<String, dynamic> item;
  final _ProductsProps props;
  final bool isTiny;
  final bool isSmall;

  const _ProductActionButton({required this.item, required this.props, required this.isTiny, required this.isSmall});

  @override
  Widget build(BuildContext context) {
    final String buttonText = item['button_text']?.toString() ?? 'Buy Now';

    return SizedBox(
      width: isTiny ? double.infinity : null,
      height: isTiny ? 24 : (isSmall ? 28 : 32),
      child: ElevatedButton(
        onPressed: () async {
          final purchaseUrl = item['purchase_url']?.toString();
          if (purchaseUrl != null && purchaseUrl.isNotEmpty) {
            final uri = Uri.tryParse(purchaseUrl);
            if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            props.onShowDetail(item);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: props.secondaryColor,
          foregroundColor: props.theme?.buttonTextColor ?? Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isTiny ? 4 : 8)),
          elevation: 0,
        ),
        child: Text(buttonText, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isTiny ? 8 : (isSmall ? 10 : 12))),
      ),
    );
  }
}

/// Shared Product Detail Modal Content.
class _ProductDetailModal extends StatelessWidget {
  final Map<String, dynamic> item;
  final Color secondary;
  final Color bgColor;
  final Color textColor;
  final Color subTextColor;
  final String? whatsappNumber;
  final LandingPageTheme? theme;

  const _ProductDetailModal({
    required this.item,
    required this.secondary,
    required this.bgColor,
    required this.textColor,
    required this.subTextColor,
    this.whatsappNumber,
    this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final String name = item['name']?.toString() ?? 'Product';
    final String price = item['price']?.toString() ?? '';
    final String description = item['description']?.toString() ?? '';
    final String imageUrl = item['image_url']?.toString() ?? 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800';
    final String buttonText = item['button_text']?.toString() ?? 'إضافة للسلة';
    final String? category = item['category']?.toString();

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: secondary.withValues(alpha: 0.2)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 40)],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(aspectRatio: 16 / 9, child: CustomNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover)),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (category != null && category.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: secondary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                      child: Text(category, style: TextStyle(color: secondary, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: Text(name, style: AppTypography.h2.copyWith(color: textColor, fontSize: 22))),
                      SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: secondary, borderRadius: BorderRadius.circular(10)),
                        child: Text(price, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(description, style: AppTypography.bodyMedium.copyWith(color: subTextColor, height: 1.6)),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final purchaseUrl = item['purchase_url']?.toString();
                            if (purchaseUrl != null && purchaseUrl.isNotEmpty) {
                              final uri = Uri.tryParse(purchaseUrl);
                              if (uri != null) {
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                                Navigator.of(context).pop();
                              }
                            } else {
                              final cartCubit = context.read<CartCubit>();
                              if (whatsappNumber != null && whatsappNumber!.isNotEmpty) {
                                cartCubit.setWhatsappNumber(whatsappNumber!);
                              }
                              cartCubit.addItem(item);
                              Navigator.of(context).pop();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: secondary,
                            foregroundColor: theme?.buttonTextColor ?? Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(buttonText == 'Buy Now' ? 'إضافة للسلة' : buttonText, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
                      ),
                      SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(foregroundColor: subTextColor, side: BorderSide(color: subTextColor.withValues(alpha: 0.4)), padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: const Text('إغلاق'),
                      ),
                    ],
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

enum _SortMode { defaultOrder, priceLow, priceHigh }

String _toSlug(String name) => name.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9\u0600-\u06ff]+'), '-');
