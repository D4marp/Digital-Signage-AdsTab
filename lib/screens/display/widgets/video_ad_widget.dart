import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoAdWidget extends StatefulWidget {
  final String videoUrl;
  final VoidCallback? onEnded;

  const VideoAdWidget({
    super.key,
    required this.videoUrl,
    this.onEnded,
  });

  @override
  State<VideoAdWidget> createState() => _VideoAdWidgetState();
}

class _VideoAdWidgetState extends State<VideoAdWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));

    try {
      await _controller.initialize();
      await _controller.setLooping(false);
      await _controller.play();

      _controller.addListener(() {
        if (_controller.value.position >= _controller.value.duration) {
          widget.onEnded?.call();
        }
      });

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Center(
      child: AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: VideoPlayer(_controller),
      ),
    );
  }
}
