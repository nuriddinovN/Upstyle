import 'package:dartz/dartz.dart';
import 'package:up_style/core/errors/failures.dart';
import 'package:up_style/features/warderobe/domain/entities/item.dart';
import 'package:up_style/service/fashion_transform/fashion_transform_service.dart';
import 'package:up_style/service/upcycle/gemini_upcycle_service.dart';
import 'package:up_style/features/warderobe/data/models/item_model.dart';
import 'package:up_style/service/upcycle/upcycle_models.dart';
import 'package:uuid/uuid.dart';

class RealFashionTransformService implements FashionTransformService {
  final GeminiUpcycleService geminiService;
  static const _uuid = Uuid();

  RealFashionTransformService({required this.geminiService});

  @override
  Future<Either<Failure, Item>> upcycleItem(
    Item originalItem, {
    String? userPrompt,
  }) async {
    try {
      print('🔄 Starting upcycle process for: ${originalItem.name}');

      // Step 1: Download original image from Firebase
      final imageBytes = await geminiService.downloadImageFromFirebase(
        originalItem.imageUrl,
      );

      // Step 2: Prepare metadata
      final metadata = {
        'category': originalItem.categoryId,
        'color': originalItem.color,
        'name': originalItem.name,
        'description': originalItem.description,
        'material': 'Unknown',
        'condition': 'Good',
      };

      // Step 3: Generate upcycling ideas
      final ideas = await geminiService.generateIdeas(
        imageBytes: imageBytes,
        userPrompt: userPrompt ?? _getDefaultPrompt(),
        metadata: metadata,
      );

      // Step 4: Select first idea (TODO: show selection UI)
      final selectedIdea = ideas.first;
      print('🎯 Selected idea: ${selectedIdea.title}');

      // Step 5: Generate product image
      final productImageFile = await geminiService.generateProductImage(
        originalImageBytes: imageBytes,
        selectedIdea: selectedIdea,
      );

      // Step 6: Create new upcycled item
      final now = DateTime.now();
      final upcycledItem = ItemModel.fromEntity(originalItem).copyWith(
        id: _uuid.v4(),
        name: '${originalItem.name} (Upcycled)',
        description:
            _createUpcycledDescription(originalItem.description, selectedIdea),
        imageUrl: productImageFile.path, // Will be uploaded by repository
        isUpcycled: true,
        originalItemId: originalItem.id,
        createdAt: now,
        updatedAt: now,
      );

      print('✅ Upcycle process completed');
      return Right(upcycledItem);
    } catch (e) {
      print('❌ Upcycle failed: $e');
      return Left(ServerFailure('Failed to upcycle item: $e'));
    }
  }

  @override
  Future<Either<Failure, Item>> upstyleItem(Item originalItem) async {
    return const Left(ServerFailure('Upstyling not implemented yet'));
  }

  @override
  Future<bool> isServiceAvailable() async {
    return true;
  }

  @override
  Future<Map<String, dynamic>> getServiceStatus() async {
    return {
      'status': 'available',
      'service_type': 'gemini_direct',
      'upcycling_enabled': true,
      'upstyling_enabled': false,
    };
  }

  String _getDefaultPrompt() {
    return "I would like to transform this clothing item into something useful and creative. "
        "Please suggest practical ideas that don't require advanced sewing skills.";
  }

  String _createUpcycledDescription(
      String originalDescription, UpcyclingIdea idea) {
    return '$originalDescription\n\n'
        '🌿 Upcycled: ${idea.title}\n'
        '${idea.whatWorkToDo}';
  }
}
