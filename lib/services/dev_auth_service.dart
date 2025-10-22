import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user.dart';

/// A development authentication service that provides simplified auth for testing
/// This is useful during development when Firebase Auth might have issues
class DevAuthService {
  final Map<String, _DevUser> _users = {};
  
  DevAuthService() {
    // Pre-populate with some test users
    _addTestUser('test@example.com', 'password123', 'Test User');
    _addTestUser('admin@example.com', 'admin123', 'Admin User', role: UserRole.admin);
    
    // Initialize Firestore with admin user documents
    _initializeAdminUsers();
  }
  
  // Create admin documents in Firestore
  Future<void> _initializeAdminUsers() async {
    try {
      // Create admin document for pre-defined admin user
      final adminUser = _users['admin@example.com']!;
      
      await FirebaseFirestore.instance
          .collection('admins')
          .doc(adminUser.userId)
          .set({
            'email': adminUser.email,
            'name': adminUser.displayName,
            'role': 'admin',
            'updatedAt': FieldValue.serverTimestamp()
          }, SetOptions(merge: true));
      
      debugPrint('Initialized admin user document in Firestore');
      
      // Also add to users collection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(adminUser.userId)
          .set({
            'id': adminUser.userId,
            'email': adminUser.email,
            'name': adminUser.displayName,
            'role': 'admin',
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
            'isActive': true,
          }, SetOptions(merge: true));
      
      debugPrint('Initialized admin user profile in Firestore');
      
    } catch (e) {
      debugPrint('Error initializing admin users: $e');
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
  }

  /// Sign up with email and password
  Future<User?> signUp(String email, String password, String name, {UserRole role = UserRole.customer}) async {
    if (_users.containsKey(email)) {
      throw Exception('User already exists');
    }
    
    final userId = 'dev-${email.hashCode}';
    final devUser = _DevUser(
      email: email,
      password: password, 
      userId: userId,
      displayName: name,
      role: role,
    );
    
    _users[email] = devUser;
    
    return User(
      id: userId,
      email: email,
      name: name,
      role: role,
    );
  }
  
  /// Sign in with email and password
  Future<User?> signIn(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay
    
    final user = _users[email];
    if (user == null) {
      throw Exception('User not found');
    }
    
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
              'email': user.email,
              'name': user.displayName,
              'role': 'admin',
              'updatedAt': FieldValue.serverTimestamp()
            }, SetOptions(merge: true));
        
        debugPrint('Created/updated admin document for ${user.email}');
      } catch (e) {
        debugPrint('Error creating admin document: $e');
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
