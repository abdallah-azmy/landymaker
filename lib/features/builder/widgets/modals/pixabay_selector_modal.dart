import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/custom_network_image.dart';
import '../../controllers/pixabay_selector_cubit.dart';

class PixabaySelectorModal extends StatefulWidget {
  final String initialQuery;
  final String initialType;
  final Function(String) onImageSelected;

  const PixabaySelectorModal({
    super.key,
    required this.initialQuery,
    this.initialType = 'photo',
    required this.onImageSelected,
  });

  @override
  State<PixabaySelectorModal> createState() => _PixabaySelectorModalState();
}

class _PixabaySelectorModalState extends State<PixabaySelectorModal> {
  late final TextEditingController _searchController;
  String _selectedType = 'photo';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    _selectedType = widget.initialType;
    context.read<PixabaySelectorCubit>().searchImages(widget.initialQuery, type: _selectedType);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildSearchArea(),
          const SizedBox(height: 16),
          _buildTypeFilters(),
          const SizedBox(height: 24),
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
          icon: const Icon(Icons.close_rounded),
        ),
      ],
    );
  }

  Widget _buildSearchArea() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: "بحث...",
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: IconButton(
          icon: const Icon(Icons.send_rounded, color: AppColors.secondary),
          onPressed: () {
            context.read<PixabaySelectorCubit>().searchImages(_searchController.text, type: _selectedType);
          },
        ),
      ),
      onSubmitted: (val) {
        context.read<PixabaySelectorCubit>().searchImages(val, type: _selectedType);
      },
    );
  }

  Widget _buildTypeFilters() {
    final types = ['photo', 'illustration', 'vector'];
    return Row(
      children: types.map((t) {
        final isSelected = _selectedType == t;
        return Padding(
          padding: const EdgeInsetsDirectional.only(end: 8),
          child: ChoiceChip(
            label: Text(t),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                setState(() => _selectedType = t);
                context.read<PixabaySelectorCubit>().searchImages(_searchController.text, type: t);
              }
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGrid() {
    return BlocBuilder<PixabaySelectorCubit, PixabaySelectorState>(
      builder: (context, state) {
        if (state is PixabaySelectorLoading) {
          return const Center(child: CircularProgressIndicator(color: AppColors.secondary));
        }
        if (state is PixabaySelectorFailure) {
          return Center(child: Text(state.error, style: const TextStyle(color: Colors.red)));
        }
        if (state is PixabaySelectorLoaded) {
          if (state.images.isEmpty) return const Center(child: Text("لا توجد نتائج."));

          return NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
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
                    widget.onImageSelected(img.webformatUrl);
                    Navigator.pop(context);
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CustomNetworkImage(imageUrl: img.previewUrl, fit: BoxFit.cover),
                  ),
                );
              },
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}
