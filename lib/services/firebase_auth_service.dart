import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user.dart' as app_user;
import 'firestore_mock_service.dart';
import 'dev_auth_service.dart';

class FirebaseAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final DevAuthService _devAuth = DevAuthService();
  
  // Flags to track if we should use dev auth (for development only)
  static bool _useDevAuth = kDebugMode;
  
  // Initialize Firebase services
  static Future<void> initialize() async {
    debugPrint('Initializing Firebase Auth Service');
    
    // Initialize admin access for development
    if (_useDevAuth) {
      debugPrint('Using development authentication service');
      
      // Create admin document to ensure admin permission works
      try {
        // Check if we are in dev mode and use the admin user from DevAuthService
        final adminId = 'dev-${('admin@example.com').hashCode}';
        debugPrint('Creating admin document with ID: $adminId');
        
        // First check if admin document exists
        final adminDocRef = _firestore.collection('admins').doc(adminId);
        final adminDocSnapshot = await adminDocRef.get();
        
        if (!adminDocSnapshot.exists) {
          debugPrint('Admin document does not exist, creating it now...');
        } else {
          debugPrint('Admin document already exists, will update it');
        }
        
        // Add or update the admin user in the admins collection
        await adminDocRef.set({
          'email': 'admin@example.com',
          'name': 'Admin User',
          'role': 'admin',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp()
        }, SetOptions(merge: true));
        
        // Also ensure the admin user exists in the users collection
        await _firestore.collection('users').doc(adminId).set({
          'id': adminId,
          'email': 'admin@example.com',
          'name': 'Admin User', 
          'role': 'admin',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'isActive': true,
        }, SetOptions(merge: true));
        
        debugPrint('Admin user documents created or updated in Firestore');
        
        // Also try to sign in with dev auth service to ensure Firebase Auth is properly set up
        try {
          await _devAuth.signIn('admin@example.com', 'admin123');
          debugPrint('Successfully signed in with dev auth service');
        } catch (signInError) {
          debugPrint('Error signing in with dev auth service: $signInError');
          // Continue anyway
        }
      } catch (e) {
        debugPrint('Failed to create admin document: $e');
        debugPrint('Error details: ${e.toString()}');
        if (e is FirebaseException) {
          debugPrint('Firebase error code: ${e.code}');
          debugPrint('Firebase error message: ${e.message}');
        }
        // Continue anyway
      }
    }
  }

  // Get current user
  static User? get currentUser => _auth.currentUser;

  // Configure Firebase Auth settings
  static void _configureAuth() {
    // Disable reCAPTCHA verification for development
    _auth.setSettings(
      appVerificationDisabledForTesting: true, // Only for development!
    );
  }

  // Sign up with email and password
  static Future<app_user.User?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
  }) async {
    try {
      // Check if we should use dev auth
      if (_useDevAuth) {
        // Use development auth service
        app_user.User? user = await _devAuth.signUp(
          email,
          password,
          name,
          role: app_user.UserRole.customer,
        );
        return user;
      }
      
      // Disable reCAPTCHA verification for development
      _configureAuth();
      
      // For testing in emulators, you can use emulator settings
      // This is only needed for local development with emulators
      if (kDebugMode) {
        debugPrint("Signing up with email and password: $email");
      }
      
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Create user document in Firestore
        app_user.User newUser = app_user.User(
          id: userCredential.user!.uid,
          name: name,
          email: email,
          phone: phoneNumber, // Use phone instead of phoneNumber
          role: app_user.UserRole.customer,
        );

        try {
          // Use real Firestore
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .set(newUser.toJson());
        } catch (e) {
          debugPrint('Failed to create user document: $e');
          // Continue anyway to return the user object
        }

        return newUser;
      }
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
    return null;
  }

  // Sign in with email and password
  static Future<app_user.User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Check if we should use dev auth
      if (_useDevAuth) {
        // Use development auth service
        app_user.User? user = await _devAuth.signIn(email, password);
        return user;
      }
      
      // Disable reCAPTCHA verification for development
      _configureAuth();
      
      if (kDebugMode) {
        debugPrint("Signing in with email and password: $email");
      }
      
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        try {
          // Get user data from real Firestore
          DocumentSnapshot userDoc = await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .get();

          // Check if the user is in admin collection
          DocumentSnapshot adminDoc = await _firestore
              .collection('admins')
              .doc(userCredential.user!.uid)
              .get();
            
          // Determine if user is admin
          bool isAdmin = adminDoc.exists;
          app_user.UserRole role = isAdmin ? app_user.UserRole.admin : app_user.UserRole.customer;
          
          if (userDoc.exists) {
            Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
            // Override role if user is admin
            if (isAdmin) {
              userData['role'] = 'admin';
            }
            return app_user.User.fromJson(userData);
          } else {
            // Create a basic user if not found in Firestore
            app_user.User newUser = app_user.User(
              id: userCredential.user!.uid,
              name: userCredential.user!.displayName ?? 'User',
              email: userCredential.user!.email ?? '',
              role: role, // Use the determined role
            );
            await _firestore
                .collection('users')
                .doc(userCredential.user!.uid)
                .set(newUser.toJson());
            return newUser;
          }
        } catch (e) {
          debugPrint('Error getting user data: $e');
          // Create and return a basic user object even if Firestore fails
          return app_user.User(
            id: userCredential.user!.uid,
            name: userCredential.user!.displayName ?? 'User',
            email: userCredential.user!.email ?? '',
            role: app_user.UserRole.customer,
          );
        }
      }
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
    return null;
  }

  // Get user data
  static Future<app_user.User?> getUserData(String userId) async {
    try {
      // Check if the user is in the admins collection
      DocumentSnapshot adminDoc = await _firestore
          .collection('admins')
          .doc(userId)
          .get();
      
      // Determine if user is admin
      bool isAdmin = adminDoc.exists;
      
      // Use real Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        // Override role if user is admin
        if (isAdmin) {
          userData['role'] = 'admin';
        }
        return app_user.User.fromJson(userData);
      } else if (isAdmin) {
        // If user is in admin collection but not in users collection
        return app_user.User(
          id: userId,
          email: adminDoc.get('email') as String? ?? 'admin@example.com',
          name: adminDoc.get('name') as String? ?? 'Admin User',
          role: app_user.UserRole.admin,
        );
      }
    } catch (e) {
      debugPrint('Failed to get user data: $e');
      // Instead of throwing, which breaks the app, return null
      // throw Exception('Failed to get user data: $e');
    }
    return null;
  }
  
  // Update user data
  static Future<void> updateUserData(app_user.User user) async {
    try {
      // Use real Firestore
      if (user.id != null) {
        await _firestore
            .collection('users')
            .doc(user.id)
            .update(user.toJson());
            
        // If user is admin, update or create admin document
        if (user.role == app_user.UserRole.admin) {
          await _firestore
              .collection('admins')
              .doc(user.id)
              .set({
                'email': user.email,
                'name': user.name,
                'role': 'admin',
                'updatedAt': FieldValue.serverTimestamp()
              }, SetOptions(merge: true));
        }
      } else {
        throw Exception('User ID is null');
      }
    } catch (e) {
      debugPrint('Failed to update user data: $e');
      // throw Exception('Failed to update user data: $e');
    }
  }  // Sign out
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  // Reset password
  static Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  // Listen to auth state changes
  static Stream<User?> get authStateChanges => _auth.authStateChanges();
}
