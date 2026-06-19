import 'package:flutter_test/flutter_test.dart';
import 'package:billing_app/features/ai_assistant/data/services/business_assistant_impl.dart';
import 'package:billing_app/features/ai_assistant/data/services/intent_parser.dart';

void main() {
  late BusinessAssistantImpl assistant;

  setUp(() {
    assistant = BusinessAssistantImpl();
  });

  group('answer', () {
    test('returns message for revenue query', () async {
      final result = await assistant.answer('Doanh thu hôm nay');
      expect(result, contains('doanh thu'));
    });

    test('returns message for expense query', () async {
      final result = await assistant.answer('Chi phí hôm nay');
      expect(result, contains('chi phí'));
    });

    test('returns message for unknown query', () async {
      final result = await assistant.answer('Xin chào');
      expect(result, contains('không'));
    });
  });
}
