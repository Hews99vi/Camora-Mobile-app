import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/cart_item.dart';

class FirebaseDbService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Products Collection
  static const String _productsCollection = 'products';
  static const String _categoriesCollection = 'categories';
  static const String _cartsCollection = 'carts';
  static const String _ordersCollection = 'orders';
  static const String _wishlistsCollection = 'wishlists';

  // ==== PRODUCTS ====
  
  // Get all products
  static Future<List<Product>> getAllProducts() async {
    try {
      debugPrint('FirebaseDbService: Getting all products');
      QuerySnapshot snapshot = await _firestore
          .collection(_productsCollection)
          .get();

      debugPrint('FirebaseDbService: Retrieved ${snapshot.docs.length} products');
      return snapshot.docs
          .map((doc) => Product.fromJson({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      debugPrint('FirebaseDbService: Error getting products: $e');
      
      // Check for database configuration errors
      if (e.toString().contains('NOT_FOUND') && 
          e.toString().contains('database') && 
          e.toString().contains('does not exist')) {
        throw Exception(
          'Firebase database not configured. Please visit https://console.cloud.google.com/datastore/setup?project=camora-mobile-app to set up your Firestore database.'
        );
      }
      
      throw Exception('Failed to get products: $e');
    }
  }

  // Get products by category
  static Future<List<Product>> getProductsByCategory(String category) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_productsCollection)
          .where('category', isEqualTo: category)
          .get();

      return snapshot.docs
          .map((doc) => Product.fromJson({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to get products by category: $e');
    }
  }

  // Get product by ID
  static Future<Product?> getProductById(String productId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_productsCollection)
          .doc(productId)
          .get();

      if (doc.exists) {
        return Product.fromJson({
          ...doc.data() as Map<String, dynamic>,
          'id': doc.id,
        });
      }
    } catch (e) {
      throw Exception('Failed to get product: $e');
    }
    return null;
  }

  // Add product (Admin only)
  static Future<String> addProduct(Product product) async {
    try {
      debugPrint('FirebaseDbService: Adding product to Firestore: ${product.name}');
      
      // Convert product to JSON
      Map<String, dynamic> productJson = product.toJson();
      debugPrint('FirebaseDbService: Product JSON prepared: ${productJson.keys.join(', ')}');
      
      // Add to Firestore
      DocumentReference docRef = await _firestore
          .collection(_productsCollection)
          .add(productJson);
          
      debugPrint('FirebaseDbService: Product added with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('FirebaseDbService: Error adding product: $e');
      
      // Check for database configuration errors
      if (e.toString().contains('NOT_FOUND') && 
          e.toString().contains('database') && 
          e.toString().contains('does not exist')) {
        throw Exception(
          'Firebase database not configured. Please visit https://console.cloud.google.com/datastore/setup?project=camora-mobile-app to set up your Firestore database.'
        );
      }
      
      throw Exception('Failed to add product: $e');
    }
  }

  // Update product (Admin only)
  static Future<void> updateProduct(Product product) async {
    try {
      await _firestore
          .collection(_productsCollection)
          .doc(product.id)
          .update(product.toJson());
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  // Delete product (Admin only)
  static Future<void> deleteProduct(String productId) async {
    try {
      await _firestore
          .collection(_productsCollection)
          .doc(productId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  // ==== CATEGORIES ====

  // Get all categories
  static Future<List<String>> getCategories() async {
    try {
      debugPrint('Getting categories from Firestore...');
      
      // Print Firebase Auth current user info for debugging
      final currentUser = FirebaseAuth.instance.currentUser;
      debugPrint('Current Firebase Auth user: ${currentUser?.uid}, email: ${currentUser?.email}');

      // Get admin document ID for the current user if possible
      final adminId = currentUser != null ? 'dev-${currentUser.email?.hashCode}' : null;
      debugPrint('Checking admin ID: $adminId');
      
      // Check if this user has an admin document
      if (adminId != null) {
        try {
          final adminDoc = await _firestore.collection('admins').doc(adminId).get();
          debugPrint('Admin document exists: ${adminDoc.exists}');
          if (adminDoc.exists) {
            debugPrint('Admin document data: ${adminDoc.data()}');
          }
        } catch (adminErr) {
          debugPrint('Error checking admin document: $adminErr');
        }
      }
      
      // Enable more detailed logging for Firestore
      debugPrint('Trying to get categories collection with path: $_categoriesCollection');
      debugPrint('Full request path: ${_firestore.collection(_categoriesCollection).path}');

      QuerySnapshot snapshot = await _firestore
          .collection(_categoriesCollection)
          .get();

      debugPrint('Got snapshot with ${snapshot.docs.length} documents');

      List<String> categories = [];
      for (var doc in snapshot.docs) {
        try {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          debugPrint('Document data: $data');
          String name = data['name'] as String;
          categories.add(name);
        } catch (docError) {
          debugPrint('Error processing category document: $docError');
        }
      }
      
      debugPrint('Retrieved ${categories.length} categories: ${categories.join(', ')}');
      return categories;
    } catch (e) {
      debugPrint('Error getting categories: $e');
      debugPrint('Error details: ${e.toString()}');
      if (e is FirebaseException) {
        debugPrint('Firebase error code: ${e.code}');
        debugPrint('Firebase error message: ${e.message}');
      }
      // Return empty list instead of throwing to prevent app crashes
      return [];
    }
  }

  // Add a new category
  static Future<void> addCategory(String categoryName) async {
    try {
      debugPrint('Adding category to Firestore: $categoryName');
      
      // Debug current auth state
      final currentUser = FirebaseAuth.instance.currentUser;
      debugPrint('Current Firebase Auth user: ${currentUser?.uid}, email: ${currentUser?.email}');
      
      // For development, ensure we have the proper admin in admins collection
      try {
        // Try to use the current user's email for the admin ID if available
        final email = currentUser?.email ?? 'admin@example.com';
        final adminId = currentUser?.uid ?? 'dev-${email.hashCode}';
        
        debugPrint('Creating admin document with ID: $adminId (from email: $email)');
        
        // Create/update admin document using current user or fallback
        await _firestore.collection('admins').doc(adminId).set({
          'email': email,
          'name': 'Admin User',
          'role': 'admin',
          'updatedAt': FieldValue.serverTimestamp()
        }, SetOptions(merge: true));
        
        // Also create a second admin document using email hash for dev auth users
        if (currentUser?.email != null) {
          final emailHashId = 'dev-${currentUser!.email!.hashCode}';
          debugPrint('Also creating admin document with email hash ID: $emailHashId');
          
          await _firestore.collection('admins').doc(emailHashId).set({
            'email': currentUser.email,
            'name': 'Admin User',
            'role': 'admin',
            'updatedAt': FieldValue.serverTimestamp()
          }, SetOptions(merge: true));
        }
        
        debugPrint('Ensured admin user document exists');
      } catch (adminError) {
        debugPrint('Error ensuring admin document: $adminError');
        debugPrint('Error details: ${adminError.toString()}');
      }
      
      // Temporarily set database rules to allow operation (for development only)
      debugPrint('Attempting to add category document: ${categoryName.toLowerCase().replaceAll(' ', '_')}');
      
      // Add the category with detailed error handling
      try {
        await _firestore
            .collection(_categoriesCollection)
            .doc(categoryName.toLowerCase().replaceAll(' ', '_'))
            .set({
          'name': categoryName,
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        debugPrint('Successfully added category: $categoryName');
      } catch (docError) {
        debugPrint('Error adding category document: $docError');
        if (docError is FirebaseException) {
          debugPrint('Firebase error code: ${docError.code}');
          debugPrint('Firebase error message: ${docError.message}');
        }
        throw docError; // Re-throw to be caught by outer catch
      }
    } catch (e) {
      debugPrint('Error adding category: $e');
      if (e is FirebaseException) {
        debugPrint('Firebase error code: ${e.code}');
        debugPrint('Firebase error message: ${e.message}');
      }
      throw Exception('Failed to add category: $e');
    }
  }

  // Update a category
  static Future<void> updateCategory(String oldName, String newName) async {
    try {
      debugPrint('Updating category: $oldName -> $newName');
      
      // Debug current auth state
      final currentUser = FirebaseAuth.instance.currentUser;
      debugPrint('Current Firebase Auth user: ${currentUser?.uid}, email: ${currentUser?.email}');
      
      // For development, ensure we have the proper admin in admins collection (reuse code from addCategory)
      try {
        final email = currentUser?.email ?? 'admin@example.com';
        final adminId = currentUser?.uid ?? 'dev-${email.hashCode}';
        
        debugPrint('Ensuring admin document with ID: $adminId exists');
        
        await _firestore.collection('admins').doc(adminId).set({
          'email': email,
          'name': 'Admin User',
          'role': 'admin',
          'updatedAt': FieldValue.serverTimestamp()
        }, SetOptions(merge: true));
        
        debugPrint('Ensured admin user document exists');
      } catch (adminError) {
        debugPrint('Error ensuring admin document: $adminError');
      }
      
      // Create new category document
      debugPrint('Creating new category document: ${newName.toLowerCase().replaceAll(' ', '_')}');
      await _firestore
          .collection(_categoriesCollection)
          .doc(newName.toLowerCase().replaceAll(' ', '_'))
          .set({
        'name': newName,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Delete old category document
      debugPrint('Deleting old category document: ${oldName.toLowerCase().replaceAll(' ', '_')}');
      await _firestore
          .collection(_categoriesCollection)
          .doc(oldName.toLowerCase().replaceAll(' ', '_'))
          .delete();

      // Update all products with old category to new category
      debugPrint('Updating products with category: $oldName -> $newName');
      QuerySnapshot products = await _firestore
          .collection(_productsCollection)
          .where('category', isEqualTo: oldName)
          .get();

      debugPrint('Found ${products.docs.length} products to update');
      
      WriteBatch batch = _firestore.batch();
      for (QueryDocumentSnapshot product in products.docs) {
        batch.update(product.reference, {'category': newName});
      }
      await batch.commit();
      debugPrint('Successfully updated category and related products');
    } catch (e) {
      debugPrint('Error updating category: $e');
      if (e is FirebaseException) {
        debugPrint('Firebase error code: ${e.code}');
        debugPrint('Firebase error message: ${e.message}');
      }
      throw Exception('Failed to update category: $e');
    }
  }

  // Delete a category
  static Future<void> deleteCategory(String categoryName) async {
    try {
      debugPrint('Deleting category: $categoryName');
      
      // Debug current auth state
      final currentUser = FirebaseAuth.instance.currentUser;
      debugPrint('Current Firebase Auth user: ${currentUser?.uid}, email: ${currentUser?.email}');
      
      // For development, ensure we have the proper admin in admins collection (reuse code from addCategory)
      try {
        final email = currentUser?.email ?? 'admin@example.com';
        final adminId = currentUser?.uid ?? 'dev-${email.hashCode}';
        
        debugPrint('Ensuring admin document with ID: $adminId exists');
        
        await _firestore.collection('admins').doc(adminId).set({
          'email': email,
          'name': 'Admin User',
          'role': 'admin',
          'updatedAt': FieldValue.serverTimestamp()
        }, SetOptions(merge: true));
        
        debugPrint('Ensured admin user document exists');
      } catch (adminError) {
        debugPrint('Error ensuring admin document: $adminError');
      }
      
      // Delete the category document
      debugPrint('Attempting to delete category document: ${categoryName.toLowerCase().replaceAll(' ', '_')}');
      await _firestore
          .collection(_categoriesCollection)
          .doc(categoryName.toLowerCase().replaceAll(' ', '_'))
          .delete();
      
      debugPrint('Successfully deleted category: $categoryName');
    } catch (e) {
      debugPrint('Error deleting category: $e');
      if (e is FirebaseException) {
        debugPrint('Firebase error code: ${e.code}');
        debugPrint('Firebase error message: ${e.message}');
      }
      throw Exception('Failed to delete category: $e');
    }
  }

  // Check if category has products
  static Future<bool> categoryHasProducts(String categoryName) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_productsCollection)
          .where('category', isEqualTo: categoryName)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check category products: $e');
    }
  }

  // ==== CART ====

  // Get user's cart
  static Future<List<CartItem>> getUserCart(String userId) async {
    try {
      DocumentSnapshot cartDoc = await _firestore
          .collection(_cartsCollection)
          .doc(userId)
          .get();

      if (cartDoc.exists) {
        Map<String, dynamic> cartData = cartDoc.data() as Map<String, dynamic>;
        List<dynamic> items = cartData['items'] ?? [];
        
        return items
            .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get cart: $e');
    }
  }

  // Update user's cart
  static Future<void> updateUserCart(String userId, List<CartItem> cartItems) async {
    try {
      await _firestore
          .collection(_cartsCollection)
          .doc(userId)
          .set({
            'items': cartItems.map((item) => item.toJson()).toList(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw Exception('Failed to update cart: $e');
    }
  }

  // Clear user's cart
  static Future<void> clearUserCart(String userId) async {
    try {
      await _firestore
          .collection(_cartsCollection)
          .doc(userId)
          .delete();
    } catch (e) {
      throw Exception('Failed to clear cart: $e');
    }
  }

  // ==== WISHLIST ====

  // Get user's wishlist
  static Future<List<String>> getUserWishlist(String userId) async {
    try {
      debugPrint('FirebaseDbService: Getting wishlist for user: $userId');
      DocumentSnapshot wishlistDoc = await _firestore
          .collection(_wishlistsCollection)
          .doc(userId)
          .get();

      if (wishlistDoc.exists) {
        Map<String, dynamic> wishlistData = wishlistDoc.data() as Map<String, dynamic>;
        List<String> productIds = List<String>.from(wishlistData['productIds'] ?? []);
        debugPrint('FirebaseDbService: Found wishlist document with ${productIds.length} items: $productIds');
        return productIds;
      } else {
        debugPrint('FirebaseDbService: No wishlist document found for user: $userId');
        return [];
      }
    } catch (e) {
      debugPrint('FirebaseDbService: Error getting wishlist for user $userId: $e');
      throw Exception('Failed to get wishlist: $e');
    }
  }

  // Add to wishlist
  static Future<void> addToWishlist(String userId, String productId) async {
    try {
      debugPrint('FirebaseDbService: Adding product $productId to wishlist for user: $userId');
      await _firestore
          .collection(_wishlistsCollection)
          .doc(userId)
          .set({
            'productIds': FieldValue.arrayUnion([productId]),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
      debugPrint('FirebaseDbService: Successfully added product $productId to wishlist for user: $userId');
    } catch (e) {
      debugPrint('FirebaseDbService: Error adding to wishlist for user $userId: $e');
      throw Exception('Failed to add to wishlist: $e');
    }
  }

  // Remove from wishlist
  static Future<void> removeFromWishlist(String userId, String productId) async {
    try {
      debugPrint('FirebaseDbService: Removing product $productId from wishlist for user: $userId');
      await _firestore
          .collection(_wishlistsCollection)
          .doc(userId)
          .update({
            'productIds': FieldValue.arrayRemove([productId]),
            'updatedAt': FieldValue.serverTimestamp(),
          });
      debugPrint('FirebaseDbService: Successfully removed product $productId from wishlist for user: $userId');
    } catch (e) {
      debugPrint('FirebaseDbService: Error removing from wishlist for user $userId: $e');
      throw Exception('Failed to remove from wishlist: $e');
    }
  }

  // ==== ORDERS ====

  // Create order
  static Future<String> createOrder(Map<String, dynamic> orderData) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(_ordersCollection)
          .add({
            ...orderData,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  // Get user's orders
  static Future<List<Map<String, dynamic>>> getUserOrders(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_ordersCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => {
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              })
          .toList();
    } catch (e) {
      throw Exception('Failed to get orders: $e');
    }
  }

  // Update order status (Admin only)
  static Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _firestore
          .collection(_ordersCollection)
          .doc(orderId)
          .update({
            'status': status,
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  // ==== REAL-TIME LISTENERS ====

  // Listen to products
  static Stream<List<Product>> listenToProducts() {
    return _firestore
        .collection(_productsCollection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromJson({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList());
  }

  // Listen to user's cart
  static Stream<List<CartItem>> listenToUserCart(String userId) {
    return _firestore
        .collection(_cartsCollection)
        .doc(userId)
        .snapshots()
        .map((doc) {
          if (doc.exists) {
            Map<String, dynamic> cartData = doc.data() as Map<String, dynamic>;
            List<dynamic> items = cartData['items'] ?? [];
            return items
                .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
                .toList();
          }
          return <CartItem>[];
        });
  }
}
