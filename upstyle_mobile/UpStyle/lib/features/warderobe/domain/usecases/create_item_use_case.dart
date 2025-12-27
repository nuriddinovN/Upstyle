import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:up_style/features/warderobe/data/models/fashionclip_models.dart';
import '../../../../core/errors/failures.dart';
import '../entities/item.dart';
import '../repositories/item_repository.dart';
import '../../data/models/paginated_items.dart';

class CreateItemUseCase {
  final ItemsRepository repository;
  CreateItemUseCase(this.repository);

  // Existing call method - keep as is
  Future<Either<Failure, Item>> call({
    required String name,
    required String description,
    required String categoryId,
    required String color,
    required File imageFile,
  }) async {
    if (name.isEmpty) {
      return const Left(ValidationFailure('Item name cannot be empty'));
    }
    if (description.isEmpty) {
      return const Left(ValidationFailure('Item description cannot be empty'));
    }
    if (categoryId.isEmpty) {
      return const Left(ValidationFailure('Category must be selected'));
    }
    if (color.isEmpty) {
      return const Left(ValidationFailure('Color must be selected'));
    }
    if (!imageFile.existsSync()) {
      return const Left(ValidationFailure('Image file is required'));
    }
    return await repository.createItem(
      name: name,
      description: description,
      categoryId: categoryId,
      color: color,
      imageFile: imageFile,
    );
  }

  // ADD THIS NEW METHOD for FashionCLIP integration
  Future<Either<Failure, Item>> callWithAnalysis({
    required String name,
    required String description,
    required String categoryId,
    required String color,
    required File imageFile,
    required FashionAnalysis analysis,
  }) async {
    if (name.isEmpty) {
      return const Left(ValidationFailure('Item name cannot be empty'));
    }
    if (description.isEmpty) {
      return const Left(ValidationFailure('Item description cannot be empty'));
    }
    if (categoryId.isEmpty) {
      return const Left(ValidationFailure('Category must be selected'));
    }
    if (color.isEmpty) {
      return const Left(ValidationFailure('Color must be selected'));
    }
    if (!imageFile.existsSync()) {
      return const Left(ValidationFailure('Image file is required'));
    }

    return await repository.createItemWithAnalysis(
      name: name,
      description: description,
      categoryId: categoryId,
      color: color,
      imageFile: imageFile,
      analysis: analysis,
    );
  }
}

// Rest of the classes stay the same
class GetItemsUseCase {
  final ItemsRepository repository;
  GetItemsUseCase(this.repository);
  Future<Either<Failure, PaginatedItems>> call(ItemQuery query) async {
    return await repository.getItems(query);
  }
}

class GetItemByIdUseCase {
  final ItemsRepository repository;
  GetItemByIdUseCase(this.repository);
  Future<Either<Failure, Item>> call(String itemId) async {
    if (itemId.isEmpty) {
      return const Left(ValidationFailure('Item ID cannot be empty'));
    }
    return await repository.getItemById(itemId);
  }
}

class DeleteItemUseCase {
  final ItemsRepository repository;
  DeleteItemUseCase(this.repository);
  Future<Either<Failure, void>> call(String itemId) async {
    if (itemId.isEmpty) {
      return const Left(ValidationFailure('Item ID cannot be empty'));
    }
    return await repository.deleteItem(itemId);
  }
}

class UpcycleItemUseCase {
  final ItemsRepository repository;
  UpcycleItemUseCase(this.repository);
  Future<Either<Failure, Item>> call(
    String itemId, {
    String? userPrompt,
  }) async {
    if (itemId.isEmpty) {
      return const Left(ValidationFailure('Item ID cannot be empty'));
    }
    if (userPrompt != null && userPrompt.trim().isEmpty) {
      return const Left(ValidationFailure('User prompt cannot be empty'));
    }
    return await repository.upcycleItem(itemId, userPrompt: userPrompt);
  }
}

class UpstyleItemUseCase {
  final ItemsRepository repository;
  UpstyleItemUseCase(this.repository);
  Future<Either<Failure, Item>> call(String itemId) async {
    if (itemId.isEmpty) {
      return const Left(ValidationFailure('Item ID cannot be empty'));
    }
    return await repository.upstyleItem(itemId);
  }
}
