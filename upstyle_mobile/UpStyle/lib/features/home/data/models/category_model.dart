import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/category.dart';

class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.title,
    required super.userId,
    required super.createdAt,
    super.isDefault = false,
    super.itemCount = 0,
    super.upcycledCount = 0,
    super.upstyledCount = 0,
  });

  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryModel(
      id: doc.id,
      title: data['title'] ?? '',
      userId: data['userId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isDefault: data['isDefault'] ?? false,
      itemCount: data['itemCount'] ?? 0,
      upcycledCount: data['upcycledCount'] ?? 0,
      upstyledCount: data['upstyledCount'] ?? 0,
    );
  }

  factory CategoryModel.fromEntity(Category category) {
    return CategoryModel(
      id: category.id,
      title: category.title,
      userId: category.userId,
      createdAt: category.createdAt,
      isDefault: category.isDefault,
      itemCount: category.itemCount,
      upcycledCount: category.upcycledCount,
      upstyledCount: category.upstyledCount,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'isDefault': isDefault,
      'itemCount': itemCount,
      'upcycledCount': upcycledCount,
      'upstyledCount': upstyledCount,
    };
  }

  CategoryModel copyWith({
    String? id,
    String? title,
    String? userId,
    DateTime? createdAt,
    bool? isDefault,
    int? itemCount,
    int? upcycledCount,
    int? upstyledCount,
  }) {
    return CategoryModel(
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
}
