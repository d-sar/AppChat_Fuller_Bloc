// lib/blocs/conversation_event.dart
import 'package:equatable/equatable.dart';
import '../models/message.dart';

abstract class ConversationEvent extends Equatable {
  const ConversationEvent();

  @override
  List<Object> get props => [];
}

class LoadConversations extends ConversationEvent {}

class SendMessage extends ConversationEvent {
  final String conversationId;
  final String content;

  const SendMessage({required this.conversationId, required this.content});

  @override
  List<Object> get props => [conversationId, content];
}

class ReceiveMessage extends ConversationEvent {
  final Message message;

  const ReceiveMessage({required this.message});

  @override
  List<Object> get props => [message];
}

class CreateConversation extends ConversationEvent {
  final String contactName;

  const CreateConversation({required this.contactName});

  @override
  List<Object> get props => [contactName];
}

class SelectConversation extends ConversationEvent {
  final String conversationId;

  const SelectConversation({required this.conversationId});

  @override
  List<Object> get props => [conversationId];
}

class MarkAsRead extends ConversationEvent {
  final String conversationId;

  const MarkAsRead({required this.conversationId});

  @override
  List<Object> get props => [conversationId];
}
