import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/services/business_assistant.dart';

part 'assistant_event.dart';
part 'assistant_state.dart';

class AssistantBloc extends Bloc<AssistantEvent, AssistantState> {
  final BusinessAssistant assistant;
  final List<ChatMessage> _messages = [];

  AssistantBloc({required this.assistant}) : super(AssistantInitial()) {
    on<AskQuestionEvent>(_onAsk);
    on<ClearChatEvent>((_, emit) {
      _messages.clear();
      emit(AssistantInitial());
    });
  }

  Future<void> _onAsk(
      AskQuestionEvent event, Emitter<AssistantState> emit) async {
    emit(AssistantLoading());
    _messages.add(ChatMessage(text: event.question, isUser: true));
    try {
      final answer = await assistant.answer(event.question);
      _messages.add(ChatMessage(text: answer, isUser: false));
      emit(AssistantAnswered(
        question: event.question,
        answer: answer,
        messages: List.unmodifiable(_messages),
      ));
    } catch (e) {
      _messages.add(ChatMessage(text: 'Lỗi: $e', isUser: false));
      emit(AssistantError(e.toString()));
    }
  }
}
