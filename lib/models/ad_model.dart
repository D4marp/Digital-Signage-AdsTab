import 'package:flutter/foundation.dart';

class AdModel {
  final String id;
  final String title;
  final String mediaUrl;                    // Main image untuk tab display
  final String mediaType;                   // 'image', 'video', or 'pdf'
  final int durationSeconds;
  final int orderIndex;
  final bool isEnabled;
  final List<String> targetLocations;       // 'all' or specific location IDs
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final bool isDeleted;
  final List<String> galleryImages;         // Semua foto promo untuk detail page
  final List<String> aboutImages;           // Foto tentang/informasi ditampilkan setelah gallery
  final int totalViews;                     // Total views tracking

  AdModel({
    required this.id,
    required this.title,
    required this.mediaUrl,
    required this.mediaType,
    required this.durationSeconds,
    required this.orderIndex,
    required this.isEnabled,
    required this.targetLocations,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.isDeleted = false,
    this.galleryImages = const [],
    this.aboutImages = const [],
    this.totalViews = 0,
  });

  factory AdModel.fromJson(Map<String, dynamic> json) {
    final galleryImages = List<String>.from(json['gallery_images'] ?? []);
    final aboutImages = List<String>.from(json['about_images'] ?? []);
    
    if (galleryImages.isNotEmpty) {
      debugPrint('✅ [AdModel] Gallery images found: $galleryImages');
    } else {
      debugPrint('⚠️  [AdModel] No gallery images in response for ad ${json['id']}');
    }
    
    if (aboutImages.isNotEmpty) {
      debugPrint('✅ [AdModel] About images found: $aboutImages');
    }
    
    return AdModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      mediaUrl: json['media_url'] ?? '',
      mediaType: json['media_type'] ?? 'image',
      durationSeconds: json['duration_seconds'] ?? 5,
      orderIndex: json['order_index'] ?? 0,
      isEnabled: json['is_enabled'] ?? true,
      targetLocations: List<String>.from(json['target_locations'] ?? ['all']),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      createdBy: json['created_by'] ?? '',
      isDeleted: json['is_deleted'] ?? false,
      galleryImages: galleryImages,
      aboutImages: aboutImages,
      totalViews: json['total_views'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'media_url': mediaUrl,
      'media_type': mediaType,
      'duration_seconds': durationSeconds,
      'order_index': orderIndex,
      'is_enabled': isEnabled,
      'target_locations': targetLocations,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'created_by': createdBy,
      'is_deleted': isDeleted,
      'gallery_images': galleryImages,
      'about_images': aboutImages,
      'total_views': totalViews,
    };
  }

  AdModel copyWith({
    String? title,
    String? mediaUrl,
    String? mediaType,
    int? durationSeconds,
    int? orderIndex,
    bool? isEnabled,
    List<String>? targetLocations,
    DateTime? updatedAt,
    bool? isDeleted,
    List<String>? galleryImages,
    List<String>? aboutImages,
    int? totalViews,
  }) {
    return AdModel(
      id: id,
      title: title ?? this.title,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaType: mediaType ?? this.mediaType,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      orderIndex: orderIndex ?? this.orderIndex,
      isEnabled: isEnabled ?? this.isEnabled,
      targetLocations: targetLocations ?? this.targetLocations,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt,
      createdBy: createdBy,
      galleryImages: galleryImages ?? this.galleryImages,
      aboutImages: aboutImages ?? this.aboutImages,
      totalViews: totalViews ?? this.totalViews,
    );
  }
}

