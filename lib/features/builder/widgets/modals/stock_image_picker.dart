import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/atoms/custom_text_field.dart';
import '../../services/stock_image_service.dart';

class StockImagePicker extends StatefulWidget {
  final Function(String) onImageSelected;

  const StockImagePicker({super.key, required this.onImageSelected});

  @override
  State<StockImagePicker> createState() => _StockImagePickerState();
}

class _StockImagePickerState extends State<StockImagePicker> {
  final _service = StockImageService();
  List<String> _images = [];
  bool _isLoading = false;
  final _searchController = TextEditingController();

  Future<void> _search(String query) async {
    if (query.isEmpty) return;
    setState(() => _isLoading = true);
    final results = await _service.searchImages(query);
    setState(() {
      _images = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("بحث عن صور احترافية", style: AppTypography.h3),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _searchController,
            hintText: "ابحث عن (مثلاً: مطعم، رياضة، سيارات...)",
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppColors.secondary,
            ),
            onSubmitted: _search,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.secondary,
                    ),
                  )
                : _images.isEmpty
                ? Center(
                    child: Text(
                      "ابدأ البحث للعثور على صور رائعة",
                      style: AppTypography.caption,
                    ),
                  )
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1,
                        ),
                    itemCount: _images.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          widget.onImageSelected(_images[index]);
                          Navigator.pop(context);
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            _images[index],
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
