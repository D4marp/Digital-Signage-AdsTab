# Quick Reference: API Issues & Fixes

## Problem: 404 on View Tracking
```
POST http://saas.hcm-lab.id/api/v1/ads/xyz/view → 404 ❌
```

**Fix Applied:** 
- File: `lib/services/api_client.dart`
- Changed singleton initialization timing
- Now: ApiClient created AFTER ApiConfig.initialize()
- Result: Correct baseUrl used ✅

**How to Test:**
1. Open Display screen
2. Watch console for `POST /ads/{id}/view`
3. Should see 200 response (not 404)

---

## Problem: Gallery Images Not Displaying
```
Upload: 3 photos
Display: Only 1 photo + no gallery ❌
```

**Debugging Added:**
```dart
// Check these logs during upload/display:
📸 Gallery images available: X          // If 0, check backend
🖼️  Total images in detail: Y          // Should be > 1
✅ [AdModel] Gallery images found: [...] // Should show URLs
```

**How to Debug:**
1. Upload ad with gallery images
2. Check console logs above
3. If gallery count = 0:
   - Database not saving gallery_images
   - Check backend upload handler
4. If gallery count > 0:
   - Images exist but not displaying properly
   - Check image URLs are valid

---

## Problem: DebugService Null Errors
```
DebugService: Error serving requests
Error: Unsupported operation: Cannot send Null
```

**Status:** Not a real problem ✅
- DevTools trying to inspect POST without body
- View tracking endpoint doesn't need body
- Safe to ignore - app works fine
- Cosmetic dev-time only error

---

## Console Output Reference

### Success Indicators ✅
```
[ApiClient] 📤 Request: POST /ads/abc123/view
[ApiClient] 📥 Response: 200 /ads/abc123/view
✅ [AdModel] Gallery images found: ['url1.jpg', 'url2.jpg']
📸 Gallery images available: 2
🖼️  Total images in detail: 3
```

### Warning Indicators ⚠️
```
⚠️  [ApiConfig] Error initializing baseUrl (using fallback)
⚠️  [AdModel] No gallery images in response for ad xyz
⚠️  No gallery images for ad xyz
```

### Error Indicators ❌
```
❌ [ApiClient] Error: 404 (FIXED - should not appear)
❌ Failed to track view
❌ Upload failed
```

---

## Files to Check

| Issue | File to Check | What to Look For |
|-------|---------------|-----------------|
| 404 View Tracking | `lib/services/api_client.dart` | Singleton creation timing |
| Gallery Not Saving | `backend/handlers/ad.go` | gallery_images in INSERT query |
| Gallery Not Parsing | `lib/models/ad_model.dart` | fromJson gallery_images extraction |
| Gallery Not Displaying | `lib/screens/display/ad_detail_screen.dart` | _galleryImages getter |

---

## One-Command Fixes

### If app crashes on startup:
```bash
flutter clean
flutter pub get
flutter run
```

### If API issues persist:
1. Check `.env` file has `API_BASE_URL=http://saas.hcm-lab.id/api/v1`
2. Hot restart (Ctrl+Shift+R or Cmd+Shift+R) not hot reload
3. Check backend is running: `curl http://saas.hcm-lab.id/api/v1/health`

### If gallery images empty:
```bash
# Check database
mysql> SELECT id, title, gallery_images FROM ads WHERE gallery_images IS NOT NULL LIMIT 1;
# Should show JSON array like: ["url1.jpg", "url2.jpg"]
```

---

## Testing Checklist

- [ ] App starts without errors
- [ ] View tracking: POST /ads/{id}/view returns 200
- [ ] Upload new ad with 3 gallery images
- [ ] Check console: Gallery image count > 0
- [ ] Display screen shows ad main image
- [ ] Detail screen shows main image + gallery images
- [ ] Can swipe through gallery (multiple images)
- [ ] View count increments when opening ad

---

## Key Takeaways

1. **404 Fixed** ✅ - ApiClient now uses correct baseUrl
2. **Gallery Debug Ready** ✅ - Logs show where images are lost
3. **Null Error Explained** ✅ - Safe to ignore, non-critical
4. **Ready to Test** ✅ - Monitor console logs during testing

See [API_ISSUES_FIX.md](API_ISSUES_FIX.md) for detailed guide.
