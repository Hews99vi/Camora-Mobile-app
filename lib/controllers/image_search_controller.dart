import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/product.dart';
import '../services/image_search_service.dart';
import '../services/tflite_model_service.dart';

class ImageSearchController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  final ImageSearchService _imageSearchService = ImageSearchService();
  final TFLiteModelService _tfliteService = TFLiteModelService();
  
  var isLoading = false.obs;
  var selectedImage = Rx<File?>(null);
  var searchResults = <Product>[].obs;
  var searchHistory = <File>[].obs;
  var predictions = <Map<String, dynamic>>[].obs;
  var showPredictions = false.obs;
  
  // Mock data for demonstration - replace with actual ML model results
  var mockSearchResults = <Product>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadSearchHistory();
    _initializeModel();
  }

  @override
  void onClose() {
    _tfliteService.dispose();
    super.onClose();
  }

  Future<void> _initializeModel() async {
    try {
      await _tfliteService.loadModel();
    } catch (e) {
      Get.snackbar(
        'Model Error',
        'Failed to load ML model: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  Future<void> pickImageFromGallery() async {
    try {
      // Request permission based on Android version
      // For Android 13+ (API 33+), use photos permission
      // For older versions, use storage permission
      PermissionStatus status;
      
      if (await _isAndroid13OrAbove()) {
        status = await Permission.photos.request();
      } else {
        status = await Permission.storage.request();
      }
      
      if (status.isDenied || status.isPermanentlyDenied) {
        Get.snackbar(
          'Permission Denied',
          status.isPermanentlyDenied 
            ? 'Please enable gallery access in Settings'
            : 'Please allow gallery access to select images',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        
        // If permanently denied, open app settings
        if (status.isPermanentlyDenied) {
          await openAppSettings();
        }
        return;
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        selectedImage.value = File(image.path);
        await performImageSearch(selectedImage.value!);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<bool> _isAndroid13OrAbove() async {
    // Check if running on Android 13 (API 33) or above
    try {
      if (Platform.isAndroid) {
        // We'll use a simple check - try photos permission first
        await Permission.photos.status;
        return true; // If photos permission exists, we're on Android 13+
      }
    } catch (e) {
      return false; // If photos permission doesn't exist, we're on older Android
    }
    return false;
  }

  Future<void> pickImageFromCamera() async {
    try {
      // Request permission
      final status = await Permission.camera.request();
      if (status.isDenied) {
        Get.snackbar(
          'Permission Denied',
          'Please allow camera access to take photos',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        selectedImage.value = File(image.path);
        await performImageSearch(selectedImage.value!);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to take photo: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> performImageSearch(File imageFile) async {
    try {
      isLoading.value = true;
      showPredictions.value = false;
      predictions.clear();
      
      // Add to search history
      searchHistory.insert(0, imageFile);
      if (searchHistory.length > 10) {
        searchHistory.removeLast();
      }
      _saveSearchHistory();
      
      // Get predictions from the model
      if (_imageSearchService.lastPredictions != null) {
        predictions.value = _imageSearchService.lastPredictions!;
      }
      
      // Perform image search using ML service
      final results = await _imageSearchService.searchSimilarProducts(imageFile);
      
      // Update predictions from the service
      if (_imageSearchService.lastPredictions != null) {
        predictions.value = _imageSearchService.lastPredictions!;
        showPredictions.value = true;
      }
      
      searchResults.value = results;
      
      // Show prediction summary
      if (predictions.isNotEmpty) {
        final topPrediction = predictions.first;
        final label = topPrediction['label'] as String;
        final confidence = topPrediction['confidence'] as double;
        
        Get.snackbar(
          'Prediction',
          'Detected: $label (${confidence.toStringAsFixed(1)}% confidence)\nFound ${results.length} similar products',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          'Search Completed',
          'Found ${results.length} similar products',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
      
    } catch (e) {
      Get.snackbar(
        'Search Failed',
        'Failed to search for similar products: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void clearSearchResults() {
    searchResults.clear();
    selectedImage.value = null;
    predictions.clear();
    showPredictions.value = false;
  }

  void clearSearchHistory() {
    searchHistory.clear();
    _saveSearchHistory();
  }

  Future<void> _loadSearchHistory() async {
    // TODO: Implement persistent storage for search history
    // For now, using in-memory storage
  }

  Future<void> _saveSearchHistory() async {
    // TODO: Implement persistent storage for search history
    // For now, using in-memory storage
  }

  void showImageSourceDialog() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Select Image Source',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Get.back();
                      pickImageFromCamera();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.pink[200]!),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.pink[50],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.camera_alt_rounded,
                            size: 32,
                            color: Colors.pink[600],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Camera',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.pink[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Get.back();
                      pickImageFromGallery();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.pink[200]!),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.pink[50],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.photo_library_rounded,
                            size: 32,
                            color: Colors.pink[600],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Gallery',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.pink[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      isDismissible: true,
      enableDrag: true,
    );
  }
}
