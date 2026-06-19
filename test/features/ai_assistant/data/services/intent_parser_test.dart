import 'package:flutter_test/flutter_test.dart';
import 'package:billing_app/features/ai_assistant/data/services/intent_parser.dart';

void main() {
  late IntentParser parser;

  setUp(() {
    parser = IntentParser();
  });

  group('parseIntent', () {
    test('recognizes revenue query', () {
      final result = parser.parseIntent('Doanh thu hôm nay bao nhiêu?');
      expect(result.intent, IntentType.revenue);
      expect(result.timeFrame, TimeFrame.today);
    });

    test('recognizes expense query', () {
      final result = parser.parseIntent('Chi phí tháng này là bao nhiêu?');
      expect(result.intent, IntentType.expense);
      expect(result.timeFrame, TimeFrame.thisMonth);
    });

    test('recognizes profit query', () {
      final result = parser.parseIntent('Lợi nhuận hôm qua?');
      expect(result.intent, IntentType.profit);
      expect(result.timeFrame, TimeFrame.yesterday);
    });

    test('recognizes top products query', () {
      final result = parser.parseIntent('Sản phẩm nào bán chạy nhất?');
      expect(result.intent, IntentType.topProducts);
    });

    test('defaults to today when no time specified', () {
      final result = parser.parseIntent('Doanh thu?');
      expect(result.intent, IntentType.revenue);
      expect(result.timeFrame, TimeFrame.today);
    });
  });
}
