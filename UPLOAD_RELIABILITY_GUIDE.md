# Image Upload Reliability Guide - Web & Android

## Overview
This guide explains the comprehensive upload system implemented to ensure reliable image/video uploads on both web and Android platforms.

## Architecture

### UploadService (`lib/services/upload_service.dart`)
Central service handling all file uploads with cross-platform support.

**Key Features:**
- ✅ **File Validation**: Size (100MB max) and format checking before upload
- ✅ **Retry Logic**: 3 automatic retries with 2-second delays on network failures
- ✅ **Platform Detection**: Automatic web (bytes) vs Android (file paths) handling
- ✅ **Batch Upload**: Concurrent upload with configurable limits (max 3 parallel)
- ✅ **Error Handling**: Comprehensive error messages and debug logging
- ✅ **Timeout Protection**: 5-minute timeout per file
- ✅ **Response Parsing**: Flexible URL extraction from various response formats

### AdProvider Integration (`lib/providers/ad_provider.dart`)
Updated `uploadMedia()` method delegates to UploadService with validation.

**Changes:**
- Added UploadService import
- Wrapped upload in validation check
- Simplified error handling with service-level retry logic
- Removed redundant retry code

### Upload Dialog Enhancement (`lib/screens/admin/widgets/ad_upload_dialog.dart`)
Updated `_handleUpload()` method with better batch processing.

**Improvements:**
- Added comprehensive debug logging
- Batch upload using UploadService.batchUpload()
- File validation for each gallery image
- Better error messages and user feedback
- Platform-aware gallery file processing

## Supported Formats

### Images
- `jpg`, `jpeg`
- `png`
- `gif`
- `webp`

### Videos
- `mp4`
- `avi`
- `mov`
- `mkv`

### Documents
- `pdf`

**Max File Size:** 100MB per file

## Platform-Specific Handling

### Web Upload
```dart
// Web uses file bytes directly
MultipartFile.fromBytes(
  fileBytes,
  filename: fileName,
)
```

**Debug:** Check if `_fileBytes` is populated from file picker

### Android/Mobile Upload
```dart
// Mobile uses file path from device storage
MultipartFile.fromFile(
  filePath,
  filename: fileName,
)
```

**Debug:** Check if `_selectedFile?.path` exists and is valid

## Debug Output

When uploading, monitor console for these debug markers:

```
========== UPLOAD START ==========
Platform: WEB/MOBILE
Main file: [filename]
File bytes available: true/false
Gallery items: [count]

Uploading main media with retry logic...
✓ Main media uploaded: [URL]

Processing [N] gallery images...
📦 Batch [N]: uploading [count] files
✓ Uploaded [N] gallery images

========== UPLOAD COMPLETE ==========
Ad creation: SUCCESS/FAILED
```

### Error Cases

**❌ Invalid File Format**
```
❌ Invalid file format: [ext]
Error: Invalid main file format or size
```

**❌ Network Timeout with Retry**
```
❌ Upload error attempt 1: timeout
🔄 Retry dalam 2 detik...
❌ Upload error attempt 2: timeout
🔄 Retry dalam 2 detik...
✅ Upload berhasil: [URL]
```

**❌ All Retries Exhausted**
```
❌ Upload gagal setelah 3 attempts: [error]
Upload failed: [error message]
```

## Testing Checklist

### Web Browser (Chrome/Firefox/Safari)
- [ ] Single image upload (JPG, PNG)
- [ ] Single video upload (MP4)
- [ ] Multiple gallery images
- [ ] Large file (50MB+) - should handle gracefully
- [ ] Network interruption during upload - should retry
- [ ] Invalid format (TXT) - should reject

### Android Device
- [ ] Single image upload from camera
- [ ] Single image upload from gallery
- [ ] Single video upload
- [ ] Multiple gallery images
- [ ] Large file (50MB+)
- [ ] Poor network (disable WiFi) - should retry
- [ ] Invalid format rejection

### Both Platforms
- [ ] Complete upload flow with form submission
- [ ] Error message display
- [ ] Success notification
- [ ] Navigate away and back
- [ ] Concurrent uploads (multiple dialogs)

## Batch Upload Configuration

Default batch settings in `UploadService.batchUpload()`:

```dart
maxConcurrent = 3  // Max 3 files uploading simultaneously
```

**Why 3 concurrent?**
- Server doesn't get overwhelmed
- Good balance between speed and stability
- Works well on slow networks

**To adjust:**
```dart
// In ad_upload_dialog.dart _handleUpload()
galleryUrls = await uploadService.batchUpload(
  webGalleryFiles,
  maxConcurrent: 5,  // Change this value
);
```

## Performance Tips

1. **Image Compression**: Consider compressing images before upload
   - JPEG: 70-80% quality is usually sufficient
   - PNG: Use compression tools for large graphics

2. **Video Formats**: MP4 with H.264 codec is most compatible
   - Bitrate: 2-5 Mbps for good quality
   - Resolution: 1920x1080 max

3. **Batch Size**: For gallery with 50+ images
   - Keep maxConcurrent at 3 to avoid server/network issues
   - Consider progressive upload UI feedback

## Troubleshooting

### "Upload failed: File bytes required for web upload"
- **Cause**: File picker didn't capture bytes on web
- **Fix**: Ensure `withData: kIsWeb` in FilePicker.platform.pickFiles()

### "Upload failed: Invalid file path"
- **Cause**: File path is empty on mobile
- **Fix**: Ensure file picker has proper permissions configured

### "Upload failed after 3 attempts"
- **Cause**: Network connection issues
- **Fix**: Check internet connection, server availability
- **Debug**: Look for timeout or connection refused errors in logs

### Gallery images fail but main media succeeds
- **Cause**: Validation failing on gallery file format
- **Fix**: Remove or reselect invalid files
- **Debug**: Check for `⚠ Skipping invalid gallery file:` logs

### Very large files (100MB+) rejected
- **Cause**: File size exceeds 100MB limit
- **Fix**: Increase limit in UploadService if server allows
  ```dart
  static const int maxFileSizeBytes = 200 * 1024 * 1024;  // 200MB
  ```

## Server Requirements

Backend must:
1. Accept multipart/form-data uploads
2. Endpoint: `/api/upload/media` (or configured in ApiConfig)
3. Field name: `file`
4. Response format:
   ```json
   {
     "url": "/uploads/filename.jpg",
     "file_url": "/uploads/filename.jpg",
     "path": "/uploads/filename.jpg"
   }
   ```
   OR just return the URL as string

5. Accept files up to 100MB
6. Support concurrent uploads (batching)

## Future Improvements

- [ ] Progress indicator for large files
- [ ] Pause/Resume upload capability
- [ ] Automatic image compression before upload
- [ ] Chunked upload for very large files (>500MB)
- [ ] S3 direct upload support
- [ ] Upload queue persistence

## Code References

| File | Purpose | Key Method |
|------|---------|-----------|
| `upload_service.dart` | Core upload logic | `uploadFile()`, `batchUpload()` |
| `ad_provider.dart` | Ad data management | `uploadMedia()` |
| `ad_upload_dialog.dart` | Upload UI | `_handleUpload()` |
| `api_config.dart` | API endpoints | `uploadMedia` endpoint |

## Support

For issues:
1. Check debug output for error markers (❌, ✅, 📦, 🔄)
2. Verify file format is in allowed list
3. Check network connection
4. Review server logs for upload endpoint errors
5. Test with smaller files first
