import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/supabase_service.dart';
import 'builder_cubit.dart';

abstract class AIGenerationState {}

class AIGenerationInitial extends AIGenerationState {}

class AIGenerationLoading extends AIGenerationState {}

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
        },
      );

      if (response.status == 200 || response.status == 201) {
        final designJson = response.data['designJson'];
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
