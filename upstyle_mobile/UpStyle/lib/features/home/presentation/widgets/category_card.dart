// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:up_style/core/theme/app_theme.dart';
import 'package:up_style/features/home/domain/entities/category.dart';
import 'package:up_style/features/warderobe/domain/entities/item.dart';

class CategoryCard extends StatelessWidget {
  final Category category;
  final List<Item> previewItems; // Items to show as preview
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const CategoryCard({
    super.key,
    required this.category,
    required this.previewItems,
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
            // Header with title and menu
            Padding(
              padding: const EdgeInsets.all(8),
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
                        const SizedBox(height: 4),
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

            // Image Preview Grid (2x2)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: _buildPreviewGrid(),
              ),
            ),

            // Footer with stats
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (category.upcycledCount > 0)
                    _buildStatBadge(
                      '🌿 ${category.upcycledCount}',
                      Colors.green.withOpacity(0.1),
                      Colors.green,
                    ),
                  if (category.upstyledCount > 0)
                    _buildStatBadge(
                      '✨ ${category.upstyledCount}',
                      Colors.purple.withOpacity(0.1),
                      Colors.purple,
                    ),
                  if (category.isDefault)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Default',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.primaryColor,
                        ),
                      ),
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
    // Take up to 4 items for preview
    final itemsToShow = previewItems.take(4).toList();
    final remainingSlots = 4 - itemsToShow.length;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: item.imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: AppTheme.backgroundColor,
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: AppTheme.backgroundColor,
          child: Icon(
            Icons.image_not_supported,
            size: 24,
            color: AppTheme.textSecondary.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(8),
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
