import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/builder/controllers/upload_manager_cubit.dart';
import '../../features/builder/models/selected_image_data.dart';
import '../../injection_container.dart';

/// A reusable, robust network image component.
/// It displays a skeleton/shimmer loader while the image is downloading,
/// and provides an error icon gracefully if the URL fails to load.
/// This prevents Layout shifts by maintaining constraints.
class CustomNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadiusGeometry borderRadius;

  const CustomNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = BorderRadius.zero,
  });

  @override
  Widget build(BuildContext context) {
    // Basic validation to prevent crashing on empty URLs.
    if (imageUrl.isEmpty) {
      return _buildErrorWidget();
    }

    if (imageUrl.startsWith('upload://')) {
      return BlocBuilder<UploadManagerCubit, UploadManagerState>(
        bloc: sl<UploadManagerCubit>(),
        builder: (context, state) {
          final task = state.uploads[imageUrl];
          if (task == null) {
            // Task completed or removed, but string hasn't updated yet
            return _buildLoadingWidget();
          }

          Widget underlyingImage;
          if (task.data.source == SelectedImageSource.local && task.data.bytes != null) {
            underlyingImage = Image.memory(
              task.data.bytes!,
              width: width,
              height: height,
              fit: fit,
              cacheWidth: width?.isFinite == true ? (width! * 2).toInt() : 1200,
            );
          } else if (task.data.source == SelectedImageSource.pixabay && task.data.url != null) {
            underlyingImage = CachedNetworkImage(
              imageUrl: task.data.url!,
              width: width,
              height: height,
              fit: fit,
              memCacheWidth: width?.isFinite == true ? (width! * 2).toInt() : 1200,
              maxWidthDiskCache: 1200,
            );
          } else {
            underlyingImage = _buildLoadingWidget();
          }

          return ClipRRect(
            borderRadius: borderRadius,
            child: Stack(
              children: [
                underlyingImage,
                // Overlay
                Positioned.fill(
                  child: Container(
                    color: Colors.black54,
                    child: Center(
                      child: task.error != null
                          ? _buildUploadErrorOverlay(task)
                          : _buildUploadProgressOverlay(task),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    final uri = Uri.tryParse(imageUrl);
    if (uri == null || !uri.isAbsolute) {
      return _buildErrorWidget();
    }

    if (kIsWeb) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: Image.network(
          imageUrl,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildLoadingWidget();
          },
        ),
      );
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        memCacheWidth: width?.isFinite == true ? (width! * 2).toInt() : 1200,
        maxWidthDiskCache: 1200,
        placeholder: (context, url) => _buildLoadingWidget(),
        errorWidget: (context, url, error) => _buildErrorWidget(),
        // Adding fadeIn duration for a polished user experience.
        fadeInDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade800,
      highlightColor: Colors.grey.shade700,
      child: Container(
        width: width,
        height: height ?? 200.0,
        color: Colors.black, // Background color that gets shimmered
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height ?? 200.0,
      color: Colors.grey.shade900,
      child: const Center(
        child: Icon(
          Icons.broken_image_rounded,
          color: Colors.grey,
          size: 32,
        ),
      ),
    );
  }

  Widget _buildUploadProgressOverlay(UploadTask task) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                value: task.progress > 0 ? task.progress : null,
                color: const Color(0xFF00E5FF),
                backgroundColor: Colors.white24,
              ),
            ),
            if (task.progress > 0)
              Text(
                '${(task.progress * 100).toInt()}%',
                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
          ],
        ),
        SizedBox(height: 8),
        IconButton(
          icon: Icon(Icons.cancel, color: Colors.white70),
          onPressed: () => sl<UploadManagerCubit>().cancelUpload(task.id),
        ),
      ],
    );
  }

  Widget _buildUploadErrorOverlay(UploadTask task) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.error_outline, color: Colors.redAccent, size: 32),
        SizedBox(height: 8),
        const Text('فشل الرفع', style: TextStyle(color: Colors.white, fontSize: 12)),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.cancel, color: Colors.white70),
              onPressed: () => sl<UploadManagerCubit>().cancelUpload(task.id),
            ),
          ],
        ),
      ],
    );
  }
}
