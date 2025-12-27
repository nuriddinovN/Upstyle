import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ChatRoom extends Equatable {
  final String id;
  final List<String> participants;
  final Map<String, String> participantNames;
  final Map<String, String> participantAvatars;
  final String lastMessage;
  final DateTime lastMessageTime;
  final Map<String, int> unreadCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChatRoom({
    required this.id,
    required this.participants,
    required this.participantNames,
    required this.participantAvatars,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatRoom.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ChatRoom(
      id: doc.id,
      participants: List<String>.from(data['participants'] ?? []),
      participantNames:
          Map<String, String>.from(data['participantNames'] ?? {}),
      participantAvatars:
          Map<String, String>.from(data['participantAvatars'] ?? {}),
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime:
          (data['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      unreadCount: Map<String, int>.from(data['unreadCount'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'participants': participants,
      'participantNames': participantNames,
      'participantAvatars': participantAvatars,
      'lastMessage': lastMessage,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'unreadCount': unreadCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Get the other participant's info
  String getOtherParticipantId(String currentUserId) {
    return participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
  }

  String getOtherParticipantName(String currentUserId) {
    final otherId = getOtherParticipantId(currentUserId);
    return participantNames[otherId] ?? 'Unknown';
  }

  String getOtherParticipantAvatar(String currentUserId) {
    final otherId = getOtherParticipantId(currentUserId);
    return participantAvatars[otherId] ?? '';
  }

  int getUnreadCountForUser(String userId) {
    return unreadCount[userId] ?? 0;
  }

  ChatRoom copyWith({
    String? id,
    List<String>? participants,
    Map<String, String>? participantNames,
    Map<String, String>? participantAvatars,
    String? lastMessage,
    DateTime? lastMessageTime,
    Map<String, int>? unreadCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      participantNames: participantNames ?? this.participantNames,
      participantAvatars: participantAvatars ?? this.participantAvatars,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        participants,
        participantNames,
        participantAvatars,
        lastMessage,
        lastMessageTime,
        unreadCount,
        createdAt,
        updatedAt,
      ];
}
