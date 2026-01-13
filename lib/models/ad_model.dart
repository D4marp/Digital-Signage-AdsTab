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
  final String? description;
  final String? companyName;
  final String? contactInfo;
  final String? websiteUrl;
  final List<String> galleryImages;         // Semua foto promo untuk detail page
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
    this.description,
    this.companyName,
    this.contactInfo,
    this.websiteUrl,
    this.galleryImages = const [],
    this.totalViews = 0,
  });

  factory AdModel.fromJson(Map<String, dynamic> json) {
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
      description: json['description'],
      companyName: json['company_name'],
      contactInfo: json['contact_info'],
      websiteUrl: json['website_url'],
      galleryImages: List<String>.from(json['gallery_images'] ?? []),
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
      'description': description,
      'company_name': companyName,
      'contact_info': contactInfo,
      'website_url': websiteUrl,
      'gallery_images': galleryImages,
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
    String? description,
    String? companyName,
    String? contactInfo,
    String? websiteUrl,
    List<String>? galleryImages,
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
      description: description ?? this.description,
      companyName: companyName ?? this.companyName,
      contactInfo: contactInfo ?? this.contactInfo,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      galleryImages: galleryImages ?? this.galleryImages,
      totalViews: totalViews ?? this.totalViews,
    );
  }
}

