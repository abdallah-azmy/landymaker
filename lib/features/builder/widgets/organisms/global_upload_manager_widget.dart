import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../controllers/upload_manager_cubit.dart';
import '../../../../injection_container.dart';
import '../../models/selected_image_data.dart';

class GlobalUploadManagerWidget extends StatelessWidget {
  const GlobalUploadManagerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UploadManagerCubit, UploadManagerState>(
      bloc: sl<UploadManagerCubit>(),
      builder: (context, state) {
        if (state.uploads.isEmpty) return SizedBox.shrink();

        return Container(
          width: 240,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                spreadRadius: 2,
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.cloud_upload_rounded, color: AppColors.primary, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'جاري الرفع...',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const ClampingScrollPhysics(),
                  itemCount: state.uploads.length,
                  itemBuilder: (context, index) {
                    final task = state.uploads.values.elementAt(index);
                    return _buildUploadRow(context, task);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUploadRow(BuildContext context, UploadTask task) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Thumbnail
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (task.data.source == SelectedImageSource.local && task.data.bytes != null)
                    Image.memory(task.data.bytes!, fit: BoxFit.cover, cacheWidth: 100)
                  else if (task.data.url != null)
                    Image.network(task.data.url!, fit: BoxFit.cover, cacheWidth: 100)
                  else
                    Icon(Icons.image, color: Colors.white24),
                  
                  // Dark overlay for progress visibility
                  Container(color: Colors.black54),
                  
                  // Circular Progress inside Thumbnail
                  if (task.error == null)
                    Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          value: task.progress > 0 ? task.progress : null,
                          strokeWidth: 2.5,
                          color: AppColors.primary,
                          backgroundColor: Colors.white24,
                        ),
                      ),
                    ),
                  
                  if (task.error != null)
                    const Center(child: Icon(Icons.error, color: AppColors.dangerRed, size: 20)),
                ],
              ),
            ),
          ),
          SizedBox(width: 12),
          
          // Progress text / Status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.error != null ? 'فشل الرفع' : '${(task.progress * 100).toInt()}%',
                  style: TextStyle(
                    color: task.error != null ? AppColors.dangerRed : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                if (task.error != null)
                  Text(
                    'حاول مرة أخرى',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11),
                  ),
              ],
            ),
          ),
          
          // Cancel Button
          IconButton(
            icon: Icon(Icons.close_rounded, color: Colors.white54, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: () => sl<UploadManagerCubit>().cancelUpload(task.id),
          ),
        ],
      ),
    );
  }
}
