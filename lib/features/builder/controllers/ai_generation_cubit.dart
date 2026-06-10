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
  late final AIConversationSession _session;

  AIGenerationCubit(this._supabase, this._builderCubit) : super(AIGenerationInitial()) {
    _session = AIConversationSession(sessionId: DateTime.now().millisecondsSinceEpoch.toString());
  }

  Future<void> processUserMessage(String message) async {
    _session.addMessage('user', message);
    
    // Determine intent based on current state
    final bool isNewSite = _builderCubit.state is BuilderLoaded && 
        ((_builderCubit.state as BuilderLoaded).designMap['blocks'] as List?)?.isEmpty == true;
    
    final String intent = isNewSite ? 'generate' : 'edit';
    
    emit(AIGenerationThinking("جاري تحليل طلبك..."));

    try {
      final currentDesign = (_builderCubit.state as BuilderLoaded).designMap;
      final context = _session.getContextForAI(currentDesign);

      // SMART CONTEXT SELECTION: Prune design data based on user message
      final minimalDesign = _getMinimalDesignContext(currentDesign, message, intent);

      emit(AIGenerationGenerating(intent == 'generate' ? "جاري بناء صفحتك الجديدة..." : "جاري تعديل التصميم..."));

      final response = await _supabase.client.functions.invoke(
        'ai-page-generate',
        body: {
          ...context,
          'intent': intent,
          'currentDesign': minimalDesign,
          'instruction': message,
          'language': 'ar',
        },
      );

      if (response.status == 200 || response.status == 201) {
        final data = response.data;
        
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
          emit(AIGenerationPixabaySelection(
            query: data['query'],
            type: data['type'] ?? 'photo',
            sectionIndex: data['sectionIndex'],
            elementId: data['elementId'],
            property: data['property'],
            onSelected: (url) {
              if (data['sectionIndex'] != null && data['elementId'] != null && data['property'] != null) {
                _builderCubit.updateElementProperty(
                  data['sectionIndex'],
                  data['elementId'],
                  data['property'],
                  url,
                );
              }
              emit(AIGenerationInitial());
            },
          ));
          return;
        }

        // Handle Design Update
        if (data['designJson'] != null) {
          emit(AIGenerationApplyingChanges());
          
          var validatedDesign = AIResponseValidator.validate(data['designJson']);
          if (validatedDesign != null) {
            // Fill placeholders if needed
            validatedDesign = PlaceholderGenerator.fillPlaceholders(
              validatedDesign, 
              _session.businessProfile.industry
            );
            
            _builderCubit.applyDesignJson(validatedDesign);
            emit(AIGenerationSuccess(validatedDesign, assistantMessage: data['assistant_message']));
          } else {
            emit(AIGenerationFailure("استجاب الذكاء الاصطناعي بتنسيق غير صالح."));
          }
        } else if (data['assistant_message'] != null) {
          // Just a conversation response
          emit(AIGenerationSuccess({}, assistantMessage: data['assistant_message']));
        }
      } else {
        emit(AIGenerationFailure(response.data['error'] ?? 'Unknown error'));
      }
    } catch (e) {
      emit(AIGenerationFailure(e.toString()));
    }
  }

  /// SMARTEST CONTEXT SELECTION: Returns only relevant blocks to save tokens
  Map<String, dynamic> _getMinimalDesignContext(Map<String, dynamic> fullDesign, String userMessage, String intent) {
    if (intent == 'generate' || fullDesign['blocks'] == null) return {};

    final msg = userMessage.toLowerCase();
    final List blocks = fullDesign['blocks'];
    final List<Map<String, dynamic>> relevantBlocks = [];

    // Keywords mapping to block types
    final Map<String, List<String>> keywordMap = {
      'hero': ['hero', 'بداية', 'رئيسي', 'صورة'],
      'features': ['features', 'مميزات', 'خدمات', 'مزايا'],
      'pricing': ['pricing', 'أسعار', 'خطط', 'اشتراك'],
      'faq': ['faq', 'أسئلة', 'شائعة'],
      'testimonials': ['testimonials', 'آراء', 'عملاء', 'قالوا'],
      'products': ['products', 'منتجات', 'متجر'],
    };

    bool addedAny = false;
    for (int i = 0; i < blocks.length; i++) {
      final block = blocks[i];
      final type = block['type'] as String? ?? '';
      
      // If message mentions a specific block type or its Arabic equivalent
      bool isRelevant = false;
      keywordMap.forEach((key, keywords) {
        if (type.contains(key)) {
          if (keywords.any((kw) => msg.contains(kw))) {
            isRelevant = true;
          }
        }
      });

      // Special case: "first", "last", "top", "bottom"
      if (msg.contains('الأول') || msg.contains('أول') || msg.contains('top')) {
        if (i == 0) isRelevant = true;
      }
      if (msg.contains('الأخير') || msg.contains('آخر') || msg.contains('bottom')) {
        if (i == blocks.length - 1) isRelevant = true;
      }

      if (isRelevant) {
        relevantBlocks.add({...block, '_index': i});
        addedAny = true;
      }
    }

    // Fallback: If no specific section found, send just the first 2 sections to provide SOME context
    if (!addedAny && blocks.isNotEmpty) {
      relevantBlocks.add({...blocks[0], '_index': 0});
      if (blocks.length > 1) relevantBlocks.add({...blocks[1], '_index': 1});
    }

    return {
      'global_theme': fullDesign['global_theme'],
      'blocks': relevantBlocks,
    };
  }
}
