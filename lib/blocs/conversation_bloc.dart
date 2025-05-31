import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import 'conversation_event.dart';
import 'conversation_state.dart';

class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  ConversationBloc() : super(ConversationInitial()) {
    on<LoadConversations>(_onLoadConversations);
    on<SendMessage>(_onSendMessage);
    on<ReceiveMessage>(_onReceiveMessage);
    on<CreateConversation>(_onCreateConversation);
    on<SelectConversation>(_onSelectConversation);
    on<MarkAsRead>(_onMarkAsRead);
  }

  // Données mock pour simulation
  final List<Conversation> _mockConversations = [
    Conversation(
      id: '1',
      contactName: 'Sara',
      lastMessage: 'Salut ! Comment ça va ?',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      unreadCount: 2,
    ),
    Conversation(
      id: '2',
      contactName: 'Laila',
      lastMessage: 'À bientôt !',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      unreadCount: 0,
    ),
    Conversation(
      id: '3',
      contactName: 'Ahmed',
      lastMessage: 'Merci pour ton aide',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      unreadCount: 1,
    ),
  ];

  final Map<String, List<Message>> _mockMessages = {
    '1': [
      Message(
        id: '1',
        conversationId: '1',
        content: 'Salut Sara !',
        isMe: true,
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
      Message(
        id: '2',
        conversationId: '1',
        content: 'Salut ! Comment ça va ?',
        isMe: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ],
    '2': [
      Message(
        id: '3',
        conversationId: '2',
        content: 'Hey Laila !',
        isMe: true,
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      Message(
        id: '4',
        conversationId: '2',
        content: 'À bientôt !',
        isMe: false,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ],
    '3': [
      Message(
        id: '5',
        conversationId: '3',
        content: 'Merci pour ton aide',
        isMe: false,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ],
  };

  void _onLoadConversations(
    LoadConversations event,
    Emitter<ConversationState> emit,
  ) async {
    emit(ConversationLoading());
    // Simulation d'un délai de chargement
    await Future.delayed(const Duration(milliseconds: 500));

    emit(
      ConversationLoaded(
        conversations: List.from(_mockConversations),
        messages: Map.from(_mockMessages),
      ),
    );
  }

  void _onSendMessage(
    SendMessage event,
    Emitter<ConversationState> emit,
  ) async {
    if (state is ConversationLoaded) {
      final currentState = state as ConversationLoaded;

      // Créer le nouveau message
      final newMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        conversationId: event.conversationId,
        content: event.content,
        isMe: true,
        timestamp: DateTime.now(),
      );

      // Mettre à jour les messages
      final updatedMessages = Map<String, List<Message>>.from(
        currentState.messages,
      );
      if (updatedMessages.containsKey(event.conversationId)) {
        updatedMessages[event.conversationId] = [
          ...updatedMessages[event.conversationId]!,
          newMessage,
        ];
      } else {
        updatedMessages[event.conversationId] = [newMessage];
      }

      // Mettre à jour la conversation
      final updatedConversations = currentState.conversations.map((conv) {
        if (conv.id == event.conversationId) {
          return conv.copyWith(
            lastMessage: event.content,
            timestamp: DateTime.now(),
          );
        }
        return conv;
      }).toList();

      // Trier les conversations par timestamp
      updatedConversations.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      emit(
        currentState.copyWith(
          conversations: updatedConversations,
          messages: updatedMessages,
        ),
      );

      // Simuler une réponse automatique après 2 secondes
      await Future.delayed(const Duration(seconds: 2));

      final responseMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        conversationId: event.conversationId,
        content: 'Message reçu !',
        isMe: false,
        timestamp: DateTime.now(),
      );

      add(ReceiveMessage(message: responseMessage));
    }
  }

  void _onReceiveMessage(
    ReceiveMessage event,
    Emitter<ConversationState> emit,
  ) {
    if (state is ConversationLoaded) {
      final currentState = state as ConversationLoaded;

      // Mettre à jour les messages
      final updatedMessages = Map<String, List<Message>>.from(
        currentState.messages,
      );
      if (updatedMessages.containsKey(event.message.conversationId)) {
        updatedMessages[event.message.conversationId] = [
          ...updatedMessages[event.message.conversationId]!,
          event.message,
        ];
      } else {
        updatedMessages[event.message.conversationId] = [event.message];
      }

      // Mettre à jour la conversation
      final updatedConversations = currentState.conversations.map((conv) {
        if (conv.id == event.message.conversationId) {
          return conv.copyWith(
            lastMessage: event.message.content,
            timestamp: event.message.timestamp,
            unreadCount: conv.unreadCount + 1,
          );
        }
        return conv;
      }).toList();

      // Trier les conversations par timestamp
      updatedConversations.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      emit(
        currentState.copyWith(
          conversations: updatedConversations,
          messages: updatedMessages,
        ),
      );
    }
  }

  void _onCreateConversation(
    CreateConversation event,
    Emitter<ConversationState> emit,
  ) {
    if (state is ConversationLoaded) {
      final currentState = state as ConversationLoaded;

      final newConversation = Conversation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        contactName: event.contactName,
        lastMessage: 'Nouvelle conversation',
        timestamp: DateTime.now(),
      );

      final updatedConversations = [
        newConversation,
        ...currentState.conversations,
      ];

      emit(currentState.copyWith(conversations: updatedConversations));
    }
  }

  void _onSelectConversation(
    SelectConversation event,
    Emitter<ConversationState> emit,
  ) {
    if (state is ConversationLoaded) {
      final currentState = state as ConversationLoaded;
      emit(currentState.copyWith(selectedConversationId: event.conversationId));
    }
  }

  void _onMarkAsRead(MarkAsRead event, Emitter<ConversationState> emit) {
    if (state is ConversationLoaded) {
      final currentState = state as ConversationLoaded;

      final updatedConversations = currentState.conversations.map((conv) {
        if (conv.id == event.conversationId) {
          return conv.copyWith(unreadCount: 0);
        }
        return conv;
      }).toList();

      emit(currentState.copyWith(conversations: updatedConversations));
    }
  }
}
