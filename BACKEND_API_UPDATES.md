# Backend API - Multi-Image Support Documentation

## Struktur Data Ad (Update)

```json
{
  "id": "ad-id",
  "title": "Ad Title",
  "media_url": "https://...",           // Main image untuk tab (10 detik tayang)
  "media_type": "image|video|pdf",
  "duration_seconds": 10,
  "order_index": 0,
  "is_enabled": true,
  "target_locations": ["all"],
  "created_by": "user-id",
  "is_deleted": false,
  "description": "Ad description",
  "company_name": "Company A",
  "contact_info": "08123456789",
  "website_url": "https://company.com",
  "gallery_images": [                   // Semua foto promo untuk detail page
    "https://..../photo1.jpg",
    "https://..../photo2.jpg",
    "https://..../photo3.jpg"
  ],
  "total_views": 1250,
  "created_at": "2026-01-13T10:00:00Z",
  "updated_at": "2026-01-13T10:00:00Z"
}
```

## New Database Schema

### Ads Table Updates
```sql
-- New columns added:
- gallery_images JSON          -- Menyimpan array URL foto promo
- total_views INT DEFAULT 0    -- Tracking jumlah views per ad
```

## API Endpoints

### 1. Create Ad dengan Gallery Images
**POST** `/api/v1/ads`

Request:
```json
{
  "title": "Promo Makanan",
  "media_url": "https://server.com/uploads/main-image.jpg",
  "media_type": "image",
  "duration_seconds": 10,
  "target_locations": ["all"],
  "description": "Promo spesial makanan",
  "company_name": "Company A",
  "contact_info": "08123456789",
  "website_url": "https://company.com",
  "gallery_images": [
    "https://server.com/uploads/promo1.jpg",
    "https://server.com/uploads/promo2.jpg",
    "https://server.com/uploads/promo3.jpg"
  ]
}
```

Response:
```json
{
  "id": "ad-id-uuid",
  "title": "Promo Makanan",
  "media_url": "https://server.com/uploads/main-image.jpg",
  "gallery_images": [...],
  "total_views": 0,
  ...
}
```

### 2. Update Ad Gallery Images
**PUT** `/api/v1/ads/:id`

```json
{
  "gallery_images": [
    "https://server.com/uploads/new-promo1.jpg",
    "https://server.com/uploads/new-promo2.jpg"
  ]
}
```

### 3. Track Ad View
**POST** `/api/v1/ads/:id/view`

- Public endpoint
- Auto increment `total_views`
- Dipanggil ketika ad ditampilkan di tab

Response:
```json
{
  "message": "View tracked"
}
```

### 4. Get All Ads by Company
**GET** `/api/v1/ads/company/list?company=Company%20A`

- Public endpoint
- Return semua ads dari perusahaan
- Include total views aggregate

Response:
```json
{
  "company": "Company A",
  "ads_count": 2,
  "total_views": 5420,
  "ads": [
    {
      "id": "ad-1",
      "title": "Promo 1",
      "total_views": 2100,
      ...
    },
    {
      "id": "ad-2",
      "title": "Promo 2", 
      "total_views": 3320,
      ...
    }
  ]
}
```

### 5. Check Company Upload Limit
**GET** `/api/v1/ads/company/check-limit?company=Company%20A`

- Public endpoint
- Max 2 ads per company
- Return remaining quota

Response:
```json
{
  "company": "Company A",
  "current_ads": 1,
  "max_ads": 2,
  "can_upload": true,
  "remaining_quota": 1
}
```

## Database Migration

Jika sudah ada database sebelumnya, jalankan:

```sql
-- Add columns if not exist
ALTER TABLE ads ADD COLUMN IF NOT EXISTS gallery_images JSON;
ALTER TABLE ads ADD COLUMN IF NOT EXISTS total_views INT DEFAULT 0;
ALTER TABLE ads ADD INDEX IF NOT EXISTS idx_company (company_name);

-- Existing data akan ke-update secara otomatis
```

## Flutter Model Update

Update di file `lib/models/ad_model.dart`:

```dart
class AdModel {
  ...
  final List<String> galleryImages;  // Semua foto promo
  final int totalViews;              // Total views tracking
  
  AdModel({
    ...
    this.galleryImages = const [],
    this.totalViews = 0,
  });

  factory AdModel.fromJson(Map<String, dynamic> json) {
    return AdModel(
      ...
      galleryImages: List<String>.from(json['gallery_images'] ?? []),
      totalViews: json['total_views'] ?? 0,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      ...
      'gallery_images': galleryImages,
      'total_views': totalViews,
    };
  }
}
```

## Key Features

✅ **Main Image** (media_url) - Untuk tab display (10 detik tayang)
✅ **Gallery Images** (gallery_images) - Semua foto promo untuk detail page
✅ **Total Views Tracking** - Jumlah views per ad untuk analytics
✅ **Company Upload Limit** - Max 2 ads per perusahaan
✅ **Backward Compatible** - Existing ads tetap berfungsi

## Frontend Integration

### Display Tab
```dart
// Show main image di tab
CachedNetworkImage(
  imageUrl: currentAd.mediaUrl,
  // Durasi: duration_seconds (default 10 detik)
)

// Track view
await adProvider.trackAdView(currentAd.id);
```

### Detail Page
```dart
// Show all gallery images
ListView.builder(
  itemCount: ad.galleryImages.length,
  itemBuilder: (_, index) => CachedNetworkImage(
    imageUrl: ad.galleryImages[index],
  ),
)

// Show total views
Text('Views: ${ad.totalViews}')
```

### Upload Dialog
```dart
// Check limit sebelum upload
final canUpload = await adProvider.checkCompanyUploadLimit(companyName);

if (!canUpload) {
  // Show error: "Sudah mencapai limit 2 ads"
}
```
