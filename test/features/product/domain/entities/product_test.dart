import 'package:flutter_test/flutter_test.dart';
import 'package:billing_app/features/product/domain/entities/product.dart';

void main() {
  group('Product', () {
    test('supports costPrice', () {
      const product = Product(
        id: '1',
        name: 'Test',
        barcode: '123',
        price: 100.0,
        costPrice: 70.0,
        stock: 10,
      );
      expect(product.costPrice, 70.0);
      expect(product.props.contains(70.0), isTrue);
    });

    test('costPrice defaults to null', () {
      const product = Product(
        id: '1',
        name: 'Test',
        barcode: '123',
        price: 100.0,
        stock: 10,
      );
      expect(product.costPrice, isNull);
    });
  });
}
