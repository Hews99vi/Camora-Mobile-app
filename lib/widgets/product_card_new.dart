import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              flex: 3,
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
                      child: CachedNetworkImage(
                        imageUrl: (product.images != null && product.images!.isNotEmpty) ? product.images![0] : '',
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[100],
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[100],
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.grey[400],
                            size: 40,
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
                        icon: Obx(() {
                          // Re-evaluate wishlist status in real-time
                          final bool isWishlisted = productController.isInWishlist(product.id ?? '');
                          return Icon(
                            isWishlisted ? Icons.favorite : Icons.favorite_border,
                            color: isWishlisted ? Colors.red : Colors.grey[600],
                            size: 20,
                          );
                        }),
                        onPressed: () async {
                          final String productId = product.id ?? '';
                          if (productId.isEmpty) {
                            Get.snackbar('Error', 'Cannot add product to wishlist');
                            return;
                          }
                          
                          debugPrint('Toggling wishlist for product: $productId');
                          await productController.toggleWishlist(productId);
                          
                          // Force UI update
                          productController.update();
                        },
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                    )),
                  ),
                ],
              ),
            ),
            
            // Product Details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      product.name ?? 'Unnamed Product',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    // Product Price
                    Text(
                      '\$${(product.price ?? 0.0).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.pink[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
