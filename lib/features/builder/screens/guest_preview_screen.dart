import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/localization/localization_cubit.dart';
import '../controllers/builder_cubit.dart';
import '../controllers/builder_state.dart';
import '../models/preview_mode.dart';
import '../widgets/organisms/builder_canvas.dart';
import '../widgets/modals/ai_chat_modal.dart';

class GuestPreviewScreen extends StatefulWidget {
  const GuestPreviewScreen({super.key});

  @override
  State<GuestPreviewScreen> createState() => _GuestPreviewScreenState();
}

class _GuestPreviewScreenState extends State<GuestPreviewScreen> {
  final PreviewMode _previewMode = PreviewMode.fullscreen;

  void _showAiWizard(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AIChatModal(currentPath: currentPath),
    );
  }

  @override
  Widget build(BuildContext context) {
    final builderCubit = context.watch<LandingPageBuilderCubit>();
    final state = builderCubit.state;
    final loc = context.watch<LocalizationCubit>();

    if (state is! BuilderLoaded) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.secondary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: Row(
          children: [
            const Icon(Icons.visibility_rounded, color: AppColors.secondary),
            const SizedBox(width: 8),
            Text(
              "استعراض الصفحة الذكية (مسودة زائر)",
              style: AppTypography.h3.copyWith(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.home_rounded, color: Colors.white70),
            tooltip: "العودة للرئيسية",
          ),
        ],
      ),
      body: Column(
        children: [
          // Registration Offer Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.95),
                  AppColors.secondary.withValues(alpha: 0.95),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "عزيزي الزائر: لحفظ هذه الصفحة، نشرها، أو تعديل الكتل يدوياً، يرجى تسجيل حساب مجاني. صفحتك الأولى مجانية بالكامل! 🎁",
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => context.go('/register'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: const Text(
                    "سجل مجاناً",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          
          // Main Preview Canvas
          Expanded(
            child: BuilderCanvas(
              isMobile: false,
              previewMode: _previewMode,
              state: state,
              loc: loc,
              onBlockTapped: (_) {}, // Non-interactive in guest mode
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAiWizard(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
        label: const Text(
          "المساعد الذكي (AI)",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
