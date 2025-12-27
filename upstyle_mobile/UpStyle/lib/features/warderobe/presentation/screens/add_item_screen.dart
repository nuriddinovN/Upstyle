import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:up_style/core/theme/app_theme.dart';
import 'package:up_style/features/home/presentation/provider/categories_provider.dart';
import 'package:up_style/features/warderobe/data/models/fashionclip_models.dart';
import 'package:up_style/features/warderobe/presentation/provider/item_provider.dart';
import 'package:up_style/service/fashion_transform/fashion_clip_service.dart';

class AddItemScreenAI extends StatefulWidget {
  const AddItemScreenAI({super.key});

  @override
  State<AddItemScreenAI> createState() => _AddItemScreenAIState();
}

class _AddItemScreenAIState extends State<AddItemScreenAI> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final FashionCLIPService _fashionService = FashionCLIPService();

  File? _selectedImage;
  FashionAnalysis? _analysis;
  bool _isAnalyzing = false;
  String? _analysisError;

  @override
  void dispose() {
    _nameController.dispose();
    _fashionService.dispose();
    super.dispose();
  }

  // Helper method to safely uppercase nullable strings
  String _safeUpperCase(String? value, [String defaultValue = 'Unknown']) {
    return value?.toUpperCase() ?? defaultValue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Add New Item',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Step indicator
              _buildStepIndicator(),
              const SizedBox(height: 24),

              // Image picker section
              _buildImagePicker(),
              const SizedBox(height: 24),

              // Analysis section
              if (_isAnalyzing) _buildAnalyzingCard(),
              if (_analysisError != null) _buildErrorCard(),
              if (_analysis != null) ...[
                _buildAnalysisResults(),
                const SizedBox(height: 24),
                _buildNameField(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    int currentStep = 0;
    if (_selectedImage != null) currentStep = 1;
    if (_analysis != null) currentStep = 2;

    return Row(
      children: [
        _buildStepCircle(1, currentStep >= 1, 'Upload'),
        _buildStepLine(currentStep >= 2),
        _buildStepCircle(2, currentStep >= 2, 'Analyze'),
        _buildStepLine(currentStep >= 3),
        _buildStepCircle(3, currentStep >= 3, 'Save'),
      ],
    );
  }

  Widget _buildStepCircle(int step, bool isActive, String label) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppTheme.primaryColor : Colors.grey.shade300,
          ),
          child: Center(
            child: Text(
              '$step',
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? AppTheme.primaryColor : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 24),
        color: isActive ? AppTheme.primaryColor : Colors.grey.shade300,
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Item Photo',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Upload a clear photo of your clothing item',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.inputBorder,
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: _selectedImage != null
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          _selectedImage!,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_analysis == null)
                              ElevatedButton.icon(
                                onPressed: _analyzeImage,
                                icon: const Icon(Icons.auto_awesome, size: 20),
                                label: const Text('Analyze'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                ),
                              ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedImage = null;
                                  _analysis = null;
                                  _analysisError = null;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate,
                        size: 64,
                        color: AppTheme.primaryColor,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Tap to add a photo',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'AI will automatically analyze your item',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyzingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withOpacity(0.1),
            Colors.purple.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          const Text(
            'AI is analyzing your item...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This may take 10-20 seconds',
            style: TextStyle(
              color: AppTheme.textSecondary.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Analysis Failed',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _analysisError!,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _analyzeImage,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisResults() {
    if (_analysis == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Success header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.green.withOpacity(0.1),
                AppTheme.primaryColor.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.green.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Analysis Complete!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'AI has analyzed your item',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Main attributes
        const Text(
          'Item Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        _buildAttributeCard(
          'Category',
          _safeUpperCase(_analysis!.category),
          Icons.category,
          Colors.blue,
        ),
        _buildAttributeCard(
          'Sub-Category',
          _safeUpperCase(_analysis!.subCategory),
          Icons.label,
          Colors.purple,
        ),
        _buildAttributeCard(
          'Material',
          _safeUpperCase(_analysis!.material),
          Icons.texture,
          Colors.brown,
        ),
        _buildAttributeCard(
          'Primary Color',
          _safeUpperCase(_analysis!.primaryColor),
          Icons.palette,
          _getColorFromName(_safeUpperCase(_analysis!.primaryColor)),
        ),
        if (_analysis!.secondaryColor != null &&
            _analysis!.secondaryColor != 'none')
          _buildAttributeCard(
            'Secondary Color',
            _safeUpperCase(_analysis!.secondaryColor),
            Icons.palette_outlined,
            _getColorFromName(_safeUpperCase(_analysis!.secondaryColor)),
          ),
        _buildAttributeCard(
          'Pattern',
          _safeUpperCase(_analysis!.pattern),
          Icons.grid_on,
          Colors.orange,
        ),
        _buildAttributeCard(
          'Style',
          _safeUpperCase(_analysis!.style),
          Icons.style,
          Colors.pink,
        ),
        _buildAttributeCard(
          'Fit',
          _safeUpperCase(_analysis!.fit),
          Icons.straighten,
          Colors.teal,
        ),

        const SizedBox(height: 24),

        // Additional Details (Expandable)
        ExpansionTile(
          title: const Text(
            'More Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          children: [
            _buildDetailRow('Gender', _safeUpperCase(_analysis!.gender)),
            _buildDetailRow('Neckline', _safeUpperCase(_analysis!.neckline)),
            _buildDetailRow('Sleeve', _safeUpperCase(_analysis!.sleeve)),
            _buildDetailRow('Length', _safeUpperCase(_analysis!.length)),
            _buildDetailRow(
                'Silhouette', _safeUpperCase(_analysis!.silhouette)),
            _buildDetailRow('Closure', _safeUpperCase(_analysis!.closureType)),
            _buildDetailRow('Occasion', _safeUpperCase(_analysis!.occasion)),
            _buildDetailRow('Season', _safeUpperCase(_analysis!.season)),
            _buildDetailRow(
                'Aesthetic', _safeUpperCase(_analysis!.aestheticKeywords)),
          ],
        ),

        const SizedBox(height: 24),

        // Sustainability Info
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.green.withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.eco, color: Colors.green),
                  SizedBox(width: 8),
                  Text(
                    'Sustainability & Upcycling',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildDetailRow('Upcycling Potential',
                  _safeUpperCase(_analysis!.upcyclingPotential)),
              _buildDetailRow(
                  'Upcycling Type', _safeUpperCase(_analysis!.upcyclingType)),
              _buildDetailRow(
                  'Repairability', _safeUpperCase(_analysis!.repairability)),
              _buildDetailRow(
                  'Sustainability', _safeUpperCase(_analysis!.sustainability)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAttributeCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.inputBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Item Name',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            hintText: 'e.g., Blue Denim Jacket',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter an item name';
            }
            return null;
          },
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: Consumer<ItemsProvider>(
            builder: (context, itemsProvider, child) {
              return ElevatedButton.icon(
                onPressed: itemsProvider.isLoading ? null : _showCategoryPicker,
                icon: const Icon(Icons.folder_open),
                label: itemsProvider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Add to Category'),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getColorFromName(String colorName) {
    final name = colorName.toLowerCase();
    if (name.contains('red')) return Colors.red;
    if (name.contains('blue')) return Colors.blue;
    if (name.contains('green')) return Colors.green;
    if (name.contains('yellow')) return Colors.yellow;
    if (name.contains('orange')) return Colors.orange;
    if (name.contains('purple')) return Colors.purple;
    if (name.contains('pink')) return Colors.pink;
    if (name.contains('brown')) return Colors.brown;
    if (name.contains('black')) return Colors.black;
    if (name.contains('white')) return Colors.white;
    if (name.contains('grey') || name.contains('gray')) return Colors.grey;
    if (name.contains('navy')) return Colors.indigo;
    if (name.contains('teal')) return Colors.teal;
    return Colors.grey;
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.of(context).pop();
                _getImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.of(context).pop();
                _getImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _analysis = null;
          _analysisError = null;
        });

        // Automatically start analysis
        _analyzeImage();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isAnalyzing = true;
      _analysisError = null;
    });

    try {
      final analysis = await _fashionService.analyzeImage(_selectedImage!);

      setState(() {
        _analysis = analysis;
        _isAnalyzing = false;
        // Generate a default name
        _nameController.text =
            '${_safeUpperCase(analysis.subCategory, '')} ${_safeUpperCase(analysis.style, '')}'
                .trim();
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✨ Item analyzed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
        _analysisError = e.toString();
      });
    }
  }

  // Show bottom sheet to select or create category
  Future<void> _showCategoryPicker() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImage == null || _analysis == null) return;

    final categoriesProvider = context.read<CategoriesProvider>();
    final categories = categoriesProvider.categories;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Select Category',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(height: 1),
              // Create new category option
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: AppTheme.primaryColor,
                  ),
                ),
                title: const Text(
                  'Create New Category',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showCreateCategoryDialog();
                },
              ),
              const Divider(height: 1),
              // Existing categories
              Expanded(
                child: categories.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            'No categories yet.\nCreate your first category!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          return ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.folder,
                                color: Colors.blue,
                              ),
                            ),
                            title: Text(
                              category.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text('${category.itemCount} items'),
                            onTap: () {
                              Navigator.pop(context);
                              _saveItemToCategory(category.id, category.title);
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Show dialog to create new category
  Future<void> _showCreateCategoryDialog() async {
    final categoryController = TextEditingController(
      text: _analysis?.getCategoryName() ?? '',
    );

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Category'),
        content: TextField(
          controller: categoryController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter category name',
            labelText: 'Category Name',
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = categoryController.text.trim();
              if (name.isNotEmpty) {
                Navigator.pop(context, name);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );

    categoryController.dispose();

    if (result != null && result.isNotEmpty) {
      await _createAndSaveToCategory(result);
    }
  }

  // Create new category and save item
  Future<void> _createAndSaveToCategory(String categoryName) async {
    final categoriesProvider = context.read<CategoriesProvider>();

    try {
      print('📁 Creating new category: $categoryName');

      await categoriesProvider.createCategory(categoryName);
      await categoriesProvider.loadCategories();

      final category = categoriesProvider.categories.firstWhere(
        (cat) => cat.title.toLowerCase() == categoryName.toLowerCase(),
        orElse: () => throw Exception('Failed to create category'),
      );

      print('✅ Category created with ID: ${category.id}');

      await _saveItemToCategory(category.id, category.title);
    } catch (e) {
      print('❌ Error creating category: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Failed to create category: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // Save item to selected category
  Future<void> _saveItemToCategory(
      String categoryId, String categoryTitle) async {
    if (_selectedImage == null || _analysis == null) return;

    final itemsProvider = context.read<ItemsProvider>();

    try {
      print('💾 Saving item to category: $categoryTitle ($categoryId)');

      await itemsProvider.createItemWithAnalysis(
        name: _nameController.text.trim(),
        description: _analysis!.generateDescription(),
        categoryId: categoryId,
        color: _analysis!.primaryColor ?? 'unknown',
        imageFile: _selectedImage!,
        analysis: _analysis!,
      );

      if (itemsProvider.errorMessage == null) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✨ ${_nameController.text} saved to $categoryTitle!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Navigate back
        Navigator.of(context).pop();
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${itemsProvider.errorMessage}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('❌ Error saving item: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
