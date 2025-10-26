import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/product.dart';
import '../controllers/product_controller.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ProductController productController = Get.find<ProductController>();
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            AspectRatio(
              aspectRatio: 1.0,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      child: Container(
                        color: Colors.white,
                        child: product.images?.isNotEmpty == true
                            ? CachedNetworkImage(
                                imageUrl: product.images![0],
                                fit: BoxFit.contain,
                                fadeInDuration: const Duration(milliseconds: 200),
                                placeholder: (context, url) => Container(
                                  color: Colors.white,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.white,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.photo_library,
                                          size: 40,
                                          color: Colors.grey[300],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'No Image',
                                          style: TextStyle(
                                            color: Colors.grey[400],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                color: Colors.white,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.photo_library,
                                        size: 40,
                                        color: Colors.grey[300],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'No Image',
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                  // Wishlist Button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Obx(() => Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          productController.isInWishlist(product.id ?? '') 
                            ? Icons.favorite 
                            : Icons.favorite_border,
                          color: productController.isInWishlist(product.id ?? '')
                            ? Colors.red
                            : Colors.grey[600],
                          size: 18,
                        ),
                        onPressed: () async {
                          await productController.toggleWishlist(product.id ?? '');
                          // Force refresh UI
                          productController.update();
                        },
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(
                          minWidth: 30,
                          minHeight: 30,
                        ),
                      ),
                    )),
                  ),
                ],
              ),
            ),
            
            // Product Details
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Product Name
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
                  
                  // Product Price
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
}
