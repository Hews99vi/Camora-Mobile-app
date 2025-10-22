import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

/// A mock service that provides user data when Firestore is not available
/// or when you encounter "Cloud Firestore API has not been used in project" errors
class FirestoreMockService {
  static final FirestoreMockService _instance = FirestoreMockService._internal();
  factory FirestoreMockService() => _instance;
  FirestoreMockService._internal();
  
  static final Map<String, User> _mockUsers = {};
  
  /// Check if Firestore is available by making a simple read
  static Future<bool> isFirestoreAvailable() async {
    try {
      await FirebaseFirestore.instance.collection('test').limit(1).get();
      return true;
    } catch (e) {
      debugPrint('Firestore not available: $e');
      return false;
    }
  }
  
  /// Create mock user in local memory
  static Future<void> createUser(User user) async {
    if (user.id != null) {
      _mockUsers[user.id!] = user;
      debugPrint('[MOCK] Created user: ${user.email}');
    } else {
      debugPrint('[MOCK] Error: Attempted to create user with null ID');
    }
  }
  
  /// Get mock user from local memory
  static Future<User?> getUser(String userId) async {
    debugPrint('[MOCK] Getting user with ID: $userId');
    return _mockUsers[userId];
  }
  
  /// Update mock user in local memory
  static Future<void> updateUser(User user) async {
    if (user.id != null) {
      _mockUsers[user.id!] = user;
      debugPrint('[MOCK] Updated user: ${user.email}');
    } else {
      debugPrint('[MOCK] Error: Attempted to update user with null ID');
    }
  }
}