import 'package:flutter/material.dart';
import 'package:up_style/core/config/upstyle_config.dart';
import 'package:up_style/core/theme/app_theme.dart';

class UpcyclePromptDialog extends StatefulWidget {
  const UpcyclePromptDialog({super.key});

  @override
  State<UpcyclePromptDialog> createState() => _UpcyclePromptDialogState();
}

class _UpcyclePromptDialogState extends State<UpcyclePromptDialog> {
  final _controller = TextEditingController();
  bool _useDefault = true;

  @override
  void initState() {
    super.initState();
    _controller.text = UpstyleConfig.defaultUpcyclePrompt;
  }

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
        '🌿 Upcycle This Item',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tell us what you\'d like to create from this item. Our AI will generate personalized upcycling ideas!',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 20),

            // Default prompt checkbox
            CheckboxListTile(
              value: _useDefault,
              onChanged: (value) {
                setState(() {
                  _useDefault = value ?? true;
                  if (_useDefault) {
                    _controller.text = UpstyleConfig.defaultUpcyclePrompt;
                  } else {
                    _controller.text = '';
                  }
                });
              },
              title: const Text('Use default prompt'),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            ),

            const SizedBox(height: 12),

            // Custom prompt input
            TextField(
              controller: _controller,
              enabled: !_useDefault,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Describe what you want to create...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Info text
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This process may take 30-60 seconds',
                      style: TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final prompt = _controller.text.trim();
            if (prompt.isNotEmpty) {
              Navigator.of(context).pop(prompt);
            }
          },
          child: const Text('Generate Ideas'),
        ),
      ],
    );
  }
}
