import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../../providers/ad_provider.dart';
import '../../../utils/responsive_helper.dart';

class AdUploadDialog extends StatefulWidget {
  const AdUploadDialog({super.key});

  @override
  State<AdUploadDialog> createState() => _AdUploadDialogState();
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
  File? _selectedFile;
  String? _mediaType;
  bool _isUploading = false;
  List<File> _galleryFiles = [];

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
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4', 'pdf'],
    );

    if (result != null) {
      final file = File(result.files.single.path!);
      final extension = result.files.single.extension?.toLowerCase();

      setState(() {
        _selectedFile = file;
        if (extension == 'mp4') {
          _mediaType = 'video';
        } else if (extension == 'pdf') {
          _mediaType = 'pdf';
        } else {
          _mediaType = 'image';
        }
      });
    }
  }

  Future<void> _pickGalleryImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        _galleryFiles = result.files.map((f) => File(f.path!)).toList();
      });
    }
  }

  void _removeGalleryImage(int index) {
    setState(() {
      _galleryFiles.removeAt(index);
    });
  }

  Future<void> _handleUpload() async {
    if (!_formKey.currentState!.validate() || _selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a main image/video/pdf')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final adProvider = context.read<AdProvider>();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${_selectedFile!.path.split('/').last}';
      final mediaUrl = await adProvider.uploadMedia(_selectedFile!, fileName);

      // Upload gallery images
      List<String> galleryUrls = [];
      for (var i = 0; i < _galleryFiles.length; i++) {
        final file = _galleryFiles[i];
        final galleryFileName = 'gallery_${DateTime.now().millisecondsSinceEpoch}_${i}_${file.path.split('/').last}';
        final galleryUrl = await adProvider.uploadMedia(file, galleryFileName);
        galleryUrls.add(galleryUrl);
      }

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

      if (mounted) {
        Navigator.of(context).pop(success);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Upload New Ad',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _isUploading ? null : () => Navigator.of(context).pop(false),
                  ),
                ],
              ),
            ),
            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // File picker
                      InkWell(
                        onTap: _isUploading ? null : _pickFile,
                        child: Container(
                          height: 150,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[100],
                          ),
                          child: _selectedFile == null
                              ? const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.cloud_upload, size: 48, color: Colors.grey),
                                    SizedBox(height: 8),
                                    Text('Click to select image, video or PDF'),
                                    SizedBox(height: 4),
                                    Text(
                                      'Supported: JPG, PNG, MP4, PDF',
                                      style: TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _mediaType == 'video'
                                          ? Icons.videocam
                                          : _mediaType == 'pdf'
                                              ? Icons.picture_as_pdf
                                              : Icons.image,
                                      size: 48,
                                      color: Colors.green,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _selectedFile!.path.split('/').last,
                                      style: const TextStyle(fontSize: 12),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Title
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Ad Title',
                          hintText: 'Enter ad title',
                          border: OutlineInputBorder(),
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
                        decoration: const InputDecoration(
                          labelText: 'Description (Optional)',
                          hintText: 'Enter ad description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),

                      // Company Name
                      TextFormField(
                        controller: _companyNameController,
                        decoration: const InputDecoration(
                          labelText: 'Company Name (Optional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Contact Info
                      TextFormField(
                        controller: _contactInfoController,
                        decoration: const InputDecoration(
                          labelText: 'Contact Info (Optional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Website URL
                      TextFormField(
                        controller: _websiteUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Website URL (Optional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Duration
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Display Duration: ${_durationSeconds}s',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Slider(
                                value: _durationSeconds.toDouble(),
                                min: 3,
                                max: 60,
                                divisions: 57,
                                label: '${_durationSeconds}s',
                                onChanged: (value) {
                                  setState(() {
                                    _durationSeconds = value.toInt();
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Gallery Images (Optional)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Gallery Images (Optional)',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: _isUploading ? null : _pickGalleryImages,
                                    icon: const Icon(Icons.add_photo_alternate),
                                    label: const Text('Add Images'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (_galleryFiles.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 24),
                                  child: Center(
                                    child: Text(
                                      'No gallery images selected\n(Up to 5 promotional images)',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ),
                                )
                              else
                                Column(
                                  children: [
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: List.generate(_galleryFiles.length, (index) {
                                        return Stack(
                                          children: [
                                            Container(
                                              width: 100,
                                              height: 100,
                                              decoration: BoxDecoration(
                                                border: Border.all(color: Colors.grey),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: Image.file(
                                                  _galleryFiles[index],
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: -8,
                                              right: -8,
                                              child: IconButton(
                                                onPressed: () => _removeGalleryImage(index),
                                                icon: const Icon(Icons.cancel, color: Colors.red),
                                                iconSize: 24,
                                              ),
                                            ),
                                          ],
                                        );
                                      }),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${_galleryFiles.length} image(s) selected',
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Target Locations
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Target Locations',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  FilterChip(
                                    label: const Text('All Locations'),
                                    selected: _targetLocations.contains('all'),
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
                            ],
                          ),
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
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isUploading ? null : () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _isUploading ? null : _handleUpload,
                    icon: _isUploading ? null : const Icon(Icons.upload),
                    label: _isUploading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Upload'),
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
