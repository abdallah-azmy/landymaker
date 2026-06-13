import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:landymaker/features/builder/controllers/ai_generation_cubit.dart';
import 'package:landymaker/features/builder/controllers/builder_cubit.dart';
import 'package:landymaker/features/builder/controllers/builder_state.dart';
import 'package:landymaker/features/builder/models/landing_page_theme.dart';
import 'package:landymaker/services/supabase_service.dart';

class MockSupabaseService extends Mock implements SupabaseService {}
class MockLandingPageBuilderCubit extends Mock implements LandingPageBuilderCubit {}
class MockFunctionsClient extends Mock implements FunctionsClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}

void main() {
  late AIGenerationCubit cubit;
  late MockSupabaseService mockSupabase;
  late MockLandingPageBuilderCubit mockBuilderCubit;
  late MockFunctionsClient mockFunctions;
  late MockGoTrueClient mockAuth;

  setUp(() {
    mockSupabase = MockSupabaseService();
    mockBuilderCubit = MockLandingPageBuilderCubit();
    mockFunctions = MockFunctionsClient();
    mockAuth = MockGoTrueClient();

    final client = MockSupabaseClient();
    when(() => mockSupabase.client).thenReturn(client);
    when(() => client.functions).thenReturn(mockFunctions);
    when(() => client.auth).thenReturn(mockAuth);
    when(() => mockAuth.currentSession).thenReturn(null);

    cubit = AIGenerationCubit(mockSupabase, mockBuilderCubit);

    // Default builder state
    when(() => mockBuilderCubit.state).thenReturn(BuilderLoaded(
      designMap: {'blocks': []},
      subdomain: 'test',
      isPublished: false,
      theme: LandingPageTheme.defaultDark(),
    ));
  });

  test('Create a gym page - Placeholder generated', () async {
    final mockResponse = FunctionResponse(
      data: {
        'designJson': {
          'blocks': <Map<String, dynamic>>[
            <String, dynamic>{'type': 'hero', 'title': ''}
          ]
        },
        'assistant_message': 'جاري إنشاء صفحة النادي الرياضي...',
        'memory_summary_update': 'User wants a gym page.',
        'business_profile_update': {'industry': 'gym'},
      },
      status: 200,
    );

    when(() => mockFunctions.invoke(
      'ai-page-generate',
      body: any(named: 'body'),
    )).thenAnswer((_) async => mockResponse);

    await cubit.processUserMessage('أنشئ صفحة لنادي رياضي');

    expect(cubit.state, isA<AIGenerationSuccess>());
    final successState = cubit.state as AIGenerationSuccess;
    expect(successState.designJson['blocks'][0]['title'], contains('النادي الرياضي'));
    verify(() => mockBuilderCubit.applyDesignJson(any())).called(1);
  });

  test('Replace images with doctors - PixabaySelector opens', () async {
    final mockResponse = FunctionResponse(
      data: {
        'action': 'pixabay_selection',
        'query': 'doctors',
        'type': 'photo',
        'sectionIndex': 0,
        'elementId': 'item_1',
        'property': 'image_url',
      },
      status: 200,
    );

    when(() => mockFunctions.invoke(
      'ai-page-generate',
      body: any(named: 'body'),
    )).thenAnswer((_) async => mockResponse);

    await cubit.processUserMessage('استبدل الصور بصور أطباء');

    expect(cubit.state, isA<AIGenerationPixabaySelection>());
    final selectionState = cubit.state as AIGenerationPixabaySelection;
    expect(selectionState.query, 'doctors');
  });
}

class MockSupabaseClient extends Mock implements SupabaseClient {}
