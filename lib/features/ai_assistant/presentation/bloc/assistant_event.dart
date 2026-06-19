part of 'assistant_bloc.dart';

abstract class AssistantEvent extends Equatable {
  const AssistantEvent();

  @override
  List<Object?> get props => [];
}

class AskQuestionEvent extends AssistantEvent {
  final String question;
  const AskQuestionEvent(this.question);

  @override
  List<Object?> get props => [question];
}

class ClearChatEvent extends AssistantEvent {}
