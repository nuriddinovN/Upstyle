import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/categories_repository.dart';
import '../datasources/categories_remote_datasource.dart';

class CategoriesRepositoryImpl implements CategoriesRepository {
  final CategoriesRemoteDataSource remoteDataSource;

  CategoriesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Category>>> getCategories() async {
    try {
      final categories = await remoteDataSource.getCategories();
      return Right(categories);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Category>> createCategory(
      {required String title}) async {
    try {
      final category = await remoteDataSource.createCategory(title: title);
      return Right(category);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String categoryId) async {
    try {
      await remoteDataSource.deleteCategory(categoryId);
      return const Right(null);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Category>> updateCategory({
    required String categoryId,
    required String title,
  }) async {
    try {
      final category = await remoteDataSource.updateCategory(
        categoryId: categoryId,
        title: title,
      );
      return Right(category);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Category>> getCategoryById(String categoryId) async {
    try {
      final category = await remoteDataSource.getCategoryById(categoryId);
      return Right(category);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> initializeDefaultCategories() async {
    try {
      await remoteDataSource.initializeDefaultCategories();
      return const Right(null);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Stream<List<Category>> watchCategories() {
    return remoteDataSource.watchCategories();
  }
}
