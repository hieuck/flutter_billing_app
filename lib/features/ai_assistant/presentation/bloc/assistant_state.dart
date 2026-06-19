part of 'assistant_bloc.dart';

abstract class AssistantState extends Equatable {
  const AssistantState();

  @override
  List<Object?> get props => [];
}

class AssistantInitial extends AssistantState {}

class AssistantLoading extends AssistantState {}

class AssistantAnswered extends AssistantState {
  final String question;
  final String answer;
  final List<ChatMessage> messages;

  const AssistantAnswered({
    required this.question,
    required this.answer,
    required this.messages,
  });

  @override
  List<Object?> get props => [question, answer, messages];
}

class AssistantError extends AssistantState {
  final String message;
  const AssistantError(this.message);

  @override
  List<Object?> get props => [message];
}

class ChatMessage {
  final String text;
  final bool isUser;
  const ChatMessage({required this.text, required this.isUser});
}
