import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:up_style/features/auth/data/repositories/message_model.dart';
import 'package:up_style/features/chat/data/datasource/chat_remote_data_source.dart';
import 'package:up_style/features/chat/data/models/chat_rooms_models.dart';

class ChatProvider extends ChangeNotifier {
  final ChatRemoteDataSource _dataSource;

  ChatProvider(this._dataSource);

  List<ChatRoom> _chatRooms = [];
  List<Message> _messages = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentChatRoomId;

  List<ChatRoom> get chatRooms => _chatRooms;
  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get currentChatRoomId => _currentChatRoomId;

  // Watch chat rooms (real-time)
  void watchChatRooms() {
    _dataSource.watchChatRooms().listen(
      (rooms) {
        _chatRooms = rooms;
        notifyListeners();
      },
      onError: (error) {
        _setError(error.toString());
      },
    );
  }

  // Get or create chat room
  Future<ChatRoom?> getOrCreateChatRoom({
    required String otherUserId,
    required String otherUserName,
    String? otherUserAvatar,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final chatRoom = await _dataSource.getOrCreateChatRoom(
        otherUserId,
        otherUserName,
        otherUserAvatar,
      );

      _currentChatRoomId = chatRoom.id;

      _setLoading(false);
      return chatRoom;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return null;
    }
  }

  // Watch messages for a chat room (real-time)
  void watchMessages(String chatRoomId) {
    _currentChatRoomId = chatRoomId;

    _dataSource.watchMessages(chatRoomId).listen(
      (msgs) {
        _messages = msgs;
        notifyListeners();
      },
      onError: (error) {
        _setError(error.toString());
      },
    );

    // Mark messages as read
    markMessagesAsRead(chatRoomId);
  }

  // Send text message
  Future<void> sendTextMessage(String text) async {
    if (_currentChatRoomId == null) return;
    if (text.trim().isEmpty) return;

    _clearError();

    try {
      await _dataSource.sendTextMessage(_currentChatRoomId!, text);
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Send image message
  Future<void> sendImageMessage(File imageFile) async {
    if (_currentChatRoomId == null) return;

    _setLoading(true);
    _clearError();

    try {
      await _dataSource.sendImageMessage(_currentChatRoomId!, imageFile);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Send item message
  Future<void> sendItemMessage(ItemData itemData) async {
    if (_currentChatRoomId == null) return;

    _clearError();

    try {
      await _dataSource.sendItemMessage(_currentChatRoomId!, itemData);
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String chatRoomId) async {
    try {
      await _dataSource.markMessagesAsRead(chatRoomId);
    } catch (e) {
      // Silently fail - not critical
      print('Failed to mark messages as read: $e');
    }
  }

  // Get total unread count
  int getTotalUnreadCount(String currentUserId) {
    return _chatRooms.fold<int>(
      0,
      (sum, room) => sum + room.getUnreadCountForUser(currentUserId),
    );
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearMessages() {
    _messages.clear();
    _currentChatRoomId = null;
    notifyListeners();
  }
}
