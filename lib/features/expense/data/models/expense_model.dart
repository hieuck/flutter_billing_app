import 'package:hive/hive.dart';
import 'package:billing_app/features/expense/domain/entities/expense.dart';
import 'package:billing_app/features/expense/domain/entities/expense_category.dart';

part 'expense_model.g.dart';

@HiveType(typeId: 2)
class ExpenseModel extends Expense {
  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final double amount;
  @override
  @HiveField(2)
  final ExpenseCategory category;
  @override
  @HiveField(3)
  final String? note;
  @override
  @HiveField(4)
  final String? imagePath;
  @override
  @HiveField(5)
  final DateTime date;
  @override
  @HiveField(6)
  final DateTime createdAt;
  @override
  @HiveField(7)
  final DateTime updatedAt;

  const ExpenseModel({
    required this.id,
    required this.amount,
    required this.category,
    this.note,
    this.imagePath,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  }) : super(
          id: id,
          amount: amount,
          category: category,
          note: note,
          imagePath: imagePath,
          date: date,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  factory ExpenseModel.fromEntity(Expense expense) {
    return ExpenseModel(
      id: expense.id,
      amount: expense.amount,
      category: expense.category,
      note: expense.note,
      imagePath: expense.imagePath,
      date: expense.date,
      createdAt: expense.createdAt,
      updatedAt: expense.updatedAt,
    );
  }

  Expense toEntity() {
    return Expense(
      id: id,
      amount: amount,
      category: category,
      note: note,
      imagePath: imagePath,
      date: date,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
