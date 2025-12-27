import 'package:equatable/equatable.dart';

/// Complete fashion analysis from FashionCLIP API
class FashionAnalysis extends Equatable {
  final String? id;
  final String? filename;
  final String? category;
  final String? subCategory;
  final String? gender;
  final String? primaryColor;
  final String? secondaryColor;
  final String? accentColor;
  final String? pattern;
  final String? material;
  final String? fit;
  final String? silhouette;
  final String? neckline;
  final String? sleeve;
  final String? length;
  final String? rise;
  final String? closureType;
  final String? style;
  final String? occasion;
  final String? season;
  final String? bodyShape;
  final String? aestheticKeywords;
  final String? detailFeatures;
  final String? upcyclingPotential;
  final String? upcyclingType;
  final String? repairability;
  final String? sustainability;
  final String? visibleAccessories;

  const FashionAnalysis({
    this.id,
    this.filename,
    this.category,
    this.subCategory,
    this.gender,
    this.primaryColor,
    this.secondaryColor,
    this.accentColor,
    this.pattern,
    this.material,
    this.fit,
    this.silhouette,
    this.neckline,
    this.sleeve,
    this.length,
    this.rise,
    this.closureType,
    this.style,
    this.occasion,
    this.season,
    this.bodyShape,
    this.aestheticKeywords,
    this.detailFeatures,
    this.upcyclingPotential,
    this.upcyclingType,
    this.repairability,
    this.sustainability,
    this.visibleAccessories,
  });

  /// Create from API JSON response
  /// API returns: {
  ///   "id": "...",
  ///   "filename": "...",
  ///   "category": {"value": "jacket", "confidence": 0.78},
  ///   "sub_category": {"value": "down jacket", "confidence": 0.95},
  ///   ...
  /// }
  factory FashionAnalysis.fromJson(Map<String, dynamic> json) {
    // Helper function to extract value from {value, confidence} structure
    String? extractValue(String key) {
      final field = json[key];
      if (field is Map<String, dynamic>) {
        return field['value'] as String?;
      }
      return field as String?; // Fallback for plain strings
    }

    return FashionAnalysis(
      id: json['id'] as String?,
      filename: json['filename'] as String?,
      category: extractValue('category'),
      subCategory: extractValue('sub_category'),
      gender: extractValue('gender'),
      primaryColor: extractValue('primary_color'),
      secondaryColor: extractValue('secondary_color'),
      accentColor: extractValue('accent_color'),
      pattern: extractValue('pattern'),
      material: extractValue('material'),
      fit: extractValue('fit'),
      silhouette: extractValue('silhouette'),
      neckline: extractValue('neckline'),
      sleeve: extractValue('sleeve'),
      length: extractValue('length'),
      rise: extractValue('rise'),
      closureType: extractValue('closure_type'),
      style: extractValue('style'),
      occasion: extractValue('occasion'),
      season: extractValue('season'),
      bodyShape: extractValue('body_shape'),
      aestheticKeywords: extractValue('aesthetic_keywords'),
      detailFeatures: extractValue('detail_features'),
      upcyclingPotential: extractValue('upcycling_potential'),
      upcyclingType: extractValue('upcycling_type'),
      repairability: extractValue('repairability'),
      sustainability: extractValue('sustainability'),
      visibleAccessories: extractValue('visible_accessories'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (filename != null) 'filename': filename,
      if (category != null) 'category': category,
      if (subCategory != null) 'sub_category': subCategory,
      if (gender != null) 'gender': gender,
      if (primaryColor != null) 'primary_color': primaryColor,
      if (secondaryColor != null) 'secondary_color': secondaryColor,
      if (accentColor != null) 'accent_color': accentColor,
      if (pattern != null) 'pattern': pattern,
      if (material != null) 'material': material,
      if (fit != null) 'fit': fit,
      if (silhouette != null) 'silhouette': silhouette,
      if (neckline != null) 'neckline': neckline,
      if (sleeve != null) 'sleeve': sleeve,
      if (length != null) 'length': length,
      if (rise != null) 'rise': rise,
      if (closureType != null) 'closure_type': closureType,
      if (style != null) 'style': style,
      if (occasion != null) 'occasion': occasion,
      if (season != null) 'season': season,
      if (bodyShape != null) 'body_shape': bodyShape,
      if (aestheticKeywords != null) 'aesthetic_keywords': aestheticKeywords,
      if (detailFeatures != null) 'detail_features': detailFeatures,
      if (upcyclingPotential != null) 'upcycling_potential': upcyclingPotential,
      if (upcyclingType != null) 'upcycling_type': upcyclingType,
      if (repairability != null) 'repairability': repairability,
      if (sustainability != null) 'sustainability': sustainability,
      if (visibleAccessories != null) 'visible_accessories': visibleAccessories,
    };
  }

  /// Generate a human-readable description
  String generateDescription() {
    final parts = <String>[];

    // Start with basic item type
    if (gender != null && subCategory != null) {
      parts.add('A ${gender!.toLowerCase()} ${subCategory!.toLowerCase()}');
    } else if (subCategory != null) {
      parts.add('A ${subCategory!.toLowerCase()}');
    } else if (category != null) {
      parts.add('A ${category!.toLowerCase()}');
    }

    // Add material
    if (material != null && material != 'unknown' && material != 'none') {
      parts.add('made of ${material!.toLowerCase()}');
    }

    // Add color
    if (primaryColor != null &&
        primaryColor != 'unknown' &&
        primaryColor != 'none') {
      parts.add('in ${primaryColor!.toLowerCase()}');

      // Add secondary color if present
      if (secondaryColor != null &&
          secondaryColor != 'none' &&
          secondaryColor != primaryColor) {
        parts.add('and ${secondaryColor!.toLowerCase()}');
      }
    }

    // Add pattern
    if (pattern != null &&
        pattern != 'solid color' &&
        pattern != 'unknown' &&
        pattern != 'none') {
      parts.add('with ${pattern!.toLowerCase()} pattern');
    }

    // Add style
    if (style != null && style != 'unknown' && style != 'none') {
      parts.add('${style!.toLowerCase()} style');
    }

    // Add fit
    if (fit != null &&
        fit != 'unknown' &&
        fit != 'none' &&
        fit != 'regular fit') {
      parts.add('${fit!.toLowerCase()}');
    }

    if (parts.isEmpty) {
      return 'Fashion item';
    }

    String description = parts
        .join(', ')
        .replaceAll(', in ', ' in ')
        .replaceAll(', and ', ' and ');
    description = description[0].toUpperCase() + description.substring(1);

    return '$description.';
  }

  /// Get a suitable category name for storage
  String getCategoryName() {
    if (category == null || category!.isEmpty) {
      return 'Clothing';
    }

    // Use category as the primary category name
    // Capitalize first letter of each word
    final words = category!.split(' ');
    final capitalized = words.map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');

    return capitalized;
  }

  @override
  List<Object?> get props => [
        id,
        filename,
        category,
        subCategory,
        gender,
        primaryColor,
        secondaryColor,
        accentColor,
        pattern,
        material,
        fit,
        silhouette,
        neckline,
        sleeve,
        length,
        rise,
        closureType,
        style,
        occasion,
        season,
        bodyShape,
        aestheticKeywords,
        detailFeatures,
        upcyclingPotential,
        upcyclingType,
        repairability,
        sustainability,
        visibleAccessories,
      ];
}
