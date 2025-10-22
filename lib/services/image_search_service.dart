import 'dart:io';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../controllers/product_controller.dart';
import 'tflite_model_service.dart';
import '../utils/logger.dart';
import 'package:get/get.dart';

class ImageSearchService {
  final String baseUrl = 'https://your-ml-api-endpoint.com'; // Replace with your ML API endpoint
  final ProductController _productController = Get.find<ProductController>();
  final TFLiteModelService _tfliteService = TFLiteModelService();
  
  // Store the last predictions for display
  List<Map<String, dynamic>>? lastPredictions;
  
  Future<List<Product>> searchSimilarProducts(File imageFile) async {
    try {
      Logger.info('Starting image search for similar products');
      
      // Ensure model is loaded
      if (!_tfliteService.isModelLoaded) {
        Logger.info('Model not loaded, loading now...');
        await _tfliteService.loadModel();
      }
      
      // Classify the image using TFLite model
      final predictions = await _tfliteService.classifyImage(imageFile);
      lastPredictions = predictions;
      
      if (predictions.isEmpty) {
        Logger.warning('No predictions returned from model');
        return [];
      }
      
      // Get the top prediction
      final topPrediction = predictions.first;
      final predictedCategory = topPrediction['label'] as String;
      final confidence = topPrediction['confidence'] as double;
      
      Logger.info('Top prediction: $predictedCategory (${confidence.toStringAsFixed(2)}%)');
      
      // Get all products
      final allProducts = _productController.products;
      if (allProducts.isEmpty) {
        Logger.warning('No products available in database');
        return [];
      }
      
      // Filter products by predicted category (case-insensitive matching)
      List<Product> matchingProducts = allProducts.where((product) {
        // Check if product name or category matches the predicted label
        final productName = product.name?.toLowerCase() ?? '';
        final productCategory = product.category?.toLowerCase() ?? '';
        final predictedLabel = predictedCategory.toLowerCase();
        
        return productName.contains(predictedLabel) || 
               productCategory.contains(predictedLabel) ||
               predictedLabel.contains(productCategory);
      }).toList();
      
      Logger.info('Found ${matchingProducts.length} products matching category: $predictedCategory');
      
      // If we found matching products, return them
      if (matchingProducts.isNotEmpty) {
        // Shuffle to add variety and limit results
        matchingProducts.shuffle();
        return matchingProducts.take(10).toList();
      }
      
      // If no exact matches, try to match with secondary predictions
      for (var i = 1; i < predictions.length && i < 3; i++) {
        final secondaryPrediction = predictions[i];
        final secondaryCategory = secondaryPrediction['label'] as String;
        
        matchingProducts = allProducts.where((product) {
          final productName = product.name?.toLowerCase() ?? '';
          final productCategory = product.category?.toLowerCase() ?? '';
          final predictedLabel = secondaryCategory.toLowerCase();
          
          return productName.contains(predictedLabel) || 
                 productCategory.contains(predictedLabel) ||
                 predictedLabel.contains(productCategory);
        }).toList();
        
        if (matchingProducts.isNotEmpty) {
          Logger.info('Found ${matchingProducts.length} products matching secondary category: $secondaryCategory');
          matchingProducts.shuffle();
          return matchingProducts.take(10).toList();
        }
      }
      
      // If still no matches, return random products as fallback
      Logger.info('No matching products found, returning random selection');
      final shuffled = List.from(allProducts)..shuffle();
      return shuffled.take(8).cast<Product>().toList();
      
      /* 
      // Uncomment this when you have your ML API ready:
      
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/search-similar'),
      );
      
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );
      
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(responseData);
        final List<dynamic> results = jsonData['similar_products'];
        
        return results.map((item) => Product.fromJson(item)).toList();
      } else {
        throw Exception('Failed to search similar products');
      }
      */
      
    } catch (e) {
      throw Exception('Error searching similar products: ${e.toString()}');
    }
  }
  
  Future<Map<String, dynamic>> analyzeImage(File imageFile) async {
    try {
      // This will be used for extracting features from the image
      // For now, return mock analysis data
      
      await Future.delayed(const Duration(seconds: 1));
      
      return {
        'categories': ['dress', 'formal', 'evening'],
        'colors': ['black', 'red', 'blue'],
        'patterns': ['solid', 'floral'],
        'style': 'elegant',
        'confidence': 0.85,
      };
      
      /*
      // Uncomment this when you have your ML API ready:
      
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/analyze-image'),
      );
      
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );
      
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        return json.decode(responseData);
      } else {
        throw Exception('Failed to analyze image');
      }
      */
      
    } catch (e) {
      throw Exception('Error analyzing image: ${e.toString()}');
    }
  }
}
