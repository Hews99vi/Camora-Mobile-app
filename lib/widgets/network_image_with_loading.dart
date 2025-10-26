import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class NetworkImageWithLoading extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const NetworkImageWithLoading({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildPlaceholder();
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Container(
        width: width,
        height: height,
        color: Colors.white,
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          fit: fit,
          placeholder: (context, url) => _buildLoadingState(),
          errorWidget: (context, url, error) => _buildPlaceholder(),
          fadeInDuration: const Duration(milliseconds: 300),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      color: Colors.white,
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 32,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              'No Image',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}