import 'dart:io';
import 'package:flutter/material.dart';
import 'package:up_style/core/theme/app_theme.dart';
import 'package:up_style/service/upcycle/upcycle_models.dart';

class UpcycleIdeasSelectionScreen extends StatefulWidget {
  final List<UpcyclingIdeaWithImage> ideasWithImages;

  const UpcycleIdeasSelectionScreen({
    super.key,
    required this.ideasWithImages,
  });

  @override
  State<UpcycleIdeasSelectionScreen> createState() =>
      _UpcycleIdeasSelectionScreenState();
}

class _UpcycleIdeasSelectionScreenState
    extends State<UpcycleIdeasSelectionScreen> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Upcycling Idea'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Colors.green.shade50,
            child: Column(
              children: [
                Icon(Icons.lightbulb, size: 48, color: Colors.green.shade700),
                const SizedBox(height: 12),
                Text(
                  'AI Generated ${widget.ideasWithImages.length} Upcycling Ideas',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Select your favorite transformation',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),

          // Ideas List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.ideasWithImages.length,
              itemBuilder: (context, index) {
                final ideaWithImage = widget.ideasWithImages[index];
                final idea = ideaWithImage.idea;
                final isSelected = _selectedIndex == index;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: isSelected ? 8 : 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isSelected ? Colors.green : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  child: InkWell(
                    onTap: () => setState(() => _selectedIndex = index),
                    borderRadius: BorderRadius.circular(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: Image.file(
                            ideaWithImage.imageFile,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),

                        // Content
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title with selection indicator
                              Row(
                                children: [
                                  if (isSelected)
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 24,
                                    ),
                                  if (isSelected) const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${index + 1}. ${idea.title}',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? Colors.green.shade700
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // What to do
                              Text(
                                idea.whatWorkToDo,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Needed Items
                              const Text(
                                '🔧 What You Need:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...idea.neededItems.map(
                                (item) => Padding(
                                  padding:
                                      const EdgeInsets.only(left: 8, bottom: 4),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.check,
                                          size: 16, color: Colors.green),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text(item)),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Step by step (collapsed by default, expandable)
                              ExpansionTile(
                                title: const Text(
                                  '📋 Step-by-Step Guide',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                tilePadding: EdgeInsets.zero,
                                children: [
                                  ...idea.stepByStepProcess.asMap().entries.map(
                                        (entry) => Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 12),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: 28,
                                                height: 28,
                                                decoration: BoxDecoration(
                                                  color: Colors.green.shade100,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    '${entry.key + 1}',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          Colors.green.shade700,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                  child: Text(entry.value)),
                                            ],
                                          ),
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
              },
            ),
          ),

          // Bottom Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedIndex != null
                      ? () => Navigator.of(context).pop(
                            widget.ideasWithImages[_selectedIndex!],
                          )
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _selectedIndex != null
                        ? 'Create This Upcycled Item'
                        : 'Select an Idea First',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
