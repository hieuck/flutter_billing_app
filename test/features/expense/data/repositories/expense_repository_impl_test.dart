import 'package:flutter_test/flutter_test.dart';
import 'package:billing_app/features/expense/data/repositories/expense_repository_impl.dart';

void main() {
  group('ExpenseRepositoryImpl', () {
    test('can be instantiated', () {
      expect(ExpenseRepositoryImpl(), isNotNull);
    });
  });
}
