import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:up_style/features/warderobe/data/models/fashionclip_models.dart';
import 'package:up_style/features/warderobe/domain/entities/item.dart';
import 'package:up_style/features/warderobe/domain/usecases/create_item_use_case.dart';
import 'package:up_style/features/warderobe/domain/usecases/save_upcycled_item_use_case.dart';
import 'package:up_style/service/upcycle/gemini_upcycle_service.dart';
import 'package:up_style/service/upcycle/upcycle_models.dart';
import '../../../../core/di/injection_container.dart';

enum ItemsStatus {
  initial,
  loading,
  loaded,
  error,
}

class ItemsProvider extends ChangeNotifier {
  ItemsStatus _status = ItemsStatus.initial;
  List<Item> _items = [];
  String? _errorMessage;
  bool _isLoading = false;
  bool _hasMore = true;
  ItemQuery _currentQuery = const ItemQuery();
  bool _isTransforming = false;

  // Use cases
  final CreateItemUseCase _createItemUseCase = sl<CreateItemUseCase>();
  final GetItemsUseCase _getItemsUseCase = sl<GetItemsUseCase>();
  final GetItemByIdUseCase _getItemByIdUseCase = sl<GetItemByIdUseCase>();
  final DeleteItemUseCase _deleteItemUseCase = sl<DeleteItemUseCase>();
  final UpcycleItemUseCase _upcycleItemUseCase = sl<UpcycleItemUseCase>();
  final UpstyleItemUseCase _upstyleItemUseCase = sl<UpstyleItemUseCase>();
  final GeminiUpcycleService _geminiService = sl<GeminiUpcycleService>();
  final SaveUpcycledItemUseCase _saveUpcycledItemUseCase =
      sl<SaveUpcycledItemUseCase>();

  // Getters
  ItemsStatus get status => _status;
  List<Item> get items => _items;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  bool get isTransforming => _isTransforming;
  ItemQuery get currentQuery => _currentQuery;

  Future<void> loadItems({
    ItemFilter filter = const ItemFilter(),
    ItemSortOption sortBy = ItemSortOption.dateDesc,
    bool refresh = false,
  }) async {
    if (refresh) {
      _items.clear();
      _currentQuery = ItemQuery(filter: filter, sortBy: sortBy);
    } else if (_isLoading || !_hasMore) {
      return;
    }

    _setLoading(true);
    _clearError();

    final query = _currentQuery.copyWith(
      filter: filter,
      sortBy: sortBy,
      lastItemId: _items.isNotEmpty ? _items.last.id : null,
    );

    final result = await _getItemsUseCase(query);

    result.fold(
      (failure) {
        _setStatus(ItemsStatus.error);
        _setError(failure.message);
      },
      (paginatedItems) {
        if (refresh) {
          _items = paginatedItems.items;
        } else {
          _items.addAll(paginatedItems.items);
        }
        _hasMore = paginatedItems.hasMore;
        _currentQuery = query;
        _setStatus(ItemsStatus.loaded);
      },
    );

    _setLoading(false);
  }

  Future<void> createItem({
    required String name,
    required String description,
    required String categoryId,
    required String color,
    required File imageFile,
  }) async {
    _setLoading(true);
    _clearError();

    final result = await _createItemUseCase(
      name: name,
      description: description,
      categoryId: categoryId,
      color: color,
      imageFile: imageFile,
    );

    result.fold(
      (failure) => _setError(failure.message),
      (item) {
        _items.insert(0, item); // Add to beginning of list
        notifyListeners();
      },
    );

    _setLoading(false);
  }

  Future<Item?> getItemById(String itemId) async {
    // First check if item is already in memory
    try {
      final cachedItem = _items.firstWhere((item) => item.id == itemId);
      return cachedItem;
    } catch (e) {
      // Item not in cache, fetch from repository
    }

    final result = await _getItemByIdUseCase(itemId);
    return result.fold(
      (failure) {
        _setError(failure.message);
        return null;
      },
      (item) => item,
    );
  }

  Future<void> deleteItem(String itemId) async {
    _setLoading(true);
    _clearError();

    final result = await _deleteItemUseCase(itemId);

    result.fold(
      (failure) => _setError(failure.message),
      (_) {
        _items.removeWhere((item) => item.id == itemId);
        notifyListeners();
      },
    );

    _setLoading(false);
  }

  Future<Item?> upcycleItem(String itemId, {String? userPrompt}) async {
    _setTransforming(true);
    _clearError();

    print('Provider: Starting upcycle with prompt: ${userPrompt ?? "default"}');

    final result = await _upcycleItemUseCase(itemId, userPrompt: userPrompt);

    Item? newItem;
    result.fold(
      (failure) {
        print('Provider: Upcycle failed: ${failure.message}');
        _setError(failure.message);
      },
      (item) {
        print('Provider: Upcycle successful: ${item.name}');
        _items.insert(0, item);
        newItem = item;
        notifyListeners();
      },
    );

    _setTransforming(false);
    return newItem;
  }

  Future<Item?> upstyleItem(String itemId) async {
    _setTransforming(true);
    _clearError();

    final result = await _upstyleItemUseCase(itemId);

    Item? newItem;
    result.fold(
      (failure) => _setError(failure.message),
      (item) {
        _items.insert(0, item); // Add transformed item to beginning
        newItem = item;
        notifyListeners();
      },
    );

    _setTransforming(false);
    return newItem;
  }

  void updateFilter(ItemFilter filter) {
    loadItems(filter: filter, refresh: true);
  }

  void updateSorting(ItemSortOption sortBy) {
    loadItems(sortBy: sortBy, refresh: true);
  }

  List<Item> getItemsByCategory(String categoryId) {
    return _items.where((item) => item.categoryId == categoryId).toList();
  }

// Save selected idea
  Future<Item?> saveSelectedUpcyclingIdea(
    String originalItemId,
    UpcyclingIdeaWithImage selectedIdea,
  ) async {
    _setTransforming(true);
    _clearError();

    try {
      print('Provider: Saving selected idea: ${selectedIdea.idea.title}');

      final result = await _saveUpcycledItemUseCase(
        originalItemId,
        selectedIdea,
      );

      Item? newItem;
      result.fold(
        (failure) {
          print('Provider: Save failed: ${failure.message}');
          _setError(failure.message);
        },
        (item) {
          print('Provider: Save successful: ${item.name}');
          _items.insert(0, item);
          newItem = item;
          notifyListeners();
        },
      );

      _setTransforming(false);
      return newItem;
    } catch (e) {
      print('Provider: Save failed: $e');
      _setError('Failed to save: $e');
      _setTransforming(false);
      return null;
    }
  }

// Add this method after createItem()
  Future<void> createItemWithAnalysis({
    required String name,
    required String description,
    required String categoryId,
    required String color,
    required File imageFile,
    required FashionAnalysis analysis,
  }) async {
    _setLoading(true);
    _clearError();

    final result = await _createItemUseCase.callWithAnalysis(
      name: name,
      description: description,
      categoryId: categoryId,
      color: color,
      imageFile: imageFile,
      analysis: analysis,
    );

    result.fold(
      (failure) => _setError(failure.message),
      (item) {
        _items.insert(0, item);
        notifyListeners();
      },
    );

    _setLoading(false);
  }

// Also update generateUpcyclingIdeas to pass full metadata
  Future<List<UpcyclingIdeaWithImage>?> generateUpcyclingIdeas(
    String itemId, {
    String? userPrompt,
  }) async {
    _setTransforming(true);
    _clearError();

    try {
      print('Provider: Generating upcycling ideas for item: $itemId');

      final item = _items.firstWhere((i) => i.id == itemId);

      final imageBytes = await _geminiService.downloadImageFromFirebase(
        item.imageUrl,
      );

      // UPDATED: Include all FashionCLIP data
      final metadata = {
        'name': item.name,
        'description': item.description,
        'category': item.categoryId,
        'color': item.color,
        // FashionCLIP data
        'subCategory': item.subCategory ?? 'unknown',
        'gender': item.gender ?? 'unisex',
        'primaryColor': item.color,
        'secondaryColor': item.secondaryColor ?? 'none',
        'accentColor': item.accentColor ?? 'none',
        'pattern': item.pattern ?? 'solid color',
        'material': item.material ?? 'unknown',
        'fit': item.fit ?? 'regular',
        'silhouette': item.silhouette ?? 'standard',
        'neckline': item.neckline ?? 'unknown',
        'sleeve': item.sleeve ?? 'unknown',
        'length': item.length ?? 'standard',
        'closureType': item.closureType ?? 'unknown',
        'style': item.style ?? 'casual',
        'occasion': item.occasion ?? 'everyday',
        'season': item.season ?? 'all-season',
        'upcyclingPotential': item.upcyclingPotential ?? 'medium',
        'upcyclingType': item.upcyclingType ?? 'general modification',
        'repairability': item.repairability ?? 'moderate',
        'sustainability': item.sustainability ?? 'standard fabric',
      };

      final ideas = await _geminiService.generateIdeas(
        imageBytes: imageBytes,
        userPrompt: userPrompt ?? "Transform this into something useful",
        metadata: metadata,
      );

      final ideasWithImages =
          await _geminiService.generateProductImagesForAllIdeas(
        originalImageBytes: imageBytes,
        ideas: ideas,
      );

      print('Provider: Generated ${ideasWithImages.length} ideas with images');
      _setTransforming(false);
      return ideasWithImages;
    } catch (e) {
      print('Provider: Failed to generate ideas: $e');
      _setError('Failed to generate ideas: $e');
      _setTransforming(false);
      return null;
    }
  }

  void refresh() {
    loadItems(
      filter: _currentQuery.filter,
      sortBy: _currentQuery.sortBy,
      refresh: true,
    );
  }

  void _setStatus(ItemsStatus status) {
    _status = status;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setTransforming(bool transforming) {
    _isTransforming = transforming;
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
