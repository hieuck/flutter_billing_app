import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billing_app/features/ai_assistant/domain/services/business_assistant.dart';
import 'package:billing_app/features/ai_assistant/presentation/bloc/assistant_bloc.dart';

class MockAssistant extends Mock implements BusinessAssistant {}

void main() {
  late AssistantBloc bloc;
  late MockAssistant mockAssistant;

  setUp(() {
    mockAssistant = MockAssistant();
    bloc = AssistantBloc(assistant: mockAssistant);
  });

  tearDown(() => bloc.close());

  blocTest<AssistantBloc, AssistantState>(
    'emits [loading, answered] on AskQuestionEvent',
    build: () {
      when(() => mockAssistant.answer('Doanh thu hôm nay'))
          .thenAnswer((_) async => 'Hôm nay doanh thu là 500.000đ');
      return bloc;
    },
    act: (bloc) => bloc.add(const AskQuestionEvent('Doanh thu hôm nay')),
    expect: () => [
      AssistantLoading(),
      isA<AssistantAnswered>(),
    ],
  );

  blocTest<AssistantBloc, AssistantState>(
    'emits [loading, error] when assistant fails',
    build: () {
      when(() => mockAssistant.answer(any()))
          .thenThrow(Exception('DB error'));
      return bloc;
    },
    act: (bloc) => bloc.add(const AskQuestionEvent('test')),
    expect: () => [
      AssistantLoading(),
      isA<AssistantError>(),
    ],
  );
}
