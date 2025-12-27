import 'package:equatable/equatable.dart';

class Item extends Equatable {
  final String id;
  final String name;
  final String description;
  final String categoryId;
  final String userId;
  final String color;
  final String imageUrl;
  final bool isUpcycled;
  final bool isUpStyled;
  final String? originalItemId;
  final DateTime createdAt;
  final DateTime updatedAt;

  // FashionCLIP analysis data
  final String? subCategory;
  final String? gender;
  final String? secondaryColor;
  final String? accentColor;
  final String? pattern;
  final String? material;
  final String? fit;
  final String? silhouette;
  final String? neckline;
  final String? sleeve;
  final String? length;
  final String? rise;
  final String? closureType;
  final String? style;
  final String? occasion;
  final String? season;
  final String? bodyShape;
  final String? aestheticKeywords;
  final String? detailFeatures;
  final String? upcyclingPotential;
  final String? upcyclingType;
  final String? repairability;
  final String? sustainability;
  final String? visibleAccessories;

  const Item({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.userId,
    required this.color,
    required this.imageUrl,
    this.isUpcycled = false,
    this.isUpStyled = false,
    this.originalItemId,
    required this.createdAt,
    required this.updatedAt,
    this.subCategory,
    this.gender,
    this.secondaryColor,
    this.accentColor,
    this.pattern,
    this.material,
    this.fit,
    this.silhouette,
    this.neckline,
    this.sleeve,
    this.length,
    this.rise,
    this.closureType,
    this.style,
    this.occasion,
    this.season,
    this.bodyShape,
    this.aestheticKeywords,
    this.detailFeatures,
    this.upcyclingPotential,
    this.upcyclingType,
    this.repairability,
    this.sustainability,
    this.visibleAccessories,
  });

  Item copyWith({
    String? id,
    String? name,
    String? description,
    String? categoryId,
    String? userId,
    String? color,
    String? imageUrl,
    bool? isUpcycled,
    bool? isUpStyled,
    String? originalItemId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? subCategory,
    String? gender,
    String? secondaryColor,
    String? accentColor,
    String? pattern,
    String? material,
    String? fit,
    String? silhouette,
    String? neckline,
    String? sleeve,
    String? length,
    String? rise,
    String? closureType,
    String? style,
    String? occasion,
    String? season,
    String? bodyShape,
    String? aestheticKeywords,
    String? detailFeatures,
    String? upcyclingPotential,
    String? upcyclingType,
    String? repairability,
    String? sustainability,
    String? visibleAccessories,
  }) {
    return Item(
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
      subCategory: subCategory ?? this.subCategory,
      gender: gender ?? this.gender,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      accentColor: accentColor ?? this.accentColor,
      pattern: pattern ?? this.pattern,
      material: material ?? this.material,
      fit: fit ?? this.fit,
      silhouette: silhouette ?? this.silhouette,
      neckline: neckline ?? this.neckline,
      sleeve: sleeve ?? this.sleeve,
      length: length ?? this.length,
      rise: rise ?? this.rise,
      closureType: closureType ?? this.closureType,
      style: style ?? this.style,
      occasion: occasion ?? this.occasion,
      season: season ?? this.season,
      bodyShape: bodyShape ?? this.bodyShape,
      aestheticKeywords: aestheticKeywords ?? this.aestheticKeywords,
      detailFeatures: detailFeatures ?? this.detailFeatures,
      upcyclingPotential: upcyclingPotential ?? this.upcyclingPotential,
      upcyclingType: upcyclingType ?? this.upcyclingType,
      repairability: repairability ?? this.repairability,
      sustainability: sustainability ?? this.sustainability,
      visibleAccessories: visibleAccessories ?? this.visibleAccessories,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        categoryId,
        userId,
        color,
        imageUrl,
        isUpcycled,
        isUpStyled,
        originalItemId,
        createdAt,
        updatedAt,
        subCategory,
        gender,
        secondaryColor,
        accentColor,
        pattern,
        material,
        fit,
        silhouette,
        neckline,
        sleeve,
        length,
        rise,
        closureType,
        style,
        occasion,
        season,
        bodyShape,
        aestheticKeywords,
        detailFeatures,
        upcyclingPotential,
        upcyclingType,
        repairability,
        sustainability,
        visibleAccessories,
      ];
}

// Filter and sort options
enum ItemSortOption {
  dateAsc,
  dateDesc,
  name,
  color,
}

class ItemFilter {
  final String? color;
  final bool? onlyUpcycled;
  final bool? onlyUpStyled;
  final String? categoryId;

  const ItemFilter({
    this.color,
    this.onlyUpcycled,
    this.onlyUpStyled,
    this.categoryId,
  });

  ItemFilter copyWith({
    String? color,
    bool? onlyUpcycled,
    bool? onlyUpStyled,
    String? categoryId,
  }) {
    return ItemFilter(
      color: color ?? this.color,
      onlyUpcycled: onlyUpcycled ?? this.onlyUpcycled,
      onlyUpStyled: onlyUpStyled ?? this.onlyUpStyled,
      categoryId: categoryId ?? this.categoryId,
    );
  }

  bool get isEmpty =>
      color == null &&
      onlyUpcycled != true &&
      onlyUpStyled != true &&
      categoryId == null;
}

class ItemQuery {
  final ItemFilter filter;
  final ItemSortOption sortBy;
  final int limit;
  final String? lastItemId;

  const ItemQuery({
    this.filter = const ItemFilter(),
    this.sortBy = ItemSortOption.dateDesc,
    this.limit = 20,
    this.lastItemId,
  });

  ItemQuery copyWith({
    ItemFilter? filter,
    ItemSortOption? sortBy,
    int? limit,
    String? lastItemId,
  }) {
    return ItemQuery(
      filter: filter ?? this.filter,
      sortBy: sortBy ?? this.sortBy,
      limit: limit ?? this.limit,
      lastItemId: lastItemId ?? this.lastItemId,
    );
  }
}
