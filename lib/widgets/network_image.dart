import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class NetworkImageWithFallback extends StatelessWidget {
  final String? imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;

  const NetworkImageWithFallback({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildPlaceholder();
    }

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      fit: fit,
      width: width,
      height: height,
      placeholder: (context, url) => _buildLoadingIndicator(),
      errorWidget: (context, url, error) => _buildPlaceholder(),
      memCacheWidth: 800, // Add reasonable cache size
      memCacheHeight: 800,
      maxWidthDiskCache: 800,
      maxHeightDiskCache: 800,
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[100],
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[100],
      child: Icon(
        Icons.photo_library,
        color: Colors.grey[400],
        size: 32,
      ),
    );
  }
}