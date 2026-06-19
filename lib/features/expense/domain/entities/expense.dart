import 'package:equatable/equatable.dart';
import 'expense_category.dart';

class Expense extends Equatable {
  final String id;
  final double amount;
  final ExpenseCategory category;
  final String? note;
  final String? imagePath;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Expense({
    required this.id,
    required this.amount,
    required this.category,
    this.note,
    this.imagePath,
    required this.date,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? date,
        updatedAt = updatedAt ?? date;

  Expense copyWith({
    double? amount,
    ExpenseCategory? category,
    String? note,
    String? imagePath,
    DateTime? date,
  }) {
    return Expense(
      id: id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      note: note ?? this.note,
      imagePath: imagePath ?? this.imagePath,
      date: date ?? this.date,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props =>
      [id, amount, category, note, imagePath, date, createdAt, updatedAt];
}
