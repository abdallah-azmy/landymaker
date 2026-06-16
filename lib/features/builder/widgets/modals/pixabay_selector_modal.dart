import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/custom_network_image.dart';
import '../../controllers/pixabay_selector_cubit.dart';

class PixabaySelectorModal extends StatefulWidget {
  final String initialQuery;
  final String initialType;
  final String? initialOrientation;
  final Function(String) onImageSelected;

  const PixabaySelectorModal({
    super.key,
    required this.initialQuery,
    this.initialType = 'photo',
    this.initialOrientation,
    required this.onImageSelected,
  });

  @override
  State<PixabaySelectorModal> createState() => _PixabaySelectorModalState();
}

class _PixabaySelectorModalState extends State<PixabaySelectorModal> {
  late final TextEditingController _searchController;
  String _selectedType = 'photo';
  String? _selectedOrientation;
  String _selectedQuality = 'webformatURL';
  final List<String> _suggestedKeywords = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    _selectedType = widget.initialType;
    _selectedOrientation = widget.initialOrientation;
    _generateSuggestions(widget.initialQuery);
    context.read<PixabaySelectorCubit>().searchImages(
      widget.initialQuery,
      type: _selectedType,
      orientation: _selectedOrientation,
    );
  }

  void _generateSuggestions(String query) {
    final suggestions = <String>[
      query,
      '$query تصميم',
      '$query احترافي',
      '$query عمل',
    ];
    _suggestedKeywords.addAll(
      suggestions.where((s) => !_suggestedKeywords.contains(s)),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search({
    String? query,
    String? type,
    String? orientation,
    String? quality,
  }) {
    context.read<PixabaySelectorCubit>().searchImages(
      query ?? _searchController.text,
      type: type ?? _selectedType,
      orientation: orientation ?? _selectedOrientation,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: 24),
          _buildSearchArea(),
          SizedBox(height: 12),
          _buildFilters(),
          SizedBox(height: 12),
          if (_suggestedKeywords.isNotEmpty) _buildSuggestions(),
          SizedBox(height: 16),
          Expanded(child: _buildGrid()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("اختر صورة من Pixabay", style: AppTypography.h3),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.close_rounded),
        ),
      ],
    );
  }

  Widget _buildSearchArea() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: "بحث...",
        prefixIcon: Icon(Icons.search_rounded),
        suffixIcon: IconButton(
          icon: Icon(Icons.send_rounded, color: AppColors.secondary),
          onPressed: () => _search(),
        ),
      ),
      onSubmitted: (val) => _search(),
    );
  }

  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Type filters
        Row(
          children: ['photo', 'illustration', 'vector'].map((t) {
            final isSelected = _selectedType == t;
            return Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: ChoiceChip(
                label: Text(t),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedType = t);
                    _search(type: t);
                  }
                },
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 8),
        // Orientation filters
        Row(
          children: [
            Text('اتجاه: ', style: AppTypography.caption),
            SizedBox(width: 8),
            ...[null, 'horizontal', 'vertical', 'square'].map((o) {
              final isSelected = _selectedOrientation == o;
              final label = o == null ? 'الكل' : o;
              return Padding(
                padding: const EdgeInsetsDirectional.only(end: 6),
                child: ChoiceChip(
                  label: Text(label, style: TextStyle(fontSize: 11)),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedOrientation = o);
                      _search(orientation: o);
                    }
                  },
                  visualDensity: VisualDensity.compact,
                ),
              );
            }).toList(),
          ],
        ),
      ],
    );
  }

  Widget _buildSuggestions() {
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _suggestedKeywords.length,
        separatorBuilder: (_, __) => SizedBox(width: 6),
        itemBuilder: (context, index) {
          final kw = _suggestedKeywords[index];
          return ActionChip(
            label: Text(kw, style: TextStyle(fontSize: 11)),
            visualDensity: VisualDensity.compact,
            onPressed: () {
              _searchController.text = kw;
              _search(query: kw);
            },
          );
        },
      ),
    );
  }

  String _resolveImageUrl(Map<String, dynamic> hit) {
    switch (_selectedQuality) {
      case 'largeImageURL':
        return hit['largeImageURL'] ?? hit['webformatURL'];
      case 'fullHDURL':
        return hit['fullHDURL'] ?? hit['largeImageURL'] ?? hit['webformatURL'];
      default:
        return hit['webformatURL'];
    }
  }

  Widget _buildGrid() {
    return BlocBuilder<PixabaySelectorCubit, PixabaySelectorState>(
      builder: (context, state) {
        if (state is PixabaySelectorLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.secondary),
          );
        }
        if (state is PixabaySelectorFailure) {
          return Center(
            child: Text(state.error, style: TextStyle(color: Colors.red)),
          );
        }
        if (state is PixabaySelectorLoaded) {
          if (state.images.isEmpty)
            return const Center(child: Text("لا توجد نتائج."));

          return NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.pixels ==
                  scrollInfo.metrics.maxScrollExtent) {
                context.read<PixabaySelectorCubit>().loadMore();
              }
              return true;
            },
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: state.images.length,
              itemBuilder: (context, index) {
                final img = state.images[index];
                return InkWell(
                  onTap: () {
                    widget.onImageSelected(
                      img.largeImageUrl.isNotEmpty
                          ? img.largeImageUrl
                          : img.webformatUrl,
                    );
                    Navigator.pop(context);
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CustomNetworkImage(
                      imageUrl: img.previewUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          );
        }
        return SizedBox();
      },
    );
  }
}
