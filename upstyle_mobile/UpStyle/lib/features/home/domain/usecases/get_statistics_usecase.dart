import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/statistics.dart';
import '../repositories/statistics_repository.dart';

class GetStatisticsUseCase {
  final StatisticsRepository repository;

  GetStatisticsUseCase(this.repository);

  Future<Either<Failure, Statistics>> call() async {
    return await repository.getStatistics();
  }
}

class GetCategoryStatisticsUseCase {
  final StatisticsRepository repository;

  GetCategoryStatisticsUseCase(this.repository);

  Future<Either<Failure, List<CategoryStatistics>>> call() async {
    return await repository.getCategoryStatistics();
  }
}
