import 'package:fpdart/fpdart.dart';
import 'package:billing_app/core/error/failure.dart';
import 'package:billing_app/core/usecase/usecase.dart';
import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

class AddExpenseUseCase extends UseCase<void, Expense> {
  final ExpenseRepository repository;
  AddExpenseUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(Expense params) =>
      repository.addExpense(params);
}

class GetExpensesByDateRangeUseCase
    extends UseCase<List<Expense>, GetExpensesByDateParams> {
  final ExpenseRepository repository;
  GetExpensesByDateRangeUseCase(this.repository);

  @override
  Future<Either<Failure, List<Expense>>> call(GetExpensesByDateParams params) =>
      repository.getExpensesByDateRange(params.from, params.to);
}

class GetExpensesByDateParams {
  final DateTime from;
  final DateTime to;
  GetExpensesByDateParams(this.from, this.to);
}

class GetAllExpensesUseCase extends UseCase<List<Expense>, NoParams> {
  final ExpenseRepository repository;
  GetAllExpensesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Expense>>> call(NoParams params) =>
      repository.getAllExpenses();
}

class DeleteExpenseUseCase extends UseCase<void, String> {
  final ExpenseRepository repository;
  DeleteExpenseUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String params) =>
      repository.deleteExpense(params);
}
