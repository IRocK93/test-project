import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Full-screen photo viewer with swipe left/right navigation, pinch-to-zoom,
/// and double-tap zoom toggle.
///
/// Uses a [PageView] to browse through all album photos. The [Hero] tag is
/// only applied to the initial photo (the one the user tapped) so the
/// shared-element transition animates correctly from the grid. Swiping to
/// other photos works without Hero transitions, and popping from a
/// non-initial photo simply fades out.
///
/// Pinch-to-zoom is handled by [InteractiveViewer] with a 1.0x–4.0x range.
/// Double-tap toggles between 1.0x and 2.5x zoom. When zoomed in, tap-to-dismiss
/// is suppressed to avoid accidental pops while panning.
class PhotoViewerPage extends StatefulWidget {
  final List<Map<String, dynamic>> photos;
  final int initialIndex;

  const PhotoViewerPage({
    super.key,
    required this.photos,
    required this.initialIndex,
  });

  @override
  State<PhotoViewerPage> createState() => _PhotoViewerPageState();
}

class _PhotoViewerPageState extends State<PhotoViewerPage> {
  late PageController _pageController;
  late int _currentIndex;

  /// Controls the zoom transformation for the current photo.
  /// Reset when navigating to a new page.
  final TransformationController _transformController =
      TransformationController();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _transformController.dispose();
    super.dispose();
  }

  /// Called when the user double-taps a photo.
  /// Toggles between 1.0x (fit) and 2.5x (zoomed in).
  void _handleDoubleTap() {
    final currentScale = _transformController.value.getMaxScaleOnAxis();
    if (currentScale < 1.5) {
      _transformController.value = Matrix4.diagonal3Values(2.5, 2.5, 1.0);
    } else {
      _transformController.value = Matrix4.identity();
    }
  }

  /// Resets zoom when the user swipes to a different photo.
  void _onPageChanged(int index) {
    _transformController.value = Matrix4.identity();
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.92),
              Colors.black.withValues(alpha: 0.95),
              Colors.black.withValues(alpha: 0.92),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // PageView for swipe left/right navigation
              PageView.builder(
                controller: _pageController,
                itemCount: widget.photos.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  final photo = widget.photos[index];
                  final url = photo['url']?.toString() ?? '';
                  final caption = photo['caption']?.toString();
                  final isInitialPage = index == widget.initialIndex;
                  final heroTag = 'photo_${photo['id'] ?? url}';

                  return Semantics(
                    label: 'Dismiss photo',
                    child: GestureDetector(
                      onTap: () {
                        // Only dismiss if not zoomed in
                        final scale =
                            _transformController.value.getMaxScaleOnAxis();
                        if (scale < 1.1) {
                          Navigator.pop(context);
                        }
                      },
                      onDoubleTap: _handleDoubleTap,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isInitialPage)
                            Hero(
                              tag: heroTag,
                              child: _buildZoomablePhoto(url),
                            )
                          else
                            _buildZoomablePhoto(url),
                          if (caption != null && caption.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              child: Text(
                                caption,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 15,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    ),
                  );
                },
              ),
              // Back button — visible arrow to return to album
              Positioned(
                top: 12,
                left: 12,
                child: Semantics(
                  label: 'Back to album',
                  child: Material(
                    color: Colors.white.withValues(alpha: 0.25),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        child: const Icon(PhosphorIconsLight.arrowLeft, color: Colors.white, size: 22),
                      ),
                    ),
                  ),
                ),
              ),
              // Bottom: dismiss hint + page indicator
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Swipe to browse  •  Tap to go back',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${_currentIndex + 1} / ${widget.photos.length}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a zoomable photo wrapped in [InteractiveViewer] for
  /// pinch-to-zoom and pan gestures.
  Widget _buildZoomablePhoto(String url) {
    return InteractiveViewer(
      transformationController: _transformController,
      minScale: 1.0,
      maxScale: 4.0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.contain,
          placeholder: (ctx, url) => const SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: Colors.white54,
            ),
          ),
          errorWidget: (ctx, url, error) => const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ExcludeSemantics(
                child: Icon(PhosphorIconsLight.imageBroken,
                    color: Colors.white54, size: 48),
              ),
              SizedBox(height: 12),
              Text('Failed to load image',
                  style: TextStyle(color: Colors.white54)),
            ],
          ),
        ),
      ),
    );
  }
}
