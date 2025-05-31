# Application de Chat Flutter

Une application de chat complète développée avec Flutter utilisant le pattern BLoC pour la gestion d'état.

## 🚀 Fonctionnalités

### ✅ Fonctionnalités Implémentées

#### 1. Écran Liste des Conversations
- ✅ Liste des conversations avec avatar, nom et dernier message
- ✅ Badge rouge pour les messages non lus avec compteur
- ✅ Navigation vers l'écran de conversation détaillée
- ✅ Possibilité de créer une nouvelle conversation
- ✅ Formatage intelligent des timestamps (maintenant, Xmin, Xh, dd/MM)
- ✅ Tri automatique des conversations par timestamp

#### 2. Écran Conversation Détaillée
- ✅ Messages de la conversation sélectionnée
- ✅ Champ de texte pour écrire un message
- ✅ Bouton envoyer avec icône
- ✅ Messages différenciés visuellement (utilisateur vs contact)
- ✅ Scroll automatique vers le bas lors de nouveaux messages
- ✅ Timestamps pour chaque message
- ✅ Interface responsive avec bulles de chat

#### 3. Gestion d'État avec BLoC
- ✅ ConversationBloc avec états immutables
- ✅ Events : LoadConversations, SendMessage, ReceiveMessage, CreateConversation, SelectConversation, MarkAsRead
- ✅ États : ConversationInitial, ConversationLoading, ConversationLoaded, ConversationError
- ✅ Utilisation d'Equatable pour les comparaisons d'états

#### 4. Modèles de Données
- ✅ **Conversation** : id, contactName, lastMessage, timestamp, unreadCount
- ✅ **Message** : id, conversationId, content, timestamp, isMe
- ✅ Méthodes copyWith pour l'immutabilité

#### 5. Fonctionnalités Avancées
- ✅ Simulation de réponses automatiques
- ✅ Marquage automatique des messages comme lus
- ✅ Données mock pour la démonstration
- ✅ Gestion des erreurs avec écran de retry
- ✅ Interface utilisateur moderne et intuitive

## 🏗️ Architecture

### Structure du Projet
```
lib/
├── blocs/
│   ├── conversation_bloc.dart
│   ├── conversation_event.dart
│   └── conversation_state.dart
├── models/
│   ├── conversation.dart
│   └── message.dart
├── screens/
│   ├── conversation_list_screen.dart
│   └── chat_screen.dart
└── main.dart
```

### Pattern BLoC
- **Bloc** : Gestion centralisée de l'état des conversations
- **Events** : Actions utilisateur (envoyer message, créer conversation, etc.)
- **States** : États de l'application (chargement, chargé, erreur)
- **Equatable** : Comparaisons optimisées des états

## 🛠️ Technologies Utilisées

- **Flutter** : Framework UI
- **flutter_bloc** : Gestion d'état
- **equatable** : Comparaisons d'objets
- **intl** : Formatage des dates

## 🚀 Installation et Lancement

1. Cloner le projet
2. Installer les dépendances :
   ```bash
   flutter pub get
   ```
3. Lancer l'application :
   ```bash
   flutter run
   ```

## 📱 Utilisation

1. **Liste des conversations** : Voir toutes les conversations avec badges de messages non lus
2. **Créer une conversation** : Appuyer sur le bouton "+" en haut à droite
3. **Ouvrir une conversation** : Appuyer sur une conversation pour voir les détails
4. **Envoyer un message** : Taper dans le champ de texte et appuyer sur envoyer
5. **Réponses automatiques** : L'application simule des réponses après 2 secondes


## 🎨 Interface Utilisateur

- Design Material moderne
- Couleurs cohérentes (bleu principal)
- Avatars avec initiales
- Bulles de chat différenciées
- Badges rouges pour les messages non lus
- Animations fluides et transitions

## capture d'ecran
### écran de liste des conversations
![alt text](<Capture d'écran 2025-05-31 111943.png>)
### écran de conversation
![alt text](<Capture d'écran 2025-05-31 112052.png>)
### écran de création de conversation
![alt text](<Capture d'écran 2025-05-31 112200.png>)
![alt text](<Capture d'écran 2025-05-31 112211.png>)

### information sur la conversation
![alt text](<Capture d'écran 2025-05-31 112255.png>)
![alt text](<Capture d'écran 2025-05-31 112310.png>)