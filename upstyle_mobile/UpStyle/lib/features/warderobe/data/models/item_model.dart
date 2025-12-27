import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/item.dart';

class ItemModel extends Item {
  const ItemModel({
    required super.id,
    required super.name,
    required super.description,
    required super.categoryId,
    required super.userId,
    required super.color,
    required super.imageUrl,
    super.isUpcycled = false,
    super.isUpStyled = false,
    super.originalItemId,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ItemModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      categoryId: data['categoryId'] ?? '',
      userId: data['userId'] ?? '',
      color: data['color'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      isUpcycled: data['isUpcycled'] ?? false,
      isUpStyled: data['isUpStyled'] ?? false,
      originalItemId: data['originalItemId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  factory ItemModel.fromEntity(Item item) {
    return ItemModel(
      id: item.id,
      name: item.name,
      description: item.description,
      categoryId: item.categoryId,
      userId: item.userId,
      color: item.color,
      imageUrl: item.imageUrl,
      isUpcycled: item.isUpcycled,
      isUpStyled: item.isUpStyled,
      originalItemId: item.originalItemId,
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'categoryId': categoryId,
      'userId': userId,
      'color': color,
      'imageUrl': imageUrl,
      'isUpcycled': isUpcycled,
      'isUpStyled': isUpStyled,
      'originalItemId': originalItemId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  ItemModel copyWith({
    String? accentColor,
    String? aestheticKeywords,
    String? bodyShape,
    String? categoryId,
    String? closureType,
    String? color,
    DateTime? createdAt,
    String? description,
    String? detailFeatures,
    String? fit,
    String? gender,
    String? id,
    String? imageUrl,
    bool? isUpStyled,
    bool? isUpcycled,
    String? length,
    String? material,
    String? name,
    String? neckline,
    String? occasion,
    String? originalItemId,
    String? pattern,
    String? repairability,
    String? rise,
    String? season,
    String? secondaryColor,
    String? silhouette,
    String? sleeve,
    String? style,
    String? subCategory,
    String? sustainability,
    String? upcyclingPotential,
    String? upcyclingType,
    DateTime? updatedAt,
    String? userId,
    String? visibleAccessories,
  }) {
    return ItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      userId: userId ?? this.userId,
      color: color ?? this.color,
      imageUrl: imageUrl ?? this.imageUrl,
      isUpcycled: isUpcycled ?? this.isUpcycled,
      isUpStyled: isUpStyled ?? this.isUpStyled,
      originalItemId: originalItemId ?? this.originalItemId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
