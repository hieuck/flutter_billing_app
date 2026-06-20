import 'package:hive/hive.dart';
import 'package:billing_app/features/billing/domain/entities/invoice.dart';
import 'package:billing_app/features/billing/domain/entities/cart_item.dart';

part 'invoice_model.g.dart';

@HiveType(typeId: 4)
class InvoiceModel {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String itemsJson;
  @HiveField(2)
  final double totalAmount;
  @HiveField(3)
  final double totalCost;
  @HiveField(4)
  final DateTime createdAt;

  const InvoiceModel({
    required this.id,
    required this.itemsJson,
    required this.totalAmount,
    required this.totalCost,
    required this.createdAt,
  });

  factory InvoiceModel.fromEntity(Invoice invoice) {
    final itemsJson = invoice.items
        .map((item) =>
            '${item.product.id}|${item.product.name}|${item.product.price}|${item.product.costPrice ?? 0}|${item.quantity}')
        .join(';');
    return InvoiceModel(
      id: invoice.id,
      itemsJson: itemsJson,
      totalAmount: invoice.totalAmount,
      totalCost: invoice.totalCost,
      createdAt: invoice.createdAt,
    );
  }

  Invoice toEntity([List<CartItem> items = const []]) {
    return Invoice(
      id: id,
      items: items,
      totalAmount: totalAmount,
      totalCost: totalCost,
      createdAt: createdAt,
    );
  }
}
