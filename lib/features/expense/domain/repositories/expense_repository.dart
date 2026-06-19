import 'package:fpdart/fpdart.dart';
import 'package:billing_app/core/error/failure.dart';
import '../entities/expense.dart';

abstract class ExpenseRepository {
  Future<Either<Failure, void>> addExpense(Expense expense);
  Future<Either<Failure, List<Expense>>> getExpensesByDateRange(
      DateTime from, DateTime to);
  Future<Either<Failure, List<Expense>>> getAllExpenses();
  Future<Either<Failure, void>> deleteExpense(String id);
}
