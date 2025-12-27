import 'package:equatable/equatable.dart';

enum UserRole { user, creator }

// 2️⃣ Define CreatorInfo class (domain layer - no Firestore dependencies)
class CreatorInfo extends Equatable {
  final List<String> specializations;
  final double rating;
  final int itemsHelped;
  final String responseTime;
  final String bio;
  final DateTime? becameCreatorAt;

  const CreatorInfo({
    required this.specializations,
    required this.rating,
    required this.itemsHelped,
    required this.responseTime,
    required this.bio,
    this.becameCreatorAt,
  });

  @override
  List<Object?> get props => [
        specializations,
        rating,
        itemsHelped,
        responseTime,
        bio,
        becameCreatorAt,
      ];
}

class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final bool emailVerified;
  final String? profileImageUrl;
  final UserRole role;
  final bool isCreator;
  final CreatorInfo? creatorInfo;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerified = false,
    this.profileImageUrl,
    this.role = UserRole.user,
    this.isCreator = false,
    this.creatorInfo,
    required this.createdAt,
    required this.updatedAt,
  });

  User copyWith({
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
    return User(
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

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        emailVerified,
        profileImageUrl,
        role,
        isCreator,
        creatorInfo,
        createdAt,
        updatedAt,
      ];
}
