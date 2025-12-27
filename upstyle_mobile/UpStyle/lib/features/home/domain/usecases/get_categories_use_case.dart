import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/category.dart';
import '../repositories/categories_repository.dart';

class GetCategoriesUseCase {
  final CategoriesRepository repository;

  GetCategoriesUseCase(this.repository);

  Future<Either<Failure, List<Category>>> call() async {
    return await repository.getCategories();
  }
}

class CreateCategoryUseCase {
  final CategoriesRepository repository;

  CreateCategoryUseCase(this.repository);

  Future<Either<Failure, Category>> call(String title) async {
    if (title.isEmpty) {
      return const Left(ValidationFailure('Category title cannot be empty'));
    }

    if (title.length > 50) {
      return const Left(
          ValidationFailure('Category title must be 50 characters or less'));
    }

    return await repository.createCategory(title: title);
  }
}

class DeleteCategoryUseCase {
  final CategoriesRepository repository;

  DeleteCategoryUseCase(this.repository);

  Future<Either<Failure, void>> call(String categoryId) async {
    if (categoryId.isEmpty) {
      return const Left(ValidationFailure('Category ID cannot be empty'));
    }

    return await repository.deleteCategory(categoryId);
  }
}

class InitializeDefaultCategoriesUseCase {
  final CategoriesRepository repository;

  InitializeDefaultCategoriesUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.initializeDefaultCategories();
  }
}
