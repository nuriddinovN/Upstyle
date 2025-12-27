import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:up_style/core/constants/app_colors.dart';
import 'package:up_style/core/theme/app_theme.dart';
import 'package:up_style/features/home/presentation/provider/categories_provider.dart';
import 'package:up_style/features/warderobe/domain/entities/item.dart';
import 'package:up_style/features/warderobe/presentation/provider/item_provider.dart';
import 'package:up_style/features/warderobe/presentation/screens/upcycle_ideas_selection_screen.dart';
import 'package:up_style/features/warderobe/presentation/widgets/upcycle_prompt_dialog.dart';
import 'package:up_style/service/upcycle/upcycle_models.dart';

class ItemDetailScreen extends StatefulWidget {
  final String itemId;

  const ItemDetailScreen({super.key, required this.itemId});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  Item? _item;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItem();
  }

  Future<void> _loadItem() async {
    final itemsProvider = context.read<ItemsProvider>();
    final item = await itemsProvider.getItemById(widget.itemId);

    if (mounted) {
      setState(() {
        _item = item;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_item == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: AppTheme.textPrimary,
          title: const Text('Item Not Found'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(
          child: Text('This item could not be found.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // App bar with image
          _buildSliverAppBar(),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item info
                  _buildItemInfo(),
                  const SizedBox(height: 24),

                  // Categories and badges
                  _buildBadges(),
                  const SizedBox(height: 32),

                  // Transform actions
                  _buildTransformActions(),
                  const SizedBox(height: 32),

                  // Additional actions
                  _buildAdditionalDetails(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.white,
      foregroundColor: AppTheme.textPrimary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: 'item_${_item!.id}',
          child: CachedNetworkImage(
            imageUrl: _item!.imageUrl,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: AppTheme.backgroundColor,
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              color: AppTheme.backgroundColor,
              child: const Center(
                child: Icon(
                  Icons.image_not_supported,
                  size: 60,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          ),
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'delete':
                _showDeleteDialog();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red, size: 18),
                  SizedBox(width: 8),
                  Text('Delete Item', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildItemInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _item!.name,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          _item!.description,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
        ),
      ],
    );
  }

  Widget _buildBadges() {
    return Consumer<CategoriesProvider>(
      builder: (context, categoriesProvider, child) {
        final category = categoriesProvider.getCategoryById(_item!.categoryId);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category and Color info
            Row(
              children: [
                _buildInfoChip(
                  icon: Icons.category,
                  label: category?.title ?? 'Unknown',
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 12),
                _buildInfoChip(
                  icon: Icons.palette,
                  label: _item!.color,
                  color: _getColorFromString(_item!.color),
                ),
              ],
            ),

            if (_item!.isUpcycled || _item!.isUpStyled) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (_item!.isUpcycled)
                    _buildInfoChip(
                      icon: Icons.recycling,
                      label: 'Upcycled',
                      color: Colors.green,
                    ),
                  if (_item!.isUpStyled) ...[
                    if (_item!.isUpcycled) const SizedBox(width: 12),
                    _buildInfoChip(
                      icon: Icons.auto_awesome,
                      label: 'Upstyled',
                      color: Colors.purple,
                    ),
                  ],
                ],
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransformActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transform Your Item',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Use AI to get creative suggestions for your wardrobe',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
        const SizedBox(height: 20),
        Consumer<ItemsProvider>(
          builder: (context, itemsProvider, child) {
            return Column(
              children: [
                // Upcycle button
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: itemsProvider.isTransforming
                        ? null
                        : () => _showUpcyclePromptDialog(itemsProvider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: itemsProvider.isTransforming
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.recycling, size: 24),
                              SizedBox(width: 12),
                              Text(
                                'Upcycle This Item',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                // Upstyle button (disabled)
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: null, // Disabled
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.withOpacity(0.5),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome, size: 24),
                        SizedBox(width: 12),
                        Text(
                          'Upstyle This Item (Coming Soon)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildAdditionalDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Item Details',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),
        _buildDetailRow('Added', _formatDate(_item!.createdAt)),
        _buildDetailRow('Last Updated', _formatDate(_item!.updatedAt)),
        if (_item!.originalItemId != null)
          _buildDetailRow('Type', 'Transformed Item'),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorFromString(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'pink':
        return Colors.pink;
      case 'brown':
        return Colors.brown;
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      case 'grey':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _showUpcyclePromptDialog(ItemsProvider itemsProvider) async {
    final userPrompt = await showDialog<String>(
      context: context,
      builder: (context) => const UpcyclePromptDialog(),
    );

    if (userPrompt != null && mounted) {
      await _upcycleItemWithPrompt(itemsProvider, userPrompt);
    }
  }

  Future<void> _upcycleItemWithPrompt(
    ItemsProvider itemsProvider,
    String userPrompt,
  ) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Generating upcycling ideas...'),
                  SizedBox(height: 8),
                  Text(
                    'This may take 60-90 seconds',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Generate ideas with images
      final ideasWithImages = await itemsProvider.generateUpcyclingIdeas(
        _item!.id,
        userPrompt: userPrompt,
      );

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      if (ideasWithImages != null && mounted) {
        // Show selection screen
        final selectedIdea =
            await Navigator.of(context).push<UpcyclingIdeaWithImage>(
          MaterialPageRoute(
            builder: (context) => UpcycleIdeasSelectionScreen(
              ideasWithImages: ideasWithImages,
            ),
          ),
        );

        if (selectedIdea != null && mounted) {
          // Show saving dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Saving your upcycled item...'),
                    ],
                  ),
                ),
              ),
            ),
          );

          // Save selected idea
          final newItem = await itemsProvider.saveSelectedUpcyclingIdea(
            _item!.id,
            selectedIdea,
          );

          // Close saving dialog
          if (mounted) Navigator.of(context).pop();

          if (newItem != null && mounted) {
            _showTransformSuccessDialog(
              'Upcycled',
              'Your item has been successfully upcycled!',
              newItem,
            );
          } else if (itemsProvider.errorMessage != null && mounted) {
            _showErrorSnackBar(itemsProvider.errorMessage!);
          }
        }
      } else if (itemsProvider.errorMessage != null && mounted) {
        _showErrorSnackBar(itemsProvider.errorMessage!);
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close any open dialogs
        _showErrorSnackBar('Failed to generate ideas: $e');
      }
    }
  }

  Future<void> _upcycleItem(ItemsProvider itemsProvider) async {
    final newItem = await itemsProvider.upcycleItem(_item!.id);

    if (newItem != null && mounted) {
      _showTransformSuccessDialog(
        'Upcycled',
        'Your item has been successfully upcycled with eco-friendly suggestions!',
        newItem,
      );
    } else if (itemsProvider.errorMessage != null && mounted) {
      _showErrorSnackBar(itemsProvider.errorMessage!);
    }
  }

  Future<void> _upstyleItem(ItemsProvider itemsProvider) async {
    final newItem = await itemsProvider.upstyleItem(_item!.id);

    if (newItem != null && mounted) {
      _showTransformSuccessDialog(
        'Upstyled',
        'Your item has been successfully upstyled with fresh styling ideas!',
        newItem,
      );
    } else if (itemsProvider.errorMessage != null && mounted) {
      _showErrorSnackBar(itemsProvider.errorMessage!);
    }
  }

  void _showTransformSuccessDialog(String type, String message, Item newItem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text('$type Successfully! ✨'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Stay Here'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to the new item using go_router
              context.pushReplacement('/item-detail/${newItem.id}');
            },
            child: const Text('View New Item'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Delete Item'),
        content: const Text(
            'Are you sure you want to delete this item? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteItem();
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

  Future<void> _deleteItem() async {
    final itemsProvider = context.read<ItemsProvider>();
    await itemsProvider.deleteItem(_item!.id);

    if (mounted) {
      if (itemsProvider.errorMessage == null) {
        // Navigate back to wardrobe
        context.pop();
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item deleted successfully'),
            backgroundColor: AppColors.primaryBlue,
          ),
        );
      } else {
        _showErrorSnackBar(itemsProvider.errorMessage!);
      }
    }
  }
}
