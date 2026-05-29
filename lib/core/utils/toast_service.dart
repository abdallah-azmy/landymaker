import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import '../theme/app_typography.dart';
import '../theme/app_colors.dart';

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
      style: ToastificationStyle.fillColored,
      primaryColor: AppColors.secondary, // Neon Cyan brand color
      backgroundColor: AppColors.cardBg,
      title: title != null 
          ? Text(title, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: Colors.white))
          : Text("تم بنجاح", style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
      description: Text(message, style: AppTypography.caption.copyWith(color: Colors.white.withValues(alpha: 0.9), fontWeight: FontWeight.w500)),
      alignment: Alignment.topCenter,
      autoCloseDuration: duration,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 20,
          offset: const Offset(0, 8),
        )
      ],
      showProgressBar: true,
      pauseOnHover: true,
      dragToClose: true,
      applyBlurEffect: true,
      callbacks: ToastificationCallbacks(
        onTap: (item) => toastification.dismiss(item),
      ),
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
      style: ToastificationStyle.fillColored,
      primaryColor: AppColors.dangerRed,
      backgroundColor: AppColors.cardBg,
      title: title != null 
          ? Text(title, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: Colors.white))
          : Text("خطأ", style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
      description: Text(message, style: AppTypography.caption.copyWith(color: Colors.white.withValues(alpha: 0.9), fontWeight: FontWeight.w500)),
      alignment: Alignment.topCenter,
      autoCloseDuration: duration,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 20,
          offset: const Offset(0, 8),
        )
      ],
      showProgressBar: true,
      pauseOnHover: true,
      dragToClose: true,
      applyBlurEffect: true,
      callbacks: ToastificationCallbacks(
        onTap: (item) => toastification.dismiss(item),
      ),
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
      style: ToastificationStyle.fillColored,
      primaryColor: AppColors.primary,
      backgroundColor: AppColors.cardBg,
      title: title != null 
          ? Text(title, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: Colors.white))
          : Text("تنبيه", style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
      description: Text(message, style: AppTypography.caption.copyWith(color: Colors.white.withValues(alpha: 0.9), fontWeight: FontWeight.w500)),
      alignment: Alignment.topCenter,
      autoCloseDuration: duration,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 20,
          offset: const Offset(0, 8),
        )
      ],
      showProgressBar: true,
      pauseOnHover: true,
      dragToClose: true,
      applyBlurEffect: true,
      callbacks: ToastificationCallbacks(
        onTap: (item) => toastification.dismiss(item),
      ),
    );
  }
}
