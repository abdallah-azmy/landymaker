import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/supabase_service.dart';
import '../ai/ai_conversation_session.dart';
import '../ai/ai_response_validator.dart';
import '../ai/placeholder_generator.dart';
import 'builder_cubit.dart';
import 'builder_state.dart';

abstract class AIGenerationState {}

class AIGenerationInitial extends AIGenerationState {}

class AIGenerationThinking extends AIGenerationState {
  final String message;
  AIGenerationThinking(this.message);
}

class AIGenerationGenerating extends AIGenerationState {
  final String message;
  AIGenerationGenerating(this.message);
}

class AIGenerationApplyingChanges extends AIGenerationState {}

class AIGenerationPixabaySelection extends AIGenerationState {
  final String query;
  final String type;
  final int? sectionIndex;
  final String? elementId;
  final String? property;
  final Function(String) onSelected;
  AIGenerationPixabaySelection({
    required this.query,
    required this.type,
    required this.onSelected,
    this.sectionIndex,
    this.elementId,
    this.property,
  });
}

class AIGenerationSuccess extends AIGenerationState {
  final Map<String, dynamic> designJson;
  final String? assistantMessage;
  AIGenerationSuccess(this.designJson, {this.assistantMessage});
}

class AIGenerationFailure extends AIGenerationState {
  final String error;
  AIGenerationFailure(this.error);
}

class AIGenerationCubit extends Cubit<AIGenerationState> {
  final SupabaseService _supabase;
  final LandingPageBuilderCubit _builderCubit;
  late AIConversationSession _session;

  AIConversationSession get session => _session;

  AIGenerationCubit(this._supabase, this._builderCubit)
    : super(AIGenerationInitial()) {
    _session = AIConversationSession(
      sessionId: DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }

  void startNewSession() {
    _session = AIConversationSession(
      sessionId: DateTime.now().millisecondsSinceEpoch.toString(),
    );
    _builderCubit.initializeNewPage();
    emit(AIGenerationInitial());
  }

  Future<void> processUserMessage(String message) async {
    _session.addMessage('user', message);

    // SAFE STATE ACCESS
    final builderState = _builderCubit.state;
    final Map<String, dynamic> currentDesign = builderState is BuilderLoaded
        ? builderState.designMap
        : {'blocks': []};

    // Determine intent based on current state
    final bool isNewSite = currentDesign['blocks']?.isEmpty == true;
    final String intent = isNewSite ? 'generate' : 'edit';

    emit(AIGenerationThinking("جاري تحليل طلبك..."));

    try {
      final context = _session.getContextForAI(currentDesign);

      // SMART CONTEXT SELECTION: Prune design data based on user message
      final minimalDesign = _getMinimalDesignContext(
        currentDesign,
        message,
        intent,
      );

      final payload = {
        ...context,
        'intent': intent,
        'currentDesign': minimalDesign,
        'instruction': message,
        'language': 'ar',
      };

      // DEBUG LOGGING: Request
      print('🚀 AI AGENT REQUEST:');
      print(const JsonEncoder.withIndent('  ').convert(payload));

      emit(
        AIGenerationGenerating(
          intent == 'generate'
              ? "جاري بناء صفحتك الجديدة..."
              : "جاري تعديل التصميم...",
        ),
      );

      final response = await _supabase.client.functions.invoke(
        'ai-page-generate',
        body: payload,
      );

      // DEBUG LOGGING: Response
      print('📥 AI AGENT RESPONSE (${response.status}):');
      print(const JsonEncoder.withIndent('  ').convert(response.data));

      if (response.status == 200 || response.status == 201) {
        final data = response.data;

        // Check for unified error payload
        if (data is Map && data['error'] != null) {
          print('❌ AI AGENT ERROR (Logical): ${data['error']}');
          _session.rollbackLastMessage();
          emit(AIGenerationFailure(data['error']));
          return;
        }

        // Update Session Memory
        if (data['memory_summary_update'] != null) {
          _session.updateSummary(data['memory_summary_update']);
        }
        if (data['business_profile_update'] != null) {
          _session.updateProfileFromAI(data['business_profile_update']);
        }
        if (data['assistant_message'] != null) {
          _session.addMessage('assistant', data['assistant_message']);
        }

        // Handle Actions
        if (data['action'] == 'pixabay_selection') {
          emit(
            AIGenerationPixabaySelection(
              query: data['query'],
              type: data['type'] ?? 'photo',
              sectionIndex: data['sectionIndex'],
              elementId: data['elementId'],
              property: data['property'],
              onSelected: (url) {
                if (data['sectionIndex'] != null &&
                    data['elementId'] != null &&
                    data['property'] != null) {
                  _builderCubit.updateElementProperty(
                    data['sectionIndex'],
                    data['elementId'],
                    data['property'],
                    url,
                  );
                }
                emit(AIGenerationInitial());
              },
            ),
          );
          return;
        }

        // Handle Design Update
        if (data['designJson'] != null) {
          emit(AIGenerationApplyingChanges());

          var validatedDesign = AIResponseValidator.validate(
            data['designJson'],
          );
          if (validatedDesign != null) {
            // Fill placeholders if needed
            validatedDesign = PlaceholderGenerator.fillPlaceholders(
              validatedDesign,
              _session.businessProfile.industry,
            );

            _builderCubit.applyDesignJson(validatedDesign);
            emit(
              AIGenerationSuccess(
                validatedDesign,
                assistantMessage: data['assistant_message'],
              ),
            );
          } else {
            _session.rollbackLastMessage();
            emit(
              AIGenerationFailure("استجاب الذكاء الاصطناعي بتنسيق غير صالح."),
            );
          }
        } else if (data['assistant_message'] != null) {
          // Just a conversation response
          emit(
            AIGenerationSuccess(
              {},
              assistantMessage: data['assistant_message'],
            ),
          );
        } else {
          _session.rollbackLastMessage();
          emit(AIGenerationFailure("لم يستجب الذكاء الاصطناعي بأي تصميم أو رسالة."));
        }
      } else {
        final errorMsg = response.data['error'] ?? 'Unknown error';
        print('❌ AI AGENT ERROR (API): $errorMsg');

        String userFriendlyError =
            "حدث خطأ غير متوقع في نظام الذكاء الاصطناعي.";
        if (errorMsg.contains('quota') || errorMsg.contains('limit')) {
          userFriendlyError =
              "لقد وصلت للحد الأقصى لاستخدام الـ AI لهذا الشهر.";
        } else if (errorMsg.contains('Invalid JSON')) {
          userFriendlyError =
              "نعتذر، نظام الـ AI يواجه صعوبة في صياغة التصميم الآن. يرجى المحاولة مرة أخرى.";
        }

        _session.rollbackLastMessage();
        emit(AIGenerationFailure(userFriendlyError));
      }
    } catch (e) {
      print('❌ AI AGENT ERROR (Exception): $e');
      _session.rollbackLastMessage();
      emit(
        AIGenerationFailure(
          "فشل الاتصال بخادم الـ AI. تأكد من اتصالك بالإنترنت.",
        ),
      );
    }
  }

  void resetState() {
    emit(AIGenerationInitial());
  }

  /// SMARTEST CONTEXT SELECTION: Returns the complete design context to ensure AI can edit all blocks globally
  Map<String, dynamic> _getMinimalDesignContext(
    Map<String, dynamic> fullDesign,
    String userMessage,
    String intent,
  ) {
    if (intent == 'generate' || fullDesign['blocks'] == null) return {};
    return fullDesign;
  }
}
