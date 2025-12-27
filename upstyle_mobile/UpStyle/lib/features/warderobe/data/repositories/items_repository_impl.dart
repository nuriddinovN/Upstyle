import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:up_style/features/warderobe/data/models/fashionclip_models.dart';
import 'package:up_style/service/fashion_transform/fashion_transform_service.dart';
import 'package:up_style/service/upcycle/upcycle_models.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/item.dart';
import '../../domain/repositories/item_repository.dart';
import '../datasources/items_remote_datasource.dart';
import '../models/item_model.dart';
import '../models/paginated_items.dart';

class ItemsRepositoryImpl implements ItemsRepository {
  final ItemsRemoteDataSource remoteDataSource;
  final FashionTransformService fashionTransformService;

  ItemsRepositoryImpl({
    required this.remoteDataSource,
    required this.fashionTransformService,
  });

  @override
  Future<Either<Failure, Item>> createItem({
    required String name,
    required String description,
    required String categoryId,
    required String color,
    required File imageFile,
  }) async {
    try {
      final item = await remoteDataSource.createItem(
        name: name,
        description: description,
        categoryId: categoryId,
        color: color,
        imageFile: imageFile,
      );
      return Right(item);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  // ADD THIS NEW METHOD
  @override
  Future<Either<Failure, Item>> createItemWithAnalysis({
    required String name,
    required String description,
    required String categoryId,
    required String color,
    required File imageFile,
    required FashionAnalysis analysis,
  }) async {
    try {
      final item = await remoteDataSource.createItemWithAnalysis(
        name: name,
        description: description,
        categoryId: categoryId,
        color: color,
        imageFile: imageFile,
        analysis: analysis,
      );
      return Right(item);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  // ... rest of the methods stay the same ...

  @override
  Future<Either<Failure, PaginatedItems>> getItems(ItemQuery query) async {
    try {
      final items = await remoteDataSource.getItems(query);
      return Right(items);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Item>> getItemById(String itemId) async {
    try {
      final item = await remoteDataSource.getItemById(itemId);
      return Right(item);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Item>> updateItem({
    required String itemId,
    String? name,
    String? description,
    String? categoryId,
    String? color,
    File? imageFile,
  }) async {
    try {
      final item = await remoteDataSource.updateItem(
        itemId: itemId,
        name: name,
        description: description,
        categoryId: categoryId,
        color: color,
        imageFile: imageFile,
      );
      return Right(item);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteItem(String itemId) async {
    try {
      await remoteDataSource.deleteItem(itemId);
      return const Right(null);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Item>> upcycleItem(
    String itemId, {
    String? userPrompt,
  }) async {
    try {
      final originalItemResult = await getItemById(itemId);
      if (originalItemResult.isLeft()) {
        return Left((originalItemResult as Left).value);
      }

      final originalItem = (originalItemResult as Right<Failure, Item>).value;

      final transformedResult = await fashionTransformService.upcycleItem(
        originalItem,
        userPrompt: userPrompt,
      );

      if (transformedResult.isLeft()) {
        return Left((transformedResult as Left).value);
      }

      final transformedItem = (transformedResult as Right<Failure, Item>).value;

      final imageFile = File(transformedItem.imageUrl);
      final imageUrl = await _uploadImage(imageFile);

      final itemWithFirebaseUrl =
          ItemModel.fromEntity(transformedItem).copyWith(
        imageUrl: imageUrl,
      );

      final savedItem =
          await remoteDataSource.saveTransformedItem(itemWithFirebaseUrl);

      return Right(savedItem);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error during upcycling: $e'));
    }
  }

  @override
  Future<Either<Failure, Item>> saveUpcycledItem(
    String originalItemId,
    UpcyclingIdeaWithImage selectedIdea,
  ) async {
    try {
      final originalItemResult = await getItemById(originalItemId);
      if (originalItemResult.isLeft()) {
        return Left((originalItemResult as Left).value);
      }

      final originalItem = (originalItemResult as Right<Failure, Item>).value;

      final imageUrl = await _uploadImage(selectedIdea.imageFile);

      final description = _createUpcycledDescription(
        originalItem.description,
        selectedIdea.idea,
      );

      final now = DateTime.now();
      final upcycledItem = ItemModel.fromEntity(originalItem).copyWith(
        id: const Uuid().v4(),
        name: '${originalItem.name} (Upcycled)',
        description: description,
        imageUrl: imageUrl,
        isUpcycled: true,
        originalItemId: originalItem.id,
        createdAt: now,
        updatedAt: now,
      );

      final savedItem =
          await remoteDataSource.saveTransformedItem(upcycledItem);

      return Right(savedItem);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Failed to save upcycled item: $e'));
    }
  }

  String _createUpcycledDescription(
      String originalDescription, UpcyclingIdea idea) {
    return '$originalDescription\n\n'
        '🌿 AI Upcycling Idea: ${idea.title}\n\n'
        '💡 ${idea.whatWorkToDo}\n\n'
        '🔧 What You Need:\n${idea.neededItems.map((item) => '  • $item').join('\n')}\n\n'
        '📋 Step-by-Step Guide:\n${idea.stepByStepProcess.asMap().entries.map((e) => '  ${e.key + 1}. ${e.value}').join('\n')}';
  }

  Future<String> _uploadImage(File imageFile) async {
    try {
      final fileName = 'upcycled_${DateTime.now().millisecondsSinceEpoch}.png';
      final storageRef =
          FirebaseStorage.instance.ref().child('items/$fileName');

      await storageRef.putFile(imageFile);
      final downloadUrl = await storageRef.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw ServerFailure('Failed to upload image: $e');
    }
  }

  @override
  Future<Either<Failure, Item>> upstyleItem(String itemId) async {
    try {
      final originalItemResult = await getItemById(itemId);
      if (originalItemResult.isLeft()) {
        return Left((originalItemResult as Left).value);
      }

      final originalItem = (originalItemResult as Right<Failure, Item>).value;

      final transformedResult =
          await fashionTransformService.upstyleItem(originalItem);
      if (transformedResult.isLeft()) {
        return Left((transformedResult as Left).value);
      }

      final transformedItem = (transformedResult as Right<Failure, Item>).value;

      final savedItem = await remoteDataSource.saveTransformedItem(
        ItemModel.fromEntity(transformedItem),
      );

      return Right(savedItem);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error during upstyling: $e'));
    }
  }

  @override
  Stream<PaginatedItems> watchItems(ItemQuery query) {
    return remoteDataSource.watchItems(query);
  }

  @override
  Future<Either<Failure, List<Item>>> getItemsByCategory(
      String categoryId) async {
    try {
      final items = await remoteDataSource.getItemsByCategory(categoryId);
      return Right(items);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}
