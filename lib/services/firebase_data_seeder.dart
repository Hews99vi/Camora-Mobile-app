import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/product.dart';

class FirebaseDataSeeder {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Seeds the database with sample data
  /// Call this method once to populate your Firestore database
  static Future<void> seedDatabase() async {
    try {
      debugPrint('Starting database seeding...');
      
      await _seedCategories();
      await _seedProducts();
      
      debugPrint('Database seeding completed successfully!');
    } catch (e) {
      debugPrint('Error seeding database: $e');
      throw Exception('Failed to seed database: $e');
    }
  }

  static Future<void> _seedCategories() async {
    debugPrint('Seeding categories...');
    
    final categories = [
      'Dresses',
      'Tops',
      'Bottoms',
      'Outerwear',
      'Accessories',
      'Shoes',
      'Activewear',
      'Lingerie',
    ];

    for (String category in categories) {
      await _firestore.collection('categories').add({
        'name': category,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    
    debugPrint('Categories seeded successfully!');
  }

  static Future<void> _seedProducts() async {
    debugPrint('Seeding products...');
    
    final sampleProducts = [
      // Dresses
      Product(
        id: '', // Firestore will generate this
        name: 'Summer Floral Dress',
        description: 'Beautiful floral print dress perfect for summer occasions. Made with breathable cotton blend fabric.',
        price: 59.99,
        images: [
          'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=300&h=400&fit=crop',
          'https://images.unsplash.com/photo-1566479179817-c8ce4e59f1ad?w=300&h=400&fit=crop',
        ],
        category: 'Dresses',
        sizes: ['XS', 'S', 'M', 'L', 'XL'],
        stock: 60, // Total stock across all sizes
        rating: 4.6,
        reviewCount: 124,
      ),
      Product(
        id: '',
        name: 'Elegant Evening Dress',
        description: 'Sophisticated black evening dress for special occasions. Features elegant draping and comfortable fit.',
        price: 129.99,
        images: [
          'https://images.unsplash.com/photo-1469833120660-1a218b53d28a?w=300&h=400&fit=crop',
        ],
        category: 'Dresses',
        sizes: ['XS', 'S', 'M', 'L'],
        stock: 29, // Total stock across all sizes
        rating: 4.8,
        reviewCount: 89,
      ),
      
      // Tops
      Product(
        id: '',
        name: 'Classic White Blouse',
        description: 'Timeless white blouse perfect for professional or casual wear. Made with premium cotton.',
        price: 45.99,
        images: [
          'https://images.unsplash.com/photo-1551698618-1dfe5d97d256?w=300&h=400&fit=crop',
        ],
        category: 'Tops',
        sizes: ['XS', 'S', 'M', 'L', 'XL'],
        stock: 80, // Total stock across all sizes
        rating: 4.4,
        reviewCount: 203,
      ),
      Product(
        id: '',
        name: 'Striped Long Sleeve Top',
        description: 'Casual striped long sleeve top perfect for everyday wear. Comfortable and stylish.',
        price: 32.99,
        images: [
          'https://images.unsplash.com/photo-1571513722275-4b9cde4d1c4a?w=300&h=400&fit=crop',
        ],
        category: 'Tops',
        sizes: ['S', 'M', 'L', 'XL'],
        stock: 90, // Total stock across all sizes
        rating: 4.2,
        reviewCount: 156,
      ),
      
      // Bottoms
      Product(
        id: '',
        name: 'High-Waisted Jeans',
        description: 'Classic high-waisted jeans with a modern fit. Perfect for any casual occasion.',
        price: 68.99,
        images: [
          'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=300&h=400&fit=crop',
        ],
        category: 'Bottoms',
        sizes: ['24', '26', '28', '30', '32', '34'],
        stock: 81, // Total stock across all sizes
        rating: 4.7,
        reviewCount: 298,
      ),
      Product(
        id: '',
        name: 'Flowy Wide-Leg Pants',
        description: 'Comfortable and elegant wide-leg pants perfect for both work and leisure.',
        price: 52.99,
        images: [
          'https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=300&h=400&fit=crop',
        ],
        category: 'Bottoms',
        sizes: ['XS', 'S', 'M', 'L', 'XL'],
        stock: 57, // Total stock across all sizes
        rating: 4.3,
        reviewCount: 87,
      ),
      
      // Outerwear
      Product(
        id: '',
        name: 'Denim Jacket',
        description: 'Classic denim jacket that goes with everything. A wardrobe essential.',
        price: 78.99,
        images: [
          'https://images.unsplash.com/photo-1551232864-8f4eb48c7953?w=300&h=400&fit=crop',
        ],
        category: 'Outerwear',
        sizes: ['XS', 'S', 'M', 'L', 'XL'],
        stock: 66, // Total stock across all sizes
        rating: 4.5,
        reviewCount: 234,
      ),
      
      // Accessories
      Product(
        id: '',
        name: 'Leather Crossbody Bag',
        description: 'Stylish leather crossbody bag perfect for daily use. Multiple compartments for organization.',
        price: 89.99,
        images: [
          'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=300&h=400&fit=crop',
        ],
        category: 'Accessories',
        sizes: ['One Size'],
        stock: 25, // Total stock
        rating: 4.9,
        reviewCount: 178,
      ),
      Product(
        id: '',
        name: 'Statement Earrings',
        description: 'Bold statement earrings to elevate any outfit. Made with high-quality materials.',
        price: 24.99,
        images: [
          'https://images.unsplash.com/photo-1617038260897-41a1f14a8ca0?w=300&h=400&fit=crop',
        ],
        category: 'Accessories',
        sizes: ['One Size'],
        stock: 50, // Total stock
        rating: 4.4,
        reviewCount: 92,
      ),
    ];

    for (Product product in sampleProducts) {
      await _firestore.collection('products').add(product.toJson());
    }
    
    debugPrint('Products seeded successfully!');
  }

  /// Creates an admin user (call this method to create an admin account)
  static Future<void> createAdminUser(String email, String password, String name) async {
    try {
      debugPrint('Creating admin user...');
      
      // Note: You'll need to create the admin user through Firebase Auth first
      // Then call this method to update their role in Firestore
      
      // This is just a placeholder - you should implement proper admin creation
      debugPrint('Admin user creation process started for: $email');
      debugPrint('Remember to:');
      debugPrint('1. Create the user account through Firebase Auth');
      debugPrint('2. Update the user document in Firestore with role: "admin"');
      
    } catch (e) {
      debugPrint('Error creating admin user: $e');
      throw Exception('Failed to create admin user: $e');
    }
  }
}

// Example usage in a Flutter app:
// 
// To seed the database, call this once (maybe in a debug menu):
// await FirebaseDataSeeder.seedDatabase();
//
// You can also create a debug screen with a button to seed data:
// ElevatedButton(
//   onPressed: () async {
//     try {
//       await FirebaseDataSeeder.seedDatabase();
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Database seeded successfully!')),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//     }
//   },
//   child: Text('Seed Database'),
// )
