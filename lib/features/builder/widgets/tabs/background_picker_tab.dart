import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../controllers/builder_cubit.dart';
import '../../controllers/builder_state.dart';
import '../../services/stock_image_service.dart';

class BackgroundPickerTab extends StatefulWidget {
  final LandingPageBuilderCubit cubit;
  final BuilderLoaded state;

  const BackgroundPickerTab({
    super.key,
    required this.cubit,
    required this.state,
  });

  @override
  State<BackgroundPickerTab> createState() => _BackgroundPickerTabState();
}

class _BackgroundPickerTabState extends State<BackgroundPickerTab> {
  final TextEditingController _searchController = TextEditingController();
  final StockImageService _imageService = StockImageService();
  
  List<String> _images = [];
  bool _isLoading = false;
  String _currentQuery = '';

  @override
  void initState() {
    super.initState();
    _searchImages('background pattern');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchImages(String query) async {
    setState(() {
      _isLoading = true;
      _currentQuery = query;
    });

    try {
      final results = await _imageService.searchImages(query);
      if (mounted) {
        setState(() {
          _images = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LandingPageBuilderCubit, BuilderState>(
      builder: (context, dynamicState) {
        if (dynamicState is! BuilderLoaded) return const SizedBox.shrink();
        
        final currentBgUrl = dynamicState.theme.globalBgImageUrl;
        final hasBackground = currentBgUrl != null && currentBgUrl.isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("خلفية الصفحة", style: AppTypography.h3),
            const SizedBox(height: 8),
            Text(
              "اختر صورة لجعلها خلفية لكامل صفحة الهبوط. سيؤدي هذا إلى إخفاء ألوان خلفية الأقسام.",
              style: AppTypography.caption,
            ),
            const SizedBox(height: 16),
            
            // Search Bar
            TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'ابحث عن صور (مثال: dark, tech, abstract)...',
                hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                filled: true,
                fillColor: AppColors.cardBg,
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.primary),
                  onPressed: () {
                    if (_searchController.text.trim().isNotEmpty) {
                      _searchImages(_searchController.text.trim());
                    }
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  _searchImages(value.trim());
                }
              },
            ),
            const SizedBox(height: 20),

            // Remove Background Button (if active)
            if (hasBackground)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      widget.cubit.updateThemeProperty('globalBgImageUrl', null);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.dangerRed.withValues(alpha: 0.1),
                      foregroundColor: AppColors.dangerRed,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppColors.dangerRed),
                      ),
                    ),
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: const Text('إزالة صورة الخلفية (استعادة الألوان)'),
                  ),
                ),
              ),

            // Results Grid
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            else if (_images.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    children: [
                      const Icon(Icons.image_not_supported_rounded, color: AppColors.textMuted, size: 48),
                      const SizedBox(height: 16),
                      Text("لم يتم العثور على صور لـ '$_currentQuery'", style: AppTypography.bodyMedium),
                    ],
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 16 / 9,
                ),
                itemCount: _images.length,
                itemBuilder: (context, index) {
                  final imageUrl = _images[index];
                  final isSelected = currentBgUrl == imageUrl;

                  return GestureDetector(
                    onTap: () {
                      widget.cubit.updateThemeProperty('globalBgImageUrl', imageUrl);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                          width: isSelected ? 3 : 1,
                        ),
                        image: DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                )
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(9),
                                color: Colors.black.withValues(alpha: 0.4),
                              ),
                              child: const Center(
                                child: Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 32),
                              ),
                            )
                          : null,
                    ),
                  );
                },
              ),
              
            const SizedBox(height: 32),
          ],
        );
      },
    );
  }
}
