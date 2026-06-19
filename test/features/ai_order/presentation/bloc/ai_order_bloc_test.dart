import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billing_app/features/ai_order/domain/services/order_parser.dart';
import 'package:billing_app/features/ai_order/domain/entities/parsed_order_item.dart';
import 'package:billing_app/features/ai_order/presentation/bloc/ai_order_bloc.dart';

class MockParser extends Mock implements OrderParser {}

void main() {
  late AiOrderBloc bloc;
  late MockParser mockParser;

  setUp(() {
    mockParser = MockParser();
    bloc = AiOrderBloc(parser: mockParser);
  });

  tearDown(() => bloc.close());

  blocTest<AiOrderBloc, AiOrderState>(
    'emits [loading, parsed] on successful parse',
    build: () {
      when(() => mockParser.parse('Trà sữa'))
          .thenReturn([ParsedOrderItem(productName: 'Trà sữa', confidence: 1.0)]);
      return bloc;
    },
    act: (bloc) => bloc.add(const ParseTextEvent('Trà sữa')),
    expect: () => [
      AiOrderLoading(),
      isA<AiOrderParsed>(),
    ],
  );

  blocTest<AiOrderBloc, AiOrderState>(
    'emits [loading, error] when no products found',
    build: () {
      when(() => mockParser.parse('xyz')).thenReturn([]);
      return bloc;
    },
    act: (bloc) => bloc.add(const ParseTextEvent('xyz')),
    expect: () => [
      AiOrderLoading(),
      isA<AiOrderError>(),
    ],
  );

  blocTest<AiOrderBloc, AiOrderState>(
    'emits [confirmed] on ConfirmItemsEvent',
    build: () => bloc,
    seed: () => AiOrderParsed(
      items: [ParsedOrderItem(productName: 'Test', confidence: 1.0)],
      sourceText: 'Test',
    ),
    act: (bloc) => bloc.add(ConfirmItemsEvent()),
    expect: () => [
      isA<AiOrderConfirmed>(),
    ],
  );
}
