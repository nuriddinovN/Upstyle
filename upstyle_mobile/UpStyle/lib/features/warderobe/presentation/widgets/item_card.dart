// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:up_style/core/theme/app_theme.dart';
import 'package:up_style/features/warderobe/domain/entities/item.dart';

class ItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const ItemCard({
    super.key,
    required this.item,
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
            // Image section
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: item.imageUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppTheme.backgroundColor,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppTheme.backgroundColor,
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 40,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Badges overlay
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Column(
                        children: [
                          if (item.isUpcycled) _buildBadge('🌿', Colors.green),
                          if (item.isUpStyled) const SizedBox(height: 4),
                          if (item.isUpStyled) _buildBadge('✨', Colors.purple),
                        ],
                      ),
                    ),

                    // Color indicator
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: _getColorFromString(item.color),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content section
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Item name
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Description
                    Expanded(
                      child: Text(
                        item.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary.withOpacity(0.8),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Bottom row with color name and menu
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.color,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                        // if (onDelete != null)
                        //   GestureDetector(
                        //     onTap: (event) {
                        //       // Prevent tap from bubbling up to parent
                        //       onDelete!();
                        //     },
                        //     child: Icon(
                        //       Icons.more_vert,
                        //       size: 16,
                        //       color: AppTheme.textSecondary.withOpacity(0.6),
                        //     ),
                        //   ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String emoji, Color color) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 12),
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
      case 'gray':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
