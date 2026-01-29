import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'dart:io' as io;
import '../config/api_config.dart';
import 'api_client.dart';

/// Service untuk handle upload file di web dan mobile platform
class UploadService {
  static const int maxFileSizeBytes = 100 * 1024 * 1024; // 100MB
  static const List<String> allowedImageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
  static const List<String> allowedVideoExtensions = ['mp4', 'avi', 'mov', 'mkv'];
  static const List<String> allowedPdfExtensions = ['pdf'];

  final ApiClient _apiClient = ApiClient();

  /// Validasi file sebelum upload
  static bool isValidFile(String fileName, int fileSize) {
    if (fileSize > maxFileSizeBytes) {
      debugPrint('❌ File terlalu besar: $fileSize bytes (max: $maxFileSizeBytes)');
      return false;
    }

    final ext = fileName.split('.').last.toLowerCase();
    final isValid = allowedImageExtensions.contains(ext) ||
        allowedVideoExtensions.contains(ext) ||
        allowedPdfExtensions.contains(ext);

    if (!isValid) {
      debugPrint('❌ Format file tidak didukung: $ext');
    }

    return isValid;
  }

  /// Validasi file sebelum upload (wrapper untuk isValidFile)
  bool validateFile(String fileName) {
    // Untuk validasi, kita anggap ukuran file reasonable
    // Akses sebenarnya akan dilakukan saat upload
    final ext = fileName.split('.').last.toLowerCase();
    final isValid = allowedImageExtensions.contains(ext) ||
        allowedVideoExtensions.contains(ext) ||
        allowedPdfExtensions.contains(ext);

    if (!isValid) {
      debugPrint('❌ Invalid file format: $ext');
    }

    return isValid;
  }

  /// Batch upload multiple files dengan concurrency control
  static String getMediaType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    if (allowedImageExtensions.contains(ext)) return 'image';
    if (allowedVideoExtensions.contains(ext)) return 'video';
    if (allowedPdfExtensions.contains(ext)) return 'pdf';
    return 'unknown';
  }

  /// Upload file dengan retry logic dan error handling
  Future<String> uploadFile(
    String fileName, {
    io.File? file,
    List<int>? fileBytes,
    int retries = 3,
  }) async {
    int attempt = 0;

    while (attempt < retries) {
      attempt++;

      try {
        // Validasi input
        if (file == null && fileBytes == null) {
          throw Exception('❌ File atau fileBytes harus disediakan');
        }

        if (fileBytes != null && fileBytes.isEmpty) {
          throw Exception('❌ File bytes kosong');
        }

        if (file != null && !kIsWeb && file.path.isEmpty) {
          throw Exception('❌ File path kosong');
        }

        // Validasi ukuran file
        late int fileSize;
        if (kIsWeb && fileBytes != null) {
          fileSize = fileBytes.length;
        } else if (!kIsWeb && file != null) {
          fileSize = await file.length();
        }

        if (!isValidFile(fileName, fileSize)) {
          throw Exception('❌ File tidak valid (ukuran atau format)');
        }

        debugPrint('📤 Upload attempt $attempt/$retries - File: $fileName, Size: $fileSize bytes');

        MultipartFile? multipartFile;

        // Handle web platform - gunakan fileBytes
        if (kIsWeb) {
          if (fileBytes == null || fileBytes.isEmpty) {
            throw Exception('❌ File bytes diperlukan untuk web');
          }
          debugPrint('  Platform: Web');
          debugPrint('  File bytes length: ${fileBytes.length}');

          multipartFile = MultipartFile.fromBytes(
            fileBytes,
            filename: fileName,
          );
        }
        // Handle mobile platform - gunakan file path
        else {
          if (file == null) {
            throw Exception('❌ File diperlukan untuk mobile');
          }

          final filePath = file.path;
          if (filePath.isEmpty) {
            throw Exception('❌ File path kosong');
          }

          debugPrint('  Platform: Mobile (Android/iOS)');
          debugPrint('  File path: $filePath');
          debugPrint('  File exists: ${file.existsSync()}');

          if (!file.existsSync()) {
            throw Exception('❌ File tidak ada di path: $filePath');
          }

          multipartFile = await MultipartFile.fromFile(
            filePath,
            filename: fileName,
          );
        }

        // Create FormData
        final formData = FormData();
        formData.files.add(MapEntry('file', multipartFile));

        debugPrint('  Endpoint: ${ApiConfig.uploadMedia}');
        debugPrint('  FormData file: ${multipartFile.filename}');

        // Send request dengan timeout
        final response = await _apiClient.dio.post(
          ApiConfig.uploadMedia,
          data: formData,
          options: Options(
            sendTimeout: const Duration(minutes: 5),
            receiveTimeout: const Duration(minutes: 5),
          ),
        ).timeout(
          const Duration(minutes: 5),
          onTimeout: () {
            throw Exception('❌ Upload timeout setelah 5 menit');
          },
        );

        debugPrint('  Response status: ${response.statusCode}');
        debugPrint('  Response data type: ${response.data.runtimeType}');

        // Validasi response
        if (response.statusCode != 200 && response.statusCode != 201) {
          throw Exception('❌ Upload gagal: HTTP ${response.statusCode}');
        }

        // Extract URL dari response
        final responseData = response.data;
        String uploadedUrl = '';

        if (responseData is Map) {
          uploadedUrl = responseData['url'] ?? 
                       responseData['file_url'] ?? 
                       responseData['path'] ?? 
                       '';
        } else if (responseData is String) {
          uploadedUrl = responseData;
        }

        if (uploadedUrl.isEmpty) {
          throw Exception('❌ URL tidak ditemukan di response: $responseData');
        }

        // Construct full URL
        final fullUrl = uploadedUrl.startsWith('http') 
            ? uploadedUrl 
            : ApiConfig.uploadBaseUrl + uploadedUrl;

        debugPrint('✅ Upload berhasil: $fullUrl');
        return fullUrl;
      } catch (e) {
        debugPrint('❌ Upload error attempt $attempt: $e');

        // Retry jika masih ada kesempatan dan error adalah network related
        if (attempt < retries && (e is DioException || e.toString().contains('timeout'))) {
          debugPrint('  🔄 Retry dalam 2 detik...');
          await Future.delayed(const Duration(seconds: 2));
          continue;
        }

        // Throw error jika sudah last attempt atau error tidak recoverable
        throw Exception('❌ Upload gagal setelah $attempt attempts: $e');
      }
    }

    throw Exception('❌ Upload gagal: maximum retries exceeded');
  }

  /// Batch upload dengan smart format handling untuk web dan mobile
  Future<List<String>> batchUpload(
    List<Map<String, dynamic>> files, {
    int maxConcurrent = 3,
  }) async {
    final results = <String>[];

    // Handle files sequentially atau batch based on platform
    for (int i = 0; i < files.length; i += maxConcurrent) {
      final batch = files.sublist(
        i,
        i + maxConcurrent > files.length ? files.length : i + maxConcurrent,
      );

      debugPrint('📦 Batch ${i ~/ maxConcurrent + 1}: uploading ${batch.length} files');

      try {
        final batchResults = await Future.wait(
          batch.map((f) {
            final fileName = f['name'] as String;
            final file = f['file'] as io.File?;
            final fileBytes = f['bytes'] as List<int>?;
            
            return uploadFile(
              fileName,
              file: file,
              fileBytes: fileBytes,
            ).catchError((e) {
              debugPrint('❌ Error uploading $fileName: $e');
              return ''; // Return empty string on error
            });
          }),
          eagerError: false,
        );

        // Filter out empty strings (failed uploads) and add successful ones
        results.addAll(batchResults.where((r) => r.isNotEmpty));
      } catch (e) {
        debugPrint('❌ Batch upload error: $e');
      }
    }

    debugPrint('✅ Batch upload complete: ${results.length}/${files.length} files uploaded');
    return results;
  }
}
