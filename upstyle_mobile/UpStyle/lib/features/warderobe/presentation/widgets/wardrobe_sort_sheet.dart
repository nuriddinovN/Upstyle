import 'package:flutter/material.dart';
import 'package:up_style/core/theme/app_theme.dart';
import 'package:up_style/features/warderobe/domain/entities/item.dart';

class WardrobeSortSheet extends StatelessWidget {
  final ItemSortOption currentSort;
  final Function(ItemSortOption) onSortChanged;

  const WardrobeSortSheet({
    super.key,
    required this.currentSort,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sort Items',
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

          // Sort options
          _buildSortOption(
            title: 'Newest First',
            subtitle: 'Recently added items appear first',
            icon: Icons.access_time,
            sortOption: ItemSortOption.dateDesc,
            context: context,
          ),
          _buildSortOption(
            title: 'Oldest First',
            subtitle: 'Older items appear first',
            icon: Icons.history,
            sortOption: ItemSortOption.dateAsc,
            context: context,
          ),
          _buildSortOption(
            title: 'Name (A-Z)',
            subtitle: 'Alphabetical order',
            icon: Icons.sort_by_alpha,
            sortOption: ItemSortOption.name,
            context: context,
          ),
          _buildSortOption(
            title: 'Color',
            subtitle: 'Grouped by color',
            icon: Icons.palette,
            sortOption: ItemSortOption.color,
            context: context,
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSortOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required ItemSortOption sortOption,
    required BuildContext context,
  }) {
    final isSelected = currentSort == sortOption;

    return ListTile(
      onTap: () {
        onSortChanged(sortOption);
        Navigator.of(context).pop();
      },
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withOpacity(0.1)
              : AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: AppTheme.textSecondary.withOpacity(0.8),
        ),
      ),
      trailing: isSelected
          ? Icon(
              Icons.check_circle,
              color: AppTheme.primaryColor,
            )
          : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
    );
  }
}
