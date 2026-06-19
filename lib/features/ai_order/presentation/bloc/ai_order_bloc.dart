import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/parsed_order_item.dart';
import '../../domain/services/order_parser.dart';

part 'ai_order_event.dart';
part 'ai_order_state.dart';

class AiOrderBloc extends Bloc<AiOrderEvent, AiOrderState> {
  final OrderParser parser;

  AiOrderBloc({required this.parser}) : super(AiOrderInitial()) {
    on<ParseTextEvent>(_onParseText);
    on<ConfirmItemsEvent>((_, emit) {
      final currentState = state;
      if (currentState is AiOrderParsed && currentState.items.isNotEmpty) {
        emit(AiOrderConfirmed(currentState.items));
      }
    });
    on<ClearResultsEvent>((_, emit) => emit(AiOrderInitial()));
  }

  Future<void> _onParseText(
      ParseTextEvent event, Emitter<AiOrderState> emit) async {
    emit(AiOrderLoading());
    try {
      final items = parser.parse(event.rawText);
      if (items.isEmpty) {
        emit(const AiOrderError('No products found in text'));
      } else {
        emit(AiOrderParsed(items: items, sourceText: event.rawText));
      }
    } catch (e) {
      emit(AiOrderError('Parse error: $e'));
    }
  }
}
