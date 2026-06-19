import 'package:flutter_test/flutter_test.dart';
import 'package:billing_app/features/ai_order/domain/entities/parsed_order_item.dart';

void main() {
  group('ParsedOrderItem', () {
    test('creates item with all fields', () {
      final item = ParsedOrderItem(
        productName: 'Trà sữa',
        quantity: 2,
        confidence: 0.95,
        matchedProductId: '123',
      );
      expect(item.productName, 'Trà sữa');
      expect(item.quantity, 2);
      expect(item.confidence, 0.95);
    });

    test('quantity defaults to 1', () {
      final item = ParsedOrderItem(
        productName: 'Cà phê',
        confidence: 0.8,
      );
      expect(item.quantity, 1);
    });

    test('props includes fields', () {
      final item = ParsedOrderItem(productName: 'Test', confidence: 1.0);
      expect(item.props.contains('Test'), isTrue);
    });
  });
}
