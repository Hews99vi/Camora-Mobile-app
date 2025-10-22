import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user.dart' as app_user;

class AdminUserService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Creates the first admin user
  /// Call this method once to create an admin account
  static Future<void> createAdminUser({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
  }) async {
    try {
      debugPrint('Creating admin user...');
      
      // Create user with Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Create admin user document in Firestore
        app_user.User adminUser = app_user.User(
          id: userCredential.user!.uid,
          name: name,
          email: email,
          phone: phoneNumber, // Use phone instead of phoneNumber
          role: app_user.UserRole.admin, // Set as admin
        );

        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(adminUser.toJson());

        debugPrint('Admin user created successfully!');
        debugPrint('Email: $email');
        debugPrint('Password: $password');
        debugPrint('Role: admin');
      }
    } catch (e) {
      debugPrint('Error creating admin user: $e');
      throw Exception('Failed to create admin user: $e');
    }
  }

  /// Promotes an existing user to admin
  static Future<void> promoteUserToAdmin(String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({'role': 'admin'});
      
      debugPrint('User $userId promoted to admin successfully!');
    } catch (e) {
      debugPrint('Error promoting user to admin: $e');
      throw Exception('Failed to promote user to admin: $e');
    }
  }

  /// Demotes an admin to regular user
  static Future<void> demoteAdminToUser(String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({'role': 'customer'});
      
      debugPrint('Admin $userId demoted to user successfully!');
    } catch (e) {
      debugPrint('Error demoting admin to user: $e');
      throw Exception('Failed to demote admin to user: $e');
    }
  }

  /// Gets all admin users
  static Future<List<app_user.User>> getAllAdmins() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .get();

      return snapshot.docs
          .map((doc) => app_user.User.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error getting admin users: $e');
      throw Exception('Failed to get admin users: $e');
    }
  }

  /// Checks if any admin users exist
  static Future<bool> adminExists() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking for admin users: $e');
      return false;
    }
  }
}
