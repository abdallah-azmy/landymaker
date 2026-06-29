import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/atoms/primary_button.dart';
import '../../controllers/builder_cubit.dart';

part 'section_library/section_data.dart';
part 'section_library/section_variant_card.dart';
part 'section_library/dual_mini_preview.dart';

class SectionLibraryModal extends StatefulWidget {
  const SectionLibraryModal({super.key});

  @override
  State<SectionLibraryModal> createState() => _SectionLibraryModalState();
}

class _SectionLibraryModalState extends State<SectionLibraryModal> {
  String _searchQuery = "";
  String _selectedCategory = "all";

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LandingPageBuilderCubit>();

    final filteredSections = _sections.where((section) {
      final q = _searchQuery.toLowerCase();
      final matchesSearch =
          section.name.toLowerCase().contains(q) ||
          section.desc.toLowerCase().contains(q) ||
          section.variants.any((variant) => variant.name.toLowerCase().contains(q));
      final matchesCategory =
          _selectedCategory == 'all' ||
          section.category == _selectedCategory ||
          (_selectedCategory == 'popular' && section.popular);
      return matchesSearch && matchesCategory;
    }).toList();

    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.9,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.88),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text("إضافة قسم جديد", style: AppTypography.h3),
              SizedBox(height: 16),
              TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: "بحث عن قسم أو شكل...",
                  hintStyle: AppTypography.bodyMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 14),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categories.entries.map((cat) {
                    final isSelected = _selectedCategory == cat.key;
                    return Padding(
                      padding: const EdgeInsetsDirectional.only(end: 8),
                      child: ChoiceChip(
                        label: Text(
                          cat.value,
                          style: AppTypography.caption.copyWith(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (_) => setState(() => _selectedCategory = cat.key),
                        selectedColor: Theme.of(context).colorScheme.primary,
                        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? Colors.transparent : Theme.of(context).colorScheme.outlineVariant,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 18),
              Expanded(
                child: filteredSections.isEmpty
                    ? _buildEmptyState()
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final bool isSmall = constraints.maxWidth < 600;
                          return GridView.builder(
                            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 340,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              childAspectRatio: isSmall ? 0.62 : 0.70,
                            ),
                            itemCount: filteredSections.length,
                            itemBuilder: (context, index) {
                              final section = filteredSections[index];
                              return _SectionVariantCard(
                                key: ValueKey(
                                  "${section.type}_${_selectedCategory}_${_searchQuery}_$index",
                                ),
                                section: section,
                                cubit: cubit,
                                index: index,
                              );
                            },
                          );
                        },
                      ),
              ),
              SizedBox(height: 14),
              PrimaryButton(
                text: "إغلاق",
                isSecondary: true,
                width: double.infinity,
                onPressed: () => Navigator.pop(context),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 48, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
          SizedBox(height: 12),
          Text("لا توجد أقسام تطابق بحثك", style: AppTypography.bodyMedium),
        ],
      ),
    );
  }
}
