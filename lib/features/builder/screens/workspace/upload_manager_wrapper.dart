import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../builder/controllers/upload_manager_cubit.dart';
import '../../widgets/organisms/global_upload_manager_widget.dart';
import '../../../../injection_container.dart';

class UploadManagerWrapper extends StatefulWidget {
  final bool isMobile;

  const UploadManagerWrapper({required this.isMobile});

  @override
  State<UploadManagerWrapper> createState() => _UploadManagerWrapperState();
}

class _UploadManagerWrapperState extends State<UploadManagerWrapper> {
  // Drag offset from default position (bottom-right)
  // positive dx = move right, positive dy = move down
  double _dx = 0;
  double _dy = 0;

  // Max widget dimensions for clamping (conservative estimates)
  static const double _maxWidgetWidth = 360;
  static const double _maxWidgetHeight = 520;

  double get _defaultRight => widget.isMobile ? 12 : 24;
  double get _defaultBottom => widget.isMobile ? 100 : 24;

  void _onPanUpdate(DragUpdateDetails details, Size screenSize) {
    setState(() {
      double newDx = _dx + details.delta.dx;
      double newDy = _dy - details.delta.dy;

      // Clamp so widget stays within screen bounds
      // right = defaultRight - dx  →  must be between 0 and screenWidth - maxWidgetWidth
      newDx = newDx.clamp(
        _defaultRight - (screenSize.width - _maxWidgetWidth),
        _defaultRight,
      );

      // bottom = defaultBottom + dy  →  must be between 0 and screenHeight - maxWidgetHeight
      newDy = newDy.clamp(
        -_defaultBottom,
        screenSize.height - _maxWidgetHeight - _defaultBottom,
      );

      _dx = newDx;
      _dy = newDy;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return BlocBuilder<UploadManagerCubit, UploadManagerState>(
      bloc: sl<UploadManagerCubit>(),
      builder: (context, uploadState) {
        final hasContent =
            uploadState.uploads.isNotEmpty || uploadState.saveProcess != null;
        if (!hasContent) return const SizedBox.shrink();

        return Positioned(
          right: _defaultRight - _dx,
          bottom: _defaultBottom + _dy,
          child: GestureDetector(
            onPanUpdate: (details) => _onPanUpdate(details, screenSize),
            child: Material(
              color: Colors.transparent,
              elevation: 8,
              shadowColor: Colors.black38,
              borderRadius: BorderRadius.circular(28),
              child: GlobalUploadManagerWidget(
                key: ValueKey('upload_mgr_${widget.isMobile}'),
              ),
            ),
          ),
        );
      },
    );
  }
}
