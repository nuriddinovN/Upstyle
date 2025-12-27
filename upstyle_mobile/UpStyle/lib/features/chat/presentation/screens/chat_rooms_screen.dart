import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../provider/chat_provider.dart';
import 'chat_screen.dart';
import '../../../../core/theme/app_theme.dart';

class ChatRoomsScreen extends StatefulWidget {
  const ChatRoomsScreen({super.key});

  @override
  State<ChatRoomsScreen> createState() => _ChatRoomsScreenState();
}

class _ChatRoomsScreenState extends State<ChatRoomsScreen> {
  @override
  void initState() {
    super.initState();
    // Start watching chat rooms
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().watchChatRooms();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId =
        firebase_auth.FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Messages',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<ChatProvider>(
        builder: (context, provider, child) {
          final chatRooms = provider.chatRooms;

          if (chatRooms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No conversations yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start chatting with creators!',
                    style: TextStyle(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: chatRooms.length,
            itemBuilder: (context, index) {
              final chatRoom = chatRooms[index];
              final otherUserName =
                  chatRoom.getOtherParticipantName(currentUserId);
              final otherUserAvatar =
                  chatRoom.getOtherParticipantAvatar(currentUserId);
              final unreadCount = chatRoom.getUnreadCountForUser(currentUserId);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundImage: otherUserAvatar.isNotEmpty
                            ? NetworkImage(otherUserAvatar)
                            : null,
                        child: otherUserAvatar.isEmpty
                            ? Text(
                                otherUserName[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      // Unread indicator
                      if (unreadCount > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Text(
                              unreadCount > 9 ? '9+' : '$unreadCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: Text(
                    otherUserName,
                    style: TextStyle(
                      fontWeight:
                          unreadCount > 0 ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    chatRoom.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: unreadCount > 0
                          ? AppTheme.textPrimary
                          : AppTheme.textSecondary,
                      fontWeight:
                          unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                  trailing: Text(
                    timeago.format(chatRoom.lastMessageTime,
                        locale: 'en_short'),
                    style: TextStyle(
                      fontSize: 12,
                      color: unreadCount > 0
                          ? AppTheme.primaryColor
                          : AppTheme.textSecondary,
                      fontWeight:
                          unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(chatRoomId: chatRoom.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
