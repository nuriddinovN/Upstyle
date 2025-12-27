import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/creators_provider.dart';
import '../../../../features/auth/presentation/provider/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';

class BecomeCreatorScreen extends StatefulWidget {
  const BecomeCreatorScreen({super.key});

  @override
  State<BecomeCreatorScreen> createState() => _BecomeCreatorScreenState();
}

class _BecomeCreatorScreenState extends State<BecomeCreatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bioController = TextEditingController();

  final List<String> _allSpecializations = [
    'Upcycling',
    'Upstyling',
    'Repairs',
    'Tailoring',
    'Embroidery',
    'Patchwork',
    'Denim Work',
    'Vintage Restoration',
    'Sustainable Fashion',
  ];

  final List<String> _selectedSpecializations = [];

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Become a Creator',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor.withOpacity(0.1),
                      Colors.purple.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.star,
                      size: 48,
                      color: Colors.amber[700],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Help Others Transform Their Wardrobe',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Share your expertise in upcycling and upstyling with the community',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Bio Field
              const Text(
                'Tell us about yourself',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _bioController,
                maxLines: 4,
                maxLength: 200,
                decoration: const InputDecoration(
                  hintText:
                      'Share your experience and what makes you passionate about sustainable fashion...',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please tell us about yourself';
                  }
                  if (value.trim().length < 20) {
                    return 'Please write at least 20 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Specializations
              const Text(
                'Your Specializations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select at least 2 areas where you can help',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 16),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _allSpecializations.map((spec) {
                  final isSelected = _selectedSpecializations.contains(spec);
                  return FilterChip(
                    label: Text(spec),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedSpecializations.add(spec);
                        } else {
                          _selectedSpecializations.remove(spec);
                        }
                      });
                    },
                    selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                    checkmarkColor: AppTheme.primaryColor,
                  );
                }).toList(),
              ),

              if (_selectedSpecializations.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${_selectedSpecializations.length} selected',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

              const SizedBox(height: 40),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: Consumer<CreatorsProvider>(
                  builder: (context, provider, child) {
                    return ElevatedButton(
                      onPressed: provider.status == CreatorsStatus.loading
                          ? null
                          : _submitForm,
                      child: provider.status == CreatorsStatus.loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Become a Creator'),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Benefits
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Creator Benefits:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildBenefit('Help others transform their wardrobe'),
                    _buildBenefit('Build your reputation in the community'),
                    _buildBenefit('Connect with sustainability enthusiasts'),
                    _buildBenefit('Share your creative ideas'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefit(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: Colors.green[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedSpecializations.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least 2 specializations'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final creatorsProvider = context.read<CreatorsProvider>();

    final success = await creatorsProvider.becomeCreator(
      bio: _bioController.text.trim(),
      specializations: _selectedSpecializations,
    );

    if (!mounted) return;

    if (success) {
      // Reload user
      await context.read<AuthProvider>().refreshUser();

      if (!mounted) return;

      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.star, color: Colors.amber[700]),
              const SizedBox(width: 12),
              const Text('Welcome, Creator!'),
            ],
          ),
          content: const Text(
            'You are now a creator! You can switch between User and Creator modes in your profile.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Return to profile
              },
              child: const Text('Got it!'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ${creatorsProvider.errorMessage}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
