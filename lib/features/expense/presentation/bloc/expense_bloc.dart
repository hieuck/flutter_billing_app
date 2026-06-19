import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:billing_app/features/expense/domain/entities/expense.dart';
import 'package:billing_app/features/expense/domain/entities/expense_category.dart';
import 'package:billing_app/features/expense/domain/usecases/expense_usecases.dart';

part 'expense_event.dart';
part 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final AddExpenseUseCase addExpenseUseCase;
  final GetExpensesByDateRangeUseCase getExpensesByDateRangeUseCase;
  final DeleteExpenseUseCase deleteExpenseUseCase;

  ExpenseBloc({
    required this.addExpenseUseCase,
    required this.getExpensesByDateRangeUseCase,
    required this.deleteExpenseUseCase,
  }) : super(ExpenseInitial()) {
    on<AddExpenseEvent>(_onAddExpense);
    on<LoadExpensesByDateEvent>(_onLoadByDate);
    on<DeleteExpenseEvent>(_onDelete);
  }

  Future<void> _onAddExpense(
      AddExpenseEvent event, Emitter<ExpenseState> emit) async {
    emit(ExpenseLoading());
    final expense = Expense(
      id: const Uuid().v4(),
      amount: event.amount,
      category: event.category,
      note: event.note,
      date: event.date ?? DateTime.now(),
    );
    final result = await addExpenseUseCase(expense);
    result.fold(
      (failure) => emit(ExpenseError(failure.message)),
      (_) => emit(ExpenseOperationSuccess()),
    );
  }

  Future<void> _onLoadByDate(
      LoadExpensesByDateEvent event, Emitter<ExpenseState> emit) async {
    emit(ExpenseLoading());
    final from = event.from ??
        DateTime.now().subtract(const Duration(days: 30));
    final to = event.to ?? DateTime.now();
    final result = await getExpensesByDateRangeUseCase(
        GetExpensesByDateParams(from, to));
    result.fold(
      (failure) => emit(ExpenseError(failure.message)),
      (expenses) => emit(ExpenseLoaded(expenses)),
    );
  }

  Future<void> _onDelete(
      DeleteExpenseEvent event, Emitter<ExpenseState> emit) async {
    final result = await deleteExpenseUseCase(event.id);
    result.fold(
      (failure) => emit(ExpenseError(failure.message)),
      (_) => add(const LoadExpensesByDateEvent()),
    );
  }
}
