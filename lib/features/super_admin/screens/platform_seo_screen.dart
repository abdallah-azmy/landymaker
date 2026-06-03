import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/organisms/responsive_data_table.dart';
import '../../../core/widgets/atoms/primary_button.dart';
import '../../../core/widgets/atoms/custom_text_field.dart';
import '../controllers/super_admin_cubit.dart';
import '../controllers/super_admin_state.dart';

class PlatformSeoScreen extends StatefulWidget {
  const PlatformSeoScreen({super.key});

  @override
  State<PlatformSeoScreen> createState() => _PlatformSeoScreenState();
}

class _PlatformSeoScreenState extends State<PlatformSeoScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh metrics if needed to ensure SEO data is loaded
    context.read<SuperAdminCubit>().fetchAdminMetrics();
  }

  void _showEditSeoDialog(Map<String, dynamic>? seoData) {
    final isNew = seoData == null;
    final pathController = TextEditingController(text: seoData?['route_path'] ?? '/');
    final titleController = TextEditingController(text: seoData?['meta_title'] ?? '');
    final descController = TextEditingController(text: seoData?['meta_description'] ?? '');
    final imgController = TextEditingController(text: seoData?['og_image_url'] ?? 'https://landymaker.com/logo_social.webp');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        title: Text(isNew ? "Add New SEO Route" : "Edit SEO: ${seoData['route_path']}"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: pathController,
                hintText: "Route Path (e.g. / or /pricing)",
                enabled: isNew,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: titleController,
                hintText: "Meta Title",
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: descController,
                hintText: "Meta Description",
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: imgController,
                hintText: "OG Image URL",
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          PrimaryButton(
            text: "Save Configuration",
            width: 150,
            onPressed: () {
              final route = pathController.text.trim();
              if (route.isEmpty) return;

              context.read<SuperAdminCubit>().updatePlatformSeo(route, {
                'meta_title': titleController.text,
                'meta_description': descController.text,
                'og_image_url': imgController.text,
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SuperAdminCubit, SuperAdminState>(
      listener: (context, stateListener) {
        if (stateListener is SuperAdminFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(stateListener.message),
              backgroundColor: AppColors.dangerRed,
            ),
          );
        }
      },
      child: BlocBuilder<SuperAdminCubit, SuperAdminState>(
        builder: (context, state) {
          if (state is! SuperAdminLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("إعدادات Platform SEO", style: AppTypography.h3),
                    PrimaryButton(
                      text: "Add New Route",
                      width: 150,
                      onPressed: () => _showEditSeoDialog(null),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  "هذه الواجهة مخصصة لإدارة الـ SEO الخاص بالمنصة فقط (مثل الصفحة الرئيسية، صفحة الأسعار). التعديلات هنا تنعكس فوراً وتؤثر على المنصة بالكامل وليس صفحات المستخدمين.",
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                ResponsiveDataTable(
                  title: "Dynamic Routes",
                  headers: const ["Route Path", "Title", "Description", "Action"],
                  rows: state.platformSeoSettings.map((seo) {
                    return [
                      Text(seo['route_path'], style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
                      Text(seo['meta_title'] ?? '-', maxLines: 1, overflow: TextOverflow.ellipsis),
                      SizedBox(
                        width: 200,
                        child: Text(seo['meta_description'] ?? '-', maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_rounded, color: AppColors.secondary),
                        onPressed: () => _showEditSeoDialog(seo),
                      ),
                    ];
                  }).toList(),
                  emptyMessage: "No SEO settings configured.",
                  onSearch: (val) {},
                  onSort: (val) {},
                  onPageChanged: (p) {},
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
