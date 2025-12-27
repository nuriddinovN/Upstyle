import 'package:dartz/dartz.dart';
import 'package:up_style/core/errors/failures.dart';
import 'package:up_style/features/warderobe/domain/entities/item.dart';
import 'package:up_style/features/warderobe/domain/repositories/item_repository.dart';
import 'package:up_style/service/upcycle/upcycle_models.dart';

class SaveUpcycledItemUseCase {
  final ItemsRepository repository;

  SaveUpcycledItemUseCase(this.repository);

  Future<Either<Failure, Item>> call(
    String originalItemId,
    UpcyclingIdeaWithImage selectedIdea,
  ) async {
    if (originalItemId.isEmpty) {
      return const Left(ValidationFailure('Item ID cannot be empty'));
    }

    return await repository.saveUpcycledItem(
      originalItemId,
      selectedIdea,
    );
  }
}
