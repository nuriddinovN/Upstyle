import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:up_style/features/chat/presentation/provider/chat_provider.dart';
import 'package:up_style/features/chat/presentation/screens/chat_screen.dart';
import 'package:up_style/features/creator/presentation/provider/creators_provider.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../../core/theme/app_theme.dart';

class CreatorProfileScreen extends StatefulWidget {
  final String creatorId;

  const CreatorProfileScreen({
    super.key,
    required this.creatorId,
  });

  @override
  State<CreatorProfileScreen> createState() => _CreatorProfileScreenState();
}

class _CreatorProfileScreenState extends State<CreatorProfileScreen> {
  UserModel? _creator;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCreator();
  }

  Future<void> _loadCreator() async {
    final provider = context.read<CreatorsProvider>();
    final creator = await provider.getCreatorById(widget.creatorId);

    setState(() {
      _creator = creator;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_creator == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(
          child: Text('Creator not found'),
        ),
      );
    }

    final creatorInfo = _creator!.creatorInfo;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // App Bar with Profile Image
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.primaryColor.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _creator!.profileImageUrl != null
                            ? NetworkImage(_creator!.profileImageUrl!)
                            : null,
                        child: _creator!.profileImageUrl == null
                            ? Text(
                                _creator!.name[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name & Rating
                  Center(
                    child: Column(
                      children: [
                        Text(
                          _creator!.name,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              creatorInfo?.rating.toStringAsFixed(1) ?? '0.0',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '${creatorInfo?.itemsHelped ?? 0} helped',
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.schedule,
                                size: 16,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Responds in ${creatorInfo?.responseTime ?? "24 hours"}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Chat Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _startChat,
                      icon: const Icon(Icons.chat_bubble),
                      label: const Text('Chat with Creator'),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Bio
                  const Text(
                    'About',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.inputBorder),
                    ),
                    child: Text(
                      creatorInfo?.bio ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Specializations
                  const Text(
                    'Specializations',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (creatorInfo?.specializations ?? [])
                        .map((spec) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppTheme.primaryColor.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                spec,
                                style: const TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ))
                        .toList(),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startChat() async {
    final chatProvider = context.read<ChatProvider>();

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final chatRoom = await chatProvider.getOrCreateChatRoom(
      otherUserId: _creator!.id,
      otherUserName: _creator!.name,
      otherUserAvatar: _creator!.profileImageUrl,
    );

    if (!mounted) return;
    Navigator.pop(context); // Close loading

    if (chatRoom != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(chatRoomId: chatRoom.id),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to start chat'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
