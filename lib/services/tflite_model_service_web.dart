import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import '../utils/logger.dart';

/// Web-specific implementation of TFLite Model Service
/// This implementation provides mock functionality for web platform
class TFLiteModelService {
  static final TFLiteModelService _instance = TFLiteModelService._internal();
  factory TFLiteModelService() => _instance;
  TFLiteModelService._internal();

  bool _modelLoaded = false;
  List<String> _labels = [];

  bool get isModelLoaded => _modelLoaded;
  List<String> get labels => _labels;

  /// Initialize and load the TFLite model (web mock implementation)
  Future<void> loadModel() async {
    try {
      Logger.warning('TFLite is not supported on web platform - using mock implementation');
      
      // Load labels for web fallback
      await _loadLabels();
      _modelLoaded = true; // Set to true for web mock
      
      Logger.info('Web mock model loaded successfully with ${_labels.length} labels');
      
    } catch (e) {
      Logger.error('Error during web model initialization: $e');
      _modelLoaded = false;
    }
  }

  /// Load labels from the labels.txt file
  Future<void> _loadLabels() async {
    try {
      final labelsData = await rootBundle.loadString('assets/models/labels.txt');
      _labels = labelsData
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .map((line) {
            // Remove the number prefix (e.g., "0 Dress" -> "Dress")
            final parts = line.trim().split(' ');
            return parts.length > 1 ? parts.sublist(1).join(' ') : line.trim();
          })
          .toList();
      
      Logger.info('Loaded ${_labels.length} labels for web: $_labels');
    } catch (e) {
      Logger.error('Error loading labels: $e');
      // Fallback labels for web
      _labels = [
        'Dress', 'Top', 'Trouser', 'Pullover', 'Coat', 
        'Sandal', 'Shirt', 'Sneaker', 'Bag', 'Ankle Boot'
      ];
    }
  }

  /// Run image classification on the provided image file (web mock implementation)
  Future<List<Map<String, dynamic>>> classifyImage(File imageFile) async {
    try {
      Logger.warning('TFLite not available on web - returning mock predictions');
      
      // Check if model is loaded
      if (!_modelLoaded) {
        Logger.warning('Model not loaded - attempting to load now');
        await loadModel();
      }

      Logger.info('Mock classifying image: ${imageFile.path}');

      // Return enhanced mock predictions with variety
      return _getEnhancedMockPredictions();
      
    } catch (e) {
      Logger.error('Error in web mock classification: $e');
      return _getMockPredictions();
    }
  }

  /// Get enhanced mock predictions with more variety for web
  List<Map<String, dynamic>> _getEnhancedMockPredictions() {
    // Simulate different predictions based on current time for variety
    final now = DateTime.now();
    final seed = now.millisecond % 5;
    
    switch (seed) {
      case 0:
        return [
          {'label': 'Dress', 'confidence': 75.0, 'index': 0},
          {'label': 'Top', 'confidence': 18.0, 'index': 1},
          {'label': 'Coat', 'confidence': 7.0, 'index': 4},
        ];
      case 1:
        return [
          {'label': 'Top', 'confidence': 68.0, 'index': 1},
          {'label': 'Shirt', 'confidence': 22.0, 'index': 6},
          {'label': 'Dress', 'confidence': 10.0, 'index': 0},
        ];
      case 2:
        return [
          {'label': 'Trouser', 'confidence': 72.0, 'index': 2},
          {'label': 'Pullover', 'confidence': 16.0, 'index': 3},
          {'label': 'Coat', 'confidence': 12.0, 'index': 4},
        ];
      case 3:
        return [
          {'label': 'Bag', 'confidence': 80.0, 'index': 8},
          {'label': 'Sneaker', 'confidence': 12.0, 'index': 7},
          {'label': 'Sandal', 'confidence': 8.0, 'index': 5},
        ];
      default:
        return [
          {'label': 'Shirt', 'confidence': 65.0, 'index': 6},
          {'label': 'Top', 'confidence': 25.0, 'index': 1},
          {'label': 'Pullover', 'confidence': 10.0, 'index': 3},
        ];
    }
  }

  /// Get basic mock predictions for web or when model is not available
  List<Map<String, dynamic>> _getMockPredictions() {
    Logger.warning('Using basic mock predictions - real model not available');
    return [
      {'label': 'Dress', 'confidence': 35.0, 'index': 0},
      {'label': 'Top', 'confidence': 30.0, 'index': 1},
      {'label': 'Shirt', 'confidence': 25.0, 'index': 6},
    ];
  }

  /// Get the top prediction from classification results
  Map<String, dynamic>? getTopPrediction(List<Map<String, dynamic>> predictions) {
    if (predictions.isEmpty) return null;
    return predictions.first;
  }

  /// Get predictions above a certain confidence threshold
  List<Map<String, dynamic>> getHighConfidencePredictions(
    List<Map<String, dynamic>> predictions, 
    double threshold
  ) {
    return predictions.where((p) => p['confidence'] >= threshold).toList();
  }

  /// Dispose and close the model (web no-op)
  Future<void> dispose() async {
    try {
      _modelLoaded = false;
      _labels.clear();
      Logger.info('Web mock model disposed successfully');
    } catch (e) {
      Logger.error('Error disposing web mock model: $e');
    }
  }

  /// Get a human-readable summary of predictions
  String getPredictionSummary(List<Map<String, dynamic>> predictions) {
    if (predictions.isEmpty) {
      return 'No predictions available';
    }

    final top = predictions.first;
    final label = top['label'] as String;
    final confidence = top['confidence'] as double;

    // Add web indicator to summary
    final webNote = kIsWeb ? ' (Web Demo)' : '';

    if (confidence >= 70) {
      return 'This looks like a $label (${confidence.toStringAsFixed(1)}% confident)$webNote';
    } else if (confidence >= 40) {
      return 'This might be a $label (${confidence.toStringAsFixed(1)}% confident)$webNote';
    } else {
      return 'Possibly a $label, but not very confident (${confidence.toStringAsFixed(1)}%)$webNote';
    }
  }
}