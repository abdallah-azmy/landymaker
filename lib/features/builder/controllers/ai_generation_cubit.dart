import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
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

class AIGenerationStreamProgress extends AIGenerationState {
  final String message;
  final double? percent;
  AIGenerationStreamProgress(this.message, {this.percent});
}

class AIGenerationApplyingChanges extends AIGenerationState {}

class AIGenerationCopyUpdate extends AIGenerationState {
  final List<Map<String, dynamic>> updates;
  final String? assistantMessage;
  AIGenerationCopyUpdate({required this.updates, this.assistantMessage});
}

class AIGenerationPixabaySelection extends AIGenerationState {
  final String query;
  final String type;
  final int? sectionIndex;
  final String? elementId;
  final String? property;
  final Function(String) onSelected;
  final String? orientation;
  AIGenerationPixabaySelection({
    required this.query,
    required this.type,
    required this.onSelected,
    this.sectionIndex,
    this.elementId,
    this.property,
    this.orientation,
  });
}

class AIGenerationSuccess extends AIGenerationState {
  final Map<String, dynamic> designJson;
  final String? assistantMessage;
  AIGenerationSuccess(this.designJson, {this.assistantMessage});
}

class AIGenerationFailure extends AIGenerationState {
  final String error;
  final bool canRetry;
  AIGenerationFailure(this.error, {this.canRetry = true});
}

class AIGenerationTemplateFallback extends AIGenerationState {
  final String error;
  AIGenerationTemplateFallback(this.error);
}

class AIGenerationCubit extends Cubit<AIGenerationState> {
  final SupabaseService _supabase;
  final LandingPageBuilderCubit _builderCubit;
  late AIConversationSession _session;

  // Context preservation for Pixabay flow
  String? _pixabayPendingMessage;
  String? _pixabayPendingIntent;

  // Cancel previous request (using counter to avoid race conditions)
  bool _isProcessing = false;
  String? _lastMessage;
  int _requestId = 0;
  int _activeRequestId = 0;

  AIConversationSession get session => _session;

  AIGenerationCubit(this._supabase, this._builderCubit)
    : super(AIGenerationInitial()) {
    _session = AIConversationSession(
      sessionId: DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }

  bool get _isGuest => _supabase.client.auth.currentSession?.accessToken == null;

  static const String _guestPromptCountKey = 'guest_ai_prompt_count';

  int _getGuestPromptCount() {
    final val = html.window.localStorage[_guestPromptCountKey];
    if (val == null) return 0;
    return int.tryParse(val) ?? 0;
  }

  void _incrementGuestPromptCount() {
    final current = _getGuestPromptCount();
    html.window.localStorage[_guestPromptCountKey] = (current + 1).toString();
  }

  bool _hasReachedGuestLimit() {
    if (!_isGuest) return false;
    return _getGuestPromptCount() >= 1;
  }

  void startNewSession() {
    _session = AIConversationSession(
      sessionId: DateTime.now().millisecondsSinceEpoch.toString(),
    );
    _pixabayPendingMessage = null;
    _pixabayPendingIntent = null;
    _builderCubit.initializeNewPage();
    emit(AIGenerationInitial());
  }

  Future<void> resumeAfterPixabaySelection() async {
    final msg = _pixabayPendingMessage;
    _pixabayPendingMessage = null;
    _pixabayPendingIntent = null;
    if (msg != null) {
      emit(AIGenerationGenerating('جاري متابعة التعديل بعد اختيار الصورة...'));
      await processUserMessage(msg);
    }
  }

  Future<void> processUserMessage(String message) async {
    // Bump request ID: any in-flight response with old ID will be ignored
    _requestId++;
    final int myRequestId = _requestId;

    // Dedup: skip if same message sent twice in a row (only for user-initiated, not Pixabay resume)
    if (_pixabayPendingMessage == null && message == _lastMessage && _lastMessage != null) {
      emit(AIGenerationSuccess(
        {},
        assistantMessage: "تم استلام طلبك مسبقاً. هل هناك شيء جديد تريد إضافته؟",
      ));
      return;
    }
    _lastMessage = message;

    // Guest limit check: unregistered users get exactly one prompt
    if (_hasReachedGuestLimit()) {
      emit(AIGenerationFailure(
        "لقد استخدمت طلبك المجاني الوحيد! سجل حساباً مجاناً لمواصلة التعديل والحصول على تصميم غير محدود. 🎁",
        canRetry: false,
      ));
      return;
    }

    _isProcessing = true;
    _activeRequestId = myRequestId;
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

      // =========== SSE STREAMING REQUEST ===========
      final functionUrl = '${SupabaseService.supabaseUrl}/functions/v1/ai-page-generate';
      final sessionToken = _supabase.client.auth.currentSession?.accessToken;

      final request = http.Request('POST', Uri.parse(functionUrl));
      request.headers['Content-Type'] = 'application/json';
      request.headers['Accept'] = 'text/event-stream';
      request.headers['Authorization'] =
          'Bearer ${sessionToken ?? SupabaseService.supabaseAnonKey}';
      request.body = jsonEncode(payload);

      final httpClient = http.Client();
      Map<String, dynamic>? finalData;
      String? errorMessage;
      bool errorCanRetry = true;
      bool stale = false;

      try {
        final streamedResponse = await httpClient.send(request);

        if (streamedResponse.statusCode != 200) {
          _handleAIError('API_ERROR: ${streamedResponse.statusCode}', intent);
          return;
        }

        // Line buffer to handle SSE events split across TCP chunks
        final lineBuffer = StringBuffer();

        await for (final chunk in streamedResponse.stream.transform(utf8.decoder)) {
          lineBuffer.write(chunk);
          final text = lineBuffer.toString();
          final lines = text.split('\n');

          // Keep the last fragment (might be incomplete) in the buffer
          lineBuffer.clear();
          lineBuffer.write(lines.last);

          for (int i = 0; i < lines.length - 1; i++) {
            final line = lines[i];
            if (!line.startsWith('data: ')) continue;

            final jsonStr = line.substring(6).trim();
            if (jsonStr.isEmpty) continue;

            try {
              final event = jsonDecode(jsonStr) as Map<String, dynamic>;
              if (myRequestId != _activeRequestId) { stale = true; break; }

              final type = event['type'] as String?;
              switch (type) {
                case 'status':
                  emit(AIGenerationStreamProgress(
                    event['message'] as String? ?? '',
                  ));
                  break;
                case 'result':
                  finalData = event['data'] as Map<String, dynamic>?;
                  break;
                case 'error':
                  errorMessage = event['message'] as String?;
                  errorCanRetry = event['canRetry'] as bool? ?? true;
                  break;
              }
            } catch (_) {}
          }
          if (stale) break;
        }

        // Flush buffer (last line after stream ends)
        if (!stale && lineBuffer.isNotEmpty) {
          final line = lineBuffer.toString().trim();
          if (line.startsWith('data: ')) {
            final jsonStr = line.substring(6).trim();
            if (jsonStr.isNotEmpty) {
              try {
                final event = jsonDecode(jsonStr) as Map<String, dynamic>;
                if (myRequestId == _activeRequestId) {
                  final type = event['type'] as String?;
                  if (type == 'result') {
                    finalData = event['data'] as Map<String, dynamic>?;
                  } else if (type == 'error') {
                    errorMessage = event['message'] as String?;
                    errorCanRetry = event['canRetry'] as bool? ?? true;
                  }
                }
              } catch (_) {}
            }
          }
        }
      } finally {
        httpClient.close();
      }

      // Ignore stale response
      if (myRequestId != _activeRequestId || stale) {
        _isProcessing = false;
        return;
      }
      _isProcessing = false;

      // Error from SSE → emit directly (pre-formatted Arabic message with canRetry)
      if (errorMessage != null) {
        _session.rollbackLastMessage();
        emit(AIGenerationFailure(errorMessage, canRetry: errorCanRetry));
        return;
      }

      if (finalData == null) {
        _handleAIError('AI_NO_RESPONSE', intent);
        return;
      }

      final data = finalData;
      print('📥 AI AGENT RESPONSE:');
      try {
        print(const JsonEncoder.withIndent('  ').convert(data));
      } catch (e) {
        print(data);
      }

      // Detect business pivot/industry change by capturing old industry first
      final String? oldIndustry = _session.businessProfile.industry;

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

      // Handle Copy Update Action
      if (data['action'] == 'copy_update' && data['copy_updates'] != null) {
        final updates = List<Map<String, dynamic>>.from(data['copy_updates']);
        for (final update in updates) {
          final sectionIndex = update['sectionIndex'] as int?;
          if (sectionIndex == null) continue;
          final field = update['field'] as String?;
          if (field == null) continue;
          final value = update['value'];
          if (update['itemIndex'] != null) {
            _builderCubit.updateBlockProperty(sectionIndex, '$field.${update['itemIndex']}', value);
          } else {
            _builderCubit.updateBlockProperty(sectionIndex, field, value);
          }
        }
        if (data['assistant_message'] != null) {
          _session.addMessage('assistant', data['assistant_message']);
        }
        emit(AIGenerationCopyUpdate(
          updates: updates,
          assistantMessage: data['assistant_message'],
        ));
        return;
      }

      // Handle Actions
      if (data['action'] == 'pixabay_selection') {
        _pixabayPendingMessage = message;
        _pixabayPendingIntent = intent;

        emit(
          AIGenerationPixabaySelection(
            query: data['query'],
            type: data['type'] ?? 'photo',
            orientation: data['orientation'],
            sectionIndex: data['sectionIndex'],
            elementId: data['elementId'],
            property: data['property'],
            onSelected: (url) {
              if (data['sectionIndex'] != null && data['property'] != null) {
                if (data['elementId'] != null) {
                  _builderCubit.updateElementProperty(
                    data['sectionIndex'],
                    data['elementId'],
                    data['property'],
                    url,
                  );
                } else {
                  _builderCubit.updateBlockProperty(
                    data['sectionIndex'],
                    data['property'],
                    url,
                  );
                }
              }
              emit(AIGenerationInitial());
              resumeAfterPixabaySelection();
            },
          ),
        );
        return;
      }

      // Handle Design Update
      if (data['designJson'] != null) {
        emit(AIGenerationApplyingChanges());

        // Detect business pivot/industry change
        final String? newIndustry = data['business_profile_update']?['industry'];
        final bool industryChanged = oldIndustry != null && oldIndustry.isNotEmpty &&
            newIndustry != null && newIndustry.isNotEmpty &&
            oldIndustry.trim().toLowerCase() != newIndustry.trim().toLowerCase();

        final bool isFullRebuild = intent != 'edit' ||
            data['full_rebuild'] == true ||
            industryChanged;

        var validatedDesign = AIResponseValidator.validate(
          data['designJson'],
          isEdit: intent == 'edit' && !isFullRebuild,
          currentBlocks: currentDesign['blocks'] as List?,
        );
        if (validatedDesign != null) {
          validatedDesign = PlaceholderGenerator.fillPlaceholders(
            validatedDesign,
            _session.businessProfile.industry,
          );

          if (isFullRebuild) {
            validatedDesign['full_rebuild'] = true;
          }

          _builderCubit.applyDesignJson(validatedDesign);

          // Track guest prompt usage in local storage
          if (_isGuest) {
            _incrementGuestPromptCount();
          }

          emit(
            AIGenerationSuccess(
              validatedDesign,
              assistantMessage: data['assistant_message'],
            ),
          );
        } else {
          _handleAIError('AI_INVALID_FORMAT', intent);
        }
      } else if (data['assistant_message'] != null) {
        emit(
          AIGenerationSuccess(
            {},
            assistantMessage: data['assistant_message'],
          ),
        );
      } else {
        _handleAIError('AI_NO_RESPONSE', intent);
      }
    } catch (e) {
      _handleAIError('EXCEPTION: $e', intent);
    }
  }

  void _handleAIError(String rawError, String intent) {
    _isProcessing = false;
    print('❌ AI AGENT ERROR: $rawError');
    _session.rollbackLastMessage();

    String userFriendlyError;
    bool canRetry = true;

    if (rawError.contains('quota') || rawError.contains('limit') || rawError.contains('AI_LIMIT')) {
      userFriendlyError = rawError.contains('شهر')
          ? rawError
          : "لقد وصلت للحد الأقصى لاستخدام الـ AI لهذا الشهر. جرّب مزوداً آخر أو انتظر حتى الشهر القادم.";
      canRetry = false;
    } else if (rawError.contains('AI_INVALID_FORMAT') || rawError.contains('Invalid JSON')) {
      userFriendlyError = "استجاب الذكاء الاصطناعي بتنسيق غير صالح. حاول مرة أخرى.";
    } else if (rawError.contains('All 4 providers')) {
      userFriendlyError = "تعذر توليد الرد من جميع مزودي الذكاء الاصطناعي. تأكد من تفعيل API keys للمزودين البديلين (Groq, OpenRouter, DeepSeek).";
    } else if (rawError.contains('Unauthorized') || rawError.contains('auth')) {
      userFriendlyError = "انتهت صلاحية الجلسة. يرجى تسجيل الدخول مرة أخرى.";
      canRetry = false;
    } else if (rawError.contains('AI_NO_RESPONSE')) {
      userFriendlyError = "لم يستجب الذكاء الاصطناعي بأي تصميم أو رسالة. حاول صياغة طلبك بشكل أوضح.";
    } else if (rawError.contains('EXCEPTION')) {
      userFriendlyError = "فشل الاتصال بخادم الـ AI. تأكد من اتصالك بالإنترنت.";
    } else {
      userFriendlyError = "حدث خطأ غير متوقع. حاول مرة أخرى أو أعد صياغة طلبك.";
    }

    // Graceful degradation: if generating a new page failed, offer template fallback
    if (intent == 'generate') {
      emit(AIGenerationTemplateFallback(userFriendlyError));
    } else {
      emit(AIGenerationFailure(userFriendlyError, canRetry: canRetry));
    }
  }

  void resetState() {
    _pixabayPendingMessage = null;
    _pixabayPendingIntent = null;
    _isProcessing = false;
    _lastMessage = null;
    emit(AIGenerationInitial());
  }

  Map<String, dynamic> _getMinimalDesignContext(
    Map<String, dynamic> fullDesign,
    String userMessage,
    String intent,
  ) {
    if (intent == 'generate' || fullDesign['blocks'] == null) return {};
    
    final blocks = fullDesign['blocks'] as List? ?? [];
    final result = Map<String, dynamic>.from(fullDesign);
    result['_meta'] = {
      'block_count': blocks.length,
      'section_types': blocks.map((b) => b['type']).toList(),
    };
    return result;
  }
}
