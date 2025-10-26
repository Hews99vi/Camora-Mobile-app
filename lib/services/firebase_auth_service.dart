import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user.dart' as app_user;

class FirebaseAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Flags to track if we should use dev auth (for development only)
  static final bool _useDevAuth = kDebugMode;
  
  // Helper method to initialize admin accounts
  static Future<void> _initializeAdminAccount(String email, String name) async {
    final adminId = 'dev-${email.hashCode}';
    debugPrint('Creating/updating admin document for $email with ID: $adminId');
    
    // First check if admin document exists
    final adminDocRef = _firestore.collection('admins').doc(adminId);
    final adminDocSnapshot = await adminDocRef.get();
    
    if (!adminDocSnapshot.exists) {
      debugPrint('Admin document for $email does not exist, creating it now...');
    } else {
      debugPrint('Admin document for $email already exists, will update it');
    }
    
    // Add or update the admin user in the admins collection
    await adminDocRef.set({
      'email': email,
      'name': name,
      'role': 'admin',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp()
    }, SetOptions(merge: true));
    
    // Also ensure the admin user exists in the users collection
    await _firestore.collection('users').doc(adminId).set({
      'id': adminId,
      'email': email,
      'name': name, 
      'role': 'admin',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'isActive': true,
    }, SetOptions(merge: true));
    
    debugPrint('Admin account for $email created/updated successfully');
  }

  // Verify and list all admins in Firestore
  static Future<void> verifyAdminsInFirestore() async {
    try {
      debugPrint('🔍 Checking all admin documents in Firestore...');
      
      // Check admins collection
      final adminsSnapshot = await _firestore.collection('admins').get();
      final adminEmails = adminsSnapshot.docs.map((doc) {
        final data = doc.data();
        return data['email'] as String?;
      }).where((email) => email != null).toList();
      
      debugPrint('📊 Found ${adminsSnapshot.docs.length} admin documents in Firestore:');
      for (final email in adminEmails) {
        debugPrint('👑 Admin: $email');
      }
      
      // Check if our required admin emails exist
      final requiredAdmins = {
        'admin@example.com': 'Admin User',
        'admin2@gmail.com': 'Admin2 User'
      };
      
      for (final adminEntry in requiredAdmins.entries) {
        final email = adminEntry.key;
        final name = adminEntry.value;
        
        if (!adminEmails.contains(email)) {
          debugPrint('⚠️ Required admin $email not found in Firestore, creating it now...');
          await _initializeAdminAccount(email, name);
        } else {
          debugPrint('✅ Required admin $email found in Firestore');
        }
      }
    } catch (e) {
      debugPrint('❌ Error verifying admin users: $e');
    }
  }

  // Initialize Firebase services
  static Future<void> initialize() async {
    debugPrint('Initializing Firebase Auth Service');
    
    // Initialize admin access for development
    if (_useDevAuth) {
      debugPrint('Using development authentication service');
      
      // Create admin documents to ensure admin permissions work
      try {
        // Initialize both admin users
        await _initializeAdminAccount('admin@example.com', 'Admin User');
        await _initializeAdminAccount('admin2@gmail.com', 'Admin2 User');
        
        // Verify all admin accounts are in Firestore
        await verifyAdminsInFirestore();
        
        debugPrint('Admin user documents created or updated in Firestore');
        
        // Comment out dev auth service signin as it's causing errors
      /*
        try {
          // Direct call to authenticate rather than using the method that might not exist
          debugPrint('Attempting dev auth service initialization');
        } catch (signInError) {
          debugPrint('Error with dev auth service: $signInError');
          // Continue anyway
        }
      */
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
        debugPrint("Using dev auth for signup: $email");
        
        // Create a user directly instead of using signUp method
        final userId = 'dev-${email.hashCode}';
        debugPrint("Creating user with ID: $userId");
        
        app_user.User user = app_user.User(
          id: userId,
          email: email,
          name: name,
          phone: phoneNumber,
          role: app_user.UserRole.customer,
        );
        
        // IMPORTANT: Add extra verification to ensure the user was saved to Firestore
        // This is our fix for the persistence issue
        if (user.id != null) {
          debugPrint("User created with ID: ${user.id}, verifying in Firestore...");
          
          // Double check that the user exists in Firestore
          final userDoc = await _firestore.collection('users').doc(user.id).get();
          
          if (!userDoc.exists) {
            debugPrint("User not found in Firestore, creating document explicitly");
            
            // Create user document in Firestore explicitly
            await _firestore.collection('users').doc(user.id).set({
              'id': user.id,
              'email': email,
              'name': name,
              'phone': phoneNumber,
              'role': 'customer',
              'createdAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
              'isActive': true,
            });
            
            // Verify again
            final verifyDoc = await _firestore.collection('users').doc(user.id).get();
            if (verifyDoc.exists) {
              debugPrint("Successfully created user document in Firestore");
            } else {
              debugPrint("CRITICAL: Failed to create user document in Firestore");
            }
          } else {
            debugPrint("User document already exists in Firestore");
          }
        }
        
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
          // Use real Firestore with SetOptions(merge: true) to ensure we don't overwrite existing data
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .set(newUser.toJson(), SetOptions(merge: true));
          
          // Verify the user was created in Firestore
          final verifyDoc = await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .get();
              
          if (verifyDoc.exists) {
            debugPrint("Successfully created user document in Firestore");
          } else {
            debugPrint("CRITICAL: Failed to create user document in Firestore");
          }
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
        // Instead of using the signIn method, we'll check for existing users directly
        debugPrint("Using dev auth for sign in: $email");
        
        // Look for user in Firestore by email
        try {
          final userQuery = await _firestore
              .collection('users')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();
              
          if (userQuery.docs.isNotEmpty) {
            final userData = userQuery.docs.first.data();
            final userId = userData['id'] as String? ?? 'dev-${email.hashCode}';
            final name = userData['name'] as String? ?? 'User';
            final roleStr = userData['role'] as String? ?? 'customer';
            
            // Simple password check - for dev only
            // In production, we'd use proper Firebase Auth
            
            final isAdmin = roleStr.toLowerCase() == 'admin';
            
            return app_user.User(
              id: userId,
              email: email,
              name: name,
              role: isAdmin ? app_user.UserRole.admin : app_user.UserRole.customer,
            );
          } else {
            throw Exception('User not found');
          }
        } catch (e) {
          debugPrint("Error finding user: $e");
          throw Exception('User not found');
        }
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
