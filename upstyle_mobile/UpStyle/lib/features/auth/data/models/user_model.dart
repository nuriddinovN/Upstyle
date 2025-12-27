import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.emailVerified = false,
    super.profileImageUrl,
    super.role = UserRole.user,
    super.isCreator = false,
    super.creatorInfo,
    required super.createdAt,
    required super.updatedAt,
  });

  // Create UserModel from User entity
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      emailVerified: user.emailVerified,
      profileImageUrl: user.profileImageUrl,
      role: user.role,
      isCreator: user.isCreator,
      creatorInfo: user.creatorInfo,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }

  // Create from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    CreatorInfo? creatorInfo;
    if (data['creatorInfo'] != null) {
      final info = data['creatorInfo'] as Map<String, dynamic>;
      creatorInfo = CreatorInfo(
        specializations: List<String>.from(info['specializations'] ?? []),
        rating: (info['rating'] ?? 0.0).toDouble(),
        itemsHelped: info['itemsHelped'] ?? 0,
        responseTime: info['responseTime'] ?? '< 24 hours',
        bio: info['bio'] ?? '',
        becameCreatorAt: info['becameCreatorAt'] != null
            ? (info['becameCreatorAt'] as Timestamp).toDate()
            : null,
      );
    }

    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      emailVerified: data['emailVerified'] ?? false,
      profileImageUrl: data['profileImageUrl'],
      role: data['role'] == 'creator' ? UserRole.creator : UserRole.user,
      isCreator: data['isCreator'] ?? false,
      creatorInfo: creatorInfo,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'emailVerified': emailVerified,
      'profileImageUrl': profileImageUrl,
      'role': role == UserRole.creator ? 'creator' : 'user',
      'isCreator': isCreator,
      if (creatorInfo != null)
        'creatorInfo': {
          'specializations': creatorInfo!.specializations,
          'rating': creatorInfo!.rating,
          'itemsHelped': creatorInfo!.itemsHelped,
          'responseTime': creatorInfo!.responseTime,
          'bio': creatorInfo!.bio,
          'becameCreatorAt': creatorInfo!.becameCreatorAt != null
              ? Timestamp.fromDate(creatorInfo!.becameCreatorAt!)
              : FieldValue.serverTimestamp(),
        },
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  @override
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    bool? emailVerified,
    String? profileImageUrl,
    UserRole? role,
    bool? isCreator,
    CreatorInfo? creatorInfo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      emailVerified: emailVerified ?? this.emailVerified,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      role: role ?? this.role,
      isCreator: isCreator ?? this.isCreator,
      creatorInfo: creatorInfo ?? this.creatorInfo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
