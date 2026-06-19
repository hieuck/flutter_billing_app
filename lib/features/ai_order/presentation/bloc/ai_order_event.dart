part of 'ai_order_bloc.dart';

abstract class AiOrderEvent extends Equatable {
  const AiOrderEvent();
  @override
  List<Object?> get props => [];
}

class ParseTextEvent extends AiOrderEvent {
  final String rawText;
  const ParseTextEvent(this.rawText);
  @override
  List<Object?> get props => [rawText];
}

class ConfirmItemsEvent extends AiOrderEvent {}

class ClearResultsEvent extends AiOrderEvent {}
