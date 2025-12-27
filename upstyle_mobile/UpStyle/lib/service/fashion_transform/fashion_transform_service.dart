import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import 'package:up_style/features/warderobe/domain/entities/item.dart';

/// Scalable service interface for AI-powered fashion transformations
/// This interface allows for future integration of various ML pipelines:
/// - REST APIs
/// - Local inference models
/// - Cloud Functions
/// - Any other ML service
abstract class FashionTransformService {
  /// Upcycle an item using AI transformation with optional user prompt
  Future<Either<Failure, Item>> upcycleItem(
    Item originalItem, {
    String? userPrompt,
  });

  /// Upstyle an item using AI transformation
  Future<Either<Failure, Item>> upstyleItem(Item originalItem);

  /// Check if the service is available and ready
  Future<bool> isServiceAvailable();

  /// Get service status and configuration
  Future<Map<String, dynamic>> getServiceStatus();
}

/// Configuration for future AI service integration
class AIServiceConfig {
  final String? apiEndpoint;
  final String? apiKey;
  final bool useLocalModel;
  final String? modelPath;
  final int timeoutSeconds;

  const AIServiceConfig({
    this.apiEndpoint,
    this.apiKey,
    this.useLocalModel = false,
    this.modelPath,
    this.timeoutSeconds = 30,
  });
}

/// Result from AI transformation
class TransformationResult {
  final Item transformedItem;
  final double confidence;
  final Map<String, dynamic> metadata;

  const TransformationResult({
    required this.transformedItem,
    required this.confidence,
    required this.metadata,
  });
}
