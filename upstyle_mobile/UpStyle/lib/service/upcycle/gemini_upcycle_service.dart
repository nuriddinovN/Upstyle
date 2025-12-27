import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:up_style/core/config/upstyle_config.dart';
import 'package:up_style/service/upcycle/upcycle_models.dart';

class GeminiUpcycleService {
  late final GenerativeModel _visionModel;
  late final GenerativeModel _textModel;

  GeminiUpcycleService() {
    _visionModel = GenerativeModel(
      model: 'gemini-2.0-flash-exp',
      apiKey: UpstyleConfig.geminiApiKey,
    );

    _textModel = GenerativeModel(
      model: 'gemini-2.0-flash-exp',
      apiKey: UpstyleConfig.geminiApiKey,
    );
  }

  static const String _systemPrompt =
      """You are an expert sustainable fashion designer and upcycling specialist with deep knowledge of:
- Clothing construction and garment transformation
- Material properties and durability
- Trendy, aesthetic fashion styles
- Practical DIY techniques accessible to beginners
- Sustainable and eco-friendly practices
Your expertise spans transforming worn, outdated, or unwanted clothing into fashionable, functional items.""";

  static const String _visionAnalysisPrompt =
      """Analyze this clothing item image in detail and provide insights that will help generate upcycling ideas.
Focus on:
1. Material texture and quality (appears to be cotton, silk, denim, wool, etc.)
2. Visible wear patterns, stains, or damage areas
3. Color vibrancy and condition
4. Stitching quality and construction
5. Unique design elements that could be repurposed
6. Overall usability for transformation
Provide a concise technical analysis that will inform creative upcycling possibilities.""";

  static const String _upcyclingGenerationPrompt =
      """You are tasked with generating exactly 4 personalized upcycling ideas for a clothing item.

## ITEM DETAILS (From Image Analysis + Metadata)
{metadata_context}

## USER PREFERENCES
{user_preferences}

## YOUR TASK
Generate EXACTLY 4 creative, actionable upcycling ideas that:
✅ Match the item's material and condition
✅ Align with the user's stated preferences
✅ Are realistic for DIY without expensive tools
✅ Transform the item into something fashionable, functional, or both
✅ Vary in difficulty (mix easy and medium complexity)

## OUTPUT FORMAT (STRICT - Return ONLY valid JSON, no extra text)
Return a JSON array with exactly 4 objects. Each object must have this exact structure:
{{
  "title": "Creative, short, clickable title for the upcycling idea",
  "needed_items": [
    "Scissors",
    "Thread and needle",
    "Elastic band"
  ],
  "what_work_to_do": "A clear 1-2 sentence explanation of the transformation and its purpose.",
  "step_by_step_process": [
    "Step 1: First action with specific details (measurements, techniques)",
    "Step 2: Second action (cutting/sewing details)",
    "Step 3: Third action (construction phase)",
    "Step 4: Fourth action (assembly or joining)",
    "Step 5: Final action (finishing touches and styling tips)"
  ]
}}

## GUIDELINES
- Keep language clear, actionable, and encouraging
- Suggest tools that are commonly available (scissors, needle, thread, fabric glue, elastic, buttons)
- Include measurements and specific techniques when relevant
- Adapt suggestions to the item's material
- Adapt to condition (if damaged, suggest using intact areas only)
- Ensure variety: mix wearable items, accessories, and home goods
- Each idea should take 1-4 hours to complete
- Make ideas sustainable and zero-waste focused
- Be enthusiastic in tone

## FINAL OUTPUT
Return ONLY a valid JSON array with 4 objects. Example:
[
  {{
    "title": "Minimalist Tote Bag",
    "needed_items": ["Scissors", "Needle and thread"],
    "what_work_to_do": "Transform the shirt into a practical tote bag for groceries.",
    "step_by_step_process": ["Step 1: ...", "Step 2: ..."]
  }},
  ...
]
IMPORTANT: Return ONLY the JSON array. No introduction, explanation, or additional text.""";

  static const String _productGenerationSystemPrompt =
      """You are an expert fashion designer and product visualizer specializing in upcycled fashion.
Your task is to visualize and generate realistic images of clothing items and accessories after they have been 
transformed according to specific upcycling instructions. 
Create photorealistic, professional-quality images that show:
- The exact result described in the upcycling idea
- Proper proportions and realistic materials
- Professional styling and presentation
- The final product in a clean, well-lit setting
- High quality that looks like product photography""";

  static const String _productGenerationPrompt =
      """Based on the original clothing item image provided and the detailed upcycling idea below,
generate a photorealistic image of the FINAL TRANSFORMED PRODUCT.

## ORIGINAL ITEM CONTEXT
The image shows the original clothing item that will be transformed.

## UPCYCLING IDEA DETAILS
Title: {idea_title}
Needed Items: {needed_items}
What Work to Do: {what_work_to_do}
Step-by-Step Process: {step_by_step_process}

## YOUR TASK
Create a photorealistic, professional-quality image showing the FINAL RESULT after completing all the steps.

## GUIDELINES
- Generate the exact product described (not the process, but the finished item)
- Show the item in a clean, professional setting suitable for product photography
- Use realistic lighting and shadows
- Display the item in a way that clearly shows its design and functionality
- Maintain high quality and realistic material textures
- Include any specific colors, patterns, or details mentioned
- If it's a wearable item, show it professionally styled
- If it's a home decor or kitchen item, show it in an appropriate setting
- Make it look like professional product photography
- Do NOT show the transformation process, only the final product
- Do NOT include the original shirt or materials, only the finished item

Generate the final product image now.""";

  Future<String> _analyzeImage(Uint8List imageBytes) async {
    try {
      final imagePart = DataPart('image/jpeg', imageBytes);
      final prompt = TextPart(_visionAnalysisPrompt);

      final response = await _visionModel.generateContent([
        Content.multi([prompt, imagePart])
      ]);

      return response.text ?? 'Unable to analyze image in detail';
    } catch (e) {
      print('Vision analysis error: $e');
      return 'Unable to analyze image in detail';
    }
  }

  Future<List<UpcyclingIdea>> generateIdeas({
    required Uint8List imageBytes,
    required String userPrompt,
    required Map<String, dynamic> metadata,
  }) async {
    try {
      print('🔍 Step 1: Analyzing image with Vision model...');

      // Analyze image first
      final visionAnalysis = await _analyzeImage(imageBytes);
      print('✅ Vision analysis complete');

      // Format metadata context
      final metadataContext = _formatMetadataContext(metadata, visionAnalysis);

      // Generate ideas
      print('💡 Step 2: Generating upcycling ideas...');
      final finalPrompt = _upcyclingGenerationPrompt
          .replaceAll('{metadata_context}', metadataContext)
          .replaceAll('{user_preferences}', userPrompt);

      final response = await _textModel.generateContent([
        Content.text(_systemPrompt),
        Content.text(finalPrompt),
      ]);

      final responseText = response.text;
      if (responseText == null) {
        throw Exception('No response from Gemini');
      }

      print('✅ Received response from Gemini');

      // Clean and parse JSON
      final cleanedJson = _cleanJsonResponse(responseText);
      final List<dynamic> ideasJson = jsonDecode(cleanedJson);

      if (ideasJson.length != 4) {
        throw Exception('Expected 4 ideas, got ${ideasJson.length}');
      }

      final ideas =
          ideasJson.map((json) => UpcyclingIdea.fromJson(json)).toList();

      print('✅ Parsed ${ideas.length} upcycling ideas');
      return ideas;
    } catch (e) {
      print('❌ Error generating ideas: $e');
      throw Exception('Failed to generate ideas: $e');
    }
  }

  Future<File> generateProductImage({
    required Uint8List originalImageBytes,
    required UpcyclingIdea selectedIdea,
  }) async {
    try {
      print('🎨 Generating product image for: ${selectedIdea.title}');

      // Format the prompt with idea details
      final neededItemsStr = selectedIdea.neededItems.join(', ');
      final stepsStr = selectedIdea.stepByStepProcess.join('\n');

      final systemPrompt = _productGenerationSystemPrompt;
      final finalPrompt = _productGenerationPrompt
          .replaceAll('{idea_title}', selectedIdea.title)
          .replaceAll('{needed_items}', neededItemsStr)
          .replaceAll('{what_work_to_do}', selectedIdea.whatWorkToDo)
          .replaceAll('{step_by_step_process}', stepsStr);

      // Convert image to base64
      final imageBase64 = base64Encode(originalImageBytes);

      // Call Gemini API directly via HTTP
      final response = await http.post(
        Uri.parse(
            'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-image:generateContent?key=${UpstyleConfig.geminiApiKey}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': systemPrompt},
                {'text': finalPrompt},
                {
                  'inline_data': {
                    'mime_type': 'image/jpeg',
                    'data': imageBase64,
                  }
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.4,
            'topK': 32,
            'topP': 1,
            'maxOutputTokens': 4096,
          }
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }

      final jsonResponse = jsonDecode(response.body);

      // Extract generated image from response
      if (jsonResponse['candidates'] != null &&
          jsonResponse['candidates'].isNotEmpty) {
        final candidate = jsonResponse['candidates'][0];

        if (candidate['content']?['parts'] != null) {
          for (final part in candidate['content']['parts']) {
            // Check for inline_data with image
            if (part['inlineData'] != null &&
                part['inlineData']['mimeType']
                        ?.toString()
                        .startsWith('image/') ==
                    true) {
              final imageData = part['inlineData']['data'] as String;
              final imageBytes = base64Decode(imageData);

              // Save to temporary file
              final tempDir = await getTemporaryDirectory();
              final timestamp = DateTime.now().millisecondsSinceEpoch;
              final file = File('${tempDir.path}/upcycled_$timestamp.png');

              await file.writeAsBytes(imageBytes);
              print('✅ Product image generated');

              return file;
            }
          }
        }
      }

      throw Exception('No image generated by Gemini');
    } catch (e) {
      print('❌ Error generating product image: $e');
      throw Exception('Failed to generate product image: $e');
    }
  }

  Future<List<UpcyclingIdeaWithImage>> generateProductImagesForAllIdeas({
    required Uint8List originalImageBytes,
    required List<UpcyclingIdea> ideas,
  }) async {
    print(
        '🎨 Step 3: Generating product images for all ${ideas.length} ideas...');

    final results = <UpcyclingIdeaWithImage>[];

    for (int i = 0; i < ideas.length; i++) {
      print(
          '🖼️  Generating image ${i + 1}/${ideas.length}: ${ideas[i].title}');

      try {
        final imageFile = await generateProductImage(
          originalImageBytes: originalImageBytes,
          selectedIdea: ideas[i],
        );

        results.add(UpcyclingIdeaWithImage(
          idea: ideas[i],
          imageFile: imageFile,
        ));

        print('✅ Image ${i + 1} generated successfully');

        // Small delay to avoid rate limiting
        if (i < ideas.length - 1) {
          await Future.delayed(const Duration(seconds: 2));
        }
      } catch (e) {
        print('⚠️  Failed to generate image ${i + 1}: $e');
        // If image generation fails, use original image as fallback
        final tempDir = await getTemporaryDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final file = File('${tempDir.path}/fallback_${i}_$timestamp.png');
        await file.writeAsBytes(originalImageBytes);

        results.add(UpcyclingIdeaWithImage(
          idea: ideas[i],
          imageFile: file,
        ));
      }
    }

    print('✅ All ${results.length} product images generated');
    return results;
  }

  String _formatMetadataContext(
      Map<String, dynamic> metadata, String visionAnalysis) {
    return '''
### Metadata Information:
- Category: ${metadata['category'] ?? 'Unknown'}
- Material: ${metadata['material'] ?? 'Unknown'}
- Primary Color: ${metadata['color'] ?? 'Unknown'}
- Condition: ${metadata['condition'] ?? 'Good condition'}
- Description: ${metadata['description'] ?? 'N/A'}
- Name: ${metadata['name'] ?? 'Unknown'}

### Vision Analysis:
$visionAnalysis
''';
  }

  String _cleanJsonResponse(String response) {
    // Remove markdown code blocks
    String cleaned = response.trim();

    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7);
    } else if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3);
    }

    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3);
    }

    return cleaned.trim();
  }

  Future<Uint8List> downloadImageFromFirebase(String firebaseUrl) async {
    try {
      print('📥 Downloading image from Firebase...');
      final response = await http.get(Uri.parse(firebaseUrl));

      if (response.statusCode != 200) {
        throw Exception('Failed to download image: ${response.statusCode}');
      }

      print('✅ Image downloaded (${response.bodyBytes.length} bytes)');
      return response.bodyBytes;
    } catch (e) {
      throw Exception('Failed to download image from Firebase: $e');
    }
  }
}
