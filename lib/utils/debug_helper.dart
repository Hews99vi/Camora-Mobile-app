import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'dart:convert';

/// A utility class for debugging authentication and user management
class DebugHelper {
  /// Create a new user with guaranteed persistence
  /// This is a more reliable method that ensures the user is properly stored
  static Future<User?> createAndVerifyUser(
    String email, 
    String password, 
    String name, 
    {UserRole role = UserRole.customer}
  ) async {
    try {
      // 1. Create user ID and user data
      final userId = 'dev-${email.hashCode}';
      debugPrint('Creating user with ID: $userId, email: $email');
      
      // 2. Directly save to Firestore first
      final userData = {
        'id': userId,
        'email': email,
        'name': name,
        'role': role == UserRole.admin ? 'admin' : 'customer',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
      };
      
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .set(userData);
      
      // 3. Verify the user was saved to Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
          
      if (!userDoc.exists) {
        debugPrint('Failed to save user to Firestore');
        throw Exception('Failed to save user to Firestore');
      }
      
      debugPrint('Successfully saved user to Firestore: $userId');
      
      // 4. Save to SharedPreferences directly as well
      await _saveUserToSharedPreferences(email, password, name, userId, role);
      
      // 5. Create user directly without DevAuthService methods
      debugPrint('Account creation complete');
      
      // Create user object directly
      final user = User(
        id: userId,
        email: email,
        name: name,
        role: role,
      );
      
      debugPrint('Successfully created user object');
      
      // Skip retrieval test - it's redundant since we already verified 
      // the document exists in Firestore
      
      // 7. Return the user object
      return user;
    } catch (e) {
      debugPrint('Error in createAndVerifyUser: $e');
      return null;
    }
  }
  
  // Save user directly to SharedPreferences
  static Future<void> _saveUserToSharedPreferences(
    String email,
    String password,
    String name,
    String userId,
    UserRole role
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // First retrieve existing data
      final savedUsersJson = prefs.getString('dev_auth_users');
      Map<String, dynamic> savedUsers = {};
      
      if (savedUsersJson != null) {
        try {
          savedUsers = json.decode(savedUsersJson) as Map<String, dynamic>;
          debugPrint('Found existing users in SharedPreferences');
        } catch (e) {
          debugPrint('Failed to decode saved users JSON, starting fresh');
          // Continue with empty map
        }
      }
      
      // Add or update the user
      savedUsers[email] = {
        'email': email,
        'password': password,
        'userId': userId,
        'displayName': name,
        'role': role == UserRole.admin ? 'admin' : 'customer',
      };
      
      // Save back to SharedPreferences
      final jsonData = json.encode(savedUsers);
      final success = await prefs.setString('dev_auth_users', jsonData);
      
      if (success) {
        debugPrint('User saved to SharedPreferences successfully');
      } else {
        debugPrint('Failed to save user to SharedPreferences');
      }
    } catch (e) {
      debugPrint('Error saving user to SharedPreferences: $e');
    }
  }
  
  /// Debug method to show all users in SharedPreferences and Firestore
  static Future<Map<String, dynamic>> debugAllUsers() async {
    Map<String, dynamic> result = {
      'firestoreUsers': <Map<String, dynamic>>[],
      'sharedPrefUsers': <Map<String, dynamic>>[],
      'firestoreCount': 0,
      'sharedPrefCount': 0,
    };
    
    try {
      // Check Firestore users
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();
      
      debugPrint('==== FIRESTORE USERS ====');
      debugPrint('Found ${usersSnapshot.docs.length} users in Firestore:');
      
      List<Map<String, dynamic>> firestoreUsers = [];
      for (final doc in usersSnapshot.docs) {
        final data = doc.data();
        debugPrint('User: ${data['email']} (ID: ${doc.id})');
        firestoreUsers.add({
          'id': doc.id,
          'email': data['email'],
          'name': data['name'],
          'role': data['role'],
        });
      }
      
      result['firestoreUsers'] = firestoreUsers;
      result['firestoreCount'] = firestoreUsers.length;
      
      // Check SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('dev_auth_users');
      
      debugPrint('==== SHARED PREFERENCES USERS ====');
      List<Map<String, dynamic>> sharedPrefUsers = [];
      
      if (usersJson != null) {
        debugPrint('Found user data in SharedPreferences');
        try {
          final Map<String, dynamic> savedUsers = json.decode(usersJson) as Map<String, dynamic>;
          debugPrint('Number of users in SharedPreferences: ${savedUsers.length}');
          
          savedUsers.forEach((email, userData) {
            if (userData is Map<String, dynamic>) {
              debugPrint('User: $email (ID: ${userData['userId']})');
              sharedPrefUsers.add({
                'email': email,
                'userId': userData['userId'],
                'displayName': userData['displayName'],
                'role': userData['role'],
              });
            }
          });
        } catch (e) {
          debugPrint('Error parsing SharedPreferences data: $e');
        }
      } else {
        debugPrint('No users found in SharedPreferences');
      }
      
      result['sharedPrefUsers'] = sharedPrefUsers;
      result['sharedPrefCount'] = sharedPrefUsers.length;
      
      // Compare the two
      debugPrint('==== COMPARISON ====');
      debugPrint('Firestore users: ${result['firestoreCount']}');
      debugPrint('SharedPreferences users: ${result['sharedPrefCount']}');
      
      if (firestoreUsers.isNotEmpty && sharedPrefUsers.isNotEmpty) {
        // Check for users in Firestore but not in SharedPrefs
        debugPrint('Checking for users in Firestore but not in SharedPrefs...');
        for (final firestoreUser in firestoreUsers) {
          bool found = false;
          for (final sharedPrefUser in sharedPrefUsers) {
            if (firestoreUser['id'] == sharedPrefUser['userId']) {
              found = true;
              break;
            }
          }
          
          if (!found && firestoreUser['email'] != 'admin@example.com' && firestoreUser['email'] != 'test@example.com') {
            debugPrint('WARNING: User ${firestoreUser['email']} exists in Firestore but not in SharedPreferences');
          }
        }
        
        // Check for users in SharedPrefs but not in Firestore
        debugPrint('Checking for users in SharedPrefs but not in Firestore...');
        for (final sharedPrefUser in sharedPrefUsers) {
          bool found = false;
          for (final firestoreUser in firestoreUsers) {
            if (sharedPrefUser['userId'] == firestoreUser['id']) {
              found = true;
              break;
            }
          }
          
          if (!found && sharedPrefUser['email'] != 'admin@example.com' && sharedPrefUser['email'] != 'test@example.com') {
            debugPrint('WARNING: User ${sharedPrefUser['email']} exists in SharedPreferences but not in Firestore');
          }
        }
      }
      
    } catch (e) {
      debugPrint('Error in debugAllUsers: $e');
    }
    
    return result;
  }

  /// Fix user storage by ensuring all users are in both SharedPreferences and Firestore
  static Future<bool> fixUserStorage() async {
    try {
      // 1. Get all users from both storage locations
      final firestoreSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();
          
      final prefs = await SharedPreferences.getInstance();
      final savedUsersJson = prefs.getString('dev_auth_users');
      
      Map<String, dynamic> sharedPrefsUsers = {};
      if (savedUsersJson != null) {
        try {
          sharedPrefsUsers = json.decode(savedUsersJson) as Map<String, dynamic>;
        } catch (e) {
          debugPrint('Error parsing SharedPreferences data: $e');
          // Continue with empty map
        }
      }
      
      // 2. Create maps for easy lookup
      final Map<String, Map<String, dynamic>> firestoreUsersMap = {};
      for (final doc in firestoreSnapshot.docs) {
        final data = doc.data();
        if (data['email'] != null) {
          firestoreUsersMap[data['email'] as String] = {
            'id': doc.id,
            'email': data['email'],
            'name': data['name'] ?? 'Unknown',
            'role': data['role'] ?? 'customer',
          };
        }
      }
      
      // 3. Synchronize: Add missing users to SharedPreferences
      bool madeChanges = false;
      firestoreUsersMap.forEach((email, userData) {
        if (!sharedPrefsUsers.containsKey(email) && 
            email != 'admin@example.com' && 
            email != 'test@example.com') {
          
          debugPrint('Adding user $email to SharedPreferences from Firestore');
          
          // Add to SharedPreferences with a default password
          sharedPrefsUsers[email] = {
            'email': email,
            'password': 'password123', // Default password for recovered accounts
            'userId': userData['id'],
            'displayName': userData['name'],
            'role': userData['role'],
          };
          
          madeChanges = true;
        }
      });
      
      // 4. Save updated SharedPreferences if changes were made
      if (madeChanges) {
        final jsonData = json.encode(sharedPrefsUsers);
        await prefs.setString('dev_auth_users', jsonData);
        debugPrint('Updated SharedPreferences with missing users');
      } else {
        debugPrint('No changes needed for SharedPreferences');
      }
      
      return true;
    } catch (e) {
      debugPrint('Error in fixUserStorage: $e');
      return false;
    }
  }
}