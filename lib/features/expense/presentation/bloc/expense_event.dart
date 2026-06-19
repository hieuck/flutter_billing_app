part of 'expense_bloc.dart';

abstract class ExpenseEvent extends Equatable {
  const ExpenseEvent();
  @override
  List<Object?> get props => [];
}

class AddExpenseEvent extends ExpenseEvent {
  final double amount;
  final ExpenseCategory category;
  final String? note;
  final DateTime? date;

  const AddExpenseEvent({
    required this.amount,
    required this.category,
    this.note,
    this.date,
  });

  @override
  List<Object?> get props => [amount, category, note, date];
}

class LoadExpensesByDateEvent extends ExpenseEvent {
  final DateTime? from;
  final DateTime? to;

  const LoadExpensesByDateEvent({this.from, this.to});

  @override
  List<Object?> get props => [from, to];
}

class DeleteExpenseEvent extends ExpenseEvent {
  final String id;
  const DeleteExpenseEvent(this.id);
  @override
  List<Object?> get props => [id];
}
