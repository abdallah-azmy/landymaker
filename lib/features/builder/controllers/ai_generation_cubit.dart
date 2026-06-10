import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/supabase_service.dart';
import 'builder_cubit.dart';

abstract class AIGenerationState {}

class AIGenerationInitial extends AIGenerationState {}

class AIGenerationLoading extends AIGenerationState {}

class AIGenerationPixabaySelection extends AIGenerationState {
  final String query;
  final String type;
  final Function(String) onSelected;
  AIGenerationPixabaySelection({required this.query, required this.type, required this.onSelected});
}

class AIGenerationSuccess extends AIGenerationState {
  final Map<String, dynamic> designJson;
  AIGenerationSuccess(this.designJson);
}

class AIGenerationFailure extends AIGenerationState {
  final String error;
  AIGenerationFailure(this.error);
}

class AIGenerationCubit extends Cubit<AIGenerationState> {
  final SupabaseService _supabase;
  final LandingPageBuilderCubit _builderCubit;

  AIGenerationCubit(this._supabase, this._builderCubit) : super(AIGenerationInitial());

  Future<void> generatePage({
    required String businessName,
    required String businessType,
    required String location,
    required String language,
    required String offer,
    String intent = 'generate',
    Map<String, dynamic>? currentDesign,
    String? instruction,
  }) async {
    emit(AIGenerationLoading());

    try {
      final response = await _supabase.client.functions.invoke(
        'ai-page-generate',
        body: {
          'businessName': businessName,
          'businessType': businessType,
          'location': location,
          'language': language,
          'offer': offer,
          'intent': intent,
          'currentDesign': currentDesign,
          'instruction': instruction,
        },
      );

      if (response.status == 200 || response.status == 201) {
        final designJson = response.data['designJson'];
        
        // CHECK: If AI returned a Pixabay search request instead of a full design update
        if (designJson != null && designJson['action'] == 'pixabay_selection') {
          emit(AIGenerationPixabaySelection(
            query: designJson['query'],
            type: designJson['type'] ?? 'photo',
            onSelected: (url) {
              // Now we have the URL, we need to apply it to the element
              _builderCubit.updateElementProperty(
                designJson['sectionIndex'],
                designJson['elementId'],
                designJson['property'],
                url,
              );
            },
          ));
          return;
        }

        emit(AIGenerationSuccess(designJson));
        
        // Apply to builder
        _builderCubit.applyDesignJson(designJson);
      } else {
        emit(AIGenerationFailure(response.data['error'] ?? 'Unknown error'));
      }
    } catch (e) {
      emit(AIGenerationFailure(e.toString()));
    }
  }
}
