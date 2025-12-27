import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final String id;
  final String title;
  final String userId;
  final DateTime createdAt;
  final bool isDefault;
  final int itemCount;
  final int upcycledCount;
  final int upstyledCount;

  const Category({
    required this.id,
    required this.title,
    required this.userId,
    required this.createdAt,
    this.isDefault = false,
    this.itemCount = 0,
    this.upcycledCount = 0,
    this.upstyledCount = 0,
  });

  Category copyWith({
    String? id,
    String? title,
    String? userId,
    DateTime? createdAt,
    bool? isDefault,
    int? itemCount,
    int? upcycledCount,
    int? upstyledCount,
  }) {
    return Category(
      id: id ?? this.id,
      title: title ?? this.title,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      isDefault: isDefault ?? this.isDefault,
      itemCount: itemCount ?? this.itemCount,
      upcycledCount: upcycledCount ?? this.upcycledCount,
      upstyledCount: upstyledCount ?? this.upstyledCount,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        userId,
        createdAt,
        isDefault,
        itemCount,
        upcycledCount,
        upstyledCount,
      ];
}

// Default categories
class DefaultCategories {
  static const List<String> categories = [
    'Clothing',
    'Accessories',
    'Items',
  ];
}
