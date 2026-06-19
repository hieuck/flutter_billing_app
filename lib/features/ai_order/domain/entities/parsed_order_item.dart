import 'package:equatable/equatable.dart';

class ParsedOrderItem extends Equatable {
  final String productName;
  final double quantity;
  final double confidence;
  final String? matchedProductId;

  const ParsedOrderItem({
    required this.productName,
    this.quantity = 1,
    required this.confidence,
    this.matchedProductId,
  });

  @override
  List<Object?> get props =>
      [productName, quantity, confidence, matchedProductId];
}
