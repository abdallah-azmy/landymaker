import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/supabase_service.dart';

abstract class AICopywriterState {}

class AICopywriterInitial extends AICopywriterState {}

class AICopywriterLoading extends AICopywriterState {}

class AICopywriterSuccess extends AICopywriterState {
  final List<String> variations;
  AICopywriterSuccess(this.variations);
}

class AICopywriterFailure extends AICopywriterState {
  final String error;
  AICopywriterFailure(this.error);
}

class AICopywriterCubit extends Cubit<AICopywriterState> {
  final SupabaseService _supabase;

  AICopywriterCubit(this._supabase) : super(AICopywriterInitial());

  Future<void> generateCopy({
    required String fieldType,
    required Map<String, dynamic> context,
    String tone = 'Professional',
    String length = 'Medium',
  }) async {
    emit(AICopywriterLoading());

    try {
      final response = await _supabase.client.functions.invoke(
        'ai-copywrite',
        body: {
          'fieldType': fieldType,
          'context': context,
          'tone': tone,
          'length': length,
        },
      );

      if (response.status == 200) {
        final variations = List<String>.from(response.data['variations']);
        emit(AICopywriterSuccess(variations));
      } else {
        emit(AICopywriterFailure(response.data['error'] ?? 'Unknown error'));
      }
    } catch (e) {
      emit(AICopywriterFailure(e.toString()));
    }
  }
}
