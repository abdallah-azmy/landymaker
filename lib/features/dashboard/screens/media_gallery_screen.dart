import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/localization/localization_cubit.dart';
import '../../../core/responsive/responsive_utils.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../core/widgets/atoms/primary_button.dart';
import '../../../core/utils/file_utils.dart';
import '../../../core/utils/toast_service.dart';
import '../controllers/media_gallery_cubit.dart';
import '../controllers/media_gallery_state.dart';
import '../../../../core/widgets/custom_network_image.dart';

class MediaGalleryScreen extends StatefulWidget {
  const MediaGalleryScreen({super.key});

  @override
  State<MediaGalleryScreen> createState() => _MediaGalleryScreenState();
}

class _MediaGalleryScreenState extends State<MediaGalleryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MediaGalleryCubit>().loadImages();
  }

  Future<void> _pickAndUpload() async {
    final file = await FileUtils.pickImage();

    if (file != null) {
      if (mounted) {
        context.read<MediaGalleryCubit>().uploadImage(file);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationCubit>();
    final isMobile = ResponsiveLayout.isMobile(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocListener<MediaGalleryCubit, MediaGalleryState>(
        listener: (context, state) {
          if (state is MediaGalleryLoaded) {
            if (state.successMessage != null) {
              ToastService.showSuccess(context, message: state.successMessage!);
            }
            if (state.errorMessage != null) {
              ToastService.showError(context, message: state.errorMessage!);
            }
          }
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(ResponsiveUtils.getPadding(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(loc, isMobile),
              SizedBox(height: 32),
              _buildGalleryContent(loc, isMobile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(LocalizationCubit loc, bool isMobile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.translate('gallery'),
              style: AppTypography.h1.copyWith(fontSize: isMobile ? 28 : 32),
            ),
            SizedBox(height: 8),
            Text(
              loc.isRtl 
                ? "أدر صورك المرفوعة واستخدمها في صفحاتك."
                : "Manage your uploaded images and use them in your pages.",
              style: AppTypography.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        if (!isMobile)
          PrimaryButton(
            text: loc.translate('upload_image'),
            icon: Icons.cloud_upload_rounded,
            onPressed: _pickAndUpload,
            width: 180,
          ),
      ],
    );
  }

  Widget _buildGalleryContent(LocalizationCubit loc, bool isMobile) {
    return BlocBuilder<MediaGalleryCubit, MediaGalleryState>(
      builder: (context, state) {
        if (state is MediaGalleryLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(60.0),
              child: CircularProgressIndicator(color: AppColors.secondary),
            ),
          );
        }

        if (state is MediaGalleryFailure) {
          return Center(child: Text(state.message, style: TextStyle(color: AppColors.dangerRed)));
        }

        if (state is MediaGalleryLoaded) {
          final images = state.images;

          if (images.isEmpty) {
            return _buildEmptyState(loc);
          }

          return Column(
            children: [
              if (isMobile) ...[
                PrimaryButton(
                  text: loc.translate('upload_image'),
                  icon: Icons.cloud_upload_rounded,
                  onPressed: _pickAndUpload,
                  width: double.infinity,
                ),
                SizedBox(height: 24),
              ],
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isMobile ? 2 : 4,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1,
                ),
                itemCount: images.length,
                itemBuilder: (context, index) {
                  final img = images[index];
                  return _ImageGalleryCard(
                    imageUrl: img['url'],
                    fileName: img['name'],
                    onDelete: () => context.read<MediaGalleryCubit>().deleteImage(
                      img['name'],
                      source: img['source'],
                      assetId: img['id'],
                    ),
                  );
                },
              ),
            ],
          );
        }

        return SizedBox();
      },
    );
  }

  Widget _buildEmptyState(LocalizationCubit loc) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(60),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(
            Icons.image_not_supported_rounded,
            size: 80,
            color: Colors.white12,
          ),
          SizedBox(height: 24),
          Text(
            loc.isRtl ? "لا توجد صور مرفوعة" : "No images uploaded yet",
            style: AppTypography.h3,
          ),
          SizedBox(height: 12),
          Text(
            loc.isRtl 
              ? "ابدأ برفع صورك الاحترافية لتتمكن من استخدامها في بناء صفحاتك."
              : "Start uploading your professional images to use them in your pages.",
            style: AppTypography.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          PrimaryButton(
            text: loc.translate('upload_image'),
            icon: Icons.cloud_upload_rounded,
            onPressed: _pickAndUpload,
            width: 200,
          ),
        ],
      ),
    );
  }
}

class _ImageGalleryCard extends StatefulWidget {
  final String imageUrl;
  final String fileName;
  final VoidCallback onDelete;

  const _ImageGalleryCard({
    required this.imageUrl,
    required this.fileName,
    required this.onDelete,
  });

  @override
  State<_ImageGalleryCard> createState() => _ImageGalleryCardState();
}

class _ImageGalleryCardState extends State<_ImageGalleryCard> {
  bool _isHovered = false;

  void _copyLink() {
    Clipboard.setData(ClipboardData(text: widget.imageUrl));
    ToastService.showSuccess(context, message: "تم نسخ رابط الصورة!");
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered ? AppColors.secondary : Theme.of(context).colorScheme.outlineVariant,
            width: 2,
          ),
          boxShadow: _isHovered ? [
            BoxShadow(
              color: AppColors.secondary.withValues(alpha: 0.2),
              blurRadius: 12,
              spreadRadius: 2,
            )
          ] : null,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomNetworkImage(
              imageUrl: widget.imageUrl,
              fit: BoxFit.cover,
            ),
            if (_isHovered)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.8),
                    ],
                  ),
                ),
              ),
            if (_isHovered)
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ActionButton(
                      icon: Icons.copy_rounded,
                      onPressed: _copyLink,
                      tooltip: "Copy Link",
                    ),
                    _ActionButton(
                      icon: Icons.delete_outline_rounded,
                      color: AppColors.dangerRed,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                            title: const Text("حذف الصورة"),
                            content: const Text("هل أنت متأكد من حذف هذه الصورة؟ لا يمكن التراجع عن هذا الإجراء."),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("إلغاء"),
                              ),
                              TextButton(
                                onPressed: () {
                                  widget.onDelete();
                                  Navigator.pop(context);
                                },
                                child: const Text("حذف", style: TextStyle(color: AppColors.dangerRed)),
                              ),
                            ],
                          ),
                        );
                      },
                      tooltip: "Delete Image",
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

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;
  final Color? color;

  const _ActionButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: color ?? Colors.white,
          ),
        ),
      ),
    );
  }
}
