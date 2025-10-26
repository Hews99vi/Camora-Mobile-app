import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../models/user.dart';
import '../services/firebase_db_service.dart';
import 'auth_controller.dart';
import 'category_controller.dart';

class ProductController extends GetxController {
  static ProductController get instance => Get.find();
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<Product> _products = <Product>[].obs;
  final RxList<CartItem> _cartItems = <CartItem>[].obs;
  final RxList<String> _wishlistIds = <String>[].obs;
  final RxList<String> _categories = <String>[].obs;
  final RxBool _isLoading = false.obs;
  
  List<Product> get products => _products;
  List<CartItem> get cartItems => _cartItems;
  List<String> get wishlistIds => _wishlistIds;
  List<String> get categories => _categories;
  bool get isLoading => _isLoading.value;
  
  // Make wishlist products reactive
  List<Product> get wishlistProducts {
    final List<Product> result = [];
    
    // Only include products whose IDs are explicitly in the wishlist
    for (final product in _products) {
      if (product.id != null && _wishlistIds.contains(product.id)) {
        result.add(product);
      }
    }
    
    debugPrint('Getting wishlist products: ${result.length} products found for wishlist IDs: $_wishlistIds');
    return result;
  }
  
  int get cartItemCount => _cartItems.fold(0, (total, item) => total + (item.quantity ?? 0));
  double get cartTotal => _cartItems.fold(0.0, (total, item) => total + ((item.price ?? 0.0) * (item.quantity ?? 0)));
  
  @override
  void onInit() {
    super.onInit();
    _checkFirebaseConfiguration();
    loadProducts();
    loadCategories();
    _initializeUserData();
  }
  
  // Check if Firebase is configured correctly
  Future<void> _checkFirebaseConfiguration() async {
    try {
      // Try to access Firestore to check if it's configured
      await _firestore
          .collection('__configuration_test')
          .limit(1)
          .get();
    } catch (e) {
      // If there's a database not found error, show a clear message
      if (e.toString().contains('NOT_FOUND') && 
          e.toString().contains('database') && 
          e.toString().contains('does not exist')) {
        debugPrint('Firebase database not configured: $e');
        Get.snackbar(
          'Firebase Setup Required',
          'Your Firebase database is not set up. Please visit the Firebase console to configure it.',
          backgroundColor: Colors.red[100],
          colorText: Colors.red[800],
          duration: Duration(seconds: 10),
          snackPosition: SnackPosition.TOP,
          borderRadius: 8,
          margin: EdgeInsets.all(8),
          icon: Icon(Icons.warning_amber_rounded, color: Colors.red[800]),
        );
      }
    }
  }
  
  void _initializeUserData() {
    final authController = Get.find<AuthController>();
    
    // Load data immediately if user is already logged in
    if (authController.currentUser != null) {
      loadUserCart();
      loadUserWishlist();
    }
    
    // Listen to auth state changes to load user-specific data
    ever(authController.currentUserRx, (User? user) {
      debugPrint('Auth state changed - User: ${user?.email ?? 'None'}');
      if (user != null) {
        debugPrint('Loading user data for: ${user.email}');
        loadUserCart();
        loadUserWishlist();
      } else {
        debugPrint('User signed out - clearing cart and wishlist');
        _cartItems.clear();
        _wishlistIds.clear();
      }
    });
  }
  
  // ==== PRODUCTS ====
  
  Future<void> loadProducts() async {
    try {
      _isLoading.value = true;
      List<Product> loadedProducts = await FirebaseDbService.getAllProducts();
      _products.assignAll(loadedProducts);
      
      // Debug: Print category distribution
      _debugCategoryDistribution();
    } catch (e) {
      debugPrint('Error loading products: $e');
      
      // Check for Firebase database configuration error
      if (e.toString().contains('NOT_FOUND') && 
          e.toString().contains('database') && 
          e.toString().contains('does not exist')) {
        Get.snackbar(
          'Firebase Setup Required', 
          'Please set up your Firebase database in the Google Cloud Console.',
          duration: Duration(seconds: 8),
          backgroundColor: Colors.red[100],
          colorText: Colors.red[800],
        );
      } else {
        Get.snackbar('Error', 'Failed to load products');
      }
    } finally {
      _isLoading.value = false;
    }
  }
  
  void _debugCategoryDistribution() {
    debugPrint('=== PRODUCT CATEGORY DEBUG ===');
    final categoryCount = <String, int>{};
    for (final product in _products) {
      final category = product.category ?? 'unknown';
      categoryCount[category] = (categoryCount[category] ?? 0) + 1;
      debugPrint('Product: ${product.name} -> Category: ${product.category}');
    }
    debugPrint('Category distribution:');
    categoryCount.forEach((category, quantity) {
      debugPrint('  $category: $quantity products');
    });
    debugPrint('===============================');
  }
  
  Future<void> loadCategories() async {
    try {
      List<String> loadedCategories = await FirebaseDbService.getCategories();
      _categories.assignAll(loadedCategories);
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
  }
  
  Future<bool> addProduct(Product product) async {
    try {
      _isLoading.value = true;
      debugPrint('Adding product: ${product.name}');
      
      // Add the product to Firebase
      String productId = await FirebaseDbService.addProduct(product);
      debugPrint('Product added with ID: $productId');
      
      // Update local list with the new product ID
      Product newProduct = Product(
        id: productId,
        name: product.name,
        description: product.description,
        price: product.price,
        images: product.images,
        category: product.category,
        sizes: product.sizes,
        stock: product.stock,
        rating: product.rating,
        reviewCount: product.reviewCount,
      );
      
      _products.add(newProduct);
      
      // Refresh categories if a category controller exists
      try {
        if (Get.isRegistered<CategoryController>()) {
          Get.find<CategoryController>().loadCategories();
        }
      } catch (e) {
        debugPrint('Category controller not found, skipping refresh');
      }
      
      return true;
    } catch (e) {
      debugPrint('Error adding product: $e');
      
      // Check for Firebase database not found error
      if (e.toString().contains('NOT_FOUND') && 
          e.toString().contains('database') && 
          e.toString().contains('does not exist')) {
        Get.snackbar(
          'Firebase Setup Required', 
          'Please set up your Firebase database in the Google Cloud Console.',
          duration: Duration(seconds: 8),
          backgroundColor: Colors.red[100],
          colorText: Colors.red[800],
        );
      }
      
      return false;
    } finally {
      // Ensure loading state is reset even if there's an error
      _isLoading.value = false;
      debugPrint('Product add operation completed, loading state reset');
    }
  }
        
  Future<bool> updateProduct(Product product) async {
    try {
      _isLoading.value = true;
      debugPrint('Updating product: ${product.name} (ID: ${product.id})');
      
      await FirebaseDbService.updateProduct(product);
      
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = product;
        debugPrint('Product updated in local list at index: $index');
      } else {
        debugPrint('Product with ID ${product.id} not found in local list');
      }
      
      return true;
    } catch (e) {
      debugPrint('Error updating product: $e');
      return false;
    } finally {
      // Ensure loading state is reset even if there's an error
      _isLoading.value = false;
      debugPrint('Product update operation completed, loading state reset');
    }
  }
  
  Future<bool> deleteProduct(String productId) async {
    try {
      _isLoading.value = true;
      
      await FirebaseDbService.deleteProduct(productId);
      _products.removeWhere((p) => p.id == productId);
      
      Get.snackbar('Success', 'Product deleted successfully!');
      return true;
    } catch (e) {
      debugPrint('Error deleting product: $e');
      Get.snackbar('Error', 'Failed to delete product');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
  
  // ==== CART ====
  
  Future<void> loadUserCart() async {
    final authController = Get.find<AuthController>();
    if (authController.currentUser == null) return;
    
    try {
      if (authController.currentUser?.id == null) {
        throw Exception("User ID is null");
      }
      List<CartItem> cartItems = await FirebaseDbService.getUserCart(
        authController.currentUser!.id!,
      );
      
      // Fix for default "Classic White Blouse" appearing in all new user carts
      // Check if there's only one item and it's the Classic White Blouse
      if (cartItems.length == 1 && 
          cartItems[0].productName == 'Classic White Blouse' &&
          cartItems[0].price == 45.99) {
        debugPrint('Detected default item in cart for new user. Clearing default item.');
        // Clear the cart in Firebase
        await FirebaseDbService.clearUserCart(authController.currentUser!.id!);
        // Clear local cart items
        _cartItems.clear();
      } else {
        // Proceed normally with the loaded cart
        _cartItems.assignAll(cartItems);
      }
    } catch (e) {
      debugPrint('Error loading cart: $e');
    }
  }
  
  Future<void> addToCart(Product product, String size, int quantity) async {
    final authController = Get.find<AuthController>();
    if (authController.currentUser == null) {
      Get.snackbar('Error', 'Please login to add items to cart');
      return;
    }
    
    try {
      // Check if item already exists in cart
      final existingItemIndex = _cartItems.indexWhere(
        (item) => item.productId == product.id && item.size == size,
      );
      
      if (existingItemIndex != -1) {
        // Update quantity
        final existingQuantity = _cartItems[existingItemIndex].quantity ?? 0;
        _cartItems[existingItemIndex] = CartItem(
          productId: product.id,
          productName: product.name,
          price: product.price,
          size: size,
          quantity: existingQuantity + quantity,
          productImage: product.images?.isNotEmpty == true ? product.images!.first : '',
        );
      } else {
        // Add new item
        _cartItems.add(CartItem(
          productId: product.id,
          productName: product.name,
          price: product.price,
          size: size,
          quantity: quantity,
          productImage: product.images?.isNotEmpty == true ? product.images!.first : '',
        ));
      }
      
      if (authController.currentUser?.id == null) {
        throw Exception("User ID is null");
      }
      await FirebaseDbService.updateUserCart(
        authController.currentUser!.id!,
        _cartItems,
      );
      
      Get.snackbar('Success', 'Item added to cart');
    } catch (e) {
      debugPrint('Error adding to cart: $e');
      Get.snackbar('Error', 'Failed to add item to cart');
    }
  }
  
  Future<void> removeFromCart(CartItem item) async {
    final authController = Get.find<AuthController>();
    if (authController.currentUser == null) return;
    
    try {
      _cartItems.removeWhere(
        (cartItem) => cartItem.productId == item.productId && cartItem.size == item.size,
      );
      
      if (authController.currentUser?.id == null) {
        throw Exception("User ID is null");
      }
      await FirebaseDbService.updateUserCart(
        authController.currentUser!.id!,
        _cartItems,
      );
      
      Get.snackbar('Success', 'Item removed from cart');
    } catch (e) {
      debugPrint('Error removing from cart: $e');
      Get.snackbar('Error', 'Failed to remove item from cart');
    }
  }
  
  Future<void> clearCart() async {
    final authController = Get.find<AuthController>();
    if (authController.currentUser == null) return;
    
    try {
      if (authController.currentUser?.id == null) {
        throw Exception("User ID is null");
      }
      await FirebaseDbService.clearUserCart(authController.currentUser!.id!);
      _cartItems.clear();
    } catch (e) {
      debugPrint('Error clearing cart: $e');
    }
  }
  
  // ==== WISHLIST ====
  
  Future<void> loadUserWishlist() async {
    final authController = Get.find<AuthController>();
    // Clear wishlist IDs first to prevent stale data
    _wishlistIds.clear();
    
    if (authController.currentUser == null) {
      debugPrint('No user logged in, cannot load wishlist');
      update(); // Ensure UI updates even when clearing
      return;
    }
    
    try {
      if (authController.currentUser?.id == null) {
        throw Exception("User ID is null");
      }
      
      final String userId = authController.currentUser!.id!;
      debugPrint('Loading wishlist for user: $userId (${authController.currentUser!.email})');
      
      // Get wishlist from Firebase
      List<String> wishlistIds = await FirebaseDbService.getUserWishlist(userId);
      debugPrint('Loaded ${wishlistIds.length} wishlist IDs from Firestore: $wishlistIds');
      
      // Validate IDs - only include non-empty product IDs
      wishlistIds = wishlistIds.where((id) => id.isNotEmpty).toList();
      
      // Update our observable list with the fetched IDs
      _wishlistIds.assignAll(wishlistIds);
      
      debugPrint('Current wishlist in controller after loading: $_wishlistIds');
      
      // Force UI update
      update();
    } catch (e) {
      debugPrint('Error loading wishlist: $e');
      _wishlistIds.clear(); // Clear wishlist on error
      update(); // Ensure UI updates even on error
    }
  }
  
  Future<void> toggleWishlist(String productId) async {
    final authController = Get.find<AuthController>();
    
    // Validate inputs
    if (productId.isEmpty) {
      debugPrint('Error: Cannot toggle wishlist for empty product ID');
      return;
    }
    
    if (authController.currentUser == null) {
      Get.snackbar('Error', 'Please login to manage wishlist');
      return;
    }
    
    if (authController.currentUser?.id == null) {
      Get.snackbar('Error', 'User ID is missing. Please login again.');
      return;
    }
    
    final String userId = authController.currentUser!.id!;
    
    try {
      debugPrint('Toggling wishlist for product: $productId');
      debugPrint('User: $userId (${authController.currentUser!.email})');
      debugPrint('Current wishlist before toggle: $_wishlistIds');
      
      // Check if the product is already in the wishlist
      final bool wasInWishlist = _wishlistIds.contains(productId);
      
      // Update Firebase first, then update local state only if Firebase succeeds
      if (wasInWishlist) {
        // Remove from Firebase
        await FirebaseDbService.removeFromWishlist(userId, productId);
        debugPrint('Removed from wishlist in Firebase');
        
        // Now update local state
        _wishlistIds.remove(productId);
        debugPrint('Removed from local wishlist. New list: $_wishlistIds');
        Get.snackbar('Success', 'Item removed from wishlist');
      } else {
        // Add to Firebase
        await FirebaseDbService.addToWishlist(userId, productId);
        debugPrint('Added to wishlist in Firebase');
        
        // Now update local state
        _wishlistIds.add(productId);
        debugPrint('Added to local wishlist. New list: $_wishlistIds');
        Get.snackbar('Success', 'Item added to wishlist');
      }
      
      // Force UI update and debug
      update();
      debugWishlistState();
    } catch (e) {
      debugPrint('Error toggling wishlist: $e');
      Get.snackbar('Error', 'Failed to update wishlist');
      
      // Refresh wishlist from Firebase to ensure consistency
      await loadUserWishlist();
    }
  }
  
  /// Force refresh the current user's wishlist data
  Future<void> refreshWishlist() async {
    debugPrint('Force refreshing wishlist...');
    await loadUserWishlist();
    // Also trigger a UI refresh
    update();
    debugWishlistState();
  }

  bool isInWishlist(String productId) {
    // Simple direct check - is this specific ID in the wishlist IDs list?
    if (productId.isEmpty) {
      return false;
    }
    
    // Important: only return true if this exact product ID is in the wishlist
    final bool result = _wishlistIds.contains(productId);
    debugPrint('isInWishlist check for product $productId: $result (wishlist: $_wishlistIds)');
    return result;
  }
  
  /// Debug method to check current user and wishlist state
  void debugWishlistState() {
    final authController = Get.find<AuthController>();
    debugPrint('=== WISHLIST DEBUG STATE ===');
    debugPrint('Current user: ${authController.currentUser?.email ?? 'None'}');
    debugPrint('Current user ID: ${authController.currentUser?.id ?? 'None'}');
    debugPrint('Wishlist IDs in controller: $_wishlistIds');
    
    // Debug individual products in wishlist
    final wishlistItems = wishlistProducts;
    debugPrint('Wishlist products count: ${wishlistItems.length}');
    if (wishlistItems.isNotEmpty) {
      debugPrint('Wishlist products:');
      for (var product in wishlistItems) {
        debugPrint('  - ID: ${product.id}, Name: ${product.name}');
      }
    }
    
    debugPrint('Total products loaded: ${_products.length}');
    
    // Check if any product IDs are null or empty
    final problemProducts = _products.where((p) => p.id == null || p.id!.isEmpty).toList();
    if (problemProducts.isNotEmpty) {
      debugPrint('WARNING: Found ${problemProducts.length} products with null or empty IDs');
      for (var product in problemProducts) {
        debugPrint('  - Problem product: ${product.name}');
      }
    }
    
    debugPrint('============================');
  }

  // ==== UTILITY METHODS ====
  
  Product? getProductById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }
  
  List<Product> getProductsByCategory(String category) {
    return _products.where((product) => product.category == category).toList();
  }
  
  List<Product> getWishlistProducts() {
    return _products.where((product) => _wishlistIds.contains(product.id)).toList();
  }
}
