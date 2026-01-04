import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web; // For platform view registry
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../discussion/discussion_section.dart';

class VideoPlayerWidget extends StatefulWidget {
  final Map<String, dynamic> video;
  const VideoPlayerWidget({super.key, required this.video});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late String _viewId;
  bool _isPlaying = false;
  bool _isYouTube = false;
  VideoPlayerController? _assetController;
  bool _isAssetInitialized = false;

  @override
  void initState() {
    super.initState();
    final url = widget.video['videoUrl'] as String;
    
    // Determine if YouTube or Local Asset
    if (url.contains('http') || url.contains('youtu')) {
      _isYouTube = true;
      _initializeYouTube(url);
    } else {
      _isYouTube = false;
      _initializeAsset(url);
    }
  }
  
  void _initializeYouTube(String url) {
    // Generate unique ID for this video player instance
    final videoId = _extractVideoId(url);
    _viewId = 'youtube-player-${DateTime.now().millisecondsSinceEpoch}';
    
    // Register the iframe factory
    // This creates a pure HTML iframe element, bypassing Flutter's complex rendering
    ui_web.platformViewRegistry.registerViewFactory(_viewId, (int viewId) {
      final iframe = html.IFrameElement()
        ..src = 'https://www.youtube.com/embed/$videoId?autoplay=1&mute=0&playsinline=1&controls=1&rel=0'
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..allow = 'autoplay; fullscreen; encrypted-media; picture-in-picture';
      
      return iframe;
    });
  }

  Future<void> _initializeAsset(String path) async {
    _assetController = VideoPlayerController.asset(path);
    try {
      await _assetController!.initialize();
      setState(() {
        _isAssetInitialized = true;
      });
    } catch (e) {
      debugPrint('Error initializing video asset: $e');
    }
  }

  @override
  void dispose() {
    _assetController?.dispose();
    super.dispose();
  }

  String? _extractVideoId(String? url) {
    if (url == null) return null;
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    if (uri.queryParameters.containsKey('v')) return uri.queryParameters['v'];
    if (uri.host.contains('youtu.be')) return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    return null;
  }

  void _showDiscussion() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.85,
        child: DiscussionSection(
          contentId: 'video_${widget.video['title']}',
          contentTitle: widget.video['title'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.video['title'],
          style: const TextStyle(color: Colors.white, fontSize: 16),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.forum_outlined, color: Color(0xFF4ECDC4)),
            onPressed: _showDiscussion,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Video Area with constrained height
            Container(
              color: Colors.black,
              width: double.infinity,
              constraints: BoxConstraints(
                maxHeight: isLandscape ? screenHeight * 0.8 : screenHeight * 0.6,
              ),
              child: Center(
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: _isPlaying
                      ? (_isYouTube
                          ? HtmlElementView(viewType: _viewId)
                          : (_isAssetInitialized
                              ? Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    VideoPlayer(_assetController!),
                                    VideoProgressIndicator(
                                      _assetController!,
                                      allowScrubbing: true,
                                      colors: const VideoProgressColors(
                                          playedColor: Color(0xFF4ECDC4)),
                                    ),
                                    _ControlsOverlay(controller: _assetController!),
                                  ],
                                )
                              : const Center(
                                  child: CircularProgressIndicator(
                                      color: Color(0xFF4ECDC4)))))
                      : Stack(
                          fit: StackFit.expand,
                          children: [
                            // Thumbnail
                            if (widget.video['thumbnail'] != null)
                              Image.network(
                                widget.video['thumbnail'],
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    Container(color: Colors.grey[900]),
                              ),
                            // Play Button
                            Center(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  iconSize: 64,
                                  icon: const Icon(Icons.play_circle_fill,
                                      color: Color(0xFF4ECDC4)),
                                  onPressed: () {
                                    setState(() => _isPlaying = true);
                                    if (!_isYouTube && _assetController != null) {
                                      _assetController!.play();
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),

            // Info Area
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.video['title'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      _buildInfoChip(
                        icon: Icons.category,
                        text: widget.video['category'],
                        isCategory: true,
                      ),
                      _buildInfoChip(
                        icon: Icons.access_time,
                        text: widget.video['duration'],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Deskripsi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.video['description'],
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _showDiscussion,
                    icon: const Icon(Icons.forum_outlined),
                    label: const Text('Diskusi & Komentar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4ECDC4),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  // Extra padding for bottom spacing
                   const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildInfoChip({
    required IconData icon,
    required String text,
    bool isCategory = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isCategory
            ? const Color(0xFF4ECDC4).withValues(alpha: 0.2)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isCategory ? const Color(0xFF4ECDC4) : Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: isCategory ? const Color(0xFF4ECDC4) : Colors.grey,
              fontSize: isCategory ? 11 : 14,
              fontWeight: isCategory ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({required this.controller});

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 50),
          reverseDuration: const Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? const SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 50.0,
                      semanticLabel: 'Play',
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
      ],
    );
  }
}