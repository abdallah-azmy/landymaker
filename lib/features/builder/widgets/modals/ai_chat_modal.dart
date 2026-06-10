import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/toast_service.dart';
import '../ai_chat_input.dart';
import 'pixabay_selector_modal.dart';
import 'package:landymaker/features/builder/controllers/ai_generation_cubit.dart';
import 'package:landymaker/features/builder/controllers/builder_cubit.dart';
import 'package:landymaker/features/builder/controllers/builder_state.dart';

class AIChatModal extends StatefulWidget {
  final String? currentPath;
  const AIChatModal({super.key, this.currentPath});

  @override
  State<AIChatModal> createState() => _AIChatModalState();
}

class _AIChatModalState extends State<AIChatModal> {
  final List<Map<String, String>> _chatHistory = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    final builderCubit = context.read<LandingPageBuilderCubit>();
    if (builderCubit.state is! BuilderLoaded) {
      builderCubit.initializeNewPage();
    }

    final aiCubit = context.read<AIGenerationCubit>();
    if (aiCubit.session.messages.isNotEmpty) {
      for (final msg in aiCubit.session.messages) {
        _chatHistory.add({'role': msg.role, 'content': msg.content});
      }
    } else {
      final bool isNewSite =
          builderCubit.state is BuilderLoaded &&
          ((builderCubit.state as BuilderLoaded).designMap['blocks'] as List?)
                  ?.isEmpty ==
              true;

      if (isNewSite) {
        _addSystemMessage(
          "أهلاً بك! دعنا نبني صفحتك. من فضلك أخبرني:\n1. اسم نشاطك التجاري\n2. مجال العمل\n3. ما هو العرض الأساسي الذي تقدمه؟",
        );
      } else {
        _addSystemMessage(
          "أهلاً بك! أنا مساعدك الذكي لبناء صفحات الهبوط. كيف يمكنني مساعدتك في تعديل صفحتك اليوم؟",
        );
      }
    }
  }

  void _addSystemMessage(String message) {
    setState(() {
      _chatHistory.add({'role': 'assistant', 'content': message});
    });
    _scrollToBottom();
  }

  void _addUserMessage(String message) {
    setState(() {
      _chatHistory.add({'role': 'user', 'content': message});
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showPixabayPicker(AIGenerationPixabaySelection state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PixabaySelectorModal(
        initialQuery: state.query,
        initialType: state.type,
        onImageSelected: (url) {
          state.onSelected(url);
          ToastService.showSuccess(context, message: "تم تحديث الصورة بنجاح");
        },
      ),
    ).then((_) {
      if (mounted) {
        final cubit = context.read<AIGenerationCubit>();
        if (cubit.state is AIGenerationPixabaySelection) {
          cubit.resetState();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AIGenerationCubit, AIGenerationState>(
      listener: (context, state) {
        if (state is AIGenerationSuccess) {
          if (state.assistantMessage != null) {
            _addSystemMessage(state.assistantMessage!);
          } else {
            _addSystemMessage("تم تنفيذ طلبك بنجاح! هل هناك شيء آخر؟");
          }
          ToastService.showSuccess(context, message: "تم تحديث التصميم بنجاح");

          // UI/UX Flow: If generated from home page, redirect user to guest preview workspace
          final currentPath = widget.currentPath ?? '';
          if (currentPath.isNotEmpty &&
              !currentPath.startsWith('/builder') &&
              !currentPath.startsWith('/guest-preview')) {
            Navigator.pop(context); // Close bottom sheet
            context.go('/guest-preview');
          }
        }
        if (state is AIGenerationPixabaySelection) {
          _showPixabayPicker(state);
        }
        if (state is AIGenerationFailure) {
          ToastService.showError(context, message: state.error);
          _addSystemMessage("عذراً، حدث خطأ أثناء معالجة طلبك: ${state.error}");
        }
      },
      builder: (context, state) {
        final bool isLoading =
            state is AIGenerationThinking ||
            state is AIGenerationGenerating ||
            state is AIGenerationApplyingChanges;
        String? progressMessage;
        if (state is AIGenerationThinking) progressMessage = state.message;
        if (state is AIGenerationGenerating) progressMessage = state.message;
        if (state is AIGenerationApplyingChanges)
          progressMessage = "جاري تطبيق التغييرات على التصميم...";

        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(20),
                  itemCount: _chatHistory.length,
                  itemBuilder: (context, index) {
                    final msg = _chatHistory[index];
                    return _buildMessageBubble(msg['role']!, msg['content']!);
                  },
                ),
              ),
              if (isLoading) _buildLoadingIndicator(progressMessage!),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: AIChatInput(
                  isLoading: isLoading,
                  onSend: (msg) {
                    _addUserMessage(msg);
                    context.read<AIGenerationCubit>().processUserMessage(msg);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, color: AppColors.primary),
              const SizedBox(width: 12),
              Text("مساعد لاندي ميكر الذكي", style: AppTypography.h3),
            ],
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String role, String content) {
    final bool isUser = role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: isUser ? AppColors.secondary : AppColors.cardBg,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 0 : 16),
            bottomRight: Radius.circular(isUser ? 16 : 0),
          ),
          border: isUser ? null : Border.all(color: AppColors.border),
        ),
        child: Text(
          content,
          style: AppTypography.bodyMedium.copyWith(
            color: isUser ? Colors.white : AppColors.textPrimary,
          ),
          textDirection: TextDirection.rtl,
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            message,
            style: AppTypography.caption.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
