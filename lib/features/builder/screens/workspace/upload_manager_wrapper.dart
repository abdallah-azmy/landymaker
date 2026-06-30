import 'package:flutter/material.dart';
import '../../../../core/localization/localization_cubit.dart';
import '../../widgets/organisms/global_upload_manager_widget.dart';

class UploadManagerWrapper extends StatelessWidget {
  final LocalizationCubit loc;
  final bool isMobile;

  const UploadManagerWrapper({required this.loc, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return PositionedDirectional(
      top: isMobile ? 80 : 24,
      end: isMobile ? 16 : 350 + 24,
      child: const GlobalUploadManagerWidget(),
    );
  }
}
