import 'package:dartz/dartz.dart';
import 'package:up_style/core/errors/failures.dart';
import 'package:up_style/features/home/domain/entities/statistics.dart';
import 'package:up_style/features/home/domain/repositories/categories_repository.dart';
import 'package:up_style/features/home/domain/repositories/statistics_repository.dart';
import 'package:up_style/features/warderobe/domain/entities/item.dart';
import 'package:up_style/features/warderobe/domain/repositories/item_repository.dart';

class StatisticsRepositoryImpl implements StatisticsRepository {
  final CategoriesRepository categoriesRepository;
  final ItemsRepository itemsRepository;

  StatisticsRepositoryImpl({
    required this.categoriesRepository,
    required this.itemsRepository,
  });

  @override
  Future<Either<Failure, Statistics>> getStatistics() async {
    try {
      // Get all categories
      final categoriesResult = await categoriesRepository.getCategories();
      if (categoriesResult.isLeft()) {
        return Left((categoriesResult as Left).value);
      }
      final categories = (categoriesResult as Right).value;

      // Get all items (without pagination for statistics)
      final allItemsResult = await itemsRepository.getItems(
        const ItemQuery(limit: 10000), // Large limit for statistics
      );
      if (allItemsResult.isLeft()) {
        return Left((allItemsResult as Left).value);
      }
      final allItemsPaginated = (allItemsResult as Right).value;
      final allItems = allItemsPaginated.items;

      // Calculate statistics
      final totalItems = allItems.length;
      final totalUpcycled = allItems.where((item) => item.isUpcycled).length;
      final totalUpStyled = allItems.where((item) => item.isUpStyled).length;

      // Calculate by category
      int totalClothing = 0;
      int totalAccessories = 0;
      int totalOtherItems = 0;

      final Map<String, int> itemsByCategory = {};
      final Map<String, int> itemsByColor = {};

      for (final category in categories) {
        final categoryItems =
            allItems.where((item) => item.categoryId == category.id);
        final count = categoryItems.length;

        itemsByCategory[category.title] = count;

        // Count default categories
        switch (category.title.toLowerCase()) {
          case 'clothing':
            totalClothing = count;
            break;
          case 'accessories':
            totalAccessories = count;
            break;
          case 'items':
            totalOtherItems = count;
            break;
        }
      }

      // Count by color
      for (final item in allItems) {
        itemsByColor[item.color] = (itemsByColor[item.color] ?? 0) + 1;
      }

      final statistics = Statistics(
        totalItems: totalItems,
        totalClothing: totalClothing,
        totalAccessories: totalAccessories,
        totalOtherItems: totalOtherItems,
        totalUpcycled: totalUpcycled,
        totalUpStyled: totalUpStyled,
        itemsByColor: itemsByColor,
        itemsByCategory: itemsByCategory,
      );

      return Right(statistics);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Failed to get statistics: $e'));
    }
  }

  @override
  Future<Either<Failure, List<CategoryStatistics>>>
      getCategoryStatistics() async {
    try {
      final categoriesResult = await categoriesRepository.getCategories();
      if (categoriesResult.isLeft()) {
        return Left((categoriesResult as Left).value);
      }
      final categories = (categoriesResult as Right).value;

      final List<CategoryStatistics> categoryStats = [];

      for (final category in categories) {
        final itemsResult =
            await itemsRepository.getItemsByCategory(category.id);
        if (itemsResult.isRight()) {
          final items = (itemsResult as Right).value;
          final upcycledCount = items.where((item) => item.isUpcycled).length;
          final upstyledCount = items.where((item) => item.isUpStyled).length;

          categoryStats.add(CategoryStatistics(
            categoryId: category.id,
            categoryName: category.title,
            totalItems: items.length,
            upcycledItems: upcycledCount,
            upstyledItems: upstyledCount,
          ));
        }
      }

      return Right(categoryStats);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Failed to get category statistics: $e'));
    }
  }

  @override
  Stream<Statistics> watchStatistics() {
    // For simplicity, return a stream that emits current statistics
    // In production, you might want to implement real-time updates
    return Stream.fromFuture(getStatistics().then((result) =>
        result.fold((failure) => throw failure, (statistics) => statistics)));
  }
}
