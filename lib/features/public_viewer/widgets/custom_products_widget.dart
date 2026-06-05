import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/section_background.dart';
import '../../builder/models/landing_page_theme.dart';
import '../controllers/cart_cubit.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helper: Convert a product name to a URL-safe slug for deep linking.
// e.g. "Smart Watch Pro"  →  "smart-watch-pro"
// ─────────────────────────────────────────────────────────────────────────────
String _toSlug(String name) => name.trim().toLowerCase().replaceAll(
  RegExp(r'[^a-z0-9\u0600-\u06ff]+'),
  '-',
);

class CustomProductsWidget extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final String layoutStyle;
  final LandingPageTheme? theme;

  /// Map populated by this widget so the parent can scroll to a product.
  /// Key = product UUID **or** slug derived from the product name.
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
  // ── Pagination ────────────────────────────────────────────────────────────
  int _currentPage = 1;
  static const int _itemsPerPage = 6;

  // ── Sort ──────────────────────────────────────────────────────────────────
  _SortMode _sortMode = _SortMode.defaultOrder;

  // ── Category tabs ─────────────────────────────────────────────────────────
  TabController? _tabController;
  List<String> _categories = [];
  String _selectedCategory = 'all';

  // ── Sorted items cache ────────────────────────────────────────────────────
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

  @override
  void initState() {
    super.initState();
    _initCategories();
  }

  @override
  void didUpdateWidget(CustomProductsWidget old) {
    super.didUpdateWidget(old);
    if (old.items != widget.items ||
        old.customCategories != widget.customCategories)
      _initCategories();
  }

  void _initCategories() {
    List<String> newCats;
    if (widget.customCategories != null &&
        widget.customCategories!.isNotEmpty) {
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
          });
        }
      });
    }

    setState(() {
      _categories = newCats;
      _tabController = newController;
      _selectedCategory = 'all';
    });

    // Register GlobalKeys for deep link scrolling (UUID + slug)
    if (widget.productKeys != null) {
      for (final p in widget.items) {
        final id = p['id']?.toString() ?? '';
        final slug = _toSlug(p['name']?.toString() ?? '');
        if (id.isNotEmpty)
          widget.productKeys!["$id-${widget.hashCode}"] ??= GlobalKey();
        if (slug.isNotEmpty)
          widget.productKeys!["$slug-${widget.hashCode}"] ??= GlobalKey();
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
    final textColor = widget.theme?.textPrimary ?? AppColors.textPrimary;
    final subTextColor = widget.theme?.textSecondary ?? AppColors.textSecondary;

    return SectionBackground(
      bgImageUrl: widget.bgImageUrl,
      bgOverlayColor: widget.bgOverlayColor,
      bgOverlayOpacity: widget.bgOverlayOpacity,
      bgBlur: widget.bgBlur,
      theme: widget.theme,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Title ─────────────────────────────────────────────────────
              Text(
                widget.title,
                style: AppTypography.h2.copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: secondaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 32),

              // ── Category Tabs (auto-generated) ────────────────────────────
              if (widget.showCategoryFilter &&
                  _categories.length > 1 &&
                  _tabController != null) ...[
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: secondaryColor,
                  unselectedLabelColor: subTextColor,
                  indicatorColor: secondaryColor,
                  dividerColor: Colors.transparent,
                  tabs: _categories
                      .map((c) => Tab(text: c == 'all' ? 'الكل' : c))
                      .toList(),
                ),
                const SizedBox(height: 24),
              ],

              // ── Sort Chips ────────────────────────────────────────────────
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _sortChip(
                      'الافتراضي',
                      _SortMode.defaultOrder,
                      secondaryColor,
                      subTextColor,
                    ),
                    const SizedBox(width: 8),
                    _sortChip(
                      'السعر: الأقل أولاً',
                      _SortMode.priceLow,
                      secondaryColor,
                      subTextColor,
                    ),
                    const SizedBox(width: 8),
                    _sortChip(
                      'السعر: الأعلى أولاً',
                      _SortMode.priceHigh,
                      secondaryColor,
                      subTextColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ── Product Grid / List ───────────────────────────────────────
              _buildProductLayout(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sortChip(
    String label,
    _SortMode mode,
    Color activeColor,
    Color inactiveColor,
  ) {
    final isActive = _sortMode == mode;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: isActive ? Colors.white : inactiveColor,
        ),
      ),
      selected: isActive,
      selectedColor: activeColor,
      backgroundColor: activeColor.withValues(alpha: 0.08),
      side: BorderSide(
        color: isActive ? activeColor : inactiveColor.withValues(alpha: 0.3),
      ),
      onSelected: (_) => setState(() => _sortMode = mode),
    );
  }

  Widget _buildProductLayout(BuildContext context) {
    final subTextColor = widget.theme?.textSecondary ?? AppColors.textSecondary;

    if (_paginatedItems.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          'لا توجد منتجات',
          style: AppTypography.caption.copyWith(color: subTextColor),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final bool isMobile = width < 600;

        if (widget.layoutStyle == 'list' ||
            widget.layoutStyle == 'list_large') {
          return Column(
            children: [
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _paginatedItems.length,
                separatorBuilder: (_, __) =>
                    SizedBox(height: isMobile ? 16 : 24),
                itemBuilder: (context, index) => _buildProductListItem(
                  context,
                  _paginatedItems[index],
                  isMobile,
                ),
              ),
              const SizedBox(height: 32),
              _buildPagination(context),
            ],
          );
        }

        int crossAxisCount;
        double childAspectRatio;
        if (widget.layoutStyle == 'grid_3') {
          crossAxisCount = isMobile ? 2 : 3;
          childAspectRatio = isMobile ? 0.6 : 0.75;
        } else {
          crossAxisCount = 2;
          childAspectRatio = isMobile ? 0.7 : 1.0;
        }

        return Column(
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _paginatedItems.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: isMobile ? 12 : 20,
                mainAxisSpacing: isMobile ? 12 : 20,
                childAspectRatio: childAspectRatio,
              ),
              itemBuilder: (context, index) =>
                  _buildProductCard(context, _paginatedItems[index], isMobile),
            ),
            const SizedBox(height: 32),
            _buildPagination(context),
          ],
        );
      },
    );
  }

  Widget _buildPagination(BuildContext context) {
    if (_totalPages <= 1) return const SizedBox.shrink();
    final secondary = widget.theme?.secondary ?? AppColors.secondary;
    final textColor = widget.theme?.textPrimary ?? AppColors.textPrimary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: _currentPage > 1
              ? () => setState(() => _currentPage--)
              : null,
          icon: const Icon(Icons.chevron_left_rounded),
          color: secondary,
        ),
        const SizedBox(width: 16),
        Text(
          "Page \$_currentPage of \$_totalPages",
          style: AppTypography.bodyMedium.copyWith(color: textColor),
        ),
        const SizedBox(width: 16),
        IconButton(
          onPressed: _currentPage < _totalPages
              ? () => setState(() => _currentPage++)
              : null,
          icon: const Icon(Icons.chevron_right_rounded),
          color: secondary,
        ),
      ],
    );
  }

  // ── Product Card (Grid) ───────────────────────────────────────────────────

  Widget _buildProductCard(
    BuildContext context,
    Map<String, dynamic> item,
    bool isMobile,
  ) {
    final secondary = widget.theme?.secondary ?? AppColors.secondary;
    final textColor = widget.theme?.textPrimary ?? AppColors.textPrimary;
    final subTextColor = widget.theme?.textSecondary ?? AppColors.textSecondary;

    final String id = item['id']?.toString() ?? '';
    final String name = item['name']?.toString() ?? 'Product';
    final String slug = _toSlug(name);
    final String price = item['price']?.toString() ?? '';
    final String description = item['description']?.toString() ?? '';
    final String imageUrl =
        item['image_url']?.toString() ??
        'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800';
    final String buttonText = item['button_text']?.toString() ?? 'Buy Now';

    // Register GlobalKeys for both UUID and slug
    final GlobalKey? cardKey = widget.productKeys != null
        ? (widget.productKeys!["$id-${widget.hashCode}"] ??= GlobalKey())
        : null;
    if (widget.productKeys != null && slug.isNotEmpty) {
      widget.productKeys!["$slug-${widget.hashCode}"] ??= GlobalKey();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardWidth = constraints.maxWidth;
        final bool isTiny = cardWidth < 160;
        final bool isSmall = cardWidth < 220;

        return GestureDetector(
          onTap: () => _showProductDetail(context, item),
          child: Container(
            key: cardKey,
            width: double.infinity,
            decoration: BoxDecoration(
              color: subTextColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(isTiny ? 8 : 16),
              border: Border.all(color: subTextColor.withValues(alpha: 0.1)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: subTextColor.withValues(alpha: 0.1),
                            child: Icon(
                              Icons.broken_image,
                              color: subTextColor,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: isTiny ? 4 : 8,
                        right: isTiny ? 4 : 8,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTiny ? 6 : 8,
                            vertical: isTiny ? 2 : 4,
                          ),
                          decoration: BoxDecoration(
                            color: secondary,
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
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isTiny ? 11 : (isSmall ? 13 : 15),
                          color: textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (!isTiny) ...[
                        const SizedBox(height: 2),
                        Text(
                          description,
                          style: TextStyle(
                            color: subTextColor,
                            fontSize: isSmall ? 9 : 11,
                            height: 1.1,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: isTiny ? 24 : (isSmall ? 28 : 32),
                        child: ElevatedButton(
                          onPressed: () async {
                            final purchaseUrl = item['purchase_url']
                                ?.toString();
                            if (purchaseUrl != null && purchaseUrl.isNotEmpty) {
                              final uri = Uri.tryParse(purchaseUrl);
                              if (uri != null) {
                                await launchUrl(
                                  uri,
                                  mode: LaunchMode.externalApplication,
                                );
                              }
                            } else {
                              _showProductDetail(context, item);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: secondary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                isTiny ? 4 : 8,
                              ),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            buttonText,
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
      },
    );
  }

  // ── Product List Item ─────────────────────────────────────────────────────

  Widget _buildProductListItem(
    BuildContext context,
    Map<String, dynamic> item,
    bool isMobile,
  ) {
    final secondary = widget.theme?.secondary ?? AppColors.secondary;
    final textColor = widget.theme?.textPrimary ?? AppColors.textPrimary;
    final subTextColor = widget.theme?.textSecondary ?? AppColors.textSecondary;

    final String id = item['id']?.toString() ?? '';
    final String name = item['name']?.toString() ?? 'Product';
    final String slug = _toSlug(name);
    final String price = item['price']?.toString() ?? '';
    final String description = item['description']?.toString() ?? '';
    final String imageUrl =
        item['image_url']?.toString() ??
        'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800';
    final String buttonText = item['button_text']?.toString() ?? 'Buy Now';

    final GlobalKey? listKey = widget.productKeys != null
        ? (widget.productKeys!["$id-${widget.hashCode}"] ??= GlobalKey())
        : null;
    if (widget.productKeys != null && slug.isNotEmpty) {
      widget.productKeys!["$slug-${widget.hashCode}"] ??= GlobalKey();
    }

    return GestureDetector(
      onTap: () => _showProductDetail(context, item),
      child: Container(
        key: listKey,
        height: isMobile ? 120 : 160,
        decoration: BoxDecoration(
          color: subTextColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(isMobile ? 12 : 20),
          border: Border.all(color: subTextColor.withValues(alpha: 0.1)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            SizedBox(
              width: isMobile ? 120 : 160,
              height: isMobile ? 120 : 160,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: subTextColor.withValues(alpha: 0.1),
                  child: Icon(Icons.broken_image, color: subTextColor),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 12 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: AppTypography.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: isMobile ? 15 : 18,
                              color: textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          price,
                          style: AppTypography.bodyLarge.copyWith(
                            color: secondary,
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 14 : 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        description,
                        style: AppTypography.bodyMedium.copyWith(
                          color: subTextColor,
                          fontSize: isMobile ? 11 : 13,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        height: isMobile ? 32 : 40,
                        child: ElevatedButton(
                          onPressed: () async {
                            final purchaseUrl = item['purchase_url']
                                ?.toString();
                            if (purchaseUrl != null && purchaseUrl.isNotEmpty) {
                              final uri = Uri.tryParse(purchaseUrl);
                              if (uri != null) {
                                await launchUrl(
                                  uri,
                                  mode: LaunchMode.externalApplication,
                                );
                              }
                            } else {
                              _showProductDetail(context, item);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: secondary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                isMobile ? 8 : 10,
                              ),
                            ),
                          ),
                          child: Text(
                            buttonText,
                            style: AppTypography.button.copyWith(
                              fontSize: isMobile ? 11 : 13,
                            ),
                          ),
                        ),
                      ),
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

  // ── Product Detail Modal ──────────────────────────────────────────────────

  void _showProductDetail(BuildContext context, Map<String, dynamic> item) {
    final secondary = widget.theme?.secondary ?? AppColors.secondary;
    final bgColor = widget.theme?.background ?? AppColors.background;
    final textColor = widget.theme?.textPrimary ?? AppColors.textPrimary;
    final subTextColor = widget.theme?.textSecondary ?? AppColors.textSecondary;

    final String name = item['name']?.toString() ?? 'Product';
    final String price = item['price']?.toString() ?? '';
    final String description = item['description']?.toString() ?? '';
    final String imageUrl =
        item['image_url']?.toString() ??
        'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800';
    final String buttonText = item['button_text']?.toString() ?? 'إضافة للسلة';
    final String? category = item['category']?.toString();

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: secondary.withValues(alpha: 0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 40,
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: subTextColor.withValues(alpha: 0.1),
                      child: Icon(
                        Icons.broken_image,
                        color: subTextColor,
                        size: 48,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (category != null && category.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: secondary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              color: secondary,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: AppTypography.h2.copyWith(
                                color: textColor,
                                fontSize: 22,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: secondary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              price,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        description,
                        style: AppTypography.bodyMedium.copyWith(
                          color: subTextColor,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                final purchaseUrl = item['purchase_url']
                                    ?.toString();
                                if (purchaseUrl != null &&
                                    purchaseUrl.isNotEmpty) {
                                  final uri = Uri.tryParse(purchaseUrl);
                                  if (uri != null) {
                                    await launchUrl(
                                      uri,
                                      mode: LaunchMode.externalApplication,
                                    );
                                    Navigator.of(ctx).pop();
                                  }
                                } else {
                                  final cartCubit = context.read<CartCubit>();
                                  if (widget.whatsappNumber != null &&
                                      widget.whatsappNumber!.isNotEmpty) {
                                    cartCubit.setWhatsappNumber(
                                      widget.whatsappNumber!,
                                    );
                                  }
                                  cartCubit.addItem(item);
                                  Navigator.of(ctx).pop();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: secondary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                buttonText == 'Buy Now'
                                    ? 'إضافة للسلة'
                                    : buttonText,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: subTextColor,
                              side: BorderSide(
                                color: subTextColor.withValues(alpha: 0.4),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
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
        ),
      ),
    );
  }
}

enum _SortMode { defaultOrder, priceLow, priceHigh }
