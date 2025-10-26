import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/product.dart';
import '../controllers/product_controller.dart';

class ProductCardV2 extends GetView<ProductController> {
  final Product product;
  final VoidCallback? onTap;

  const ProductCardV2({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: _buildProductImage(),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _buildWishlistButton(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.name ?? 'Unnamed Product',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\$${(product.price ?? 0.0).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink[600],
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

  Widget _buildProductImage() {
    if (product.images == null || product.images!.isEmpty || product.images!.first.isEmpty) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.photo_library,
                size: 32,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 4),
              Text(
                'No Image',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      child: Image.network(
        product.images!.first,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.white,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.white,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_library,
                    size: 32,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'No Image',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWishlistButton() {
    return Obx(() {
      final isInWishlist = controller.isInWishlist(product.id ?? '');
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: Icon(
            isInWishlist ? Icons.favorite : Icons.favorite_border,
            color: isInWishlist ? Colors.red : Colors.grey[600],
            size: 18,
          ),
          onPressed: () => controller.toggleWishlist(product.id ?? ''),
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(
            minWidth: 30,
            minHeight: 30,
          ),
        ),
      );
    });
  }
}