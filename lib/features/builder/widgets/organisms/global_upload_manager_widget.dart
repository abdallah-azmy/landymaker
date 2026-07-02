import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../controllers/upload_manager_cubit.dart';
import '../../../../injection_container.dart';
import '../../../../core/widgets/atoms/cube_progress.dart';
import '../../../../core/localization/localization_cubit.dart';
import '../../models/selected_image_data.dart';

class GlobalUploadManagerWidget extends StatefulWidget {
  const GlobalUploadManagerWidget({super.key});

  @override
  State<GlobalUploadManagerWidget> createState() => _GlobalUploadManagerWidgetState();
}

class _GlobalUploadManagerWidgetState extends State<GlobalUploadManagerWidget>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = true;
  Timer? _autoDismissTimer;
  late AnimationController _animController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
    _expandAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOutCubic,
      reverseCurve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    });
  }

  void _ensureExpanded() {
    if (!_isExpanded) {
      setState(() {
        _isExpanded = true;
        _animController.forward();
      });
    }
  }

  void _maybeAutoDismiss(UploadManagerState uploadState) {
    final sp = uploadState.saveProcess;
    if (sp == null || sp.phase != SavePhase.completed) {
      _autoDismissTimer?.cancel();
      return;
    }
    if (_autoDismissTimer != null && _autoDismissTimer!.isActive) return;

    _autoDismissTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        sl<UploadManagerCubit>().clearSaveProcess();
      }
    });
  }

  double _responsiveExpandedWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) {
      return (screenWidth - 20).clamp(200.0, 340.0);
    }
    return 340;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UploadManagerCubit, UploadManagerState>(
      bloc: sl<UploadManagerCubit>(),
      listener: (context, uploadState) {
        _maybeAutoDismiss(uploadState);
      },
      builder: (context, uploadState) {
        final uploadCount = uploadState.uploads.length;
        final hasSaveProcess = uploadState.saveProcess != null;

        if (uploadCount == 0 && !hasSaveProcess) {
          if (_isExpanded) {
            _isExpanded = false;
            _animController.reverse();
          }
          return const SizedBox.shrink();
        }

        if (hasSaveProcess) {
          return _buildSaveProcessPanel(context, uploadState);
        }

        // Regular upload overlay
        final loc = context.read<LocalizationCubit>();
        final hasErrors = uploadState.uploads.values.any((t) => t.error != null);
        final allDone = uploadState.uploads.values.every((t) => t.progress >= 1.0 && t.error == null);

        return Directionality(
          textDirection: TextDirection.rtl,
          child: _buildUploadPanel(context, loc, uploadState, uploadCount, hasErrors, allDone),
        );
      },
    );
  }

  // ──────────────────────────────────────────────
  // SAVE PROCESS OVERLAY
  // ──────────────────────────────────────────────

  Widget _buildSaveProcessPanel(BuildContext context, UploadManagerState uploadState) {
    final saveProcess = uploadState.saveProcess!;
    final colorScheme = Theme.of(context).colorScheme;
    final loc = context.read<LocalizationCubit>();
    final useRtl = loc.locale.languageCode == 'ar';
    final expandedWidth = _responsiveExpandedWidth(context);

    return Directionality(
      textDirection: useRtl ? TextDirection.rtl : TextDirection.ltr,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        alignment: Alignment.bottomCenter,
        child: Container(
          width: _isExpanded ? expandedWidth : null,
          constraints: _isExpanded
              ? BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7)
              : null,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(_isExpanded ? 16 : 28),
            border: Border.all(
              color: saveProcess.phase == SavePhase.error
                  ? colorScheme.error.withValues(alpha: 0.4)
                  : colorScheme.outlineVariant,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: saveProcess.phase == SavePhase.error
                    ? colorScheme.error.withValues(alpha: 0.1)
                    : colorScheme.primary.withValues(alpha: 0.08),
                blurRadius: 24,
              ),
            ],
          ),
          child: _isExpanded
              ? _buildSaveProcessExpanded(context, loc, uploadState, saveProcess, colorScheme)
              : _buildSaveProcessMinimized(context, loc, saveProcess, colorScheme),
        ),
      ),
    );
  }

  Widget _buildSaveProcessMinimized(
    BuildContext context,
    LocalizationCubit loc,
    SaveProcessState saveProcess,
    ColorScheme colorScheme,
  ) {
    final isDone = saveProcess.phase == SavePhase.completed;
    final isError = saveProcess.phase == SavePhase.error;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: _toggleExpanded,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isDone
                      ? Colors.green
                      : isError
                          ? colorScheme.error
                          : colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: isDone
                      ? Icon(Icons.check_circle_rounded, color: Colors.white, size: 18)
                      : isError
                          ? Icon(Icons.warning_amber_rounded, color: colorScheme.onError, size: 16)
                          : CubeProgress(size: 18, color: colorScheme.onPrimary),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  loc.translate('save_progress_title'),
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.expand_less_rounded, color: colorScheme.onSurfaceVariant, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaveProcessExpanded(
    BuildContext context,
    LocalizationCubit loc,
    UploadManagerState uploadState,
    SaveProcessState saveProcess,
    ColorScheme colorScheme,
  ) {
    final isDone = saveProcess.phase == SavePhase.completed;
    final isError = saveProcess.phase == SavePhase.error;
    final isUploading = saveProcess.phase == SavePhase.uploadingImages;
    final isIdle = saveProcess.phase == SavePhase.idle;
    final isSaving = saveProcess.phase == SavePhase.savingToDb;
    final hasUploads = uploadState.uploads.isNotEmpty;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSaveHeader(context, loc, saveProcess, colorScheme),
          _buildSavePageInfo(context, loc, saveProcess, colorScheme),
          _buildSaveStatus(context, loc, saveProcess, colorScheme, isUploading, isSaving, isDone, isError, isIdle),
          if (hasUploads && (isUploading || isIdle || (!isDone && !isError)))
            _buildSaveUploads(context, loc, uploadState, colorScheme),
          if (isDone || isError)
            _buildSaveFooter(context, loc, saveProcess, colorScheme, isDone, isError),
        ],
      ),
    );
  }

  Widget _buildSaveHeader(
    BuildContext context,
    LocalizationCubit loc,
    SaveProcessState saveProcess,
    ColorScheme colorScheme,
  ) {
    final isDone = saveProcess.phase == SavePhase.completed;
    final isError = saveProcess.phase == SavePhase.error;
    final canDismiss = isDone || isError;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isDone
                  ? Colors.green.withValues(alpha: 0.15)
                  : isError
                      ? colorScheme.error.withValues(alpha: 0.15)
                      : colorScheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: isDone
                  ? Icon(Icons.check_circle_rounded, color: Colors.green, size: 18)
                  : isError
                      ? Icon(Icons.warning_amber_rounded, color: colorScheme.error, size: 18)
                      : CubeProgress(size: 16, color: colorScheme.primary),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              loc.translate('save_progress_title'),
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          if (canDismiss)
            IconButton(
              icon: Icon(Icons.close_rounded, size: 18, color: colorScheme.onSurfaceVariant),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              onPressed: () => sl<UploadManagerCubit>().clearSaveProcess(),
              tooltip: loc.translate('save_progress_dismiss'),
            )
          else
            IconButton(
              icon: Icon(Icons.remove_rounded, size: 18, color: colorScheme.onSurfaceVariant),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              onPressed: _toggleExpanded,
              tooltip: loc.translate('upload_minimize'),
            ),
        ],
      ),
    );
  }

  Widget _buildSavePageInfo(
    BuildContext context,
    LocalizationCubit loc,
    SaveProcessState saveProcess,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Icon(Icons.language_rounded, size: 14, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              loc.translate('save_progress_page_label')
                  .replaceAll('{subdomain}', saveProcess.subdomain),
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 11,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveStatus(
    BuildContext context,
    LocalizationCubit loc,
    SaveProcessState saveProcess,
    ColorScheme colorScheme,
    bool isUploading,
    bool isSaving,
    bool isDone,
    bool isError,
    bool isIdle,
  ) {
    Widget? icon;
    Color? iconColor;

    if (isDone) {
      icon = Icon(Icons.check_circle_rounded, color: Colors.green, size: 24);
      iconColor = Colors.green;
    } else if (isError) {
      icon = Icon(Icons.error_rounded, color: colorScheme.error, size: 24);
      iconColor = colorScheme.error;
    } else if (isIdle || isUploading || isSaving) {
      icon = CubeProgress(size: 22, color: colorScheme.primary);
      iconColor = colorScheme.primary;
    }

    final statusText = saveProcess.statusText.isNotEmpty
        ? saveProcess.statusText
        : isIdle
            ? loc.translate('save_progress_uploading')
            : isUploading
                ? loc.translate('save_progress_uploading')
                : isSaving
                    ? loc.translate('save_progress_saving')
                        .replaceAll('{subdomain}', saveProcess.subdomain)
                    : isDone
                        ? loc.translate('save_progress_complete')
                            .replaceAll('{subdomain}', saveProcess.subdomain)
                        : isError
                            ? loc.translate('save_progress_error')
                                .replaceAll('{error}', saveProcess.errorMessage ?? '')
                            : '';

    final errorMsg = isError && saveProcess.errorMessage != null
        ? saveProcess.errorMessage
        : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: icon,
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    color: iconColor ?? colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                if (errorMsg != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    errorMsg,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
                if (!isDone && !isError) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.info_outline_rounded, size: 11, color: colorScheme.primary),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            loc.translate('save_progress_wait_msg'),
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (isDone) ...[
                  const SizedBox(height: 4),
                  Text(
                    loc.translate('save_dismiss_tooltip'),
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveUploads(
    BuildContext context,
    LocalizationCubit loc,
    UploadManagerState uploadState,
    ColorScheme colorScheme,
  ) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 200),
      child: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        physics: const ClampingScrollPhysics(),
        itemCount: uploadState.uploads.length,
        itemBuilder: (context, index) {
          final task = uploadState.uploads.values.elementAt(index);
          return _buildUploadRow(context, loc, task, colorScheme);
        },
      ),
    );
  }

  Widget _buildSaveFooter(
    BuildContext context,
    LocalizationCubit loc,
    SaveProcessState saveProcess,
    ColorScheme colorScheme,
    bool isDone,
    bool isError,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: isDone
                ? Colors.green.withValues(alpha: 0.1)
                : colorScheme.error.withValues(alpha: 0.1),
            foregroundColor: isDone ? Colors.green.shade700 : colorScheme.error,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          icon: Icon(
            isDone ? Icons.check_circle_rounded : Icons.close_rounded,
            size: 18,
          ),
          label: Text(
            isDone
                ? loc.translate('save_progress_dismiss')
                : loc.translate('close'),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          onPressed: () => sl<UploadManagerCubit>().clearSaveProcess(),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // REGULAR UPLOAD OVERLAY
  // ──────────────────────────────────────────────

  Widget _buildUploadPanel(
    BuildContext context,
    LocalizationCubit loc,
    UploadManagerState uploadState,
    int uploadCount,
    bool hasErrors,
    bool allDone,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final expandedWidth = _responsiveExpandedWidth(context);

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      alignment: Alignment.bottomCenter,
      child: Container(
        width: _isExpanded ? expandedWidth : null,
        constraints: _isExpanded
            ? BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.65)
            : null,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(_isExpanded ? 16 : 28),
          border: Border.all(
            color: hasErrors ? colorScheme.error.withValues(alpha: 0.4) : colorScheme.outlineVariant,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: hasErrors
                  ? colorScheme.error.withValues(alpha: 0.1)
                  : colorScheme.primary.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: _isExpanded
            ? _buildUploadExpanded(context, loc, uploadState, uploadCount, hasErrors, allDone)
            : _buildUploadMinimized(context, loc, uploadCount, hasErrors),
      ),
    );
  }

  Widget _buildUploadMinimized(
    BuildContext context,
    LocalizationCubit loc,
    int uploadCount,
    bool hasErrors,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: _toggleExpanded,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: hasErrors ? colorScheme.error : colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: hasErrors
                      ? Icon(Icons.warning_amber_rounded, color: colorScheme.onError, size: 16)
                      : CubeProgress(size: 18, color: colorScheme.onPrimary),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$uploadCount',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  hasErrors ? loc.translate('upload_failed') : loc.translate('upload_pending'),
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.expand_less_rounded, color: colorScheme.onSurfaceVariant, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadExpanded(
    BuildContext context,
    LocalizationCubit loc,
    UploadManagerState uploadState,
    int uploadCount,
    bool hasErrors,
    bool allDone,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildUploadHeader(context, loc, uploadCount, hasErrors, allDone, colorScheme),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 280),
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const ClampingScrollPhysics(),
              itemCount: uploadState.uploads.length,
              itemBuilder: (context, index) {
                final task = uploadState.uploads.values.elementAt(index);
                return _buildUploadRow(context, loc, task, colorScheme);
              },
            ),
          ),
          _buildUploadFooter(context, loc, allDone, colorScheme),
        ],
      ),
    );
  }

  Widget _buildUploadHeader(
    BuildContext context,
    LocalizationCubit loc,
    int uploadCount,
    bool hasErrors,
    bool allDone,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: allDone
                  ? Colors.green.withValues(alpha: 0.15)
                  : hasErrors
                      ? colorScheme.error.withValues(alpha: 0.15)
                      : colorScheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: allDone
                  ? Icon(Icons.check_circle_rounded, color: Colors.green, size: 18)
                  : hasErrors
                      ? Icon(Icons.warning_amber_rounded, color: colorScheme.error, size: 18)
                      : CubeProgress(size: 16, color: colorScheme.primary),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              allDone
                  ? loc.translate('upload_complete')
                  : hasErrors
                      ? loc.translate('upload_failed')
                      : loc.translate('uploads_active').replaceAll('{count}', uploadCount.toString()),
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close_rounded, size: 18, color: colorScheme.onSurfaceVariant),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            onPressed: _toggleExpanded,
            tooltip: loc.translate('upload_minimize'),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadRow(
    BuildContext context,
    LocalizationCubit loc,
    UploadTask task,
    ColorScheme colorScheme,
  ) {
    final isError = task.error != null;
    final isComplete = task.progress >= 1.0 && !isError;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          // Thumbnail with progress
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (task.data.source == SelectedImageSource.local && task.data.bytes != null)
                    Image.memory(task.data.bytes!, fit: BoxFit.cover, cacheWidth: 80)
                  else if (task.data.url != null)
                    Image.network(task.data.url!, fit: BoxFit.cover, cacheWidth: 80)
                  else
                    Icon(Icons.image_outlined, color: colorScheme.onSurfaceVariant, size: 18),
                  if (!isComplete)
                    Container(color: Colors.black45),
                  if (!isComplete && !isError)
                    Center(
                      child: CubeProgress(
                        size: 18,
                        color: colorScheme.primary,
                        value: task.progress > 0 ? task.progress : null,
                      ),
                    ),
                  if (isError)
                    Center(child: Icon(Icons.error, color: colorScheme.error, size: 16)),
                  if (isComplete)
                    Center(child: Icon(Icons.check_circle, color: Colors.green, size: 18)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Name or status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isError
                      ? loc.translate('upload_failed')
                      : isComplete
                          ? loc.translate('upload_complete')
                          : loc.translate('upload_progress').replaceAll('{percent}', '${(task.progress * 100).toInt()}'),
                  style: TextStyle(
                    color: isError ? colorScheme.error : colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                if (!isComplete && !isError && task.progress > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: task.progress,
                        minHeight: 3,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                      ),
                    ),
                  ),
                if (isError && task.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      task.error!.length > 40 ? '${task.error!.substring(0, 40)}...' : task.error!,
                      style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          // Action button (cancel or retry)
          if (!isComplete)
            IconButton(
              icon: Icon(
                isError ? Icons.refresh_rounded : Icons.close_rounded,
                color: isError ? colorScheme.primary : colorScheme.onSurfaceVariant,
                size: 18,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              onPressed: () {
                if (isError) {
                  sl<UploadManagerCubit>().retryUpload(task.id, (url) {});
                } else {
                  sl<UploadManagerCubit>().cancelUpload(task.id);
                }
              },
              tooltip: isError ? loc.translate('upload_retry') : loc.translate('upload_cancel'),
            ),
        ],
      ),
    );
  }

  Widget _buildUploadFooter(
    BuildContext context,
    LocalizationCubit loc,
    bool allDone,
    ColorScheme colorScheme,
  ) {
    if (!allDone) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.withValues(alpha: 0.1),
            foregroundColor: Colors.green.shade700,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          icon: const Icon(Icons.check_circle_rounded, size: 18),
          label: Text(
            loc.translate('upload_complete'),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          onPressed: _toggleExpanded,
        ),
      ),
    );
  }
}
