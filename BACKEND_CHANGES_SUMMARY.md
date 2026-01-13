# Backend Multi-Image Support - Summary

## ✅ Struktur Yang Telah Diupdate

### 1. Database Schema (`backend/database/database.go`)
```
Tabel ads - Tambah 2 kolom baru:
├── gallery_images JSON       // Array URL foto promo
└── total_views INT           // Counter views
```

### 2. Ad Model (`backend/models/ad.go`)
```go
type Ad struct {
  ...
  GalleryImages StringArray    // Semua foto untuk detail
  TotalViews    int            // Total views tracking
}
```

### 3. API Requests
```go
CreateAdRequest:
├── media_url           // 1 main image (tab display)
└── gallery_images []   // Multiple promo images (detail)

UpdateAdRequest:
└── gallery_images []   // Update gallery kapan saja
```

### 4. New API Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/v1/ads/:id/view` | POST | Track view count |
| `/api/v1/ads/company/list` | GET | Get all ads by company + total views |
| `/api/v1/ads/company/check-limit` | GET | Check upload limit (max 2 per company) |

### 5. Handlers Updates (`backend/handlers/ad.go`)
```
✅ GetAds()              - Include gallery_images & total_views
✅ GetAdByID()           - Include gallery_images & total_views  
✅ CreateAd()            - Save gallery_images
✅ UpdateAd()            - Update gallery_images
✅ TrackAdView()         - NEW: Increment total_views
✅ GetAdsByCompany()     - NEW: Company analytics
✅ CheckCompanyUploadLimit() - NEW: Validate limit
```

### 6. Routes Updates (`backend/routes/routes.go`)
```
POST /api/v1/ads/:id/view
GET  /api/v1/ads/company/list?company=XXX
GET  /api/v1/ads/company/check-limit?company=XXX
```

## 📊 Use Case: Company A Upload

```
Step 1: Check Limit
GET /api/v1/ads/company/check-limit?company=Company%20A
Response: { can_upload: true, remaining_quota: 1 }

Step 2: Upload Main Image + 2 Promo Images
POST /api/v1/ads
{
  media_url: "main-image.jpg",
  gallery_images: ["promo1.jpg", "promo2.jpg"],
  duration_seconds: 10,
  ...
}

Step 3: Tab Display (10 detik)
- Show: media_url (main image)
- Duration: 10 seconds

Step 4: View Tracking
POST /api/v1/ads/{id}/view
- Increment total_views

Step 5: Detail Page
- Show: gallery_images (all promo photos)
- Show: total_views (viewer count)

Step 6: Analytics
GET /api/v1/ads/company/list?company=Company%20A
Response: 
{
  ads_count: 1,
  total_views: 1250,
  ads: [...]
}
```

## 🔄 Backward Compatibility

✅ Old ads without gallery_images masih berfungsi (default [])
✅ Old ads without total_views masih berfungsi (default 0)
✅ Existing queries di-update dengan COALESCE

## 🚀 Migration untuk Database Lama

Backend otomatis jalankan:
```sql
ALTER TABLE ads ADD COLUMN IF NOT EXISTS gallery_images JSON;
ALTER TABLE ads ADD COLUMN IF NOT EXISTS total_views INT DEFAULT 0;
ALTER TABLE ads ADD INDEX IF NOT EXISTS idx_company (company_name);
```

## 📝 Next Steps untuk Frontend

1. Update AdModel (`lib/models/ad_model.dart`)
   - Add `galleryImages: List<String>`
   - Add `totalViews: int`

2. Update Upload Dialog (`lib/screens/admin/widgets/ad_upload_dialog.dart`)
   - Add gallery images multi-select
   - Check upload limit

3. Update Display Tab (`lib/screens/display/display_home_screen.dart`)
   - Show media_url (main image)
   - Call TrackAdView on display

4. Update Detail Page
   - Show gallery_images (carousel/grid)
   - Show total_views

5. Update Analytics Tab
   - Group by company
   - Show total_views per company

## 💾 Files Modified

Backend:
- ✅ `backend/models/ad.go` - Add fields & JSON mappings
- ✅ `backend/database/database.go` - Schema + migration
- ✅ `backend/handlers/ad.go` - Handlers & new endpoints
- ✅ `backend/routes/routes.go` - New routes

Documentation:
- ✅ `BACKEND_API_UPDATES.md` - Full API docs

Ready untuk implementasi frontend! 🎉
