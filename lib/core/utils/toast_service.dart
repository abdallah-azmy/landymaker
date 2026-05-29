import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class ToastService {
  static void showSuccess(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 4),
  }) {
    toastification.show(
      context: context,
      type: ToastificationType.success,
      style: ToastificationStyle.flatColored,
      title: title != null 
          ? Text(title, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold))
          : null,
      description: Text(message, style: AppTypography.bodySmall),
      alignment: Alignment.topCenter,
      autoCloseDuration: duration,
      borderRadius: BorderRadius.circular(12),
      boxShadow: highModeShadow,
      showProgressBar: true,
      pauseOnHover: true,
      dragToClose: true,
      applyBlurEffect: true,
    );
  }

  static void showError(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 5),
  }) {
    toastification.show(
      context: context,
      type: ToastificationType.error,
      style: ToastificationStyle.flatColored,
      title: title != null 
          ? Text(title, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold))
          : null,
      description: Text(message, style: AppTypography.bodySmall),
      alignment: Alignment.topCenter,
      autoCloseDuration: duration,
      borderRadius: BorderRadius.circular(12),
      boxShadow: highModeShadow,
      showProgressBar: true,
      pauseOnHover: true,
      dragToClose: true,
      applyBlurEffect: true,
    );
  }

  static void showInfo(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 4),
  }) {
    toastification.show(
      context: context,
      type: ToastificationType.info,
      style: ToastificationStyle.flatColored,
      title: title != null 
          ? Text(title, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold))
          : null,
      description: Text(message, style: AppTypography.bodySmall),
      alignment: Alignment.topCenter,
      autoCloseDuration: duration,
      borderRadius: BorderRadius.circular(12),
      boxShadow: highModeShadow,
      showProgressBar: true,
      pauseOnHover: true,
      dragToClose: true,
      applyBlurEffect: true,
    );
  }
}
