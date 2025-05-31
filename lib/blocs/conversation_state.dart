import 'package:equatable/equatable.dart';
import '../models/conversation.dart';
import '../models/message.dart';

abstract class ConversationState extends Equatable {
  const ConversationState();

  @override
  List<Object?> get props => [];
}

class ConversationInitial extends ConversationState {}

class ConversationLoading extends ConversationState {}

class ConversationLoaded extends ConversationState {
  final List<Conversation> conversations;
  final Map<String, List<Message>> messages;
  final String? selectedConversationId;

  const ConversationLoaded({
    required this.conversations,
    required this.messages,
    this.selectedConversationId,
  });

  @override
  List<Object?> get props => [conversations, messages, selectedConversationId];

  ConversationLoaded copyWith({
    List<Conversation>? conversations,
    Map<String, List<Message>>? messages,
    String? selectedConversationId,
  }) {
    return ConversationLoaded(
      conversations: conversations ?? this.conversations,
      messages: messages ?? this.messages,
      selectedConversationId: selectedConversationId ?? this.selectedConversationId,
    );
  }
}

class ConversationError extends ConversationState {
  final String message;

  const ConversationError({required this.message});

  @override
  List<Object> get props => [message];
}
