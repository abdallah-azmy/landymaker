import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/localization/localization_cubit.dart';

class FullscreenCloseButton extends StatelessWidget {
  final LocalizationCubit loc;
  final VoidCallback onBack;

  const FullscreenCloseButton({required this.loc, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return PositionedDirectional(
      top: 24,
      start: 24,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5), shape: BoxShape.circle),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded),
              color: Colors.white,
              iconSize: 22,
              padding: const EdgeInsets.all(6),
              constraints: const BoxConstraints(),
              onPressed: onBack,
            ),
          ),
        ),
      ),
    );
  }
}
