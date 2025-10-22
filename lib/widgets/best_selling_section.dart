import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import '../screens/product_details_screen.dart';
import '../controllers/product_controller.dart';

class BestSellingSection extends StatelessWidget {
  const BestSellingSection({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductController productController = Get.find<ProductController>();
    
    return Obx(() {
      // Use products from the controller instead of hardcoded ones
      List<Product> bestSellers = productController.products.take(3).toList();
      
      // If no products loaded from Firebase, use hardcoded fallback
      if (bestSellers.isEmpty) {
        bestSellers = [
          Product(
            id: 'fallback-1',
            name: 'Regular Fit Long Sleeve Top',
            description: 'Classic long sleeve top perfect for any occasion',
            price: 29.99,
            images: ['https://images.unsplash.com/photo-1434389677669-e08b4cac3105?w=300&h=400&fit=crop'],
            category: 'Tops',
            sizes: ['S', 'M', 'L', 'XL'],
            stock: 11, // Total stock
            rating: 4.5,
            reviewCount: 128,
          ),
          Product(
            id: 'fallback-2',
            name: 'Black Crop Hooded Jacket',
            description: 'Stylish black hooded jacket for a casual look',
            price: 49.99,
            images: ['https://images.unsplash.com/photo-1551232864-8f4eb48c7953?w=300&h=400&fit=crop'],
            category: 'Jackets',
            sizes: ['S', 'M', 'L'],
            stock: 10, // Total stock
            rating: 4.8,
            reviewCount: 95,
          ),
          Product(
            id: 'fallback-3',
            name: 'Two-tone Blouse',
            description: 'Elegant two-tone blouse for a sophisticated look',
            price: 39.99,
            images: ['https://images.unsplash.com/photo-1485230895905-ec40ba36b9bc?w=300&h=400&fit=crop'],
            category: 'Blouses',
            sizes: ['S', 'M', 'L'],
            stock: 13, // Total stock
            rating: 4.6,
            reviewCount: 82,
          ),
        ];
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Best selling',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Get in on the trend with our curated selection of best-selling styles.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 320,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: bestSellers.length,
              itemBuilder: (context, index) {
                return SizedBox(
                  width: 200,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: ProductCard(
                      product: bestSellers[index],
                      onTap: () {
                        Get.to(() => ProductDetailsScreen(product: bestSellers[index]));
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}
