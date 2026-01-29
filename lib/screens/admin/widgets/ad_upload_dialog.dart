import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'dart:io' as io;
import '../../../providers/ad_provider.dart';
import '../../../utils/responsive_helper.dart';
import '../../../services/upload_service.dart';

class AdUploadDialog extends StatefulWidget {
  const AdUploadDialog({super.key});

  @override
  State<AdUploadDialog> createState() => _AdUploadDialogState();
}

class WebFileData {
  final String name;
  final List<int> bytes;

  WebFileData({required this.name, required this.bytes});
}

class _AdUploadDialogState extends State<AdUploadDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _contactInfoController = TextEditingController();
  final _websiteUrlController = TextEditingController();
  int _durationSeconds = 5;
  List<String> _targetLocations = ['all'];
  io.File? _selectedFile;
  List<int>? _fileBytes;
  String? _selectedFileName;
  String? _mediaType;
  bool _isUploading = false;
  List<io.File> _galleryFiles = [];
  List<WebFileData> _galleryFilesWeb = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _companyNameController.dispose();
    _contactInfoController.dispose();
    _websiteUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4', 'pdf'],
        withData: kIsWeb,
        withReadStream: !kIsWeb,
      );

      if (result != null && result.files.isNotEmpty) {
        final pickedFile = result.files.single;
        
        // Validate file data based on platform
        final hasValidData = kIsWeb 
          ? pickedFile.bytes != null && pickedFile.bytes!.isNotEmpty
          : pickedFile.path != null && pickedFile.path!.isNotEmpty;
          
        if (!hasValidData) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to load file. Please try again.')),
            );
          }
          return;
        }

        final extension = pickedFile.extension?.toLowerCase();
        
        setState(() {
          _selectedFileName = pickedFile.name;
          if (kIsWeb) {
            // For web, store bytes only (never access path on web)
            _fileBytes = pickedFile.bytes;
            _selectedFile = null;
          } else {
            // For mobile, store File with path
            _selectedFile = io.File(pickedFile.path!);
            _fileBytes = null;
          }
          
          if (extension == 'mp4') {
            _mediaType = 'video';
          } else if (extension == 'pdf') {
            _mediaType = 'pdf';
          } else {
            _mediaType = 'image';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking file: ${e.toString()}')),
        );
      }
      debugPrint('File pick error: $e');
    }
  }

  Future<void> _pickGalleryImages() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
        allowMultiple: true,
        withData: kIsWeb,
        withReadStream: !kIsWeb,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          if (kIsWeb) {
            // For web, store bytes only (never access path on web)
            _galleryFilesWeb = result.files
                .where((f) => f.bytes != null && f.bytes!.isNotEmpty)
                .map((f) => WebFileData(name: f.name, bytes: f.bytes!))
                .toList();
            _galleryFiles = [];
          } else {
            // For mobile, store File objects with paths
            _galleryFiles = result.files
                .where((f) => f.path != null && f.path!.isNotEmpty)
                .map((f) => io.File(f.path!))
                .toList();
            _galleryFilesWeb = [];
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking images: ${e.toString()}')),
        );
      }
      debugPrint('Gallery pick error: $e');
    }
  }

  void _removeGalleryImage(int index) {
    setState(() {
      if (kIsWeb) {
        _galleryFilesWeb.removeAt(index);
      } else {
        _galleryFiles.removeAt(index);
      }
    });
  }

  Future<void> _handleUpload() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    if (kIsWeb && _fileBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a main image/video/pdf')),
      );
      return;
    }

    if (!kIsWeb && _selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a main image/video/pdf')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final adProvider = context.read<AdProvider>();
      final uploadService = UploadService();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${_selectedFileName ?? "file"}';
      
      debugPrint('========== UPLOAD START ==========');
      debugPrint('Platform: ${kIsWeb ? "WEB" : "MOBILE"}');
      debugPrint('Main file: $fileName');
      debugPrint('File bytes available: ${_fileBytes != null ? _fileBytes!.isNotEmpty : false}');
      debugPrint('Gallery items: ${kIsWeb ? _galleryFilesWeb.length : _galleryFiles.length}');
      
      // Validate main file
      if (!uploadService.validateFile(fileName)) {
        throw Exception('Invalid main file format or size');
      }
      
      // Upload main media with retry logic via uploadMedia
      debugPrint('Uploading main media with retry logic...');
      final mediaUrl = await adProvider.uploadMedia(
        _selectedFile,
        fileName,
        fileBytes: kIsWeb ? _fileBytes : null,
      );
      debugPrint('✓ Main media uploaded: $mediaUrl');

      // Upload gallery images with optimized batch processing
      List<String> galleryUrls = [];
      
      if (kIsWeb && _galleryFilesWeb.isNotEmpty) {
        debugPrint('Processing ${_galleryFilesWeb.length} web gallery images...');
        
        // Use batch upload for better performance on web
        final webGalleryFiles = _galleryFilesWeb.asMap().entries.map((entry) {
          final i = entry.key;
          final webFile = entry.value;
          return {
            'name': 'gallery_${DateTime.now().millisecondsSinceEpoch}_${i}_${webFile.name}',
            'bytes': webFile.bytes,
          };
        }).toList();
        
        // Batch upload with concurrency limit
        galleryUrls = await uploadService.batchUpload(webGalleryFiles);
        debugPrint('✓ Uploaded ${galleryUrls.length} web gallery images');
        
      } else if (!kIsWeb && _galleryFiles.isNotEmpty) {
        debugPrint('Processing ${_galleryFiles.length} mobile gallery images...');
        
        // Process mobile gallery files
        List<Map<String, dynamic>> mobileGalleryFiles = [];
        for (var i = 0; i < _galleryFiles.length; i++) {
          final file = _galleryFiles[i];
          final fileExtName = file.path.split('/').last;
          final galleryFileName = 'gallery_${DateTime.now().millisecondsSinceEpoch}_${i}_$fileExtName';
          
          // Validate each gallery file
          if (!uploadService.validateFile(galleryFileName)) {
            debugPrint('⚠ Skipping invalid gallery file: $galleryFileName');
            continue;
          }
          
          mobileGalleryFiles.add({
            'name': galleryFileName,
            'file': file,
          });
        }
        
        // Batch upload mobile files
        if (mobileGalleryFiles.isNotEmpty) {
          galleryUrls = await uploadService.batchUpload(mobileGalleryFiles);
          debugPrint('✓ Uploaded ${galleryUrls.length} mobile gallery images');
        }
      }

      debugPrint('Creating ad with ${galleryUrls.length} gallery images...');
      final success = await adProvider.createAd(
        title: _titleController.text.trim(),
        mediaUrl: mediaUrl,
        mediaType: _mediaType!,
        durationSeconds: _durationSeconds,
        targetLocations: _targetLocations,
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        companyName: _companyNameController.text.trim().isEmpty 
            ? null 
            : _companyNameController.text.trim(),
        contactInfo: _contactInfoController.text.trim().isEmpty 
            ? null 
            : _contactInfoController.text.trim(),
        websiteUrl: _websiteUrlController.text.trim().isEmpty 
            ? null 
            : _websiteUrlController.text.trim(),
        galleryImages: galleryUrls.isNotEmpty ? galleryUrls : null,
      );

      debugPrint('========== UPLOAD COMPLETE ==========');
      debugPrint('Ad creation: ${success ? "SUCCESS" : "FAILED"}');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Ad uploaded successfully!' : 'Ad creation failed'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
        Navigator.of(context).pop(success);
      }
    } catch (e) {
      debugPrint('❌ UPLOAD ERROR: $e');
      debugPrint('Error type: ${e.runtimeType}');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dialogWidth = ResponsiveHelper.getDialogWidth(context);

    return Dialog(
      child: Container(
        width: dialogWidth,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.95,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade600, Colors.blue.shade400],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Upload New Ad',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Create a new advertisement campaign',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: _isUploading ? null : () => Navigator.of(context).pop(false),
                  ),
                ],
              ),
            ),
            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Main Media Preview Section
                      Text(
                        'Main Media',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // File picker with enhanced preview
                      InkWell(
                        onTap: _isUploading ? null : _pickFile,
                        child: Container(
                          height: _selectedFile != null ? 280 : 200,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: _selectedFile != null 
                              ? Colors.grey.shade50
                              : Colors.grey.shade100,
                          ),
                          child: _selectedFile == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade100,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.cloud_upload_outlined,
                                        size: 48,
                                        color: Colors.blue.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Click to select image, video or PDF',
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Supported: JPG, PNG, MP4, PDF',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Max size: 50MB',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade500,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                )
                              : Stack(
                                  children: [
                                    // Image Preview
                                    if (_mediaType == 'image' && (kIsWeb ? _fileBytes != null : _selectedFile != null))
                                      Center(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: kIsWeb && _fileBytes != null
                                              ? Image.memory(
                                                  Uint8List.fromList(_fileBytes!),
                                                  fit: BoxFit.contain,
                                                )
                                              : !kIsWeb && _selectedFile != null
                                                  ? Image.file(
                                                      _selectedFile!,
                                                      fit: BoxFit.contain,
                                                    )
                                                  : const SizedBox.shrink(),
                                        ),
                                      )
                                    else
                                      Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(20),
                                              decoration: BoxDecoration(
                                                color: _mediaType == 'video'
                                                    ? Colors.orange.shade100
                                                    : Colors.red.shade100,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                _mediaType == 'video'
                                                    ? Icons.videocam
                                                    : Icons.picture_as_pdf,
                                                size: 48,
                                                color: _mediaType == 'video'
                                                    ? Colors.orange.shade600
                                                    : Colors.red.shade600,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              _selectedFileName ?? 'file',
                                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    // Change button
                                    Positioned(
                                      bottom: 8,
                                      right: 8,
                                      child: ElevatedButton.icon(
                                        onPressed: _isUploading ? null : _pickFile,
                                        icon: const Icon(Icons.edit, size: 16),
                                        label: const Text('Change'),
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Form Section
                      Text(
                        'Ad Information',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Title
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Ad Title *',
                          hintText: 'Enter ad title',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.title),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description (Optional)',
                          hintText: 'Enter ad description',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.description),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      // Company Name
                      TextFormField(
                        controller: _companyNameController,
                        decoration: InputDecoration(
                          labelText: 'Company Name (Optional)',
                          hintText: 'Your company name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.business),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Contact Info
                      TextFormField(
                        controller: _contactInfoController,
                        decoration: InputDecoration(
                          labelText: 'Contact Info (Optional)',
                          hintText: 'Email or phone number',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.phone),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Website URL
                      TextFormField(
                        controller: _websiteUrlController,
                        decoration: InputDecoration(
                          labelText: 'Website URL (Optional)',
                          hintText: 'https://example.com',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.language),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Display Settings Section
                      Text(
                        'Display Settings',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Duration
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.shade50,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Display Duration',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '$_durationSeconds seconds',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Slider(
                              value: _durationSeconds.toDouble(),
                              min: 3,
                              max: 60,
                              divisions: 57,
                              label: '${_durationSeconds}s',
                              activeColor: Colors.blue.shade600,
                              onChanged: (value) {
                                setState(() {
                                  _durationSeconds = value.toInt();
                                });
                              },
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '3s',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                Text(
                                  '60s',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Gallery Images Section
                      Text(
                        'Gallery Images (Optional)',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.shade50,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  (kIsWeb ? _galleryFilesWeb.isEmpty : _galleryFiles.isEmpty)
                                      ? 'No gallery images selected'
                                      : '${kIsWeb ? _galleryFilesWeb.length : _galleryFiles.length} image(s) selected',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: _isUploading ? null : _pickGalleryImages,
                                  icon: const Icon(Icons.add_photo_alternate, size: 18),
                                  label: const Text('Add Images'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (kIsWeb ? _galleryFilesWeb.isEmpty : _galleryFiles.isEmpty)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 24),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.image_not_supported,
                                        size: 40,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Add up to 5 promotional images',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: List.generate(
                                  kIsWeb ? _galleryFilesWeb.length : _galleryFiles.length,
                                  (index) {
                                    return Stack(
                                      children: [
                                        Container(
                                          width: 120,
                                          height: 120,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.grey.shade300,
                                            ),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: kIsWeb && _galleryFilesWeb.isNotEmpty
                                                ? Image.memory(
                                                    Uint8List.fromList(_galleryFilesWeb[index].bytes),
                                                    fit: BoxFit.cover,
                                                  )
                                                : Image.file(
                                                    _galleryFiles[index],
                                                    fit: BoxFit.cover,
                                                  ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: InkWell(
                                            onTap: () => _removeGalleryImage(index),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.red.shade500,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Target Locations
                      Text(
                        'Target Locations',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.shade50,
                        ),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            FilterChip(
                              label: const Text('All Locations'),
                              selected: _targetLocations.contains('all'),
                              selectedColor: Colors.blue.shade100,
                              labelStyle: TextStyle(
                                color: _targetLocations.contains('all')
                                    ? Colors.blue.shade700
                                    : Colors.grey.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _targetLocations = ['all'];
                                  } else {
                                    _targetLocations.remove('all');
                                  }
                                });
                              },
                            ),
                            FilterChip(
                              label: const Text('Location 1'),
                              selected: _targetLocations.contains('location1'),
                              selectedColor: Colors.blue.shade100,
                              labelStyle: TextStyle(
                                color: _targetLocations.contains('location1')
                                    ? Colors.blue.shade700
                                    : Colors.grey.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _targetLocations.remove('all');
                                    _targetLocations.add('location1');
                                  } else {
                                    _targetLocations.remove('location1');
                                  }
                                });
                              },
                            ),
                            FilterChip(
                              label: const Text('Location 2'),
                              selected: _targetLocations.contains('location2'),
                              selectedColor: Colors.blue.shade100,
                              labelStyle: TextStyle(
                                color: _targetLocations.contains('location2')
                                    ? Colors.blue.shade700
                                    : Colors.grey.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _targetLocations.remove('all');
                                    _targetLocations.add('location2');
                                  } else {
                                    _targetLocations.remove('location2');
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
                color: Colors.grey.shade50,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isUploading ? null : () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _isUploading ? null : _handleUpload,
                    icon: _isUploading 
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Icon(Icons.cloud_upload_outlined),
                    label: _isUploading ? const Text('Uploading...') : const Text('Upload Ad'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      backgroundColor: Colors.blue.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

