import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/user.dart';
import '../services/firebase_auth_service.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find();
  
  final Rx<User?> _currentUser = Rx<User?>(null);
  final RxBool _isLoading = false.obs;
  
  User? get currentUser => _currentUser.value;
  Rx<User?> get currentUserRx => _currentUser; // Expose the reactive user
  bool get isLoading => _isLoading.value;
  bool get isLoggedIn => _currentUser.value != null;
  
  // Enhanced isAdmin check that also looks at email for the development admin accounts
  bool get isAdmin {
    final user = _currentUser.value;
    if (user == null) return false;
    
    // Normal role-based check
    if (user.role == UserRole.admin) {
      return true;
    }
    
    // Special cases for known admin emails
    final email = user.email?.toLowerCase() ?? '';
    if (email == 'admin@example.com' || email == 'admin2@gmail.com') {
      debugPrint('⚠️ AuthController: Known admin email detected ($email) but role is not admin!');
      debugPrint('⚠️ AuthController: Forcing admin status for this user');
      return true;
    }
    
    return false;
  }
  
  final _storage = const FlutterSecureStorage();
  
  @override
  void onInit() {
    super.onInit();
    _initializeAuthListener();
  }
  
  void _initializeAuthListener() {
    // First try to restore user from secure storage
    _tryRestoreUserFromStorage();
    
    // Listen to Firebase auth state changes
    FirebaseAuthService.authStateChanges.listen((firebase_auth.User? firebaseUser) async {
      debugPrint('=== AUTH STATE CHANGE ===');
      debugPrint('Firebase user: ${firebaseUser?.email ?? 'None'}');
      debugPrint('Firebase user UID: ${firebaseUser?.uid ?? 'None'}');
      
      if (firebaseUser != null) {
        // User is signed in, get user data from Firestore
        try {
          User? userData = await FirebaseAuthService.getUserData(firebaseUser.uid);
          if (userData != null) {
            debugPrint('Setting current user: ${userData.email} (ID: ${userData.id})');
            _currentUser.value = userData;
            
            // Save to secure storage as JSON string
            final userJson = userData.toJson();
            await _storage.write(key: 'user_data', value: userJson.toString());
            debugPrint('User data saved to secure storage');
          } else {
            debugPrint('User data not found in Firestore, checking secure storage...');
            await _tryRestoreUserFromStorage();
          }
        } catch (e) {
          debugPrint('Error loading user data: $e');
          
          // Try to restore from secure storage as fallback
          await _tryRestoreUserFromStorage();
        }
      } else {
        // User is signed out
        debugPrint('User signed out - clearing current user data');
        _currentUser.value = null;
        await _storage.delete(key: 'user_data');
      }
      debugPrint('Current user after change: ${_currentUser.value?.email ?? 'None'}');
      debugPrint('========================');
    });
  }
  
  Future<void> _tryRestoreUserFromStorage() async {
    try {
      final storedUserData = await _storage.read(key: 'user_data');
      if (storedUserData != null && storedUserData.isNotEmpty) {
        debugPrint('Found user data in secure storage, attempting to restore');
        
        try {
          // This approach needs proper JSON parsing - we should improve this
          // For now, we'll use a basic fallback approach
          
          // Try to extract ID and email at minimum
          final String id = RegExp(r"'id': '([^']*)'").firstMatch(storedUserData)?.group(1) ?? '';
          final String email = RegExp(r"'email': '([^']*)'").firstMatch(storedUserData)?.group(1) ?? '';
          final String name = RegExp(r"'name': '([^']*)'").firstMatch(storedUserData)?.group(1) ?? '';
          final String roleStr = RegExp(r"'role': '([^']*)'").firstMatch(storedUserData)?.group(1) ?? 'customer';
          
          if (id.isNotEmpty && email.isNotEmpty) {
            debugPrint('Successfully restored basic user from secure storage: $email');
            
            // Special case for admin emails - ensure they have admin role
            UserRole role;
            final lowerEmail = email.toLowerCase();
            if (lowerEmail == 'admin@example.com' || lowerEmail == 'admin2@gmail.com') {
              role = UserRole.admin;
              debugPrint('🔐 Restored admin user ($lowerEmail) - ensuring admin role is set');
            } else {
              role = roleStr == 'admin' ? UserRole.admin : UserRole.customer;
            }
            
            // Create a basic user object
            final userData = User(
              id: id,
              email: email,
              name: name,
              role: role,
            );
            
            _currentUser.value = userData;
            
            // Debug log the restored user
            debugPrint('🔐 User restored from storage: ${userData.email} (${userData.id})');
            debugPrint('🔐 User role: ${userData.role}');
            debugPrint('🔐 Is admin: ${userData.role == UserRole.admin}');
          } else {
            debugPrint('Could not extract user ID and email from stored data');
          }
        } catch (parseError) {
          debugPrint('Error parsing stored user data: $parseError');
          // Delete corrupted data
          await _storage.delete(key: 'user_data');
        }
      } else {
        debugPrint('No user data found in secure storage');
      }
    } catch (e) {
      debugPrint('Error restoring user from storage: $e');
    }
  }
  
  Future<bool> login(String email, String password) async {
    try {
      _isLoading.value = true;
      
      User? user = await FirebaseAuthService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (user != null) {
        _currentUser.value = user;
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Login error: $e');
      Get.snackbar('Login Error', e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
  
  Future<bool> register(String name, String email, String password, {UserRole role = UserRole.customer, String? phoneNumber}) async {
    try {
      _isLoading.value = true;
      
      User? user = await FirebaseAuthService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
        phoneNumber: phoneNumber,
      );
      
      if (user != null) {
        _currentUser.value = user;
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Registration error: $e');
      Get.snackbar('Registration Error', e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
  
  Future<void> logout() async {
    try {
      await FirebaseAuthService.signOut();
      _currentUser.value = null;
    } catch (e) {
      debugPrint('Logout error: $e');
      Get.snackbar('Logout Error', e.toString().replaceAll('Exception: ', ''));
    }
  }
  
  Future<bool> resetPassword(String email) async {
    try {
      await FirebaseAuthService.resetPassword(email);
      Get.snackbar('Success', 'Password reset email sent to $email');
      return true;
    } catch (e) {
      debugPrint('Reset password error: $e');
      Get.snackbar('Reset Password Error', e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }
  
  Future<bool> updateProfile(User updatedUser) async {
    try {
      _isLoading.value = true;
      
      await FirebaseAuthService.updateUserData(updatedUser);
      _currentUser.value = updatedUser;
      
      Get.snackbar('Success', 'Profile updated successfully');
      return true;
    } catch (e) {
      debugPrint('Update profile error: $e');
      Get.snackbar('Update Error', e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
}
