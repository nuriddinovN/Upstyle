import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum MessageType { text, image, item }

class ItemData extends Equatable {
  final String itemId;
  final String itemName;
  final String itemImageUrl;
  final String categoryId;
  final String? description;

  const ItemData({
    required this.itemId,
    required this.itemName,
    required this.itemImageUrl,
    required this.categoryId,
    this.description,
  });

  factory ItemData.fromMap(Map<String, dynamic> map) {
    return ItemData(
      itemId: map['itemId'] ?? '',
      itemName: map['itemName'] ?? '',
      itemImageUrl: map['itemImageUrl'] ?? '',
      categoryId: map['categoryId'] ?? '',
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'itemName': itemName,
      'itemImageUrl': itemImageUrl,
      'categoryId': categoryId,
      if (description != null) 'description': description,
    };
  }

  @override
  List<Object?> get props =>
      [itemId, itemName, itemImageUrl, categoryId, description];
}

class Message extends Equatable {
  final String id;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String? text;
  final String? imageUrl;
  final ItemData? itemData;
  final MessageType type;
  final DateTime timestamp;
  final bool isRead;

  const Message({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    this.text,
    this.imageUrl,
    this.itemData,
    required this.type,
    required this.timestamp,
    this.isRead = false,
  });

  factory Message.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    MessageType type;
    switch (data['type']) {
      case 'image':
        type = MessageType.image;
        break;
      case 'item':
        type = MessageType.item;
        break;
      default:
        type = MessageType.text;
    }

    return Message(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      senderAvatar: data['senderAvatar'],
      text: data['text'],
      imageUrl: data['imageUrl'],
      itemData:
          data['itemData'] != null ? ItemData.fromMap(data['itemData']) : null,
      type: type,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      if (senderAvatar != null) 'senderAvatar': senderAvatar,
      if (text != null) 'text': text,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (itemData != null) 'itemData': itemData!.toMap(),
      'type': type == MessageType.image
          ? 'image'
          : type == MessageType.item
              ? 'item'
              : 'text',
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': isRead,
    };
  }

  Message copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? senderAvatar,
    String? text,
    String? imageUrl,
    ItemData? itemData,
    MessageType? type,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      text: text ?? this.text,
      imageUrl: imageUrl ?? this.imageUrl,
      itemData: itemData ?? this.itemData,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  List<Object?> get props => [
        id,
        senderId,
        senderName,
        senderAvatar,
        text,
        imageUrl,
        itemData,
        type,
        timestamp,
        isRead,
      ];
}
