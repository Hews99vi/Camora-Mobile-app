import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../services/firebase_db_service.dart';
import '../utils/category_seeder.dart';

class CategoryController extends GetxController {
  static CategoryController get instance => Get.find();
  
  final RxList<String> _categories = <String>[].obs;
  final RxBool _isLoading = false.obs;
  
  List<String> get categories => _categories;
  bool get isLoading => _isLoading.value;
  
  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }
  
  // Load all categories
  Future<void> loadCategories() async {
    try {
      _isLoading.value = true;
      List<String> loadedCategories = await FirebaseDbService.getCategories();
      _categories.assignAll(loadedCategories);
    } catch (e) {
      debugPrint('Error loading categories: $e');
      Get.snackbar('Error', 'Failed to load categories');
    } finally {
      _isLoading.value = false;
    }
  }
  
  // Seed default categories
  Future<void> seedDefaultCategories() async {
    try {
      _isLoading.value = true;
      await CategorySeeder.seedDefaultCategories();
      await loadCategories(); // Reload after seeding
      Get.snackbar('Success', 'Default categories added successfully');
    } catch (e) {
      debugPrint('Error seeding categories: $e');
      Get.snackbar('Error', 'Failed to add default categories');
    } finally {
      _isLoading.value = false;
    }
  }
  
  // Add a new category
  Future<bool> addCategory(String categoryName) async {
    try {
      _isLoading.value = true;
      
      // Check if category already exists
      if (_categories.contains(categoryName)) {
        Get.snackbar('Error', 'Category already exists');
        return false;
      }
      
      await FirebaseDbService.addCategory(categoryName);
      _categories.add(categoryName);
      Get.snackbar('Success', 'Category added successfully');
      return true;
    } catch (e) {
      debugPrint('Error adding category: $e');
      Get.snackbar('Error', 'Failed to add category');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
  
  // Update a category
  Future<bool> updateCategory(String oldName, String newName) async {
    try {
      _isLoading.value = true;
      
      // Check if new name already exists (and it's different from old name)
      if (oldName != newName && _categories.contains(newName)) {
        Get.snackbar('Error', 'Category name already exists');
        return false;
      }
      
      await FirebaseDbService.updateCategory(oldName, newName);
      
      // Update local list
      int index = _categories.indexOf(oldName);
      if (index != -1) {
        _categories[index] = newName;
      }
      
      Get.snackbar('Success', 'Category updated successfully');
      return true;
    } catch (e) {
      debugPrint('Error updating category: $e');
      Get.snackbar('Error', 'Failed to update category');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
  
  // Delete a category
  Future<bool> deleteCategory(String categoryName) async {
    try {
      _isLoading.value = true;
      
      // Check if category has products
      bool hasProducts = await FirebaseDbService.categoryHasProducts(categoryName);
      if (hasProducts) {
        Get.snackbar(
          'Warning', 
          'Cannot delete category with existing products. Please move or delete products first.',
          duration: const Duration(seconds: 4),
        );
        return false;
      }
      
      await FirebaseDbService.deleteCategory(categoryName);
      _categories.remove(categoryName);
      Get.snackbar('Success', 'Category deleted successfully');
      return true;
    } catch (e) {
      debugPrint('Error deleting category: $e');
      Get.snackbar('Error', 'Failed to delete category');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
  
  // Get category count
  int get categoryCount => _categories.length;
}
