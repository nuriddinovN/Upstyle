import 'package:equatable/equatable.dart';

class Statistics extends Equatable {
  final int totalItems;
  final int totalClothing;
  final int totalAccessories;
  final int totalOtherItems;
  final int totalUpcycled;
  final int totalUpStyled;
  final Map<String, int> itemsByColor;
  final Map<String, int> itemsByCategory;

  const Statistics({
    required this.totalItems,
    required this.totalClothing,
    required this.totalAccessories,
    required this.totalOtherItems,
    required this.totalUpcycled,
    required this.totalUpStyled,
    required this.itemsByColor,
    required this.itemsByCategory,
  });

  Statistics copyWith({
    int? totalItems,
    int? totalClothing,
    int? totalAccessories,
    int? totalOtherItems,
    int? totalUpcycled,
    int? totalUpStyled,
    Map<String, int>? itemsByColor,
    Map<String, int>? itemsByCategory,
  }) {
    return Statistics(
      totalItems: totalItems ?? this.totalItems,
      totalClothing: totalClothing ?? this.totalClothing,
      totalAccessories: totalAccessories ?? this.totalAccessories,
      totalOtherItems: totalOtherItems ?? this.totalOtherItems,
      totalUpcycled: totalUpcycled ?? this.totalUpcycled,
      totalUpStyled: totalUpStyled ?? this.totalUpStyled,
      itemsByColor: itemsByColor ?? this.itemsByColor,
      itemsByCategory: itemsByCategory ?? this.itemsByCategory,
    );
  }

  @override
  List<Object?> get props => [
        totalItems,
        totalClothing,
        totalAccessories,
        totalOtherItems,
        totalUpcycled,
        totalUpStyled,
        itemsByColor,
        itemsByCategory,
      ];
}

class CategoryStatistics extends Equatable {
  final String categoryId;
  final String categoryName;
  final int totalItems;
  final int upcycledItems;
  final int upstyledItems;

  const CategoryStatistics({
    required this.categoryId,
    required this.categoryName,
    required this.totalItems,
    required this.upcycledItems,
    required this.upstyledItems,
  });

  @override
  List<Object?> get props => [
        categoryId,
        categoryName,
        totalItems,
        upcycledItems,
        upstyledItems,
      ];
}
