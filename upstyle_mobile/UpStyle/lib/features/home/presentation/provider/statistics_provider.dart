import 'package:flutter/foundation.dart';
import 'package:up_style/core/di/injection_container.dart';
import 'package:up_style/features/home/domain/entities/statistics.dart';
import 'package:up_style/features/home/domain/usecases/get_statistics_usecase.dart';

enum StatisticsStatus {
  initial,
  loading,
  loaded,
  error,
}

class StatisticsProvider extends ChangeNotifier {
  StatisticsStatus _status = StatisticsStatus.initial;
  Statistics? _statistics;
  List<CategoryStatistics> _categoryStatistics = [];
  String? _errorMessage;
  bool _isLoading = false;

  // Use cases
  final GetStatisticsUseCase _getStatisticsUseCase = sl<GetStatisticsUseCase>();
  final GetCategoryStatisticsUseCase _getCategoryStatisticsUseCase =
      sl<GetCategoryStatisticsUseCase>();

  // Getters
  StatisticsStatus get status => _status;
  Statistics? get statistics => _statistics;
  List<CategoryStatistics> get categoryStatistics => _categoryStatistics;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  Future<void> loadStatistics() async {
    _setLoading(true);
    _clearError();

    final result = await _getStatisticsUseCase();

    result.fold(
      (failure) {
        _setStatus(StatisticsStatus.error);
        _setError(failure.message);
      },
      (statistics) {
        _statistics = statistics;
        _setStatus(StatisticsStatus.loaded);
      },
    );

    _setLoading(false);
  }

  Future<void> loadCategoryStatistics() async {
    _setLoading(true);
    _clearError();

    final result = await _getCategoryStatisticsUseCase();

    result.fold(
      (failure) => _setError(failure.message),
      (categoryStats) {
        _categoryStatistics = categoryStats;
        notifyListeners();
      },
    );

    _setLoading(false);
  }

  Future<void> refresh() async {
    await loadStatistics();
    await loadCategoryStatistics();
  }

  void _setStatus(StatisticsStatus status) {
    _status = status;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() => _clearError();
}
