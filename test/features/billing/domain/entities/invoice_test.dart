import 'package:flutter_test/flutter_test.dart';
import 'package:billing_app/features/billing/domain/entities/invoice.dart';
import 'package:billing_app/features/billing/domain/entities/cart_item.dart';
import 'package:billing_app/features/product/domain/entities/product.dart';

void main() {
  group('Invoice', () {
    test('calculates profit correctly', () {
      final product = Product(
        id: '1', name: 'Test', barcode: '123',
        price: 100.0, costPrice: 60.0,
      );
      final items = [CartItem(product: product, quantity: 2)];
      final invoice = Invoice(
        id: 'inv1',
        items: items,
        totalAmount: 200.0,
        totalCost: 120.0,
      );
      expect(invoice.profit, 80.0);
      expect(invoice.itemCount, 1);
    });

    test('profit is totalAmount - totalCost', () {
      final invoice = Invoice(
        id: 'inv1',
        items: [],
        totalAmount: 100.0,
        totalCost: 0,
      );
      expect(invoice.profit, 100.0);
    });
  });
}
