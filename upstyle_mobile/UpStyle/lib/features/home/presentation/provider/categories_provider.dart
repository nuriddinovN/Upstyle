//import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:up_style/core/di/injection_container.dart';
import 'package:up_style/features/home/domain/entities/category.dart';
import 'package:up_style/features/home/domain/usecases/get_categories_use_case.dart';

enum CategoriesStatus {
  initial,
  loading,
  loaded,
  error,
}

class CategoriesProvider extends ChangeNotifier {
  CategoriesStatus _status = CategoriesStatus.initial;
  List<Category> _categories = [];
  String? _errorMessage;
  bool _isLoading = false;

  // Use cases
  final GetCategoriesUseCase _getCategoriesUseCase = sl<GetCategoriesUseCase>();
  final CreateCategoryUseCase _createCategoryUseCase =
      sl<CreateCategoryUseCase>();
  final DeleteCategoryUseCase _deleteCategoryUseCase =
      sl<DeleteCategoryUseCase>();

  // Getters
  CategoriesStatus get status => _status;
  List<Category> get categories => _categories;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  Future<void> loadCategories() async {
    _setLoading(true);
    _clearError();

    final result = await _getCategoriesUseCase();

    result.fold(
      (failure) {
        _setStatus(CategoriesStatus.error);
        _setError(failure.message);
      },
      (categories) {
        _categories = categories;
        _setStatus(CategoriesStatus.loaded);
      },
    );

    _setLoading(false);
  }

  Future<void> createCategory(String title) async {
    _setLoading(true);
    _clearError();

    final result = await _createCategoryUseCase(title);

    result.fold(
      (failure) => _setError(failure.message),
      (category) {
        _categories.add(category);
        notifyListeners();
      },
    );

    _setLoading(false);
  }

  Future<void> deleteCategory(String categoryId) async {
    _setLoading(true);
    _clearError();

    // Check if category is default
    final category = _categories.firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () => throw Exception('Category not found'),
    );

    if (category.isDefault) {
      _setError('Cannot delete default category');
      _setLoading(false);
      return;
    }

    if (category.itemCount > 0) {
      _setError(
          'Cannot delete category with items. Please move or delete all items first.');
      _setLoading(false);
      return;
    }

    final result = await _deleteCategoryUseCase(categoryId);

    result.fold(
      (failure) => _setError(failure.message),
      (_) {
        _categories.removeWhere((cat) => cat.id == categoryId);
        notifyListeners();
      },
    );

    _setLoading(false);
  }

  Category? getCategoryById(String categoryId) {
    try {
      return _categories.firstWhere((cat) => cat.id == categoryId);
    } catch (e) {
      return null;
    }
  }

  void _setStatus(CategoriesStatus status) {
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
