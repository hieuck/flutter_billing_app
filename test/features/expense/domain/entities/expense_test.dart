import 'package:flutter_test/flutter_test.dart';
import 'package:billing_app/features/expense/domain/entities/expense.dart';
import 'package:billing_app/features/expense/domain/entities/expense_category.dart';

void main() {
  group('Expense', () {
    test('creates expense with all fields', () {
      final now = DateTime.now();
      final expense = Expense(
        id: '1',
        amount: 50000,
        category: ExpenseCategory.rawMaterials,
        note: 'Mua bột mì',
        date: now,
      );
      expect(expense.amount, 50000);
      expect(expense.category, ExpenseCategory.rawMaterials);
      expect(expense.note, 'Mua bột mì');
    });

    test('props includes all fields', () {
      final now = DateTime.now();
      final expense = Expense(
        id: '1',
        amount: 100000,
        category: ExpenseCategory.utilities,
        date: now,
      );
      expect(expense.props.contains(100000), isTrue);
      expect(expense.props.contains(ExpenseCategory.utilities), isTrue);
    });
  });
}
