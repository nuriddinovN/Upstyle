import 'package:dartz/dartz.dart';
import 'package:up_style/features/warderobe/data/models/fashionclip_models.dart';
import 'package:up_style/service/upcycle/upcycle_models.dart';
import '../../../../core/errors/failures.dart';
import '../entities/item.dart';
import '../../data/models/paginated_items.dart';
import 'dart:io';

abstract class ItemsRepository {
  Future<Either<Failure, Item>> createItem({
    required String name,
    required String description,
    required String categoryId,
    required String color,
    required File imageFile,
  });

  // ADD THIS NEW METHOD
  Future<Either<Failure, Item>> createItemWithAnalysis({
    required String name,
    required String description,
    required String categoryId,
    required String color,
    required File imageFile,
    required FashionAnalysis analysis,
  });

  Future<Either<Failure, Item>> upcycleItem(
    String itemId, {
    String? userPrompt,
  });

  Future<Either<Failure, PaginatedItems>> getItems(ItemQuery query);
  Future<Either<Failure, Item>> getItemById(String itemId);
  Future<Either<Failure, Item>> updateItem({
    required String itemId,
    String? name,
    String? description,
    String? categoryId,
    String? color,
    File? imageFile,
  });
  Future<Either<Failure, void>> deleteItem(String itemId);
  Future<Either<Failure, Item>> upstyleItem(String itemId);
  Stream<PaginatedItems> watchItems(ItemQuery query);
  Future<Either<Failure, List<Item>>> getItemsByCategory(String categoryId);
  Future<Either<Failure, Item>> saveUpcycledItem(
    String originalItemId,
    UpcyclingIdeaWithImage selectedIdea,
  );
}
