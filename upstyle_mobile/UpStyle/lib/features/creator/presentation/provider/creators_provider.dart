import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:up_style/features/auth/data/models/user_model.dart';
import 'package:up_style/features/creator/data/datasource/creators_remote_data_source.dart';

enum CreatorsStatus { initial, loading, loaded, error }

class CreatorsProvider extends ChangeNotifier {
  final CreatorsRemoteDataSource _dataSource;

  CreatorsProvider(this._dataSource);

  CreatorsStatus _status = CreatorsStatus.initial;
  List<UserModel> _creators = [];
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  String? _errorMessage;
  bool _isLoadingMore = false;

  CreatorsStatus get status => _status;
  List<UserModel> get creators => _creators;
  bool get hasMore => _hasMore;
  String? get errorMessage => _errorMessage;
  bool get isLoadingMore => _isLoadingMore;

  // Load initial creators
  Future<void> loadCreators({bool refresh = false}) async {
    if (refresh) {
      _creators.clear();
      _lastDocument = null;
      _hasMore = true;
    }

    if (!_hasMore || _isLoadingMore) return;

    _setStatus(CreatorsStatus.loading);
    _clearError();

    try {
      final result = await _dataSource.getCreators(
        limit: 20,
        lastDocument: _lastDocument,
      );

      if (refresh) {
        _creators = result;
      } else {
        _creators.addAll(result);
      }

      _hasMore = result.length >= 20;

      if (result.isNotEmpty) {
        // Note: You'll need to modify the data source to return DocumentSnapshots
        // or implement pagination differently
      }

      _setStatus(CreatorsStatus.loaded);
    } catch (e) {
      _setError(e.toString());
      _setStatus(CreatorsStatus.error);
    }
  }

  // Load more creators (pagination)
  Future<void> loadMoreCreators() async {
    if (!_hasMore || _isLoadingMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final result = await _dataSource.getCreators(
        limit: 20,
        lastDocument: _lastDocument,
      );

      _creators.addAll(result);
      _hasMore = result.length >= 20;

      _isLoadingMore = false;
      notifyListeners();
    } catch (e) {
      _isLoadingMore = false;
      _setError(e.toString());
    }
  }

  // Get creator by ID
  Future<UserModel?> getCreatorById(String creatorId) async {
    try {
      return await _dataSource.getCreatorById(creatorId);
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  // Become a creator
  Future<bool> becomeCreator({
    required String bio,
    required List<String> specializations,
  }) async {
    try {
      await _dataSource.becomeCreator(
        bio: bio,
        specializations: specializations,
      );
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Switch to creator mode
  Future<bool> switchToCreatorMode() async {
    try {
      await _dataSource.switchToCreatorMode();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Switch to user mode
  Future<bool> switchToUserMode() async {
    try {
      await _dataSource.switchToUserMode();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Search creators
  Future<void> searchCreators(String query) async {
    if (query.isEmpty) {
      loadCreators(refresh: true);
      return;
    }

    _setStatus(CreatorsStatus.loading);
    _clearError();

    try {
      final result = await _dataSource.searchCreators(query);
      _creators = result;
      _hasMore = false;
      _setStatus(CreatorsStatus.loaded);
    } catch (e) {
      _setError(e.toString());
      _setStatus(CreatorsStatus.error);
    }
  }

  void _setStatus(CreatorsStatus status) {
    _status = status;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void refresh() {
    loadCreators(refresh: true);
  }
}
