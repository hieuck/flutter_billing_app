import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billing_app/features/expense/domain/entities/expense.dart';
import 'package:billing_app/features/expense/domain/entities/expense_category.dart';
import 'package:billing_app/features/expense/domain/usecases/expense_usecases.dart';
import 'package:billing_app/features/expense/presentation/bloc/expense_bloc.dart';

class MockAddExpense extends Mock implements AddExpenseUseCase {}
class MockGetExpensesByDate extends Mock implements GetExpensesByDateRangeUseCase {}
class MockDeleteExpense extends Mock implements DeleteExpenseUseCase {}

class _FakeExpense extends Fake implements Expense {}
class _FakeGetExpensesByDateParams extends Fake implements GetExpensesByDateParams {}

void main() {
  late ExpenseBloc bloc;
  late MockAddExpense mockAdd;
  late MockGetExpensesByDate mockGetByDate;
  late MockDeleteExpense mockDelete;

  setUpAll(() {
    registerFallbackValue(_FakeExpense());
    registerFallbackValue(_FakeGetExpensesByDateParams());
  });

  setUp(() {
    mockAdd = MockAddExpense();
    mockGetByDate = MockGetExpensesByDate();
    mockDelete = MockDeleteExpense();
    bloc = ExpenseBloc(
      addExpenseUseCase: mockAdd,
      getExpensesByDateRangeUseCase: mockGetByDate,
      deleteExpenseUseCase: mockDelete,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('AddExpenseEvent', () {
    blocTest<ExpenseBloc, ExpenseState>(
      'emits [loading, success] when add succeeds',
      build: () {
        when(() => mockAdd(any()))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(const AddExpenseEvent(
        amount: 50000, category: ExpenseCategory.other, date: null,
      )),
      expect: () => [
        ExpenseLoading(),
        ExpenseOperationSuccess(),
      ],
    );
  });

  group('LoadExpensesByDateEvent', () {
    blocTest<ExpenseBloc, ExpenseState>(
      'emits [loading, loaded] with expenses',
      build: () {
        when(() => mockGetByDate(any()))
            .thenAnswer((_) async => Right(<Expense>[]));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadExpensesByDateEvent(
        from: null, to: null,
      )),
      expect: () => [
        ExpenseLoading(),
        isA<ExpenseLoaded>(),
      ],
    );
  });
}
