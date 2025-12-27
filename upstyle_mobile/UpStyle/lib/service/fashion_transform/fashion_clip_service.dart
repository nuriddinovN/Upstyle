import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:up_style/features/warderobe/data/models/fashionclip_models.dart';

class FashionCLIPService {
  static const String _baseUrl =
      'https://fashionclip-api-ghrly4qhta-uc.a.run.app';

  final http.Client _client;

  FashionCLIPService({http.Client? client}) : _client = client ?? http.Client();

  /// Check if the service is online
  Future<bool> checkHealth() async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/health'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'online' && data['model_loaded'] == true;
      }
      return false;
    } catch (e) {
      print('❌ FashionCLIP health check failed: $e');
      return false;
    }
  }

  /// Analyze a clothing item image
  Future<FashionAnalysis> analyzeImage(File imageFile) async {
    try {
      print('📤 Uploading image to FashionCLIP API...');

      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/analyze'),
      );

      // Determine content type based on file extension
      final extension = imageFile.path.toLowerCase().split('.').last;
      MediaType contentType;

      switch (extension) {
        case 'jpg':
        case 'jpeg':
          contentType = MediaType('image', 'jpeg');
          break;
        case 'png':
          contentType = MediaType('image', 'png');
          break;
        case 'webp':
          contentType = MediaType('image', 'webp');
          break;
        case 'gif':
          contentType = MediaType('image', 'gif');
          break;
        default:
          // Default to jpeg if unknown
          contentType = MediaType('image', 'jpeg');
      }

      // Add image file with proper content type
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
          contentType: contentType,
        ),
      );

      print(
          '📝 Sending ${extension.toUpperCase()} image with content type: ${contentType.mimeType}');

      // Send request with longer timeout
      final streamedResponse = await request.send().timeout(
            const Duration(seconds: 30),
          );

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        print('✅ FashionCLIP analysis successful');
        final jsonData = jsonDecode(response.body);
        return FashionAnalysis.fromJson(jsonData);
      } else {
        throw Exception(
          'FashionCLIP API error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ FashionCLIP analysis failed: $e');
      throw Exception('Failed to analyze image: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}
