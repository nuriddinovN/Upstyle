import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:up_style/core/theme/app_theme.dart';
import 'package:up_style/features/home/presentation/provider/categories_provider.dart';
import 'package:up_style/features/warderobe/domain/entities/item.dart';

class WardrobeFilterSheet extends StatefulWidget {
  final ItemFilter currentFilter;
  final Function(ItemFilter) onFilterChanged;

  const WardrobeFilterSheet({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  State<WardrobeFilterSheet> createState() => _WardrobeFilterSheetState();
}

class _WardrobeFilterSheetState extends State<WardrobeFilterSheet> {
  late ItemFilter _filter;

  final List<String> _colors = [
    'Red',
    'Blue',
    'Green',
    'Yellow',
    'Orange',
    'Purple',
    'Pink',
    'Brown',
    'Black',
    'White',
    'Grey'
  ];

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Items',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Category Filter
          _buildCategoryFilter(),
          const SizedBox(height: 24),

          // Color Filter
          _buildColorFilter(),
          const SizedBox(height: 24),

          // Type Filter
          _buildTypeFilter(),
          const SizedBox(height: 32),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _clearFilters,
                  child: const Text('Clear All'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Consumer<CategoriesProvider>(
          builder: (context, categoriesProvider, child) {
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // All categories option
                _buildFilterChip(
                  label: 'All',
                  isSelected: _filter.categoryId == null,
                  onTap: () {
                    setState(() {
                      _filter = _filter.copyWith(categoryId: null);
                    });
                  },
                ),
                // Individual categories
                ...categoriesProvider.categories.map(
                  (category) => _buildFilterChip(
                    label: category.title,
                    isSelected: _filter.categoryId == category.id,
                    onTap: () {
                      setState(() {
                        _filter = _filter.copyWith(categoryId: category.id);
                      });
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildColorFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Color',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // All colors option
            _buildFilterChip(
              label: 'All',
              isSelected: _filter.color == null,
              onTap: () {
                setState(() {
                  _filter = _filter.copyWith(color: null);
                });
              },
            ),
            // Individual colors
            ..._colors.map(
              (color) => _buildColorChip(
                color: color,
                isSelected: _filter.color == color,
                onTap: () {
                  setState(() {
                    _filter = _filter.copyWith(color: color);
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: [
            CheckboxListTile(
              title: const Text('Upcycled Only'),
              subtitle: const Text('Show only upcycled items'),
              value: _filter.onlyUpcycled == true,
              onChanged: (value) {
                setState(() {
                  _filter = _filter.copyWith(onlyUpcycled: value);
                });
              },
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            ),
            CheckboxListTile(
              title: const Text('Upstyled Only'),
              subtitle: const Text('Show only upstyled items'),
              value: _filter.onlyUpStyled == true,
              onChanged: (value) {
                setState(() {
                  _filter = _filter.copyWith(onlyUpStyled: value);
                });
              },
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.inputBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildColorChip({
    required String color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.inputBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: _getColorFromString(color),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              color,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
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

  void _clearFilters() {
    setState(() {
      _filter = const ItemFilter();
    });
  }

  void _applyFilters() {
    widget.onFilterChanged(_filter);
    Navigator.of(context).pop();
  }
}
