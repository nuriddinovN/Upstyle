import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:up_style/features/auth/data/repositories/message_model.dart';
import 'package:up_style/features/chat/data/models/chat_rooms_models.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/failures.dart';

abstract class ChatRemoteDataSource {
  Stream<List<ChatRoom>> watchChatRooms();
  Future<ChatRoom> getOrCreateChatRoom(
      String otherUserId, String otherUserName, String? otherUserAvatar);
  Stream<List<Message>> watchMessages(String chatRoomId);
  Future<void> sendTextMessage(String chatRoomId, String text);
  Future<void> sendImageMessage(String chatRoomId, File imageFile);
  Future<void> sendItemMessage(String chatRoomId, ItemData itemData);
  Future<void> markMessagesAsRead(String chatRoomId);
}

class FirebaseChatDataSource implements ChatRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;
  static const _uuid = Uuid();

  FirebaseChatDataSource({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _storage = storage ?? FirebaseStorage.instance;

  String get _userId {
    final user = _auth.currentUser;
    if (user == null) throw AuthFailure('No user logged in');
    return user.uid;
  }

  String get _userName {
    final user = _auth.currentUser;
    return user?.displayName ?? 'User';
  }

  String? get _userAvatar {
    final user = _auth.currentUser;
    return user?.photoURL;
  }

  // Generate chat room ID from two user IDs
  String _generateChatRoomId(String userId1, String userId2) {
    final sorted = [userId1, userId2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  @override
  Stream<List<ChatRoom>> watchChatRooms() {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: _userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ChatRoom.fromFirestore(doc)).toList());
  }

  @override
  Future<ChatRoom> getOrCreateChatRoom(
    String otherUserId,
    String otherUserName,
    String? otherUserAvatar,
  ) async {
    try {
      final chatRoomId = _generateChatRoomId(_userId, otherUserId);
      final chatRoomRef = _firestore.collection('chats').doc(chatRoomId);

      final doc = await chatRoomRef.get();

      if (doc.exists) {
        return ChatRoom.fromFirestore(doc);
      }

      // Create new chat room
      final now = DateTime.now();
      final chatRoom = ChatRoom(
        id: chatRoomId,
        participants: [_userId, otherUserId],
        participantNames: {
          _userId: _userName,
          otherUserId: otherUserName,
        },
        participantAvatars: {
          if (_userAvatar != null) _userId: _userAvatar!,
          if (otherUserAvatar != null) otherUserId: otherUserAvatar,
        },
        lastMessage: 'Start a conversation',
        lastMessageTime: now,
        unreadCount: {
          _userId: 0,
          otherUserId: 0,
        },
        createdAt: now,
        updatedAt: now,
      );

      await chatRoomRef.set(chatRoom.toFirestore());

      return chatRoom;
    } catch (e) {
      throw ServerFailure('Failed to create chat room: $e');
    }
  }

  @override
  Stream<List<Message>> watchMessages(String chatRoomId) {
    return _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList());
  }

  @override
  Future<void> sendTextMessage(String chatRoomId, String text) async {
    try {
      final messageRef = _firestore
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .doc();

      final message = Message(
        id: messageRef.id,
        senderId: _userId,
        senderName: _userName,
        senderAvatar: _userAvatar,
        text: text,
        type: MessageType.text,
        timestamp: DateTime.now(),
      );

      await messageRef.set(message.toFirestore());

      // Update chat room
      await _updateChatRoom(chatRoomId, text);
    } catch (e) {
      throw ServerFailure('Failed to send message: $e');
    }
  }

  @override
  Future<void> sendImageMessage(String chatRoomId, File imageFile) async {
    try {
      // Upload image to Firebase Storage
      final imageUrl = await _uploadImage(imageFile);

      final messageRef = _firestore
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .doc();

      final message = Message(
        id: messageRef.id,
        senderId: _userId,
        senderName: _userName,
        senderAvatar: _userAvatar,
        imageUrl: imageUrl,
        type: MessageType.image,
        timestamp: DateTime.now(),
      );

      await messageRef.set(message.toFirestore());

      // Update chat room
      await _updateChatRoom(chatRoomId, '📷 Photo');
    } catch (e) {
      throw ServerFailure('Failed to send image: $e');
    }
  }

  @override
  Future<void> sendItemMessage(String chatRoomId, ItemData itemData) async {
    try {
      final messageRef = _firestore
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .doc();

      final message = Message(
        id: messageRef.id,
        senderId: _userId,
        senderName: _userName,
        senderAvatar: _userAvatar,
        itemData: itemData,
        type: MessageType.item,
        timestamp: DateTime.now(),
      );

      await messageRef.set(message.toFirestore());

      // Update chat room
      await _updateChatRoom(chatRoomId, '👕 ${itemData.itemName}');
    } catch (e) {
      throw ServerFailure('Failed to send item: $e');
    }
  }

  @override
  Future<void> markMessagesAsRead(String chatRoomId) async {
    try {
      // Get all unread messages from other users
      final messagesSnapshot = await _firestore
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .where('senderId', isNotEqualTo: _userId)
          .where('isRead', isEqualTo: false)
          .get();

      // Mark all as read
      final batch = _firestore.batch();
      for (final doc in messagesSnapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();

      // Reset unread count
      await _firestore.collection('chats').doc(chatRoomId).update({
        'unreadCount.$_userId': 0,
      });
    } catch (e) {
      throw ServerFailure('Failed to mark messages as read: $e');
    }
  }

  Future<void> _updateChatRoom(String chatRoomId, String lastMessage) async {
    try {
      final chatRoomRef = _firestore.collection('chats').doc(chatRoomId);
      final doc = await chatRoomRef.get();

      if (!doc.exists) return;

      final chatRoom = ChatRoom.fromFirestore(doc);
      final otherUserId = chatRoom.getOtherParticipantId(_userId);

      await chatRoomRef.update({
        'lastMessage': lastMessage,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'unreadCount.$otherUserId': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Don't fail if chat room update fails
      print('Warning: Failed to update chat room: $e');
    }
  }

  Future<String> _uploadImage(File imageFile) async {
    try {
      final fileName = '${_uuid.v4()}.jpg';
      final ref =
          _storage.ref().child('chat_images').child(_userId).child(fileName);

      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() => null);

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw ServerFailure('Failed to upload image: $e');
    }
  }
}
