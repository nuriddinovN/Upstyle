import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:up_style/core/theme/app_theme.dart';
import 'package:up_style/features/home/presentation/provider/categories_provider.dart';
import 'package:up_style/features/warderobe/domain/entities/item.dart';
import 'package:up_style/features/warderobe/presentation/provider/item_provider.dart';
import 'package:up_style/features/warderobe/presentation/widgets/item_card.dart';
import 'package:up_style/features/warderobe/presentation/widgets/wardrobe_filter_sheet.dart';
import 'package:up_style/features/warderobe/presentation/widgets/wardrobe_sort_sheet.dart';

class WardrobeScreen extends StatefulWidget {
  final String? categoryId;

  const WardrobeScreen({super.key, this.categoryId});

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadItems();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadItems() {
    final itemsProvider = context.read<ItemsProvider>();
    final filter = widget.categoryId != null
        ? ItemFilter(categoryId: widget.categoryId)
        : const ItemFilter();

    itemsProvider.loadItems(filter: filter, refresh: true);
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      final itemsProvider = context.read<ItemsProvider>();
      if (itemsProvider.hasMore && !itemsProvider.isLoading) {
        itemsProvider.loadItems();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: _buildAppBar(),
      body: Consumer<ItemsProvider>(
        builder: (context, itemsProvider, child) {
          if (itemsProvider.status == ItemsStatus.initial ||
              (itemsProvider.status == ItemsStatus.loading &&
                  itemsProvider.items.isEmpty)) {
            return const Center(child: CircularProgressIndicator());
          }

          if (itemsProvider.status == ItemsStatus.error &&
              itemsProvider.items.isEmpty) {
            return _buildErrorState(itemsProvider.errorMessage);
          }

          if (itemsProvider.items.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              itemsProvider.refresh();
            },
            child: _buildItemsList(itemsProvider),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
        onPressed: () => context.pop(),
      ),
      title: Consumer<CategoriesProvider>(
        builder: (context, categoriesProvider, child) {
          if (widget.categoryId != null) {
            final category =
                categoriesProvider.getCategoryById(widget.categoryId!);
            return Text(
              category?.title ?? 'Wardrobe',
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            );
          }
          return const Text(
            'Wardrobe',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          );
        },
      ),
      actions: [
        IconButton(
          onPressed: _showFilterSheet,
          icon: const Icon(Icons.filter_list, color: AppTheme.textPrimary),
        ),
        IconButton(
          onPressed: _showSortSheet,
          icon: const Icon(Icons.sort, color: AppTheme.textPrimary),
        ),
      ],
    );
  }

  Widget _buildItemsList(ItemsProvider itemsProvider) {
    return Column(
      children: [
        // Active filters display
        _buildActiveFilters(itemsProvider),

        Expanded(
          child: GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount:
                itemsProvider.items.length + (itemsProvider.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= itemsProvider.items.length) {
                return const Center(child: CircularProgressIndicator());
              }

              final item = itemsProvider.items[index];
              return ItemCard(
                item: item,
                onTap: () => _navigateToItemDetail(item.id),
                onDelete: () => _showDeleteDialog(item.id),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActiveFilters(ItemsProvider itemsProvider) {
    final filter = itemsProvider.currentQuery.filter;
    final hasActiveFilters = !filter.isEmpty;

    if (!hasActiveFilters) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: AppTheme.primaryColor.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.filter_list,
                size: 16,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              const Text(
                'Active Filters:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  itemsProvider.updateFilter(const ItemFilter());
                },
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (filter.color != null)
                _buildFilterChip('Color: ${filter.color}'),
              if (filter.onlyUpcycled == true)
                _buildFilterChip('Upcycled Only'),
              if (filter.onlyUpStyled == true)
                _buildFilterChip('Upstyled Only'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
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
              'No Items Found',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 20,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.categoryId != null
                  ? 'This category doesn\'t have any items yet.\nAdd some items to get started!'
                  : 'Your wardrobe is empty.\nAdd some items to get started!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.push('/add-item');
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Item'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String? errorMessage) {
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
              errorMessage ?? 'Unknown error occurred',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<ItemsProvider>().refresh();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => WardrobeFilterSheet(
        currentFilter: context.read<ItemsProvider>().currentQuery.filter,
        onFilterChanged: (filter) {
          context.read<ItemsProvider>().updateFilter(filter);
        },
      ),
    );
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => WardrobeSortSheet(
        currentSort: context.read<ItemsProvider>().currentQuery.sortBy,
        onSortChanged: (sortBy) {
          context.read<ItemsProvider>().updateSorting(sortBy);
        },
      ),
    );
  }

  void _navigateToItemDetail(String itemId) {
    context.push('/item-detail/$itemId');
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
              await context.read<ItemsProvider>().deleteItem(itemId);

              if (mounted) {
                final provider = context.read<ItemsProvider>();
                if (provider.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(provider.errorMessage!),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Item deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
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
}
