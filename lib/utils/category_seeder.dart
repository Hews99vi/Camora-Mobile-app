import '../services/firebase_db_service.dart';
import 'package:flutter/foundation.dart';

class CategorySeeder {
  static final List<String> _defaultCategories = [
    'Dresses',
    'Tops',
    'Bottoms',
    'Outerwear',
    'Activewear',
    'Lingerie',
    'Swimwear',
    'Accessories',
    'Shoes',
    'Bags',
  ];

  static Future<void> seedDefaultCategories() async {
    try {
      debugPrint('Seeding default categories...');
      
      // First ensure admin access by creating admin document explicitly 
      try {
        await _ensureAdminAccess();
      } catch (adminError) {
        debugPrint('Admin access setup error (continuing anyway): $adminError');
      }
      
      // Get existing categories
      debugPrint('Retrieving existing categories...');
      List<String> existingCategories = await FirebaseDbService.getCategories();
      debugPrint('Found ${existingCategories.length} existing categories');
      
      // Add categories that don't exist
      for (String category in _defaultCategories) {
        if (!existingCategories.contains(category)) {
          debugPrint('Adding new category: $category');
          await FirebaseDbService.addCategory(category);
          debugPrint('Added category: $category');
        } else {
          debugPrint('Category already exists (skipping): $category');
        }
      }
      
      debugPrint('Category seeding completed!');
    } catch (e) {
      debugPrint('Error seeding categories: $e');
      debugPrint('Error details: ${e.toString()}');
    }
  }
  
  // Helper method to ensure admin access before category operations
  static Future<void> _ensureAdminAccess() async {
    try {
      debugPrint('Ensuring admin access...');
      
      // Add admin category to test permissions
      final testCategoryName = '_test_admin_${DateTime.now().millisecondsSinceEpoch}';
      await FirebaseDbService.addCategory(testCategoryName);
      debugPrint('Successfully created test category (confirming admin access)');
      
      // Clean up test category
      await FirebaseDbService.deleteCategory(testCategoryName);
      debugPrint('Admin access verified successfully');
    } catch (e) {
      debugPrint('Admin access verification failed: $e');
      throw Exception('Admin access verification failed: $e');
    }
  }

  static List<String> get defaultCategories => _defaultCategories;
}
