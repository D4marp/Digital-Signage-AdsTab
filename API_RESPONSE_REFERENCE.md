# API Response Reference Guide

## Authentication Responses

### POST /auth/register
**Request:**
```json
{
  "email": "user@example.com",
  "password": "Password123!",
  "display_name": "John Doe"
}
```

**Response (201 Created):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "user@example.com",
    "display_name": "John Doe",
    "role": "admin",
    "created_at": "2026-01-20T10:00:00Z",
    "updated_at": "2026-01-20T10:00:00Z"
  }
}
```

### POST /auth/login
**Request:**
```json
{
  "email": "user@example.com",
  "password": "Password123!"
}
```

**Response (200 OK):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "user@example.com",
    "display_name": "John Doe",
    "role": "admin",
    "created_at": "2026-01-20T10:00:00Z",
    "updated_at": "2026-01-20T10:00:00Z"
  }
}
```

### GET /auth/me
**Headers:** Authorization: Bearer {token}

**Response (200 OK):**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "email": "user@example.com",
  "display_name": "John Doe",
  "role": "admin",
  "created_at": "2026-01-20T10:00:00Z",
  "updated_at": "2026-01-20T10:00:00Z"
}
```

---

## Ads Responses

### GET /ads
**Query Params:** 
- `location` (optional): Filter by location
- `active` (optional): true/false for active only

**Response (200 OK):**
```json
[
  {
    "id": "ad-001",
    "title": "Amazing Product",
    "media_url": "https://cdn.example.com/image.jpg",
    "media_type": "image",
    "duration_seconds": 10,
    "order_index": 1,
    "is_enabled": true,
    "target_locations": ["all"],
    "created_by": "user-001",
    "is_deleted": false,
    "description": "Best product ever",
    "company_name": "Acme Corp",
    "contact_info": "sales@acme.com",
    "website_url": "https://acme.com",
    "gallery_images": [
      "https://cdn.example.com/gallery1.jpg",
      "https://cdn.example.com/gallery2.jpg"
    ],
    "total_views": 156,
    "created_at": "2026-01-15T08:30:00Z",
    "updated_at": "2026-01-20T10:00:00Z"
  }
]
```

### POST /ads
**Headers:** Authorization: Bearer {token}

**Request:**
```json
{
  "title": "New Ad",
  "media_url": "https://example.com/main.jpg",
  "media_type": "image",
  "duration_seconds": 15,
  "target_locations": ["all"],
  "description": "Product description",
  "company_name": "My Company",
  "contact_info": "contact@company.com",
  "website_url": "https://company.com",
  "gallery_images": ["https://...", "https://..."]
}
```

**Response (201 Created):**
```json
{
  "id": "new-ad-id",
  "title": "New Ad",
  "media_url": "https://example.com/main.jpg",
  "media_type": "image",
  "duration_seconds": 15,
  "order_index": 32,
  "is_enabled": true,
  "target_locations": ["all"],
  "created_by": "user-id",
  "is_deleted": false,
  "description": "Product description",
  "company_name": "My Company",
  "contact_info": "contact@company.com",
  "website_url": "https://company.com",
  "gallery_images": ["https://...", "https://..."],
  "total_views": 0,
  "created_at": "2026-01-20T10:00:00Z",
  "updated_at": "2026-01-20T10:00:00Z"
}
```

### GET /ads/:id
**Response (200 OK):**
```json
{
  "id": "ad-001",
  "title": "Amazing Product",
  "media_url": "https://cdn.example.com/image.jpg",
  "media_type": "image",
  "duration_seconds": 10,
  "order_index": 1,
  "is_enabled": true,
  "target_locations": ["all"],
  "created_by": "user-001",
  "is_deleted": false,
  "description": "Best product ever",
  "company_name": "Acme Corp",
  "contact_info": "sales@acme.com",
  "website_url": "https://acme.com",
  "gallery_images": [
    "https://cdn.example.com/gallery1.jpg",
    "https://cdn.example.com/gallery2.jpg"
  ],
  "total_views": 156,
  "created_at": "2026-01-15T08:30:00Z",
  "updated_at": "2026-01-20T10:00:00Z"
}
```

### PUT /ads/:id
**Headers:** Authorization: Bearer {token}

**Request (partial update):**
```json
{
  "gallery_images": ["https://new1.jpg", "https://new2.jpg"],
  "title": "Updated Title"
}
```

**Response (200 OK):** Same as GET /ads/:id with updated fields

### DELETE /ads/:id
**Headers:** Authorization: Bearer {token}

**Response (200 OK):**
```json
{
  "message": "Ad deleted successfully"
}
```

### POST /ads/:id/view
**Response (200 OK):**
```json
{
  "message": "View tracked"
}
```

### GET /ads/company/list?company=Acme%20Corp
**Query Params:**
- `company` (required, URL encoded): Company name

**Response (200 OK):**
```json
{
  "company": "Acme Corp",
  "ads_count": 3,
  "total_views": 450,
  "ads": [
    {
      "id": "ad-001",
      "title": "Product A",
      ...
    }
  ]
}
```

### GET /ads/company/check-limit?company=Acme%20Corp
**Query Params:**
- `company` (required, URL encoded): Company name

**Response (200 OK):**
```json
{
  "company": "Acme Corp",
  "current_ads": 2,
  "max_ads": 2,
  "can_upload": false,
  "remaining_quota": 0
}
```

---

## Device Responses

### POST /devices/register
**Request:**
```json
{
  "device_id": "device-uuid-123",
  "location": "Main Store",
  "device_type": "display"
}
```

**Response (201 Created):**
```json
{
  "id": "internal-device-id",
  "device_id": "device-uuid-123",
  "location": "Main Store",
  "is_online": true,
  "last_active": "2026-01-20T10:00:00Z",
  "today_views": 0,
  "settings": {
    "slideshowInterval": 5,
    "videoAutoplay": true,
    "enabledAds": []
  },
  "created_at": "2026-01-20T10:00:00Z",
  "updated_at": "2026-01-20T10:00:00Z"
}
```

### GET /devices
**Headers:** Authorization: Bearer {token}

**Response (200 OK):**
```json
[
  {
    "id": "device-id-1",
    "device_id": "device-uuid-123",
    "location": "Main Store",
    "is_online": true,
    "last_active": "2026-01-20T10:00:00Z",
    "today_views": 42,
    "settings": {
      "slideshowInterval": 5,
      "videoAutoplay": true,
      "enabledAds": ["ad-001", "ad-002"]
    },
    "created_at": "2026-01-20T10:00:00Z",
    "updated_at": "2026-01-20T10:00:00Z"
  }
]
```

### GET /devices/:id
**Headers:** Authorization: Bearer {token}

**Response (200 OK):** Single device object (same format as array item above)

### POST /devices/:id/heartbeat
**Request:**
```json
{
  "status": "online"
}
```

**Response (200 OK):**
```json
{
  "message": "Heartbeat received"
}
```

### POST /devices/:id/increment-views
**Response (200 OK):**
```json
{
  "message": "Views incremented"
}
```

---

## Analytics Responses

### POST /analytics/impressions
**Request:**
```json
{
  "ad_id": "ad-001",
  "device_id": "device-id-1",
  "impression_type": "view"
}
```

**Response (201 Created):**
```json
{
  "id": "impression-id",
  "ad_id": "ad-001",
  "device_id": "device-id-1",
  "viewed_at": "2026-01-20T10:00:00Z"
}
```

### GET /analytics
**Headers:** Authorization: Bearer {token}

**Query Params:**
- `start_date` (optional): YYYY-MM-DD
- `end_date` (optional): YYYY-MM-DD
- `ad_id` (optional): Filter by ad

**Response (200 OK):**
```json
[
  {
    "id": "analytics-001",
    "ad_id": "ad-001",
    "date": "2026-01-20",
    "impressions": 42,
    "unique_devices": 5,
    "created_at": "2026-01-20T10:00:00Z",
    "updated_at": "2026-01-20T10:00:00Z"
  }
]
```

### GET /analytics/dashboard
**Headers:** Authorization: Bearer {token}

**Response (200 OK):**
```json
{
  "active_ads": 4,
  "online_devices": 22,
  "today_impressions": 156,
  "top_ads": [
    {
      "ad_id": "ad-001",
      "impressions": 42,
      "title": "Amazing Product"
    },
    {
      "ad_id": "ad-002",
      "impressions": 38,
      "title": "Great Deal"
    }
  ],
  "total_ads": 10,
  "total_devices": 50,
  "total_impressions_30d": 3250
}
```

---

## Error Responses

### 400 Bad Request
```json
{
  "error": "Validation error message"
}
```

### 401 Unauthorized
```json
{
  "error": "Unauthorized"
}
```

### 404 Not Found
```json
{
  "error": "Resource not found"
}
```

### 409 Conflict
```json
{
  "error": "Email already registered"
}
```

### 500 Internal Server Error
```json
{
  "error": "Database error or Internal server error"
}
```

---

## Response Field Types Reference

| Field | Type | Example |
|-------|------|---------|
| id | string (UUID) | "550e8400-e29b-41d4-a716-446655440000" |
| token | string (JWT) | "eyJhbGciOiJIUzI1NiI..." |
| title | string | "Amazing Product" |
| media_url | string (URL) | "https://cdn.example.com/image.jpg" |
| media_type | string | "image" ∣ "video" ∣ "pdf" |
| duration_seconds | integer | 10 |
| order_index | integer | 1 |
| is_enabled | boolean | true |
| target_locations | array[string] | ["all"] ∣ ["loc1", "loc2"] |
| gallery_images | array[string] | ["https://...", "https://..."] |
| total_views | integer | 156 |
| is_online | boolean | true |
| today_views | integer | 42 |
| impressions | integer | 42 |
| unique_devices | integer | 5 |
| created_at | ISO8601 | "2026-01-20T10:00:00Z" |
| updated_at | ISO8601 | "2026-01-20T10:00:00Z" |

---

## Important Notes

1. **URL Encoding:** Company names must be URL encoded (spaces → %20)
2. **Authorization:** Protected endpoints require `Authorization: Bearer {token}` header
3. **JSON Format:** All requests/responses use application/json
4. **Timestamps:** All timestamps are ISO8601 format in UTC (Z)
5. **Null Safety:** Optional fields may be null or omitted
6. **Arrays:** Empty arrays return `[]` not null
7. **View Tracking:** POST to /:id/view automatically increments total_views
8. **Heartbeat:** Should be sent periodically (recommend every 30 seconds)
9. **Impressions:** Should be tracked whenever ad is displayed

---

**Last Updated:** 2026-01-20  
**API Version:** v1  
**Base URL:** http://saas.hcm-lab.id/api/v1
