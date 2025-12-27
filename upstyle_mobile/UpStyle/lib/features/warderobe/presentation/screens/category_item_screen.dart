import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:up_style/core/di/injection_container.dart';
import 'package:up_style/core/theme/app_theme.dart';
import 'package:up_style/features/warderobe/domain/entities/item.dart';
import 'package:up_style/features/warderobe/domain/usecases/create_item_use_case.dart';
import 'package:up_style/features/warderobe/presentation/provider/item_provider.dart';
import 'package:up_style/features/warderobe/presentation/widgets/item_card.dart';

/// Separate screen for viewing items in a specific category
/// This is DIFFERENT from the main Wardrobe tab in bottom navigation
class CategoryItemsScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const CategoryItemsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryItemsScreen> createState() => _CategoryItemsScreenState();
}

class _CategoryItemsScreenState extends State<CategoryItemsScreen> {
  final ScrollController _scrollController = ScrollController();
  List<Item> _items = [];
  bool _isLoading = false;
  bool _hasMore = true;
  String? _errorMessage;
  String? _lastItemId;

  @override
  void initState() {
    super.initState();
    _loadItems();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadItems({bool refresh = false}) async {
    if (_isLoading) return;
    if (!refresh && !_hasMore) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      if (refresh) {
        _items.clear();
        _lastItemId = null;
        _hasMore = true;
      }
    });

    try {
      // Create query with category filter and simple ordering
      final filter = ItemFilter(categoryId: widget.categoryId);
      final query = ItemQuery(
        filter: filter,
        sortBy: ItemSortOption.dateDesc,
        limit: 20,
        lastItemId: _lastItemId,
      );

      final getItemsUseCase = sl<GetItemsUseCase>();
      final result = await getItemsUseCase(query);

      result.fold(
        (failure) {
          if (mounted) {
            setState(() {
              _errorMessage = failure.message;
              _isLoading = false;
            });
          }
        },
        (paginatedItems) {
          if (mounted) {
            setState(() {
              if (refresh) {
                _items = paginatedItems.items;
              } else {
                _items.addAll(paginatedItems.items);
              }
              _hasMore = paginatedItems.hasMore;
              if (paginatedItems.items.isNotEmpty) {
                _lastItemId = paginatedItems.items.last.id;
              }
              _isLoading = false;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading items: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      if (_hasMore && !_isLoading) {
        _loadItems();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.categoryName,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadItems(refresh: true),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _items.isEmpty) {
      return _buildErrorState();
    }

    if (_items.isEmpty) {
      return _buildEmptyState();
    }

    return _buildItemsGrid();
  }

  Widget _buildItemsGrid() {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _items.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _items.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final item = _items[index];
        return ItemCard(
          item: item,
          onTap: () => context.push('/item-detail/${item.id}'),
          onDelete: () => _showDeleteDialog(item.id),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.checkroom_outlined,
              size: 80,
              color: AppTheme.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No Items in ${widget.categoryName}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 20,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Add some items to this category to get started!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push('/add-item'),
              icon: const Icon(Icons.add),
              label: const Text('Add Item'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: AppTheme.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 20,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'Unknown error occurred',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _loadItems(refresh: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(String itemId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Delete Item'),
        content: const Text(
          'Are you sure you want to delete this item? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteItem(itemId);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteItem(String itemId) async {
    final itemsProvider = context.read<ItemsProvider>();
    await itemsProvider.deleteItem(itemId);

    if (mounted) {
      if (itemsProvider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(itemsProvider.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        // Remove from local list
        setState(() {
          _items.removeWhere((item) => item.id == itemId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}
