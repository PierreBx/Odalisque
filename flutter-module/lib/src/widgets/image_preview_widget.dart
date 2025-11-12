import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';

/// A widget for displaying image previews with thumbnail and lightbox functionality
class ImagePreviewWidget extends StatelessWidget {
  /// The image source (URL or base64 data URL)
  final String imageSource;

  /// Width of the thumbnail
  final double? thumbnailWidth;

  /// Height of the thumbnail
  final double? thumbnailHeight;

  /// Border radius for the thumbnail
  final double borderRadius;

  /// Whether to show a lightbox when clicked
  final bool enableLightbox;

  /// Fit for the thumbnail image
  final BoxFit fit;

  const ImagePreviewWidget({
    super.key,
    required this.imageSource,
    this.thumbnailWidth,
    this.thumbnailHeight = 100,
    this.borderRadius = 8,
    this.enableLightbox = true,
    this.fit = BoxFit.cover,
  });

  bool get _isDataUrl => imageSource.startsWith('data:image');

  Uint8List? get _imageBytes {
    if (_isDataUrl) {
      try {
        // Extract base64 data from data URL
        final base64Data = imageSource.split(',')[1];
        return base64Decode(base64Data);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  void _showLightbox(BuildContext context) {
    if (!enableLightbox) return;

    showDialog(
      context: context,
      builder: (context) => ImageLightbox(
        imageSource: imageSource,
        imageBytes: _imageBytes,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enableLightbox ? () => _showLightbox(context) : null,
      child: Container(
        width: thumbnailWidth,
        height: thumbnailHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: Colors.grey.shade300),
        ),
        clipBehavior: Clip.antiAlias,
        child: _isDataUrl && _imageBytes != null
            ? Image.memory(
                _imageBytes!,
                fit: fit,
                errorBuilder: (context, error, stackTrace) {
                  return _buildErrorWidget();
                },
              )
            : Image.network(
                imageSource,
                fit: fit,
                errorBuilder: (context, error, stackTrace) {
                  return _buildErrorWidget();
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey.shade100,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, size: 32, color: Colors.grey),
            SizedBox(height: 4),
            Text(
              'Image failed to load',
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-screen lightbox viewer for images
class ImageLightbox extends StatelessWidget {
  final String imageSource;
  final Uint8List? imageBytes;

  const ImageLightbox({
    super.key,
    required this.imageSource,
    this.imageBytes,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black87,
      insetPadding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          // Image
          Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: imageBytes != null
                  ? Image.memory(
                      imageBytes!,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image,
                                size: 64,
                                color: Colors.white54,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Failed to load image',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  : Image.network(
                      imageSource,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image,
                                size: 64,
                                color: Colors.white54,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Failed to load image',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
            ),
          ),

          // Close button
          Positioned(
            top: 16,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 32),
              onPressed: () => Navigator.of(context).pop(),
              tooltip: 'Close',
            ),
          ),

          // Instructions
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Pinch to zoom • Drag to pan',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Gallery widget for displaying multiple images
class ImageGalleryWidget extends StatelessWidget {
  final List<String> imageSources;
  final double thumbnailSize;
  final double spacing;
  final int crossAxisCount;

  const ImageGalleryWidget({
    super.key,
    required this.imageSources,
    this.thumbnailSize = 100,
    this.spacing = 8,
    this.crossAxisCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    if (imageSources.isEmpty) {
      return const SizedBox.shrink();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: 1,
      ),
      itemCount: imageSources.length,
      itemBuilder: (context, index) {
        return ImagePreviewWidget(
          imageSource: imageSources[index],
          thumbnailWidth: thumbnailSize,
          thumbnailHeight: thumbnailSize,
        );
      },
    );
  }
}
