import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';

/// A development authentication service that provides simplified auth for testing
/// This is useful during development when Firebase Auth might have issues
class DevAuthService {
  final Map<String, _DevUser> _users = {};
  
  // Fixed: Changed the storage key to match what we're using elsewhere
  static const String _usersStorageKey = 'dev_auth_users';
  bool _isInitialized = false;
  
  DevAuthService() {
    // Pre-populate with some test users
    _addTestUser('test@example.com', 'password123', 'Test User');
    _addTestUser('admin@example.com', 'admin123', 'Admin User', role: UserRole.admin);
    _addTestUser('admin2@gmail.com', 'admin1234', 'Admin2 User', role: UserRole.admin);
    
    // Initialize - this will be awaited before any auth operations
    _initialize();
  }
  
  Future<void> _initialize() async {
    debugPrint('⭐️ DevAuthService initializing...');
    
    // Load any saved users from SharedPreferences
    await _loadSavedUsers();
    
    // Initialize Firestore with admin user documents
    await _initializeAdminUsers();
    
    // Debug information about stored users
    debugPrint('⭐️ DevAuthService loaded ${_users.length} users');
    _users.forEach((email, user) {
      debugPrint('⭐️ User: $email (ID: ${user.userId})');
    });
    
    _isInitialized = true;
    debugPrint('⭐️ DevAuthService initialization completed');
  }
  
  // Load saved users from SharedPreferences
  Future<void> _loadSavedUsers() async {
    try {
      debugPrint('⭐️ Loading saved users from SharedPreferences');
      final prefs = await SharedPreferences.getInstance();
      
      // Try to load with the standard key first
      String? savedUsersJson = prefs.getString(_usersStorageKey);
      
      if (savedUsersJson == null) {
        debugPrint('⭐️ No users found with primary key, checking alternate key');
        // Try an alternate key that might have been used in previous versions
        savedUsersJson = prefs.getString('dev_auth_users');
        
        // If found with alternate key, migrate it
        if (savedUsersJson != null) {
          debugPrint('⭐️ Found users with alternate key, migrating...');
          await prefs.setString(_usersStorageKey, savedUsersJson);
          await prefs.remove('dev_auth_users');
        }
      }
      
      if (savedUsersJson != null) {
        debugPrint('⭐️ Found saved users data in SharedPreferences');
        final Map<String, dynamic> savedUsers;
        
        try {
          savedUsers = json.decode(savedUsersJson) as Map<String, dynamic>;
          debugPrint('⭐️ Successfully parsed JSON data with ${savedUsers.length} users');
        } catch (e) {
          debugPrint('❌ Failed to decode saved users JSON: $e');
          // If there's an error decoding the JSON, clear the corrupted data
          await prefs.remove(_usersStorageKey);
          return;
        }
        
        savedUsers.forEach((email, userData) {
          if (userData is Map<String, dynamic>) {
            try {
              // Don't overwrite the default users if they already exist
              if (!_users.containsKey(email)) {
                _users[email] = _DevUser(
                  email: email,
                  password: userData['password'] as String,
                  userId: userData['userId'] as String,
                  displayName: userData['displayName'] as String,
                  role: _parseUserRole(userData['role'] as String),
                );
                debugPrint('⭐️ Loaded saved user: $email (ID: ${userData['userId']})');
              }
            } catch (e) {
              debugPrint('❌ Error loading user $email: $e');
              // Continue with next user
            }
          }
        });
        
        // Debug log all loaded users
        debugPrint('⭐️ Loaded ${_users.length} users: ${_users.keys.join(', ')}');
      } else {
        debugPrint('⭐️ No saved users found in SharedPreferences');
      }
    } catch (e) {
      debugPrint('❌ Error loading saved users: $e');
    }
  }
  
  UserRole _parseUserRole(String roleStr) {
    switch (roleStr.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.customer;
    }
  }
  
  // Create admin documents in Firestore
  Future<void> _initializeAdminUsers() async {
    try {
      // List of admin emails to initialize - add both admins here
      final adminEmails = ['admin@example.com', 'admin2@gmail.com'];
      
      // Make sure both admin emails are properly set up
      for (final email in adminEmails) {
        if (!_users.containsKey(email)) {
          debugPrint('⚠️ Admin user $email not found in local users list, skipping initialization');
          continue;
        }
        
        final adminUser = _users[email]!;
        debugPrint('🔐 Initializing admin user: $email (ID: ${adminUser.userId})');
        
        // First, ensure the admin exists in the users collection with admin role
        await FirebaseFirestore.instance
            .collection('users')
            .doc(adminUser.userId)
            .set({
              'id': adminUser.userId,
              'email': adminUser.email,
              'name': adminUser.displayName,
              'role': 'admin', // Set role as admin
              'createdAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
              'isActive': true,
            }, SetOptions(merge: true));
        
        // Also add to admins collection for dual verification
        await FirebaseFirestore.instance
            .collection('admins')
            .doc(adminUser.userId)
            .set({
              'id': adminUser.userId, // Add ID field 
              'email': adminUser.email,
              'name': adminUser.displayName,
              'role': 'admin',
              'createdAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
              'isActive': true,
            }, SetOptions(merge: true));
        
        // Verify that both documents exist
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(adminUser.userId)
            .get();
            
        final adminDoc = await FirebaseFirestore.instance
            .collection('admins')
            .doc(adminUser.userId)
            .get();
            
        if (userDoc.exists && adminDoc.exists) {
          debugPrint('✅ Verified admin user $email exists in both collections');
        } else {
          debugPrint('⚠️ Admin user $email missing from one or more collections!');
        }
      }
      
      // Extra verification step - check all admin users in Firestore
      debugPrint('📋 Checking all admin documents in Firestore...');
      try {
        final adminsSnapshot = await FirebaseFirestore.instance.collection('admins').get();
        debugPrint('📊 Found ${adminsSnapshot.docs.length} admin documents in Firestore:');
        
        for (final doc in adminsSnapshot.docs) {
          final data = doc.data();
          debugPrint('👑 Admin: ${data['email'] ?? 'Unknown'} (ID: ${doc.id})');
        }
      } catch (e) {
        debugPrint('❌ Error checking admin documents: $e');
      }
      
      // Call our helper method to verify and fix any inconsistencies
      await _verifyAndFixAdminUsers();
    } catch (e) {
      debugPrint('❌ Error initializing admin users: $e');
      // Continue anyway
    }
  }
  
  /// Verify admin users in Firestore and ensure they exist in both collections
  /// This is called from _initializeAdminUsers to ensure consistency
  Future<void> _verifyAndFixAdminUsers() async {
    try {
      debugPrint('🔍 Verifying admin users in Firestore...');
      
      // Get all users from the admins collection
      final adminsSnapshot = await FirebaseFirestore.instance.collection('admins').get();
      
      debugPrint('📊 Found ${adminsSnapshot.docs.length} admin documents');
      
      for (final doc in adminsSnapshot.docs) {
        final data = doc.data();
        final email = data['email'] as String?;
        final name = data['name'] as String?;
        
        if (email != null) {
          debugPrint('👑 Verifying admin: $email (ID: ${doc.id})');
          
          // Check if the user also exists in the users collection
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(doc.id)
              .get();
              
          if (!userDoc.exists) {
            debugPrint('⚠️ Admin $email missing from users collection, adding now...');
            
            // Create in users collection
            await FirebaseFirestore.instance
                .collection('users')
                .doc(doc.id)
                .set({
                  'id': doc.id,
                  'email': email,
                  'name': name ?? 'Admin User',
                  'role': 'admin',
                  'createdAt': FieldValue.serverTimestamp(),
                  'updatedAt': FieldValue.serverTimestamp(),
                  'isActive': true,
                }, SetOptions(merge: true));
          } else {
            // Make sure the role is set to admin
            final userData = userDoc.data();
            final userRole = userData?['role'] as String?;
            
            if (userRole?.toLowerCase() != 'admin') {
              debugPrint('⚠️ User $email has role $userRole in users collection, updating to admin...');
              
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(doc.id)
                  .update({
                    'role': 'admin',
                    'updatedAt': FieldValue.serverTimestamp()
                  });
            } else {
              debugPrint('✅ Admin $email exists in both collections with correct roles');
            }
          }
        } else {
          debugPrint('⚠️ Admin document ${doc.id} has no email field!');
        }
      }
      
      debugPrint('✅ Admin verification complete');
    } catch (e) {
      debugPrint('❌ Error verifying admin users: $e');
      // Continue anyway
    }
  }
  
  void _addTestUser(String email, String password, String name, {UserRole role = UserRole.customer}) {
    final userId = 'dev-${email.hashCode}';
    _users[email] = _DevUser(
      email: email,
      password: password,
      userId: userId,
      displayName: name,
      role: role,
    );
    // Don't save default test users to SharedPreferences - they're always added on init
  }

  /// Save all users to SharedPreferences
  Future<void> _saveUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final usersMap = <String, dynamic>{};
      _users.forEach((email, user) {
        usersMap[email] = {
          'email': user.email,
          'password': user.password,
          'userId': user.userId,
          'displayName': user.displayName,
          'role': user.role == UserRole.admin ? 'admin' : 'customer',
        };
      });
      
      final jsonData = json.encode(usersMap);
      debugPrint('⭐️ Saving ${_users.length} users to SharedPreferences');
      
      // First, try to save and verify
      final success = await prefs.setString(_usersStorageKey, jsonData);
      
      if (success) {
        // Verify the data was saved correctly
        final verifyJson = prefs.getString(_usersStorageKey);
        if (verifyJson == jsonData) {
          debugPrint('✅ Users saved to SharedPreferences successfully and verified');
          debugPrint('⭐️ Saved users: ${_users.keys.join(', ')}');
        } else {
          debugPrint('⚠️ Users saved but verification failed - data mismatch');
        }
      } else {
        debugPrint('❌ Failed to save users to SharedPreferences');
      }
    } catch (e) {
      debugPrint('❌ Error saving users: $e');
    }
  }

  /// Sign up with email and password
  Future<User?> signUp(String email, String password, String name, {UserRole role = UserRole.customer}) async {
    // Make sure initialization is complete before proceeding
    if (!_isInitialized) {
      debugPrint('DevAuthService not yet initialized, waiting...');
      await _initialize();
      debugPrint('DevAuthService initialization completed, proceeding with sign up');
    }
    
    if (_users.containsKey(email)) {
      throw Exception('User already exists');
    }
    
    final userId = 'dev-${email.hashCode}';
    debugPrint('Creating new user with ID: $userId, email: $email');
    
    final devUser = _DevUser(
      email: email,
      password: password, 
      userId: userId,
      displayName: name,
      role: role,
    );
    
    // Add to in-memory map
    _users[email] = devUser;
    
    // First save to SharedPreferences to ensure we have a local backup
    await _saveUsers();
    
    // Then create user in Firestore for persistence with retries
    int maxRetries = 3;
    int retryCount = 0;
    bool success = false;
    
    while (retryCount < maxRetries && !success) {
      try {
        final userData = {
          'id': userId,
          'email': email,
          'name': name,
          'role': role == UserRole.admin ? 'admin' : 'customer',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'isActive': true,
        };
        
        debugPrint('Saving user to Firestore (attempt ${retryCount + 1}): $userData');
        
        // Try direct set operation first
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .set(userData, SetOptions(merge: true));
        
        // Wait a moment to ensure the write is propagated
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Verify the user was saved by reading it back
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
            
        if (userDoc.exists) {
          debugPrint('Successfully created user document in Firestore for $email');
          success = true;
          break;
        } else {
          debugPrint('Failed to verify user document in Firestore for $email - retrying...');
          retryCount++;
          await Future.delayed(const Duration(seconds: 1));
        }
      } catch (e) {
        debugPrint('Error creating user document in Firestore (attempt ${retryCount + 1}): $e');
        retryCount++;
        await Future.delayed(const Duration(seconds: 1));
      }
    }
    
    if (!success) {
      debugPrint('WARNING: Failed to save user to Firestore after $maxRetries attempts. '
                'The user will be available in memory but may not persist across app restarts.');
    }
    
    // Return the user object regardless of Firestore success
    // We've saved it to SharedPreferences, so it should be available for this session
    return User(
      id: userId,
      email: email,
      name: name,
      role: role,
    );
  }
  
  /// Sign in with email and password
  Future<User?> signIn(String email, String password) async {
    // Make sure initialization is complete before proceeding
    if (!_isInitialized) {
      debugPrint('DevAuthService not yet initialized, waiting...');
      await _initialize();
      debugPrint('DevAuthService initialization completed, proceeding with sign in');
    }
    
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay
    
    // Check if user exists in memory
    var user = _users[email];
    
    // Log all users in memory for debugging
    debugPrint('Available users in memory: ${_users.keys.join(', ')}');
    
    // If not found in memory, try to find in Firestore
    if (user == null) {
      try {
        debugPrint('User $email not found in memory, checking Firestore...');
        
        // Query users by email
        final userQuery = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();
        
        if (userQuery.docs.isNotEmpty) {
          final userData = userQuery.docs.first.data();
          final userId = userData['id'] as String;
          final name = userData['name'] as String;
          final roleStr = userData['role'] as String? ?? 'customer';
          
          // We don't store passwords in Firestore for security reasons,
          // so we'll have to accept any password in this recovery path
          // This is just for development, so it's acceptable
          
          // Check if user is in admin collection regardless of role in users collection
          bool isAdmin = roleStr.toLowerCase() == 'admin';
          
          // Double check admin status in admins collection
          if (!isAdmin) {
            final adminDoc = await FirebaseFirestore.instance
                .collection('admins')
                .doc(userId)
                .get();
                
            if (adminDoc.exists) {
              isAdmin = true;
              debugPrint('User found in admins collection but not marked as admin in users collection. '
                         'Setting role to admin.');
              
              // Update users collection to mark as admin
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .update({'role': 'admin'});
            }
          }
          
          user = _DevUser(
            email: email,
            password: password, // Use the provided password
            userId: userId,
            displayName: name,
            role: isAdmin ? UserRole.admin : UserRole.customer,
          );
          
          // Add to our in-memory map
          _users[email] = user;
          
          // Save to SharedPreferences
          await _saveUsers();
          
          debugPrint('Recovered user $email from Firestore with role: ${isAdmin ? 'admin' : 'customer'}');
        } else {
          throw Exception('User not found');
        }
      } catch (e) {
        debugPrint('Error looking up user in Firestore: $e');
        throw Exception('User not found');
      }
    }
    
    // At this point user should exist since we either found it in memory
    // or recovered it from Firestore. If not, an exception would have been thrown earlier.
    
    // Check password (skip if recovered from Firestore)
    if (user.password != password) {
      throw Exception('Invalid password');
    }
    
    // Create or update the admin document in Firestore for admin users
    if (user.role == UserRole.admin) {
      try {
        // Add user to admins collection to ensure proper permissions
        await FirebaseFirestore.instance
            .collection('admins')
            .doc(user.userId)
            .set({
              'id': user.userId,  // Add ID field
              'email': user.email,
              'name': user.displayName,
              'role': 'admin',
              'createdAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
              'isActive': true
            }, SetOptions(merge: true));
        
        // Also make sure the user document has admin role
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.userId)
            .update({
              'role': 'admin',
              'updatedAt': FieldValue.serverTimestamp()
            });
        
        debugPrint('Created/updated admin documents for ${user.email} in both collections');
      } catch (e) {
        debugPrint('Error updating admin documents: $e');
        // Continue anyway
      }
    }
    
    return User(
      id: user.userId,
      email: user.email,
      name: user.displayName,
      role: user.role,
    );
  }
  
  /// Check if dev auth should be used
  bool shouldUse() {
    // In a real app, you might check for specific conditions
    // like a debug flag or a specific environment
    return kDebugMode;
  }
  
  /// Debug method to check all users in Firestore
  /// This is useful for debugging only
  Future<void> checkFirestoreUsers() async {
    try {
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();
      
      debugPrint('Found ${usersSnapshot.docs.length} users in Firestore:');
      for (final doc in usersSnapshot.docs) {
        final data = doc.data();
        debugPrint('User: ${data['email']} (ID: ${doc.id})');
      }
    } catch (e) {
      debugPrint('Error checking Firestore users: $e');
    }
  }
  
  /// Reset all stored users (except defaults)
  /// This is useful for debugging or testing
  Future<void> resetStoredUsers() async {
    try {
      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_usersStorageKey);
      
      // Reset in-memory users to defaults only
      final defaultUsers = Map<String, _DevUser>.from(_users);
      _users.clear();
      
      // Only keep test@example.com and admin@example.com
      if (defaultUsers.containsKey('test@example.com')) {
        _users['test@example.com'] = defaultUsers['test@example.com']!;
      }
      
      if (defaultUsers.containsKey('admin@example.com')) {
        _users['admin@example.com'] = defaultUsers['admin@example.com']!;
      }
      
      debugPrint('Reset stored users to defaults only');
    } catch (e) {
      debugPrint('Error resetting stored users: $e');
    }
  }
}

/// Internal user class for dev auth service
class _DevUser {
  final String email;
  final String password;
  final String userId;
  final String displayName;
  final UserRole role;
  
  _DevUser({
    required this.email,
    required this.password,
    required this.userId,
    required this.displayName,
    required this.role,
  });
}
