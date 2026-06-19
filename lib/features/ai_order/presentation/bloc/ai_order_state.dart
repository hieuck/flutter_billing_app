part of 'ai_order_bloc.dart';

abstract class AiOrderState extends Equatable {
  const AiOrderState();
  @override
  List<Object?> get props => [];
}

class AiOrderInitial extends AiOrderState {}

class AiOrderLoading extends AiOrderState {}

class AiOrderParsed extends AiOrderState {
  final List<ParsedOrderItem> items;
  final String sourceText;
  const AiOrderParsed({required this.items, required this.sourceText});
  @override
  List<Object?> get props => [items, sourceText];
}

class AiOrderConfirmed extends AiOrderState {
  final List<ParsedOrderItem> items;
  const AiOrderConfirmed(this.items);
  @override
  List<Object?> get props => [items];
}

class AiOrderError extends AiOrderState {
  final String message;
  const AiOrderError(this.message);
  @override
  List<Object?> get props => [message];
}
