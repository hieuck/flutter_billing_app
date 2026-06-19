import 'package:equatable/equatable.dart';
import 'cart_item.dart';

class Invoice extends Equatable {
  final String id;
  final List<CartItem> items;
  final double subtotal;
  final double discount;
  final double totalAmount;
  final double totalCost;
  final DateTime createdAt;

  Invoice({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.totalCost,
    this.subtotal = 0,
    this.discount = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  double get profit => totalAmount - totalCost;
  int get itemCount => items.length;

  @override
  List<Object?> get props =>
      [id, items, subtotal, discount, totalAmount, totalCost, createdAt];
}
