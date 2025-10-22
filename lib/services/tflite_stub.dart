// Stub implementation for web platform where TFLite is not available

class Interpreter {
  static Future<Interpreter> fromAsset(String path) async {
    throw UnsupportedError('TFLite is not supported on web platform');
  }
  
  void run(dynamic input, dynamic output) {
    throw UnsupportedError('TFLite is not supported on web platform');
  }
  
  dynamic getInputTensor(int index) {
    throw UnsupportedError('TFLite is not supported on web platform');
  }
  
  dynamic getOutputTensor(int index) {
    throw UnsupportedError('TFLite is not supported on web platform');
  }
  
  void close() {
    // No-op for web
  }
}

class Tensor {
  List<int> get shape => [];
}