import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billing_app/core/error/failure.dart';
import 'package:billing_app/features/expense/domain/entities/expense.dart';
import 'package:billing_app/features/expense/domain/entities/expense_category.dart';
import 'package:billing_app/features/expense/domain/repositories/expense_repository.dart';
import 'package:billing_app/features/expense/domain/usecases/expense_usecases.dart';

class MockExpenseRepository extends Mock implements ExpenseRepository {}

void main() {
  late MockExpenseRepository mockRepository;
  late AddExpenseUseCase addUseCase;
  late GetExpensesByDateRangeUseCase getByDateUseCase;
  late DeleteExpenseUseCase deleteUseCase;

  setUp(() {
    mockRepository = MockExpenseRepository();
    addUseCase = AddExpenseUseCase(mockRepository);
    getByDateUseCase = GetExpensesByDateRangeUseCase(mockRepository);
    deleteUseCase = DeleteExpenseUseCase(mockRepository);
  });

  group('AddExpenseUseCase', () {
    test('returns Right when repository succeeds', () async {
      final expense = Expense(
        id: '1', amount: 50000,
        category: ExpenseCategory.other,
        date: DateTime.now(),
      );
      when(() => mockRepository.addExpense(any()))
          .thenAnswer((_) async => const Right(null));

      final result = await addUseCase(expense);
      expect(result.isRight(), isTrue);
      verify(() => mockRepository.addExpense(expense)).called(1);
    });
  });

  group('GetExpensesByDateRangeUseCase', () {
    test('returns list of expenses', () async {
      final from = DateTime(2026, 1, 1);
      final to = DateTime(2026, 1, 31);
      when(() => mockRepository.getExpensesByDateRange(from, to))
          .thenAnswer((_) async => Right([]));

      final result = await getByDateUseCase(GetExpensesByDateParams(from, to));
      expect(result.isRight(), isTrue);
    });
  });

  group('DeleteExpenseUseCase', () {
    test('deletes expense', () async {
      when(() => mockRepository.deleteExpense('1'))
          .thenAnswer((_) async => const Right(null));

      final result = await deleteUseCase('1');
      expect(result.isRight(), isTrue);
    });
  });
}
