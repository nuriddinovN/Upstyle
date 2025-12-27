import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:up_style/core/theme/app_theme.dart';
import 'package:up_style/features/home/presentation/provider/categories_provider.dart';

class AddCategoryDialog extends StatefulWidget {
  const AddCategoryDialog({super.key});

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text(
        'Add Category',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create a new category to organize your wardrobe items.',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                hintText: 'e.g., Shoes, Bags, Jackets',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a category name';
                }
                if (value.length > 50) {
                  return 'Category name must be 50 characters or less';
                }
                return null;
              },
              textCapitalization: TextCapitalization.words,
              autofocus: true,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        Consumer<CategoriesProvider>(
          builder: (context, categoriesProvider, child) {
            return ElevatedButton(
              onPressed: categoriesProvider.isLoading
                  ? null
                  : () => _createCategory(categoriesProvider),
              child: categoriesProvider.isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create'),
            );
          },
        ),
      ],
    );
  }

  Future<void> _createCategory(CategoriesProvider categoriesProvider) async {
    if (!_formKey.currentState!.validate()) return;

    final title = _controller.text.trim();

    await categoriesProvider.createCategory(title);

    if (categoriesProvider.errorMessage == null) {
      Navigator.of(context).pop();
      _showSuccessSnackBar();
    } else {
      _showErrorSnackBar(categoriesProvider.errorMessage!);
    }
  }

  void _showSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Category created successfully'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
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
}
