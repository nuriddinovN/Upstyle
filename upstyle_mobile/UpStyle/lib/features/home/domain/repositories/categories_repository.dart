import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/category.dart';

abstract class CategoriesRepository {
  Future<Either<Failure, List<Category>>> getCategories();

  Future<Either<Failure, Category>> createCategory({
    required String title,
  });

  Future<Either<Failure, void>> deleteCategory(String categoryId);

  Future<Either<Failure, Category>> updateCategory({
    required String categoryId,
    required String title,
  });

  Future<Either<Failure, Category>> getCategoryById(String categoryId);

  Future<Either<Failure, void>> initializeDefaultCategories();

  Stream<List<Category>> watchCategories();
}
