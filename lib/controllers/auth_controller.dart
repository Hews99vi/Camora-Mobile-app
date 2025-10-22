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
  bool get isAdmin => _currentUser.value?.role == UserRole.admin;
  
  final _storage = const FlutterSecureStorage();
  
  @override
  void onInit() {
    super.onInit();
    _initializeAuthListener();
  }
  
  void _initializeAuthListener() {
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
            await _storage.write(key: 'user_data', value: userData.toJson().toString());
          }
        } catch (e) {
          debugPrint('Error loading user data: $e');
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
