import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/statistics.dart';

abstract class StatisticsRepository {
  Future<Either<Failure, Statistics>> getStatistics();

  Future<Either<Failure, List<CategoryStatistics>>> getCategoryStatistics();

  Stream<Statistics> watchStatistics();
}
