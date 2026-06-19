import 'package:flutter_test/flutter_test.dart';
import 'package:billing_app/features/ai_order/data/services/order_parser_impl.dart';

void main() {
  late OrderParserImpl parser;

  setUp(() {
    parser = OrderParserImpl([]);
  });

  group('parse', () {
    test('parses single product name', () {
      parser = OrderParserImpl(['Trà sữa', 'Cà phê']);
      final result = parser.parse('Trà sữa');
      expect(result.length, 1);
      expect(result.first.productName, 'Trà sữa');
      expect(result.first.quantity, 1);
    });

    test('parses product with quantity prefix', () {
      parser = OrderParserImpl(['Trà sữa']);
      final result = parser.parse('2 Trà sữa');
      expect(result.length, 1);
      expect(result.first.productName, 'Trà sữa');
      expect(result.first.quantity, 2);
    });

    test('parses multiple lines', () {
      parser = OrderParserImpl(['Trà sữa', 'Cà phê']);
      final result = parser.parse('2 Trà sữa\n1 Cà phê');
      expect(result.length, 2);
      expect(result.first.productName, 'Trà sữa');
      expect(result.first.quantity, 2);
      expect(result.last.productName, 'Cà phê');
    });

    test('returns empty list when no match', () {
      parser = OrderParserImpl(['Trà sữa']);
      final result = parser.parse('Bánh mì');
      expect(result, isEmpty);
    });

    test('handles comma-separated input', () {
      parser = OrderParserImpl(['Trà sữa', 'Cà phê']);
      final result = parser.parse('Trà sữa, Cà phê');
      expect(result.length, 2);
    });
  });
}
