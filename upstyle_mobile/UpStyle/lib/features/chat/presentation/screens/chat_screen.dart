import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:intl/intl.dart';
import 'package:up_style/features/auth/data/repositories/message_model.dart';
import '../provider/chat_provider.dart';
import '../../../warderobe/presentation/provider/item_provider.dart';
import '../../../../core/theme/app_theme.dart';

class ChatScreen extends StatefulWidget {
  final String chatRoomId;
  final String?
      otherUserName; // Optional - if not provided, will load from chat room
  final String? otherUserAvatar; // Optional

  const ChatScreen({
    super.key,
    required this.chatRoomId,
    this.otherUserName,
    this.otherUserAvatar,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();

  String get _currentUserId =>
      firebase_auth.FirebaseAuth.instance.currentUser?.uid ?? '';

  String? _loadedOtherUserName;
  String? _loadedOtherUserAvatar;

  @override
  void initState() {
    super.initState();
    // Start watching messages
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().watchMessages(widget.chatRoomId);
      // Load user's wardrobe items for sharing
      context.read<ItemsProvider>().loadItems();

      // If names weren't provided, load them from chat room
      if (widget.otherUserName == null) {
        _loadChatRoomInfo();
      }
    });
  }

  Future<void> _loadChatRoomInfo() async {
    final chatProvider = context.read<ChatProvider>();

    // Try to find in loaded chat rooms
    final chatRoom = chatProvider.chatRooms.firstWhere(
      (room) => room.id == widget.chatRoomId,
      orElse: () => null as dynamic,
    );

    if (chatRoom != null && mounted) {
      setState(() {
        _loadedOtherUserName = chatRoom.getOtherParticipantName(_currentUserId);
        _loadedOtherUserAvatar =
            chatRoom.getOtherParticipantAvatar(_currentUserId);
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    context.read<ChatProvider>().clearMessages();
    super.dispose();
  }

  String get _otherUserName =>
      widget.otherUserName ?? _loadedOtherUserName ?? 'User';

  String get _otherUserAvatar =>
      widget.otherUserAvatar ?? _loadedOtherUserAvatar ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: _otherUserAvatar.isNotEmpty
                  ? NetworkImage(_otherUserAvatar)
                  : null,
              child: _otherUserAvatar.isEmpty
                  ? Text(
                      _otherUserName[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _otherUserName,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, provider, child) {
                final messages = provider.messages;

                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No messages yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Send a message to start the conversation',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Auto-scroll to bottom when new messages arrive
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == _currentUserId;

                    // Show timestamp for first message and every 5 minutes
                    bool showTimestamp = false;
                    if (index == messages.length - 1) {
                      showTimestamp = true;
                    } else {
                      final nextMessage = messages[index + 1];
                      final timeDiff =
                          message.timestamp.difference(nextMessage.timestamp);
                      if (timeDiff.inMinutes >= 5) {
                        showTimestamp = true;
                      }
                    }

                    return Column(
                      children: [
                        if (showTimestamp)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              _formatTimestamp(message.timestamp),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ),
                        _MessageBubble(
                          message: message,
                          isMe: isMe,
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),

          // Input Area
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Attachment buttons
            IconButton(
              icon:
                  const Icon(Icons.photo_camera, color: AppTheme.primaryColor),
              onPressed: _pickImageFromCamera,
            ),
            IconButton(
              icon:
                  const Icon(Icons.photo_library, color: AppTheme.primaryColor),
              onPressed: _pickImageFromGallery,
            ),
            IconButton(
              icon: const Icon(Icons.checkroom, color: AppTheme.primaryColor),
              onPressed: _showItemPicker,
            ),

            // Text input
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    border: InputBorder.none,
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
            ),

            // Send button
            const SizedBox(width: 8),
            Consumer<ChatProvider>(
              builder: (context, provider, child) {
                return IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: provider.isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 20,
                          ),
                  ),
                  onPressed: provider.isLoading ? null : _sendTextMessage,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendTextMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();

    final provider = context.read<ChatProvider>();
    await provider.sendTextMessage(text);
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );

      if (image != null) {
        await _sendImage(File(image.path));
      }
    } catch (e) {
      _showError('Failed to take photo: $e');
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (image != null) {
        await _sendImage(File(image.path));
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  Future<void> _sendImage(File imageFile) async {
    final provider = context.read<ChatProvider>();
    await provider.sendImageMessage(imageFile);
  }

  void _showItemPicker() {
    final itemsProvider = context.read<ItemsProvider>();
    final items = itemsProvider.items;

    if (items.isEmpty) {
      _showError('No items in your wardrobe to share');
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Share Item from Wardrobe',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(height: 1),
              // Items grid
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _sendItem(item);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(
                                  image: NetworkImage(item.imageUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendItem(dynamic item) async {
    final itemData = ItemData(
      itemId: item.id,
      itemName: item.name,
      itemImageUrl: item.imageUrl,
      categoryId: item.categoryId,
      description: item.description,
    );

    final provider = context.read<ChatProvider>();
    await provider.sendItemMessage(itemData);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(
      timestamp.year,
      timestamp.month,
      timestamp.day,
    );

    if (messageDate == today) {
      return DateFormat('h:mm a').format(timestamp);
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday, ${DateFormat('h:mm a').format(timestamp)}';
    } else if (now.difference(timestamp).inDays < 7) {
      return DateFormat('EEEE, h:mm a').format(timestamp);
    } else {
      return DateFormat('MMM d, h:mm a').format(timestamp);
    }
  }
}

// Message Bubble Widget
class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const _MessageBubble({
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMe ? AppTheme.primaryColor : Colors.grey[200],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                  bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                ),
              ),
              child: _buildMessageContent(context),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('h:mm a').format(message.timestamp),
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    switch (message.type) {
      case MessageType.text:
        return Text(
          message.text ?? '',
          style: TextStyle(
            color: isMe ? Colors.white : AppTheme.textPrimary,
            fontSize: 15,
          ),
        );

      case MessageType.image:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                message.imageUrl ?? '',
                width: 200,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 200,
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 200,
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(Icons.error),
                  );
                },
              ),
            ),
          ],
        );

      case MessageType.item:
        return _buildItemMessage(context);

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildItemMessage(BuildContext context) {
    final itemData = message.itemData;
    if (itemData == null) return const SizedBox.shrink();

    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: isMe ? Colors.white.withOpacity(0.2) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12),
            ),
            child: Image.network(
              itemData.itemImageUrl,
              width: 200,
              height: 200,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: 200,
                  height: 200,
                  color: Colors.grey[300],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              },
            ),
          ),
          // Item Info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.checkroom,
                      size: 16,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        itemData.itemName,
                        style: TextStyle(
                          color: isMe ? Colors.white : AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (itemData.description != null &&
                    itemData.description!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    itemData.description!,
                    style: TextStyle(
                      color: isMe
                          ? Colors.white.withOpacity(0.9)
                          : AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
