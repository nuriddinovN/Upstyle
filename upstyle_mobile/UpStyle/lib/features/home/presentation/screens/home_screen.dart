// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:up_style/core/theme/app_theme.dart';
import 'package:up_style/core/di/injection_container.dart';
import 'package:up_style/features/home/domain/entities/category.dart';
import 'package:up_style/features/home/presentation/provider/categories_provider.dart';
import 'package:up_style/features/home/presentation/provider/statistics_provider.dart';
import 'package:up_style/features/home/presentation/widgets/add_category_card_dialog.dart';
import 'package:up_style/features/home/presentation/widgets/statistics_ovierview.dart';
import 'package:up_style/features/warderobe/domain/entities/item.dart';
import 'package:up_style/features/warderobe/domain/usecases/create_item_use_case.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Map<String, List<Item>> _categoryItemsCache = {};
  bool _isLoadingItems = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final categoriesProvider = context.read<CategoriesProvider>();
    final statisticsProvider = context.read<StatisticsProvider>();

    await Future.wait([
      categoriesProvider.loadCategories(),
      statisticsProvider.loadStatistics(),
    ]);

    // Load items for each category for preview
    await _loadCategoryItems(categoriesProvider.categories);
  }

  Future<void> _loadCategoryItems(List<Category> categories) async {
    if (!mounted) return;

    setState(() => _isLoadingItems = true);

    // Get the use case from dependency injection
    final getItemsUseCase = sl<GetItemsUseCase>();

    for (final category in categories) {
      try {
        print('Loading items for category: ${category.title} (${category.id})');

        // Create a simple query - just filter by category, no complex sorting
        final filter = ItemFilter(categoryId: category.id);
        final query = ItemQuery(
          filter: filter,
          sortBy: ItemSortOption.dateDesc, // Simple sorting
          limit: 4,
        );

        // Fetch items using the use case
        final result = await getItemsUseCase(query);

        if (mounted) {
          result.fold(
            (failure) {
              print(
                  'Error loading items for ${category.title}: ${failure.message}');
              setState(() {
                _categoryItemsCache[category.id] = [];
              });
            },
            (paginatedItems) {
              print(
                  'Loaded ${paginatedItems.items.length} items for ${category.title}');
              setState(() {
                _categoryItemsCache[category.id] = paginatedItems.items;
              });
            },
          );
        }
      } catch (e) {
        print('Exception loading items for ${category.title}: $e');
        if (mounted) {
          setState(() {
            _categoryItemsCache[category.id] = [];
          });
        }
      }
    }

    if (mounted) {
      setState(() => _isLoadingItems = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: Consumer2<CategoriesProvider, StatisticsProvider>(
            builder: (context, categoriesProvider, statisticsProvider, child) {
              if (categoriesProvider.status == CategoriesStatus.initial ||
                  categoriesProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (categoriesProvider.status == CategoriesStatus.error) {
                return _buildErrorState(categoriesProvider.errorMessage);
              }

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),

                      // Statistics Overview
                      if (statisticsProvider.statistics != null)
                        StatisticsOverview(
                          statistics: statisticsProvider.statistics!,
                        ),

                      const SizedBox(height: 32),

                      // Categories Section
                      _buildCategoriesSection(categoriesProvider.categories),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good morning';
    } else if (hour < 17) {
      greeting = 'Good afternoon';
    } else {
      greeting = 'Good evening';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Ready to style today?',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildCategoriesSection(List<Category> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My Wardrobe',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            IconButton(
              onPressed: () => _showAddCategoryDialog(),
              icon: const Icon(
                Icons.add_circle_outline,
                color: AppTheme.primaryColor,
                size: 28,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (categories.isEmpty)
          _buildEmptyCategoriesState()
        else
          _buildCategoriesGrid(categories),
      ],
    );
  }

  Widget _buildCategoriesGrid(List<Category> categories) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final previewItems = _categoryItemsCache[category.id] ?? [];

        return CategoryCardWithPreview(
          category: category,
          previewItems: previewItems,
          isLoadingItems: _isLoadingItems,
          onTap: () => _navigateToCategoryItems(category),
          onDelete:
              category.isDefault ? null : () => _deleteCategory(category.id),
        );
      },
    );
  }

  Widget _buildEmptyCategoriesState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.inputBorder),
      ),
      child: Column(
        children: [
          Icon(
            Icons.category_outlined,
            size: 64,
            color: AppTheme.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Categories Yet',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 18,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first category to organize your wardrobe',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String? errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppTheme.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 18,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage ?? 'Unknown error occurred',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddCategoryDialog(),
    ).then((_) {
      // Reload categories after dialog closes
      final categoriesProvider = context.read<CategoriesProvider>();
      _loadCategoryItems(categoriesProvider.categories);
    });
  }

  void _navigateToCategoryItems(Category category) {
    // Navigate to CategoryItemsScreen (NOT the main Wardrobe tab)
    context.push('/category-items/${category.id}/${category.title}');
  }

  void _deleteCategory(String categoryId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Delete Category'),
        content: const Text(
          'Are you sure you want to delete this category? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await context
                  .read<CategoriesProvider>()
                  .deleteCategory(categoryId);

              // Show feedback
              if (mounted) {
                final provider = context.read<CategoriesProvider>();
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
                      content: Text('Category deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  // Reload data
                  _loadData();
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

// Category Card Widget with Item Preview
class CategoryCardWithPreview extends StatelessWidget {
  final Category category;
  final List<Item> previewItems;
  final bool isLoadingItems;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const CategoryCardWithPreview({
    super.key,
    required this.category,
    required this.previewItems,
    required this.isLoadingItems,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.inputBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Preview Grid (2x2)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: isLoadingItems
                    ? const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : _buildPreviewGrid(),
              ),
            ),

            Padding(
              padding:
                  const EdgeInsets.only(left: 12, right: 12, bottom: 8, top: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${category.itemCount} items',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onDelete != null)
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        size: 20,
                        color: AppTheme.textSecondary.withOpacity(0.6),
                      ),
                      onSelected: (value) {
                        if (value == 'delete' && onDelete != null) {
                          onDelete!();
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red, size: 18),
                              SizedBox(width: 8),
                              Text('Delete',
                                  style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewGrid() {
    final itemsToShow = previewItems.take(4).toList();

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        if (index < itemsToShow.length) {
          return _buildItemPreview(itemsToShow[index]);
        } else {
          return _buildPlaceholder();
        }
      },
    );
  }

  Widget _buildItemPreview(Item item) {
    print('Building preview for item: ${item.name}, URL: ${item.imageUrl}');

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        child: CachedNetworkImage(
          imageUrl: item.imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) {
            print('Loading image: $url');
            return Container(
              color: AppTheme.backgroundColor,
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          },
          errorWidget: (context, url, error) {
            print('Error loading image: $url, Error: $error');
            return Container(
              color: AppTheme.backgroundColor,
              child: Icon(
                Icons.image_not_supported,
                size: 24,
                color: AppTheme.textSecondary.withOpacity(0.5),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.inputBorder,
          width: 1,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.add_photo_alternate_outlined,
          size: 24,
          color: AppTheme.textSecondary.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildStatBadge(String text, Color backgroundColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }
}
