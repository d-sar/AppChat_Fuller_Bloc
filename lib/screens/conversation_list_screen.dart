import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../blocs/conversation_bloc.dart';
import '../blocs/conversation_event.dart';
import '../blocs/conversation_state.dart';
import '../models/conversation.dart';
import 'chat_screen.dart';

class ConversationListScreen extends StatelessWidget {
  const ConversationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversations'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
            tooltip: 'Rechercher une conversation',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateConversationDialog(context),
            tooltip: 'Nouvelle conversation',
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, value),
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('Actualiser'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'mark_all_read',
                child: Row(
                  children: [
                    Icon(Icons.mark_email_read),
                    SizedBox(width: 8),
                    Text('Tout marquer comme lu'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Paramètres'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocBuilder<ConversationBloc, ConversationState>(
        builder: (context, state) {
          if (state is ConversationInitial) {
            context.read<ConversationBloc>().add(LoadConversations());
            return const Center(child: CircularProgressIndicator());
          } else if (state is ConversationLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ConversationLoaded) {
            return _buildConversationList(context, state.conversations);
          } else if (state is ConversationError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur: ${state.message}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ConversationBloc>().add(LoadConversations());
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateConversationDialog(context),
        backgroundColor: Colors.blue,
        tooltip: 'Nouvelle conversation',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildConversationList(
    BuildContext context,
    List<Conversation> conversations,
  ) {
    if (conversations.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Aucune conversation',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Appuyez sur + pour créer une nouvelle conversation',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final conversation = conversations[index];
        return _buildConversationTile(context, conversation);
      },
    );
  }

  Widget _buildConversationTile(
    BuildContext context,
    Conversation conversation,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            conversation.contactName.isNotEmpty
                ? conversation.contactName[0].toUpperCase()
                : '?',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          conversation.contactName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          conversation.lastMessage,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatTimestamp(conversation.timestamp),
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                if (conversation.unreadCount > 0) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      conversation.unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.grey),
              onPressed: () => _showConversationOptions(context, conversation),
              tooltip: 'Options de conversation',
            ),
          ],
        ),
        onTap: () => _navigateToChat(context, conversation),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return DateFormat('dd/MM').format(timestamp);
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min';
    } else {
      return 'maintenant';
    }
  }

  void _navigateToChat(BuildContext context, Conversation conversation) {
    final bloc = context.read<ConversationBloc>();

    // Sélectionner la conversation
    bloc.add(SelectConversation(conversationId: conversation.id));

    // Marquer les messages comme lus
    if (conversation.unreadCount > 0) {
      bloc.add(MarkAsRead(conversationId: conversation.id));
    }

    // Naviguer vers l'écran de chat
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ChatScreen(conversation: conversation, conversationBloc: bloc),
      ),
    );
  }

  void _showConversationOptions(
    BuildContext context,
    Conversation conversation,
  ) {
    final bloc = context.read<ConversationBloc>();
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bottomSheetContext) {
        return BlocProvider.value(
          value: bloc,
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.chat),
                  title: const Text('Ouvrir la conversation'),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    _navigateToChat(context, conversation);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.mark_email_read),
                  title: Text(
                    conversation.unreadCount > 0
                        ? 'Marquer comme lu'
                        : 'Déjà lu',
                  ),
                  enabled: conversation.unreadCount > 0,
                  onTap: conversation.unreadCount > 0
                      ? () {
                          Navigator.pop(bottomSheetContext);
                          bottomSheetContext.read<ConversationBloc>().add(
                            MarkAsRead(conversationId: conversation.id),
                          );
                        }
                      : null,
                ),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('Informations du contact'),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    _showContactInfo(context, conversation);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.cancel),
                  title: const Text('Annuler'),
                  onTap: () => Navigator.pop(bottomSheetContext),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showContactInfo(BuildContext context, Conversation conversation) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Informations - ${conversation.contactName}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.person, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text('Nom: ${conversation.contactName}'),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.message, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Dernier message: ${conversation.lastMessage}'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(
                    'Dernière activité: ${_formatTimestamp(conversation.timestamp)}',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    conversation.unreadCount > 0
                        ? Icons.mark_email_unread
                        : Icons.mark_email_read,
                    color: conversation.unreadCount > 0
                        ? Colors.red
                        : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text('Messages non lus: ${conversation.unreadCount}'),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _navigateToChat(context, conversation);
              },
              child: const Text('Ouvrir conversation'),
            ),
          ],
        );
      },
    );
  }

  void _showSearchDialog(BuildContext context) {
    final searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rechercher une conversation'),
        content: TextField(
          controller: searchController,
          decoration: const InputDecoration(
            labelText: 'Nom du contact',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.search),
          ),
          autofocus: true,
          onChanged: (value) {
            // TODO: Implémenter la recherche en temps réel
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implémenter la logique de recherche
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fonctionnalité de recherche à venir'),
                ),
              );
            },
            child: const Text('Rechercher'),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'refresh':
        context.read<ConversationBloc>().add(LoadConversations());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conversations actualisées')),
        );
        break;
      case 'mark_all_read':
        _markAllAsRead(context);
        break;
      case 'settings':
        _showSettings(context);
        break;
    }
  }

  void _markAllAsRead(BuildContext context) {
    final state = context.read<ConversationBloc>().state;
    if (state is ConversationLoaded) {
      final unreadConversations = state.conversations
          .where((conv) => conv.unreadCount > 0)
          .toList();

      if (unreadConversations.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Aucun message non lu')));
        return;
      }

      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Marquer tout comme lu'),
          content: Text(
            'Marquer ${unreadConversations.length} conversation(s) comme lue(s) ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                for (final conversation in unreadConversations) {
                  context.read<ConversationBloc>().add(
                    MarkAsRead(conversationId: conversation.id),
                  );
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${unreadConversations.length} conversation(s) marquée(s) comme lue(s)',
                    ),
                  ),
                );
              },
              child: const Text('Confirmer'),
            ),
          ],
        ),
      );
    }
  }

  void _showSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Paramètres'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.notifications),
                title: Text('Notifications'),
                subtitle: Text('Gérer les notifications'),
              ),
              ListTile(
                leading: Icon(Icons.dark_mode),
                title: Text('Thème sombre'),
                subtitle: Text('Activer le mode sombre'),
              ),
              ListTile(
                leading: Icon(Icons.language),
                title: Text('Langue'),
                subtitle: Text('Changer la langue'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  void _showCreateConversationDialog(BuildContext context) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Nouvelle conversation'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Nom du contact',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                context.read<ConversationBloc>().add(
                  CreateConversation(contactName: nameController.text.trim()),
                );
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }
}
