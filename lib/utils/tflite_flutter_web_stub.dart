// Web-specific build configuration
// This file helps exclude TensorFlow Lite dependencies for web builds

// Stub classes that match the TensorFlow Lite API but do nothing
class Interpreter {
  static Future<Interpreter> fromAsset(String assetName) async {
    throw UnsupportedError('TensorFlow Lite is not supported on web');
  }
  
  void run(dynamic input, dynamic output) {
    throw UnsupportedError('TensorFlow Lite is not supported on web');
  }
  
  dynamic getInputTensor(int index) {
    throw UnsupportedError('TensorFlow Lite is not supported on web');
  }
  
  dynamic getOutputTensor(int index) {
    throw UnsupportedError('TensorFlow Lite is not supported on web');
  }
  
  void close() {
    // No-op for web
  }
}

// Additional stub classes as needed
class TensorType {
  static const float32 = 'float32';
}