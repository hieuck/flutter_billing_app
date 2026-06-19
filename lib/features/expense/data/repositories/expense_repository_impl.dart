import 'package:fpdart/fpdart.dart';
import 'package:billing_app/core/error/failure.dart';
import 'package:billing_app/core/data/hive_database.dart';
import 'package:billing_app/features/expense/domain/entities/expense.dart';
import 'package:billing_app/features/expense/domain/repositories/expense_repository.dart';
import '../models/expense_model.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  @override
  Future<Either<Failure, void>> addExpense(Expense expense) async {
    try {
      final model = ExpenseModel.fromEntity(expense);
      await HiveDatabase.expensesBox.put(expense.id, model);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Expense>>> getExpensesByDateRange(
      DateTime from, DateTime to) async {
    try {
      final all = HiveDatabase.expensesBox.values
          .where((e) =>
              e.date.isAfter(from.subtract(const Duration(days: 1))) &&
              e.date.isBefore(to.add(const Duration(days: 1))))
          .map((e) => e.toEntity())
          .toList();
      return Right(all);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Expense>>> getAllExpenses() async {
    try {
      final all = HiveDatabase.expensesBox.values
          .map((e) => e.toEntity())
          .toList();
      return Right(all);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteExpense(String id) async {
    try {
      await HiveDatabase.expensesBox.delete(id);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
